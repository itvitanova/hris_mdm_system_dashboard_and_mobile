package service

import (
	"context"
	"errors"
	"fmt"
	"hrismdm/backend/internal/domain"
	"strings"
)

var requestKinds = map[string]bool{"Cuti": true, "Reimbursement": true, "Petty Cash": true, "General Affair": true, "Lembur": true}

func defaultPolicy(kind string) domain.ApprovalPolicy {
	p := domain.ApprovalPolicy{ID: kind, Stages: []domain.ApprovalStage{{Name: "Persetujuan atasan", Source: "manager", Level: 1, Mode: "all"}}}
	if kind == "Reimbursement" {
		p.Stages = append(p.Stages, domain.ApprovalStage{Name: "Verifikasi finance", Source: "finance", Mode: "any"})
	}
	return p
}
func (a *App) ApprovalPolicies(ctx context.Context, actor domain.Actor) ([]domain.ApprovalPolicy, error) {
	if actor.Role != "admin" {
		return nil, ErrForbidden
	}
	out := []domain.ApprovalPolicy{}
	var saved []domain.ApprovalPolicy
	if err := a.Store.List(ctx, "approval_policies", &saved); err != nil {
		return nil, err
	}
	for _, kind := range []string{"Cuti", "Reimbursement", "Petty Cash", "General Affair", "Lembur"} {
		p := defaultPolicy(kind)
		for _, v := range saved {
			if v.ID == kind {
				p = v
			}
		}
		out = append(out, p)
	}
	return out, nil
}
func (a *App) SaveApprovalPolicy(ctx context.Context, actor domain.Actor, p domain.ApprovalPolicy) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	if !requestKinds[p.ID] || len(p.Stages) == 0 || len(p.Stages) > 10 {
		return errors.New("alur harus memiliki 1–10 tahap")
	}
	return a.write(ctx, func(s domain.Store) error {
		finance := 0
		for i, st := range p.Stages {
			if strings.TrimSpace(st.Name) == "" || len(st.Name) > 100 || (st.Mode != "all" && st.Mode != "any") {
				return errors.New("nama dan mode tahap wajib diisi")
			}
			switch st.Source {
			case "manager":
				if st.Level < 1 || st.Level > 10 {
					return errors.New("tingkat atasan harus 1–10")
				}
			case "employees":
				if len(st.EmployeeIDs) == 0 || len(st.EmployeeIDs) > 20 {
					return errors.New("pilih 1–20 approver")
				}
				seen := map[string]bool{}
				for _, id := range st.EmployeeIDs {
					var e domain.Employee
					if seen[id] || s.Get(ctx, "employees", id, &e) != nil || e.Status == "Nonaktif" {
						return errors.New("approver tidak valid atau duplikat")
					}
					seen[id] = true
				}
			case "finance":
				finance++
				if i != len(p.Stages)-1 {
					return errors.New("verifikasi finance harus tahap terakhir")
				}
			default:
				return errors.New("sumber approver tidak valid")
			}
			if st.Source == "finance" && p.ID != "Reimbursement" {
				return errors.New("tahap finance hanya untuk reimbursement")
			}
		}
		if p.ID == "Reimbursement" && (finance != 1 || len(p.Stages) < 2) {
			return errors.New("reimbursement wajib memiliki persetujuan dan verifikasi finance terakhir")
		}
		if err := s.Put(ctx, "approval_policies", p.ID, p); err != nil {
			return err
		}
		return audit(ctx, s, actor, "approval-policy.save", p.ID)
	})
}
func validateReportingLine(ctx context.Context, s domain.Store, e domain.Employee) error {
	seen := map[string]bool{}
	if e.ID != "" {
		seen[e.ID] = true
	}
	id := e.ManagerID
	for id != "" {
		if seen[id] {
			return errors.New("struktur atasan tidak boleh berputar atau menunjuk diri sendiri")
		}
		seen[id] = true
		var m domain.Employee
		if s.Get(ctx, "employees", id, &m) != nil || m.Status == "Nonaktif" {
			return errors.New("atasan tidak ditemukan atau tidak aktif")
		}
		id = m.ManagerID
	}
	return nil
}
func resolveSteps(ctx context.Context, s domain.Store, emp domain.Employee, kind string) ([]domain.ApprovalStep, error) {
	p := defaultPolicy(kind)
	var allPolicies []domain.ApprovalPolicy
	if err := s.List(ctx, "approval_policies", &allPolicies); err != nil {
		return nil, err
	}
	for _, v := range allPolicies {
		if v.ID == kind {
			p = v
		}
	}
	var employees []domain.Employee
	var users []domain.User
	if err := s.List(ctx, "employees", &employees); err != nil {
		return nil, err
	}
	if err := s.List(ctx, "users", &users); err != nil {
		return nil, err
	}
	accounts := map[string]bool{}
	for _, u := range users {
		accounts[u.EmployeeID] = true
	}
	byID := map[string]domain.Employee{}
	for _, e := range employees {
		byID[e.ID] = e
	}
	out := []domain.ApprovalStep{}
	previous := map[string]bool{}
	for _, stage := range p.Stages {
		ids := []string{}
		switch stage.Source {
		case "manager":
			m := emp
			seen := map[string]bool{emp.ID: true}
			for i := 0; i < stage.Level; i++ {
				next, ok := byID[m.ManagerID]
				if !ok || seen[next.ID] {
					return nil, errors.New("atasan belum lengkap. Minta HR melengkapi struktur atau alur persetujuan")
				}
				seen[next.ID] = true
				m = next
			}
			ids = append(ids, m.ID)
		case "employees":
			ids = append(ids, stage.EmployeeIDs...)
		case "finance":
			for _, e := range employees {
				if e.FinanceVerifier && e.ID != emp.ID && !previous[e.ID] && e.Status != "Nonaktif" && accounts[e.ID] {
					ids = append(ids, e.ID)
				}
			}
		}
		step := domain.ApprovalStep{Name: stage.Name, Source: stage.Source, Mode: stage.Mode, Status: "Menunggu", Approvers: []domain.Approver{}, Decisions: []domain.ApprovalEvent{}}
		seen := map[string]bool{}
		for _, id := range ids {
			e, ok := byID[id]
			if !ok || id == emp.ID || seen[id] || e.Status == "Nonaktif" || !accounts[id] {
				return nil, fmt.Errorf("approver tahap %s tidak aktif, belum memiliki akun, atau pemohon sendiri", stage.Name)
			}
			if stage.Source == "finance" && previous[id] {
				return nil, errors.New("verifikator finance harus berbeda dari pemberi persetujuan")
			}
			seen[id] = true
			step.Approvers = append(step.Approvers, domain.Approver{EmployeeID: id, Name: e.Name})
		}
		if len(step.Approvers) == 0 {
			return nil, fmt.Errorf("belum ada petugas untuk tahap %s; hubungi HR", stage.Name)
		}
		for _, v := range step.Approvers {
			previous[v.EmployeeID] = true
		}
		out = append(out, step)
	}
	return out, nil
}
func canSeeRequest(actor domain.Actor, r domain.Request) bool {
	if actor.Role == "admin" || actor.EmployeeID == r.EmployeeID {
		return true
	}
	for _, st := range r.Steps {
		for _, p := range st.Approvers {
			if p.EmployeeID == actor.EmployeeID {
				return true
			}
		}
	}
	return false
}
func canReviewRequest(actor domain.Actor, r domain.Request) bool {
	if actor.EmployeeID == r.EmployeeID || r.Status != "Menunggu" {
		return false
	}
	if r.Version < 2 {
		return actor.Role == "admin"
	}
	if r.CurrentStep < 0 || r.CurrentStep >= len(r.Steps) {
		return false
	}
	st := r.Steps[r.CurrentStep]
	for _, d := range st.Decisions {
		if d.EmployeeID == actor.EmployeeID {
			return false
		}
	}
	for _, p := range st.Approvers {
		if p.EmployeeID == actor.EmployeeID {
			return true
		}
	}
	return false
}
func (a *App) ApprovalAccess(ctx context.Context, actor domain.Actor) (bool, error) {
	if actor.Role == "admin" {
		return true, nil
	}
	var rows []domain.Employee
	if err := a.Store.List(ctx, "employees", &rows); err != nil {
		return false, err
	}
	for _, e := range rows {
		if e.ManagerID == actor.EmployeeID || (e.ID == actor.EmployeeID && e.FinanceVerifier) {
			return true, nil
		}
	}
	var policies []domain.ApprovalPolicy
	if err := a.Store.List(ctx, "approval_policies", &policies); err != nil {
		return false, err
	}
	for _, p := range policies {
		for _, st := range p.Stages {
			for _, id := range st.EmployeeIDs {
				if id == actor.EmployeeID {
					return true, nil
				}
			}
		}
	}
	var requests []domain.Request
	if err := a.Store.List(ctx, "requests", &requests); err != nil {
		return false, err
	}
	for _, r := range requests {
		if r.EmployeeID != actor.EmployeeID && canSeeRequest(actor, r) {
			return true, nil
		}
	}
	return false, nil
}
