package service

import (
	"context"
	"errors"
	"fmt"
	"hrismdm/backend/internal/domain"
	"sort"
	"strings"
)

// Add future catalog types here; HTTP and CRUD rules remain shared.
var masterKinds = map[string]string{"departments": "Departemen", "positions": "Jabatan"}

func masterCollection(kind string) (string, error) {
	if _, ok := masterKinds[kind]; !ok {
		return "", errors.New("jenis master data tidak dikenal")
	}
	return "master_" + kind, nil
}
func cleanName(s string) string { return strings.Join(strings.Fields(s), " ") }
func (a *App) MasterData(ctx context.Context, actor domain.Actor, kind string) ([]domain.MasterData, error) {
	if actor.Role != "admin" {
		return nil, ErrForbidden
	}
	collection, err := masterCollection(kind)
	if err != nil {
		return nil, err
	}
	var rows []domain.MasterData
	if err = a.Store.List(ctx, collection, &rows); err != nil {
		return nil, err
	}
	sort.Slice(rows, func(i, j int) bool { return strings.ToLower(rows[i].Name) < strings.ToLower(rows[j].Name) })
	return rows, nil
}
func (a *App) SaveMasterData(ctx context.Context, actor domain.Actor, kind string, v domain.MasterData) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	collection, err := masterCollection(kind)
	if err != nil {
		return err
	}
	v.Name = cleanName(v.Name)
	v.Code = strings.ToUpper(strings.TrimSpace(v.Code))
	v.Description = strings.TrimSpace(v.Description)
	if v.Name == "" || len(v.Name) > 120 || v.Code == "" || len(v.Code) > 30 || len(v.Description) > 1000 {
		return errors.New("kode (maks. 30 karakter) dan nama (maks. 120 karakter) wajib diisi")
	}
	return a.write(ctx, func(s domain.Store) error {
		var rows []domain.MasterData
		if err := s.List(ctx, collection, &rows); err != nil {
			return err
		}
		if kind == "positions" {
			var department domain.MasterData
			var previous domain.MasterData
			if v.ID != "" {
				_ = s.Get(ctx, "master_positions", v.ID, &previous)
			}
			if s.Get(ctx, "master_departments", v.DepartmentID, &department) != nil || (!department.Active && previous.DepartmentID != v.DepartmentID) {
				return errors.New("pilih departemen aktif untuk jabatan")
			}
			var employees []domain.Employee
			if err := s.List(ctx, "employees", &employees); err != nil {
				return err
			}
			for _, e := range employees {
				if e.PositionID == v.ID && e.DepartmentID != v.DepartmentID {
					return errors.New("jabatan masih digunakan departemen lain; buat jabatan baru")
				}
			}
		}
		for _, row := range rows {
			if row.ID != v.ID && (strings.EqualFold(row.Name, v.Name) && (kind != "positions" || row.DepartmentID == v.DepartmentID) || strings.EqualFold(row.Code, v.Code)) {
				return errors.New("kode atau nama sudah digunakan")
			}
		}
		if v.ID == "" {
			v.ID = ID()
		} else {
			var old domain.MasterData
			if err := s.Get(ctx, collection, v.ID, &old); err != nil {
				return errors.New("master data tidak ditemukan")
			}
		}
		if err := s.Put(ctx, collection, v.ID, v); err != nil {
			return err
		}
		// Current employee labels follow catalog renames; historical payroll snapshots stay unchanged.
		var employees []domain.Employee
		if err := s.List(ctx, "employees", &employees); err != nil {
			return err
		}
		for _, e := range employees {
			changed := false
			if kind == "departments" && e.DepartmentID == v.ID {
				e.Department = v.Name
				changed = true
			}
			if kind == "positions" && e.PositionID == v.ID {
				e.Position = v.Name
				changed = true
			}
			if changed {
				if err := s.Put(ctx, "employees", e.ID, e); err != nil {
					return err
				}
			}
		}
		return audit(ctx, s, actor, "master."+kind+".save", v.ID)
	})
}
func (a *App) DeleteMasterData(ctx context.Context, actor domain.Actor, kind, id string) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	collection, err := masterCollection(kind)
	if err != nil {
		return err
	}
	return a.write(ctx, func(s domain.Store) error {
		var row domain.MasterData
		if s.Get(ctx, collection, id, &row) != nil {
			return errors.New("master data tidak ditemukan")
		}
		var employees []domain.Employee
		if err := s.List(ctx, "employees", &employees); err != nil {
			return err
		}
		for _, e := range employees {
			if (kind == "departments" && e.DepartmentID == id) || (kind == "positions" && e.PositionID == id) {
				return errors.New("data masih digunakan karyawan; nonaktifkan jika tidak ingin dipilih lagi")
			}
		}
		if kind == "departments" {
			var positions []domain.MasterData
			if err := s.List(ctx, "master_positions", &positions); err != nil {
				return err
			}
			for _, p := range positions {
				if p.DepartmentID == id {
					return errors.New("departemen masih memiliki jabatan; nonaktifkan jika tidak digunakan")
				}
			}
		}
		if err := s.Delete(ctx, collection, id); err != nil {
			return err
		}
		return audit(ctx, s, actor, "master."+kind+".delete", id)
	})
}
func resolveMaster(ctx context.Context, s domain.Store, kind, id, previousID string) (domain.MasterData, error) {
	var v domain.MasterData
	collection, err := masterCollection(kind)
	if err != nil {
		return v, err
	}
	if id == "" || s.Get(ctx, collection, id, &v) != nil {
		return v, fmt.Errorf("pilih %s dari master data", strings.ToLower(masterKinds[kind]))
	}
	if !v.Active && id != previousID {
		return v, fmt.Errorf("%s tidak aktif", masterKinds[kind])
	}
	return v, nil
}

// Idempotent backfill preserves legacy employee names and assigns stable master IDs.
// It runs after seed/bootstrap, inside the same database transaction lock as CRUD.
func (a *App) EnsureMasterData(ctx context.Context) error {
	return a.write(ctx, func(s domain.Store) error {
		var employees []domain.Employee
		if err := s.List(ctx, "employees", &employees); err != nil {
			return err
		}
		catalogs := map[string][]domain.MasterData{}
		for kind := range masterKinds {
			var rows []domain.MasterData
			if err := s.List(ctx, "master_"+kind, &rows); err != nil {
				return err
			}
			catalogs[kind] = rows
		}
		find := func(kind, name, departmentID string) (domain.MasterData, error) {
			name = cleanName(name)
			if name == "" {
				name = "Belum ditentukan"
			}
			for i, v := range catalogs[kind] {
				if strings.EqualFold(v.Name, name) && (kind != "positions" || v.DepartmentID == departmentID || v.DepartmentID == "") {
					if kind == "positions" && v.DepartmentID == "" {
						v.DepartmentID = departmentID
						catalogs[kind][i] = v
						if err := s.Put(ctx, "master_positions", v.ID, v); err != nil {
							return v, err
						}
					}
					return v, nil
				}
			}
			id := ID()
			prefix := "DEP"
			if kind == "positions" {
				prefix = "POS"
			}
			v := domain.MasterData{ID: id, Code: prefix + "-" + strings.ToUpper(id[:12]), Name: name, Active: true, DepartmentID: departmentID}
			if err := s.Put(ctx, "master_"+kind, id, v); err != nil {
				return v, err
			}
			catalogs[kind] = append(catalogs[kind], v)
			return v, nil
		}
		for _, e := range employees {
			changed := false
			if e.DepartmentID == "" {
				v, err := find("departments", e.Department, "")
				if err != nil {
					return err
				}
				e.DepartmentID = v.ID
				e.Department = v.Name
				changed = true
			}
			var currentPosition domain.MasterData
			positionMissing := e.PositionID == "" || s.Get(ctx, "master_positions", e.PositionID, &currentPosition) != nil
			if positionMissing || currentPosition.DepartmentID != e.DepartmentID {
				positionName := e.Position
				if !positionMissing {
					positionName = currentPosition.Name
				}
				v, err := find("positions", positionName, e.DepartmentID)
				if err != nil {
					return err
				}
				e.PositionID = v.ID
				e.Position = v.Name
				changed = true
			}
			if changed {
				if err := s.Put(ctx, "employees", e.ID, e); err != nil {
					return err
				}
			}
		}
		return ensureServicePoints(ctx, s)
	})
}
