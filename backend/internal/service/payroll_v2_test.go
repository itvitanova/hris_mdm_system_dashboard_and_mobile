package service

import (
	"bytes"
	"errors"
	"github.com/xuri/excelize/v2"
	"hrismdm/backend/internal/domain"
	"strconv"
	"testing"
)

func TestTERBoundariesAndComponents(t *testing.T) {
	for category, bands := range terBands {
		for i, b := range bands {
			previous := int64(0)
			if i > 0 {
				previous = bands[i-1].RateBps
			}
			_, at := CalculateTER(b.Threshold, category)
			_, above := CalculateTER(b.Threshold+1, category)
			if at != previous || above != b.RateBps {
				t.Fatalf("category %s threshold %d: at=%d above=%d", category, b.Threshold, at, above)
			}
		}
	}
	p := domain.Payroll{Version: 2, BaseSalary: 8000000, Allowance: 1000000, Bonus: 500000, Overtime: 200000, PTKP: "TK/0", Period: "2026-10", TaxMode: "auto", Reimbursement: 1000000}
	must(t, recalculatePayroll(&p))
	if p.GrossSalary != 9700000 || p.PPh21 != 194000 || p.BPJSHealth != 80000 || p.JHT != 160000 || p.JP != 80000 || p.NetSalary != 9186000 || p.Reimbursement != 0 {
		t.Fatalf("incorrect components: %+v", p)
	}
	for _, status := range []string{"TK/0", "TK/1", "K/0"} {
		if PTKPCategory(status) != "A" {
			t.Fatal(status)
		}
	}
	for _, status := range []string{"TK/2", "TK/3", "K/1", "K/2"} {
		if PTKPCategory(status) != "B" {
			t.Fatal(status)
		}
	}
	if PTKPCategory("K/3") != "C" || PTKPCategory("bad") != "" {
		t.Fatal("PTKP mapping")
	}
}
func TestPayrollManualRefundRevisionAndRegeneration(t *testing.T) {
	a, admin, employee := setup(t)
	must(t, a.GeneratePayroll(ctx, admin, "2026-12"))
	rows, err := a.Payroll(ctx, employee)
	must(t, err)
	p := rows[0]
	if p.TaxReady || p.TaxMode != "manual" {
		t.Fatal("December requires explicit manual tax")
	}
	if a.FinalizePayroll(ctx, admin, p.ID, p.Revision) == nil {
		t.Fatal("missing December tax finalized")
	}
	refund := int64(-500000)
	input := PayrollInput{Revision: p.Revision, Allowance: 1000000, Bonus: 200000, PTKP: "K/1", TaxMode: "manual", ManualPPh21: &refund, TaxNote: "Rekonsiliasi periode Desember"}
	must(t, a.UpdatePayroll(ctx, admin, p.ID, input))
	if a.UpdatePayroll(ctx, admin, p.ID, input) == nil {
		t.Fatal("stale draft overwritten")
	}
	must(t, a.GeneratePayroll(ctx, admin, "2026-12"))
	rows, err = a.Payroll(ctx, employee)
	must(t, err)
	p = rows[0]
	if p.Allowance != 1000000 || p.Bonus != 200000 || p.PPh21 != -500000 || !p.TaxReady {
		t.Fatal("HR input lost on regeneration")
	}
	if p.NetSalary != p.GrossSalary+500000-p.BPJSHealth-p.JHT-p.JP {
		t.Fatal("refund not added to net")
	}
	must(t, a.FinalizePayroll(ctx, admin, p.ID, p.Revision))
	input.Revision = p.Revision + 1
	if a.UpdatePayroll(ctx, admin, p.ID, input) == nil {
		t.Fatal("final slip edited")
	}
	if !errors.Is(a.UpdatePayroll(ctx, employee, p.ID, input), ErrForbidden) {
		t.Fatal("employee can edit payroll")
	}
	must(t, a.GeneratePayroll(ctx, admin, "2027-01"))
	rows, err = a.Payroll(ctx, employee)
	must(t, err)
	for _, r := range rows {
		if r.Period == "2027-01" && (r.Allowance != 0 || r.Bonus != 0) {
			t.Fatal("manual amounts carried into next month")
		}
	}
}
func TestPayrollTaxImportAtomicAndExplicitZero(t *testing.T) {
	a, admin, employee := setup(t)
	must(t, a.GeneratePayroll(ctx, admin, "2026-12"))
	template, err := a.TaxTemplate(ctx, admin, "2026-12")
	must(t, err)
	f, err := excelize.OpenReader(bytes.NewReader(template))
	must(t, err)
	defer f.Close()
	sheet := "PPh21 Manual"
	rows, err := f.GetRows(sheet)
	must(t, err)
	for row := 4; row <= len(rows); row++ {
		f.SetCellValue(sheet, "E"+strconv.Itoa(row), 0)
		f.SetCellValue(sheet, "F"+strconv.Itoa(row), "Nihil sesuai rekonsiliasi")
	}
	f.SetCellValue(sheet, "E5", "invalid")
	bad, err := f.WriteToBuffer()
	must(t, err)
	if _, err = a.ImportTax(ctx, admin, "2026-12", bad.Bytes()); err == nil {
		t.Fatal("invalid import accepted")
	}
	slips, err := a.Payroll(ctx, employee)
	must(t, err)
	if slips[0].TaxReady || slips[0].Revision != 1 {
		t.Fatal("failed import partially committed")
	}
	f.SetCellValue(sheet, "E5", -100000)
	good, err := f.WriteToBuffer()
	must(t, err)
	count, err := a.ImportTax(ctx, admin, "2026-12", good.Bytes())
	must(t, err)
	if count != 18 {
		t.Fatalf("imported %d rows", count)
	}
	if _, err = a.ImportTax(ctx, admin, "2026-12", good.Bytes()); err == nil {
		t.Fatal("stale import overwrote payroll")
	}
}
func TestPayrollMigrationOnlyDrafts(t *testing.T) {
	a, _, employee := setup(t)
	draft := domain.Payroll{ID: "2025-10-" + employee.EmployeeID, EmployeeID: employee.EmployeeID, Period: "2025-10", BaseSalary: 8000000, Reimbursement: 50000, NetSalary: 8050000, Status: "Draft"}
	final := draft
	final.ID = "2025-11-" + employee.EmployeeID
	final.Period = "2025-11"
	final.Status = "Final"
	must(t, a.Store.Put(ctx, "payroll", draft.ID, draft))
	must(t, a.Store.Put(ctx, "payroll", final.ID, final))
	must(t, a.EnsurePayrollV2(ctx))
	var migrated, historical, archive domain.Payroll
	must(t, a.Store.Get(ctx, "payroll", draft.ID, &migrated))
	must(t, a.Store.Get(ctx, "payroll", final.ID, &historical))
	must(t, a.Store.Get(ctx, "payroll_legacy", draft.ID, &archive))
	if migrated.Version != 2 || migrated.Reimbursement != 0 || archive.Reimbursement != 50000 || historical.Reimbursement != 50000 || historical.Version != 0 {
		t.Fatal("migration modified final history or lost archive")
	}
	must(t, a.EnsurePayrollV2(ctx))
	var again domain.Payroll
	must(t, a.Store.Get(ctx, "payroll", draft.ID, &again))
	if again.Revision != migrated.Revision {
		t.Fatal("migration not idempotent")
	}
}
