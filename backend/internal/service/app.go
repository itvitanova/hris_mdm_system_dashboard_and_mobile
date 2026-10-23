package service

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"hrismdm/backend/internal/domain"
	"net/mail"
	"strings"
	"sync"
	"time"
)

var ErrForbidden = errors.New("akses tidak diizinkan")

type App struct {
	Store domain.Store
	Face  FaceProvider
	mu    sync.Mutex
}

func New(s domain.Store, f FaceProvider) *App { return &App{Store: s, Face: f} }
func ID() string {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		panic(err)
	}
	return hex.EncodeToString(b)
}
func now() string { return time.Now().UTC().Format(time.RFC3339) }
func audit(ctx context.Context, s domain.Store, a domain.Actor, action, target string) error {
	id := ID()
	return s.Put(ctx, "audit", id, domain.Audit{ID: id, ActorID: a.ID, Action: action, Target: target, CreatedAt: now()})
}
func (a *App) write(ctx context.Context, fn func(domain.Store) error) error {
	a.mu.Lock()
	defer a.mu.Unlock()
	return a.Store.Within(ctx, fn)
}
func (a *App) Settings(ctx context.Context) (domain.Settings, error) {
	var v domain.Settings
	err := a.Store.Get(ctx, "settings", "company", &v)
	return v, err
}
func (a *App) SaveSettings(ctx context.Context, actor domain.Actor, v domain.Settings) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	if len(v.Company) > 120 || len(v.CompanyAddress) > 500 {
		return errors.New("nama perusahaan maksimal 120 karakter dan alamat maksimal 500 karakter")
	}
	if err := validateCompanyLogo(v.CompanyLogo); err != nil {
		return err
	}
	if !validCoordinates(v.Latitude, v.Longitude) || v.Company == "" || v.LocationName == "" {
		return errors.New("lokasi atau nama perusahaan tidak valid")
	}
	if _, err := time.LoadLocation(v.Timezone); err != nil {
		return errors.New("zona waktu tidak valid")
	}
	if _, err := time.Parse("15:04", v.WorkStart); err != nil {
		return errors.New("jam masuk tidak valid")
	}
	v.ID = "company"
	if v.Radius == 0 {
		v.Radius = 100
	}
	if !(v.Radius >= 10 && v.Radius <= 10000) {
		return errors.New("radius harus 10–10000 meter")
	}
	return a.write(ctx, func(s domain.Store) error {
		if err := s.Put(ctx, "settings", v.ID, v); err != nil {
			return err
		}
		var hq domain.ServicePoint
		if err := s.Get(ctx, "service_points", "HQ", &hq); err == nil {
			hq.Name = v.LocationName
			hq.Latitude = v.Latitude
			hq.Longitude = v.Longitude
			hq.Radius = v.Radius
			hq.Timezone = v.Timezone
			hq.WorkStart = v.WorkStart
			if err := s.Put(ctx, "service_points", hq.ID, hq); err != nil {
				return err
			}
		}
		return audit(ctx, s, actor, "settings.update", v.ID)
	})
}
func (a *App) Employees(ctx context.Context, actor domain.Actor) ([]domain.Employee, error) {
	var rows []domain.Employee
	if err := a.Store.List(ctx, "employees", &rows); err != nil {
		return nil, err
	}
	if actor.Role != "admin" {
		for _, v := range rows {
			if v.ID == actor.EmployeeID {
				return []domain.Employee{v}, nil
			}
		}
		return []domain.Employee{}, nil
	}
	return rows, nil
}
func (a *App) SaveEmployee(ctx context.Context, actor domain.Actor, v domain.Employee) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	v.Name = strings.TrimSpace(v.Name)
	v.Email = strings.ToLower(strings.TrimSpace(v.Email))
	v.PTKP = strings.ToUpper(strings.TrimSpace(v.PTKP))
	if v.PTKP != "" && PTKPCategory(v.PTKP) == "" {
		return errors.New("status PTKP tidak valid")
	}
	if _, err := mail.ParseAddress(v.Email); err != nil {
		return errors.New("alamat email tidak valid")
	}
	if v.Name == "" || v.Email == "" || v.Salary < 0 || v.Salary > 1000000000000 || v.LeaveBalance < 0 || v.LeaveBalance > 365 {
		return errors.New("nama, email, departemen dan angka valid wajib diisi")
	}
	for _, date := range []string{v.BirthDate, v.JoinDate} {
		if date != "" {
			if _, err := time.Parse("2006-01-02", date); err != nil {
				return errors.New("tanggal tidak valid")
			}
		}
	}
	if v.Status != "Aktif" && v.Status != "Probation" && v.Status != "Nonaktif" {
		return errors.New("status karyawan tidak valid")
	}
	return a.write(ctx, func(s domain.Store) error {
		var previous domain.Employee
		if v.ID != "" {
			if err := s.Get(ctx, "employees", v.ID, &previous); err != nil {
				return errors.New("karyawan tidak ditemukan")
			}
		}
		department, err := resolveMaster(ctx, s, "departments", v.DepartmentID, previous.DepartmentID)
		if err != nil {
			return err
		}
		position, err := resolveMaster(ctx, s, "positions", v.PositionID, previous.PositionID)
		if err != nil {
			return err
		}
		if v.ServicePointID == "" {
			v.ServicePointID = previous.ServicePointID
			if v.ServicePointID == "" {
				v.ServicePointID = "HQ"
			}
		}
		var site domain.ServicePoint
		if s.Get(ctx, "service_points", v.ServicePointID, &site) != nil {
			return errors.New("pilih Service Point / HQ yang valid")
		}
		if !site.Active && previous.ServicePointID != site.ID {
			return errors.New("lokasi penugasan tidak aktif")
		}
		v.Department = department.Name
		v.Position = position.Name
		var all []domain.Employee
		if err := s.List(ctx, "employees", &all); err != nil {
			return err
		}
		for _, e := range all {
			if strings.EqualFold(e.Email, v.Email) && e.ID != v.ID {
				return errors.New("email sudah digunakan")
			}
		}
		if v.ID == "" {
			v.ID = ID()
			v.FaceEnrolled = false
		} else {
			var old domain.Employee
			if err := s.Get(ctx, "employees", v.ID, &old); err != nil {
				return errors.New("karyawan tidak ditemukan")
			}
			v.FaceEnrolled = old.FaceEnrolled
		}
		if err := s.Put(ctx, "employees", v.ID, v); err != nil {
			return err
		}
		var users []domain.User
		if err := s.List(ctx, "users", &users); err != nil {
			return err
		}
		for _, u := range users {
			if u.EmployeeID == v.ID {
				u.Email = v.Email
				if err := s.Put(ctx, "users", u.ID, u); err != nil {
					return err
				}
			}
		}
		return audit(ctx, s, actor, "employee.save", v.ID)
	})
}
func money(v int64) error {
	if v < 0 || v > 1000000000000 {
		return fmt.Errorf("nominal di luar batas")
	}
	return nil
}
