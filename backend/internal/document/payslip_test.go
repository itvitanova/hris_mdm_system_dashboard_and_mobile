package document_test

import (
	"bytes"
	"hrismdm/backend/internal/document"
	"hrismdm/backend/internal/domain"
	"os"
	"path/filepath"
	"testing"
)

func TestPayslipPDFWithDetailedComponents(t *testing.T) {
	p := domain.Payroll{Version: 2, Revision: 3, ID: "2026-10-EMP-002", EmployeeID: "EMP-002", EmployeeName: "Nádia Putri", Department: "Engineering", Position: "Software Engineer", CompanyName: "PT MDM Indonesia (Contoh)", CompanyAddress: "Jl. Contoh No. 10, Jakarta Selatan\nDKI Jakarta, Indonesia", Period: "2026-10", BaseSalary: 8000000, Allowance: 1000000, Overtime: 200000, Bonus: 500000, GrossSalary: 9700000, PTKP: "TK/0", TaxCategory: "A", TaxRateBps: 200, PPh21: 194000, TaxMode: "auto", TaxReady: true, BPJSHealth: 80000, JHT: 160000, JP: 80000, Deductions: 514000, NetSalary: 9186000, Status: "Final", FinalizedBy: "Administrator HR", FinalizedAt: "2026-10-28T09:00:00+07:00"}
	b, err := document.Payslip(p)
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.HasPrefix(b, []byte("%PDF-")) {
		t.Fatal("not a PDF")
	}
	if path := os.Getenv("PDF_PREVIEW_PATH"); path != "" {
		if err = os.MkdirAll(filepath.Dir(path), 0700); err != nil {
			t.Fatal(err)
		}
		if err = os.WriteFile(path, b, 0600); err != nil {
			t.Fatal(err)
		}
	}
}
