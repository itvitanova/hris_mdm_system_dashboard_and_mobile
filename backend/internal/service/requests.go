package service

import (
	"context"
	"errors"
	"hrismdm/backend/internal/domain"
	"sort"
	"time"
)

func (a *App) Requests(ctx context.Context, actor domain.Actor) ([]domain.Request, error) {
	var all []domain.Request
	if err := a.Store.List(ctx, "requests", &all); err != nil {
		return nil, err
	}
	out := []domain.Request{}
	for _, r := range all {
		if actor.Role == "admin" || r.EmployeeID == actor.EmployeeID {
			out = append(out, r)
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].CreatedAt > out[j].CreatedAt })
	return out, nil
}
func (a *App) SubmitRequest(ctx context.Context, actor domain.Actor, r domain.Request) error {
	valid := map[string]bool{"Cuti": true, "Reimbursement": true, "Petty Cash": true, "General Affair": true, "Lembur": true}
	if !valid[r.Kind] || r.Title == "" || r.Description == "" {
		return errors.New("jenis, judul dan keperluan wajib diisi")
	}
	start, err := time.Parse("2006-01-02", r.StartDate)
	if err != nil {
		return errors.New("tanggal mulai wajib diisi")
	}
	end, err := time.Parse("2006-01-02", r.EndDate)
	if err != nil || end.Before(start) {
		return errors.New("tanggal selesai tidak valid")
	}
	if err = money(r.Amount); err != nil {
		return err
	}
	if r.Kind == "Lembur" && (r.Hours <= 0 || r.Hours > 24 || r.StartDate != r.EndDate) {
		return errors.New("lembur 0–24 jam, satu tanggal per pengajuan")
	}
	if (r.Kind == "Reimbursement" || r.Kind == "Petty Cash") && r.Amount <= 0 {
		return errors.New("nominal harus lebih dari nol")
	}
	return a.write(ctx, func(s domain.Store) error {
		var emp domain.Employee
		if err := s.Get(ctx, "employees", actor.EmployeeID, &emp); err != nil {
			return err
		}
		r.ID = ID()
		r.EmployeeID = actor.EmployeeID
		r.EmployeeName = emp.Name
		r.Status = "Menunggu"
		r.CreatedAt = now()
		r.ReviewedBy = ""
		r.ReviewNote = ""
		r.Days = 0
		if r.Kind == "Cuti" {
			r.Amount = 0
			r.Hours = 0
			r.Days = int(end.Sub(start).Hours()/24) + 1
			if r.Days > emp.LeaveBalance {
				return errors.New("saldo cuti tidak cukup")
			}
		}
		if err := s.Put(ctx, "requests", r.ID, r); err != nil {
			return err
		}
		return audit(ctx, s, actor, "request.submit", r.ID)
	})
}
func (a *App) ReviewRequest(ctx context.Context, actor domain.Actor, id, status, note string) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	if status != "Disetujui" && status != "Ditolak" {
		return errors.New("keputusan tidak valid")
	}
	return a.write(ctx, func(s domain.Store) error {
		var r domain.Request
		if err := s.Get(ctx, "requests", id, &r); err != nil {
			return errors.New("pengajuan tidak ditemukan")
		}
		if r.Status != "Menunggu" {
			return errors.New("pengajuan sudah diproses")
		}
		if r.EmployeeID == actor.EmployeeID {
			return errors.New("pengajuan sendiri harus ditinjau admin lain")
		}
		if status == "Disetujui" && r.Kind == "Cuti" {
			var emp domain.Employee
			if err := s.Get(ctx, "employees", r.EmployeeID, &emp); err != nil {
				return err
			}
			if emp.LeaveBalance < r.Days {
				return errors.New("saldo cuti tidak cukup")
			}
			var requests []domain.Request
			if err := s.List(ctx, "requests", &requests); err != nil {
				return err
			}
			for _, other := range requests {
				if other.EmployeeID == r.EmployeeID && other.Kind == "Cuti" && other.Status == "Disetujui" && r.StartDate <= other.EndDate && r.EndDate >= other.StartDate {
					return errors.New("tanggal cuti bertumpang tindih")
				}
			}
			emp.LeaveBalance -= r.Days
			if err := s.Put(ctx, "employees", emp.ID, emp); err != nil {
				return err
			}
		}
		r.Status = status
		r.ReviewedBy = actor.Name
		r.ReviewNote = note
		if err := s.Put(ctx, "requests", id, r); err != nil {
			return err
		}
		return audit(ctx, s, actor, "request."+status, id)
	})
}
