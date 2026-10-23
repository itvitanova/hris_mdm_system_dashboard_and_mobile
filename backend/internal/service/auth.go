package service

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"golang.org/x/crypto/bcrypt"
	"hrismdm/backend/internal/domain"
	"strings"
	"time"
)

func tokenID(token string) string { h := sha256.Sum256([]byte(token)); return hex.EncodeToString(h[:]) }
func (a *App) Login(ctx context.Context, email, password string) (string, domain.Actor, error) {
	var users []domain.User
	if err := a.Store.List(ctx, "users", &users); err != nil {
		return "", domain.Actor{}, err
	}
	for _, u := range users {
		if strings.EqualFold(u.Email, email) && bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(password)) == nil {
			var emp domain.Employee
			if err := a.Store.Get(ctx, "employees", u.EmployeeID, &emp); err != nil || emp.Status == "Nonaktif" {
				break
			}
			token := ID() + ID()
			session := domain.Session{ID: tokenID(token), UserID: u.ID, ExpiresAt: time.Now().Add(12 * time.Hour).Unix()}
			if err := a.Store.Put(ctx, "sessions", session.ID, session); err != nil {
				return "", domain.Actor{}, err
			}
			return token, domain.Actor{ID: u.ID, EmployeeID: u.EmployeeID, Email: u.Email, Role: u.Role, Name: emp.Name}, nil
		}
	}
	return "", domain.Actor{}, errors.New("email atau kata sandi salah")
}
func (a *App) Authenticate(ctx context.Context, token string) (domain.Actor, error) {
	var sess domain.Session
	var u domain.User
	var emp domain.Employee
	if token == "" || a.Store.Get(ctx, "sessions", tokenID(token), &sess) != nil || sess.ExpiresAt < time.Now().Unix() {
		return domain.Actor{}, ErrForbidden
	}
	if a.Store.Get(ctx, "users", sess.UserID, &u) != nil || a.Store.Get(ctx, "employees", u.EmployeeID, &emp) != nil || emp.Status == "Nonaktif" {
		return domain.Actor{}, ErrForbidden
	}
	return domain.Actor{ID: u.ID, EmployeeID: u.EmployeeID, Email: u.Email, Role: u.Role, Name: emp.Name}, nil
}
func (a *App) Logout(ctx context.Context, token string) error {
	return a.Store.Delete(ctx, "sessions", tokenID(token))
}

func (a *App) ChangePassword(ctx context.Context, actor domain.Actor, current, next string) error {
	if len(next) < 12 || len(next) > 72 {
		return errors.New("kata sandi baru harus 12–72 byte")
	}
	if current == next {
		return errors.New("kata sandi baru harus berbeda")
	}
	return a.write(ctx, func(s domain.Store) error {
		var user domain.User
		if err := s.Get(ctx, "users", actor.ID, &user); err != nil {
			return err
		}
		if bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(current)) != nil {
			return errors.New("kata sandi saat ini salah")
		}
		hash, err := bcrypt.GenerateFromPassword([]byte(next), bcrypt.DefaultCost)
		if err != nil {
			return err
		}
		user.PasswordHash = string(hash)
		if err := s.Put(ctx, "users", user.ID, user); err != nil {
			return err
		}
		var sessions []domain.Session
		if err := s.List(ctx, "sessions", &sessions); err != nil {
			return err
		}
		for _, session := range sessions {
			if session.UserID == user.ID {
				if err := s.Delete(ctx, "sessions", session.ID); err != nil {
					return err
				}
			}
		}
		return audit(ctx, s, actor, "account.password.change", user.ID)
	})
}
func (a *App) Provision(ctx context.Context, actor domain.Actor, employeeID, password, role string) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	if len(password) < 12 {
		return errors.New("kata sandi minimal 12 karakter")
	}
	if len(password) > 72 {
		return errors.New("kata sandi maksimal 72 byte")
	}
	if role == "" {
		role = "employee"
	}
	if role != "employee" && role != "admin" {
		return errors.New("peran tidak valid")
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	return a.write(ctx, func(s domain.Store) error {
		var emp domain.Employee
		if err := s.Get(ctx, "employees", employeeID, &emp); err != nil {
			return errors.New("karyawan tidak ditemukan")
		}
		var users []domain.User
		if err := s.List(ctx, "users", &users); err != nil {
			return err
		}
		for _, u := range users {
			if u.EmployeeID == employeeID {
				return errors.New("akun karyawan sudah ada")
			}
		}
		id := ID()
		if err := s.Put(ctx, "users", id, domain.User{ID: id, EmployeeID: employeeID, Email: emp.Email, Role: role, PasswordHash: string(hash)}); err != nil {
			return err
		}
		return audit(ctx, s, actor, "account.create", employeeID)
	})
}
