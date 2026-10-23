package service

import (
	"errors"
	"hrismdm/backend/internal/domain"
	"testing"
)

func TestMasterBackfillIsStableAndAdminOnly(t *testing.T) {
	a, admin, employee := setup(t)
	departments, err := a.MasterData(ctx, admin, "departments")
	must(t, err)
	positions, err := a.MasterData(ctx, admin, "positions")
	must(t, err)
	if len(departments) != 6 || len(positions) != 6 {
		t.Fatal("legacy labels were not backfilled")
	}
	employees, err := a.Employees(ctx, admin)
	must(t, err)
	for _, e := range employees {
		if e.DepartmentID == "" || e.PositionID == "" {
			t.Fatal("legacy employee missing master reference")
		}
	}
	must(t, a.EnsureMasterData(ctx))
	again, err := a.MasterData(ctx, admin, "departments")
	must(t, err)
	if len(again) != len(departments) {
		t.Fatal("backfill duplicated master data")
	}
	for i := range again {
		if again[i].ID != departments[i].ID {
			t.Fatal("master ID changed on restart")
		}
	}
	if _, err = a.MasterData(ctx, employee, "departments"); !errors.Is(err, ErrForbidden) {
		t.Fatal("employee can access master administration")
	}
	if !errors.Is(a.SaveMasterData(ctx, employee, "positions", domain.MasterData{Name: "Unauthorized", Code: "NO", Active: true}), ErrForbidden) {
		t.Fatal("employee can mutate masters")
	}
	if _, err = a.MasterData(ctx, admin, "unknown"); err == nil {
		t.Fatal("unknown master collection allowed")
	}
}

func TestMasterReferencesRenameDeactivateAndDelete(t *testing.T) {
	a, admin, employee := setup(t)
	rows, err := a.Employees(ctx, employee)
	must(t, err)
	e := rows[0]
	departments, err := a.MasterData(ctx, admin, "departments")
	must(t, err)
	var dept domain.MasterData
	for _, v := range departments {
		if v.ID == e.DepartmentID {
			dept = v
		}
	}
	original := dept
	dept.Name = "Product Engineering"
	must(t, a.SaveMasterData(ctx, admin, "departments", dept))
	rows, err = a.Employees(ctx, employee)
	must(t, err)
	if rows[0].Department != dept.Name || rows[0].DepartmentID != dept.ID {
		t.Fatal("rename lost employee relationship")
	}
	duplicate := domain.MasterData{Code: "NEW", Name: "  product   engineering ", Active: true}
	if a.SaveMasterData(ctx, admin, "departments", duplicate) == nil {
		t.Fatal("case/whitespace duplicate name accepted")
	}
	duplicate.Name = "Other"
	duplicate.Code = original.Code
	if a.SaveMasterData(ctx, admin, "departments", duplicate) == nil {
		t.Fatal("duplicate code accepted")
	}
	if a.DeleteMasterData(ctx, admin, "departments", dept.ID) == nil {
		t.Fatal("referenced master deleted")
	}
	dept.Active = false
	must(t, a.SaveMasterData(ctx, admin, "departments", dept))
	e = rows[0]
	e.Phone = "081200001234"
	must(t, a.SaveEmployee(ctx, admin, e)) // existing inactive placement remains editable
	fresh := e
	fresh.ID = ""
	fresh.Email = "new-person@mdm.local"
	if a.SaveEmployee(ctx, admin, fresh) == nil {
		t.Fatal("new employee assigned to inactive master")
	}
	fresh.DepartmentID = "missing"
	if a.SaveEmployee(ctx, admin, fresh) == nil {
		t.Fatal("unregistered master accepted")
	}
	fresh.DepartmentID = ""
	fresh.Department = "Manual"
	if a.SaveEmployee(ctx, admin, fresh) == nil {
		t.Fatal("free-text master assignment accepted")
	}
	must(t, a.SaveMasterData(ctx, admin, "departments", domain.MasterData{Code: "TEMP", Name: "Temporary", Active: true}))
	all, err := a.MasterData(ctx, admin, "departments")
	must(t, err)
	for _, v := range all {
		if v.Code == "TEMP" {
			must(t, a.DeleteMasterData(ctx, admin, "departments", v.ID))
		}
	}
}
