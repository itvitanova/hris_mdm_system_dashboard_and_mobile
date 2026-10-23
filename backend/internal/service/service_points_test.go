package service

import (
	"errors"
	"hrismdm/backend/internal/domain"
	"math"
	"testing"
	"time"
)

func TestAssignedServicePointAndAnyLocationSnapshots(t *testing.T) {
	a, admin, employee := setup(t)
	var seeded []domain.Attendance
	must(t, a.Store.List(ctx, "attendance", &seeded))
	for _, row := range seeded {
		must(t, a.Store.Delete(ctx, "attendance", row.ID))
	}
	sites, err := a.ServicePoints(ctx, admin)
	must(t, err)
	if len(sites) != 1 || sites[0].ID != "HQ" {
		t.Fatal("legacy HQ not migrated")
	}
	site := domain.ServicePoint{Code: "JPR", Name: "Jayapura", Kind: "Service Point", Latitude: -2.533, Longitude: 140.718, Radius: 150, Timezone: "Asia/Jayapura", WorkStart: "08:00", Active: true}
	must(t, a.SaveServicePoint(ctx, admin, site))
	sites, err = a.ServicePoints(ctx, admin)
	must(t, err)
	for _, p := range sites {
		if p.Code == site.Code {
			site = p
		}
	}
	own, err := a.Employees(ctx, employee)
	must(t, err)
	emp := own[0]
	emp.ServicePointID = site.ID
	must(t, a.SaveEmployee(ctx, admin, emp))
	must(t, a.EnsureMasterData(ctx))
	must(t, a.Enroll(ctx, employee, emp.ID, photo(t)))
	visible, err := a.ServicePoints(ctx, employee)
	must(t, err)
	if len(visible) != 1 || visible[0].ID != site.ID {
		t.Fatal("site privacy / assignment")
	}
	policy, err := a.AttendancePolicy(ctx, employee)
	must(t, err)
	if policy.AllowAnyLocation || policy.Timezone != "Asia/Jayapura" {
		t.Fatal("wrong default policy")
	}
	far := Punch{Type: "in", Latitude: -6.137643, Longitude: 106.799746, Accuracy: 5, Photo: photo(t)}
	if a.Punch(ctx, employee, far) == nil {
		t.Fatal("accepted HQ instead of assigned site")
	}
	near := far
	near.Latitude = site.Latitude
	near.Longitude = site.Longitude
	must(t, a.Punch(ctx, employee, near))
	emp.AllowAnyLocation = true
	if !errors.Is(a.SaveEmployee(ctx, employee, emp), ErrForbidden) {
		t.Fatal("employee granted own exemption")
	}
	must(t, a.SaveEmployee(ctx, admin, emp))
	far.Type = "out"
	must(t, a.Punch(ctx, employee, far))
	rows, err := a.Attendance(ctx, employee)
	must(t, err)
	var saved domain.Attendance
	for _, r := range rows {
		if r.CheckInLocation != nil && r.CheckInLocation.Policy.ID == site.ID {
			saved = r
		}
	}
	zone, _ := time.LoadLocation(site.Timezone)
	if saved.Date != time.Now().In(zone).Format("2006-01-02") {
		t.Fatal("date ignores site timezone")
	}
	if saved.CheckOutLocation == nil || saved.CheckOutLocation.Latitude != far.Latitude || saved.CheckInLocation.Latitude != near.Latitude || saved.CheckInLocation.Policy.AllowAnyLocation || !saved.CheckOutLocation.Policy.AllowAnyLocation {
		t.Fatal("missing immutable in/out location and permission snapshots")
	}
	if a.DeleteServicePoint(ctx, admin, site.ID) == nil {
		t.Fatal("deleted assigned site")
	}
	site.Name = "Jayapura baru"
	must(t, a.SaveServicePoint(ctx, admin, site))
	var persisted domain.Attendance
	must(t, a.Store.Get(ctx, "attendance", saved.ID, &persisted))
	if persisted.CheckInLocation.Policy.Name == site.Name {
		t.Fatal("historical site changed")
	}
}
func TestAnyLocationStillRequiresGPSFaceAndActiveSite(t *testing.T) {
	a, admin, employee := setup(t)
	own, err := a.Employees(ctx, employee)
	must(t, err)
	emp := own[0]
	emp.AllowAnyLocation = true
	must(t, a.SaveEmployee(ctx, admin, emp))
	must(t, a.Enroll(ctx, employee, emp.ID, photo(t)))
	p := Punch{Type: "in", Latitude: -2, Longitude: 130, Accuracy: 51, Photo: photo(t)}
	if a.Punch(ctx, employee, p) == nil {
		t.Fatal("poor GPS accepted")
	}
	p.Accuracy = math.NaN()
	if a.Punch(ctx, employee, p) == nil {
		t.Fatal("nonfinite GPS accepted")
	}
	p.Accuracy = 5
	a.Face.(*fakeFace).allowed = false
	if a.Punch(ctx, employee, p) == nil {
		t.Fatal("face bypassed")
	}
	a.Face.(*fakeFace).allowed = true
	sites, err := a.ServicePoints(ctx, admin)
	must(t, err)
	hq := sites[0]
	hq.Active = false
	must(t, a.SaveServicePoint(ctx, admin, hq))
	if a.Punch(ctx, employee, p) == nil {
		t.Fatal("inactive site accepted")
	}
	hq.Active = true
	must(t, a.SaveServicePoint(ctx, admin, hq))
	var seeded []domain.Attendance
	must(t, a.Store.List(ctx, "attendance", &seeded))
	for _, row := range seeded {
		must(t, a.Store.Delete(ctx, "attendance", row.ID))
	}
	must(t, a.Punch(ctx, employee, p))
}
func TestServicePointValidationAndPermissions(t *testing.T) {
	a, admin, employee := setup(t)
	p := domain.ServicePoint{Code: "BDG", Name: "Bandung", Kind: "Service Point", Latitude: -6.9, Longitude: 107.6, Radius: 100, Timezone: "Asia/Jakarta", WorkStart: "08:00", Active: true}
	if !errors.Is(a.SaveServicePoint(ctx, employee, p), ErrForbidden) {
		t.Fatal("employee writes master")
	}
	must(t, a.SaveServicePoint(ctx, admin, p))
	if a.SaveServicePoint(ctx, admin, p) == nil {
		t.Fatal("duplicate code accepted")
	}
	p.Code = "X"
	p.Name = "Other"
	p.Latitude = 91
	if a.SaveServicePoint(ctx, admin, p) == nil {
		t.Fatal("invalid latitude")
	}
	p.Latitude = -6
	p.Radius = -1
	if a.SaveServicePoint(ctx, admin, p) == nil {
		t.Fatal("invalid radius")
	}
	must(t, a.EnsureMasterData(ctx))
	own, err := a.Employees(ctx, employee)
	must(t, err)
	if own[0].ServicePointID != "HQ" || own[0].AllowAnyLocation {
		t.Fatal("migration changed default")
	}
}
