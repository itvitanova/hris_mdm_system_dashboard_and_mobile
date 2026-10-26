package service

import (
	"context"
	"errors"
	"hrismdm/backend/internal/domain"
	"math"
	"sort"
	"strings"
	"time"
)

func validCoordinates(lat, lng float64) bool {
	return !math.IsNaN(lat) && !math.IsNaN(lng) && !math.IsInf(lat, 0) && !math.IsInf(lng, 0) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180
}
func ensureServicePoints(ctx context.Context, s domain.Store) error {
	var points []domain.ServicePoint
	if err := s.List(ctx, "service_points", &points); err != nil {
		return err
	}
	if len(points) == 0 {
		var settings domain.Settings
		if err := s.Get(ctx, "settings", "company", &settings); err != nil {
			return err
		}
		hq := domain.ServicePoint{ID: "HQ", Code: "HQ", Name: settings.LocationName, Kind: "HQ", Address: settings.CompanyAddress, Latitude: settings.Latitude, Longitude: settings.Longitude, Radius: settings.Radius, Timezone: settings.Timezone, WorkStart: settings.WorkStart, WorkEnd: settings.WorkEnd, Active: true}
		if err := s.Put(ctx, "service_points", hq.ID, hq); err != nil {
			return err
		}
	}
	var employees []domain.Employee
	if err := s.List(ctx, "employees", &employees); err != nil {
		return err
	}
	for _, e := range employees {
		if e.ServicePointID == "" {
			e.ServicePointID = "HQ"
			if err := s.Put(ctx, "employees", e.ID, e); err != nil {
				return err
			}
		}
	}
	return nil
}
func (a *App) ServicePoints(ctx context.Context, actor domain.Actor) ([]domain.ServicePoint, error) {
	var rows []domain.ServicePoint
	if err := a.Store.List(ctx, "service_points", &rows); err != nil {
		return nil, err
	}
	if actor.Role != "admin" {
		var emp domain.Employee
		if err := a.Store.Get(ctx, "employees", actor.EmployeeID, &emp); err != nil {
			return nil, err
		}
		filtered := []domain.ServicePoint{}
		for _, p := range rows {
			if p.ID == emp.ServicePointID {
				filtered = append(filtered, p)
			}
		}
		rows = filtered
	}
	sort.Slice(rows, func(i, j int) bool { return rows[i].Name < rows[j].Name })
	return rows, nil
}
func policyFor(ctx context.Context, s domain.Store, employeeID string) (domain.AttendancePolicy, error) {
	var emp domain.Employee
	var p domain.ServicePoint
	if s.Get(ctx, "employees", employeeID, &emp) != nil || emp.ServicePointID == "" || s.Get(ctx, "service_points", emp.ServicePointID, &p) != nil {
		return domain.AttendancePolicy{}, errors.New("lokasi penugasan belum ditentukan; hubungi admin")
	}
	return domain.AttendancePolicy{ServicePoint: p, AllowAnyLocation: emp.AllowAnyLocation}, nil
}
func (a *App) AttendancePolicy(ctx context.Context, actor domain.Actor) (domain.AttendancePolicy, error) {
	return policyFor(ctx, a.Store, actor.EmployeeID)
}
func (a *App) SaveServicePoint(ctx context.Context, actor domain.Actor, p domain.ServicePoint) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	p.Name = cleanName(p.Name)
	p.Code = strings.ToUpper(strings.TrimSpace(p.Code))
	p.Address = strings.TrimSpace(p.Address)
	if p.Name == "" || len(p.Name) > 120 || p.Code == "" || len(p.Code) > 30 || len(p.Address) > 1000 || !validCoordinates(p.Latitude, p.Longitude) || math.IsNaN(p.Radius) || p.Radius < 10 || p.Radius > 10000 || math.IsInf(p.Radius, 0) {
		return errors.New("nama, kode, koordinat, dan radius 10–10000 meter wajib valid")
	}
	if p.Kind != "HQ" && p.Kind != "Service Point" {
		return errors.New("jenis lokasi tidak valid")
	}
	if p.Timezone != "Asia/Jakarta" && p.Timezone != "Asia/Makassar" && p.Timezone != "Asia/Jayapura" {
		return errors.New("pilih zona waktu WIB, WITA, atau WIT")
	}
	if _, err := time.Parse("15:04", p.WorkStart); err != nil {
		return errors.New("jam masuk tidak valid")
	}
	if p.WorkEnd != "" {
		if _, err := time.Parse("15:04", p.WorkEnd); err != nil || p.WorkEnd <= p.WorkStart {
			return errors.New("jam pulang harus setelah jam masuk pada hari yang sama")
		}
	}
	return a.write(ctx, func(s domain.Store) error {
		var all []domain.ServicePoint
		if err := s.List(ctx, "service_points", &all); err != nil {
			return err
		}
		for _, v := range all {
			if v.ID != p.ID && (strings.EqualFold(v.Code, p.Code) || strings.EqualFold(v.Name, p.Name)) {
				return errors.New("kode atau nama lokasi sudah digunakan")
			}
		}
		if p.ID == "" {
			p.ID = ID()
		} else {
			var old domain.ServicePoint
			if s.Get(ctx, "service_points", p.ID, &old) != nil {
				return errors.New("lokasi tidak ditemukan")
			}
		}
		if err := s.Put(ctx, "service_points", p.ID, p); err != nil {
			return err
		}
		// Keep the legacy HQ settings in sync while attendance uses the assigned site.
		if p.ID == "HQ" {
			var settings domain.Settings
			if err := s.Get(ctx, "settings", "company", &settings); err != nil {
				return err
			}
			settings.LocationName = p.Name
			settings.Latitude = p.Latitude
			settings.Longitude = p.Longitude
			settings.Radius = p.Radius
			settings.Timezone = p.Timezone
			settings.WorkStart = p.WorkStart
			settings.WorkEnd = p.WorkEnd
			if err := s.Put(ctx, "settings", "company", settings); err != nil {
				return err
			}
		}
		return audit(ctx, s, actor, "service-point.save", p.ID)
	})
}
func (a *App) DeleteServicePoint(ctx context.Context, actor domain.Actor, id string) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	if id == "HQ" {
		return errors.New("lokasi HQ bawaan tidak dapat dihapus")
	}
	return a.write(ctx, func(s domain.Store) error {
		var p domain.ServicePoint
		if s.Get(ctx, "service_points", id, &p) != nil {
			return errors.New("lokasi tidak ditemukan")
		}
		var employees []domain.Employee
		if err := s.List(ctx, "employees", &employees); err != nil {
			return err
		}
		for _, e := range employees {
			if e.ServicePointID == id {
				return errors.New("lokasi masih digunakan karyawan; pindahkan penugasan terlebih dahulu")
			}
		}
		if err := s.Delete(ctx, "service_points", id); err != nil {
			return err
		}
		return audit(ctx, s, actor, "service-point.delete", id)
	})
}
