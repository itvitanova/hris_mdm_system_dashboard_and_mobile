package service

import (
	"context"
	"errors"
	"fmt"
	"hrismdm/backend/internal/domain"
	"math"
	"strings"
	"time"
)

type PayrollInput struct {
	Revision      int    `json:"revision"`
	Allowance     int64  `json:"allowance"`
	Bonus         int64  `json:"bonus"`
	PTKP          string `json:"ptkp"`
	TaxMode       string `json:"taxMode"`
	ManualPPh21   *int64 `json:"manualPph21"`
	TaxNote       string `json:"taxNote"`
	LastTaxPeriod bool   `json:"lastTaxPeriod"`
}

func recalculatePayroll(p *domain.Payroll) error {
	if len(p.TaxNote) > 1000 {
		return errors.New("catatan pajak maksimal 1000 karakter")
	}
	if err := money(p.Allowance); err != nil {
		return err
	}
	if err := money(p.Bonus); err != nil {
		return err
	}
	p.GrossSalary = p.BaseSalary + p.Allowance + p.Overtime + p.Bonus
	p.Reimbursement = 0
	p.BPJSHealth = (p.BaseSalary + 50) / 100
	p.JHT = (p.BaseSalary*2 + 50) / 100
	p.JP = (p.BaseSalary + 50) / 100
	p.PTKP = strings.ToUpper(strings.TrimSpace(p.PTKP))
	p.TaxCategory = PTKPCategory(p.PTKP)
	p.TaxReady = false
	p.PPh21 = 0
	p.TaxRateBps = 0
	last := strings.HasSuffix(p.Period, "-12") || p.LastTaxPeriod
	if p.TaxMode == "" {
		p.TaxMode = "auto"
	}
	if last {
		p.TaxMode = "manual"
	}
	if p.TaxMode != "auto" && p.TaxMode != "manual" {
		return errors.New("mode pajak tidak valid")
	}
	if p.TaxCategory != "" {
		if p.TaxMode == "auto" {
			p.PPh21, p.TaxRateBps = CalculateTER(p.GrossSalary, p.TaxCategory)
			p.TaxReady = true
		} else if p.ManualPPh21 != nil {
			if *p.ManualPPh21 < -1000000000000 || *p.ManualPPh21 > 1000000000000 {
				return errors.New("PPh21 manual di luar batas")
			}
			if *p.ManualPPh21 < 0 && !last {
				return errors.New("pengembalian PPh21 hanya untuk masa pajak terakhir")
			}
			if strings.TrimSpace(p.TaxNote) == "" {
				return errors.New("catatan PPh21 manual wajib diisi")
			}
			p.PPh21 = *p.ManualPPh21
			p.TaxReady = true
		}
	}
	p.Deductions = p.PPh21 + p.BPJSHealth + p.JHT + p.JP
	p.NetSalary = p.GrossSalary - p.Deductions
	if p.NetSalary < 0 {
		return errors.New("potongan melebihi total pendapatan")
	}
	return nil
}
func (a *App) Payroll(ctx context.Context, actor domain.Actor) ([]domain.Payroll, error) {
	var all []domain.Payroll
	if err := a.Store.List(ctx, "payroll", &all); err != nil {
		return nil, err
	}
	out := []domain.Payroll{}
	for _, p := range all {
		if actor.Role == "admin" || p.EmployeeID == actor.EmployeeID {
			out = append(out, p)
		}
	}
	return out, nil
}
func (a *App) PayrollSlip(ctx context.Context, actor domain.Actor, id string) (domain.Payroll, error) {
	var p domain.Payroll
	if err := a.Store.Get(ctx, "payroll", id, &p); err != nil {
		return p, errors.New("slip tidak ditemukan")
	}
	if actor.Role != "admin" && p.EmployeeID != actor.EmployeeID {
		return domain.Payroll{}, ErrForbidden
	}
	return p, nil
}
func newPayroll(e domain.Employee, settings domain.Settings, period string) domain.Payroll {
	return domain.Payroll{Version: 2, Revision: 1, ID: fmt.Sprintf("%s-%s", period, e.ID), EmployeeID: e.ID, EmployeeName: e.Name, Department: e.Department, Position: e.Position, CompanyName: settings.Company, CompanyAddress: settings.CompanyAddress, CompanyLogo: settings.CompanyLogo, Period: period, BaseSalary: e.Salary, PTKP: e.PTKP, TaxMode: "auto", Status: "Draft"}
}
func (a *App) GeneratePayroll(ctx context.Context, actor domain.Actor, period string) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	if _, err := time.Parse("2006-01", period); err != nil {
		return errors.New("periode tidak valid")
	}
	return a.write(ctx, func(s domain.Store) error {
		var employees []domain.Employee
		var requests []domain.Request
		var existing []domain.Payroll
		var settings domain.Settings
		if err := s.List(ctx, "employees", &employees); err != nil {
			return err
		}
		if err := s.List(ctx, "requests", &requests); err != nil {
			return err
		}
		if err := s.List(ctx, "payroll", &existing); err != nil {
			return err
		}
		if err := s.Get(ctx, "settings", "company", &settings); err != nil {
			return err
		}
		previous := map[string]domain.Payroll{}
		for _, p := range existing {
			if p.Period == period {
				if p.Status == "Final" {
					return errors.New("periode memiliki slip final dan tidak dapat dihitung ulang")
				}
				previous[p.EmployeeID] = p
			}
		}
		for _, e := range employees {
			if e.Status == "Nonaktif" {
				continue
			}
			p := newPayroll(e, settings, period)
			if old, ok := previous[e.ID]; ok && old.Version == 2 {
				p.Revision = old.Revision + 1
				p.Allowance = old.Allowance
				p.Bonus = old.Bonus
				p.ManualPPh21 = old.ManualPPh21
				p.TaxMode = old.TaxMode
				p.TaxNote = old.TaxNote
				p.LastTaxPeriod = old.LastTaxPeriod
				if old.PTKP != "" {
					p.PTKP = old.PTKP
				}
			}
			for _, r := range requests {
				if r.EmployeeID == e.ID && r.Status == "Disetujui" && r.Kind == "Lembur" && len(r.StartDate) >= 7 && r.StartDate[:7] == period {
					p.Overtime += int64(math.Round(float64(e.Salary) / 173 * 1.5 * r.Hours))
				}
			}
			if err := recalculatePayroll(&p); err != nil {
				return fmt.Errorf("%s: %w", e.Name, err)
			}
			if err := s.Put(ctx, "payroll", p.ID, p); err != nil {
				return err
			}
			delete(previous, e.ID)
		}
		for _, old := range previous {
			if err := s.Delete(ctx, "payroll", old.ID); err != nil {
				return err
			}
		}
		return audit(ctx, s, actor, "payroll.generate", period)
	})
}
func updatePayroll(ctx context.Context, s domain.Store, actor domain.Actor, id string, input PayrollInput) error {
	var p domain.Payroll
	if s.Get(ctx, "payroll", id, &p) != nil {
		return errors.New("slip tidak ditemukan")
	}
	if p.Status != "Draft" || p.Version != 2 {
		return errors.New("hanya draft payroll format baru yang dapat diubah")
	}
	if input.Revision != p.Revision {
		return errors.New("data payroll telah berubah; muat ulang sebelum menyimpan")
	}
	if PTKPCategory(input.PTKP) == "" {
		return errors.New("pilih status PTKP yang valid")
	}
	p.Allowance = input.Allowance
	p.Bonus = input.Bonus
	p.PTKP = input.PTKP
	p.TaxMode = input.TaxMode
	p.ManualPPh21 = input.ManualPPh21
	p.TaxNote = strings.TrimSpace(input.TaxNote)
	p.LastTaxPeriod = input.LastTaxPeriod
	if err := recalculatePayroll(&p); err != nil {
		return err
	}
	p.Revision++
	if err := s.Put(ctx, "payroll", id, p); err != nil {
		return err
	}
	return audit(ctx, s, actor, "payroll.update", id)
}
func (a *App) UpdatePayroll(ctx context.Context, actor domain.Actor, id string, input PayrollInput) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	return a.write(ctx, func(s domain.Store) error { return updatePayroll(ctx, s, actor, id, input) })
}
func (a *App) FinalizePayroll(ctx context.Context, actor domain.Actor, id string, revision int) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	return a.write(ctx, func(s domain.Store) error {
		var p domain.Payroll
		if s.Get(ctx, "payroll", id, &p) != nil {
			return errors.New("payroll tidak ditemukan")
		}
		if p.Status != "Draft" || p.Version != 2 {
			return errors.New("payroll sudah final atau perlu diperbarui")
		}
		if p.Revision != revision {
			return errors.New("data payroll telah berubah; tinjau slip terbaru")
		}
		if err := recalculatePayroll(&p); err != nil {
			return err
		}
		if !p.TaxReady {
			return errors.New("lengkapi status PTKP dan PPh21 manual untuk masa pajak terakhir sebelum finalisasi")
		}
		p.Status = "Final"
		p.FinalizedAt = now()
		p.FinalizedBy = actor.Name
		p.Revision++
		if err := s.Put(ctx, "payroll", id, p); err != nil {
			return err
		}
		return audit(ctx, s, actor, "payroll.finalize", id)
	})
}

// Only legacy drafts are upgraded. Original records are archived; final history stays immutable.
func (a *App) EnsurePayrollV2(ctx context.Context) error {
	return a.write(ctx, func(s domain.Store) error {
		var rows []domain.Payroll
		var settings domain.Settings
		if err := s.List(ctx, "payroll", &rows); err != nil {
			return err
		}
		if err := s.Get(ctx, "settings", "company", &settings); err != nil {
			return err
		}
		for _, old := range rows {
			if old.Version >= 2 || old.Status != "Draft" {
				continue
			}
			var e domain.Employee
			if err := s.Get(ctx, "employees", old.EmployeeID, &e); err != nil {
				return err
			}
			if err := s.Put(ctx, "payroll_legacy", old.ID, old); err != nil {
				return err
			}
			p := newPayroll(e, settings, old.Period)
			p.BaseSalary = old.BaseSalary
			p.Overtime = old.Overtime
			if err := recalculatePayroll(&p); err != nil {
				return err
			}
			if err := s.Put(ctx, "payroll", p.ID, p); err != nil {
				return err
			}
		}
		return nil
	})
}
