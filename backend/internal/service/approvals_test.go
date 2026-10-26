package service

import (
	"errors"
	"hrismdm/backend/internal/domain"
	"sync"
	"testing"
)

func expenseFixture(t *testing.T, a *App, employee domain.Actor) domain.Request {
	t.Helper()
	file, err := a.UploadReceipt(ctx, employee, "nota.pdf", []byte("%PDF-1.4\nfixture"))
	must(t, err)
	return domain.Request{Kind: "Reimbursement", Title: "Parkir dan e-money", Description: "Kunjungan kantor", StartDate: "2026-01-02", EndDate: "2026-01-02", Amount: 1,
		Items: []domain.ExpenseItem{{Date: "2026-01-02", Description: "Parkir", Category: "Transportasi", Amount: 15000, ReceiptID: file.ID}, {Date: "2026-01-02", Description: "Top up e-money kantor", Category: "Transportasi", Amount: 100000, ReceiptID: file.ID}}}
}
func requestByTitle(t *testing.T, a *App, actor domain.Actor, title string) domain.Request {
	t.Helper()
	rows, err := a.Requests(ctx, actor)
	must(t, err)
	for _, r := range rows {
		if r.Title == title {
			return r
		}
	}
	t.Fatal("request missing")
	return domain.Request{}
}
func financeActor(t *testing.T, a *App) domain.Actor {
	t.Helper()
	_, f, err := a.Login(ctx, "karyawan15@mdm.local", "DemoHris2026!")
	must(t, err)
	return f
}
func TestReimbursementApprovalFinanceSnapshotsAndPrivacy(t *testing.T) {
	a, lead, employee := setup(t)
	finance := financeActor(t, a)
	input := expenseFixture(t, a, employee)
	must(t, a.SubmitRequest(ctx, employee, input))
	r := requestByTitle(t, a, employee, input.Title)
	if r.Amount != 115000 || len(r.Steps) != 2 || r.Snapshot.BankAccountNumber == "" {
		t.Fatal("total/route/snapshot missing")
	}
	if _, err := a.ReimbursementDocument(ctx, employee, r.ID); err == nil {
		t.Fatal("early document available")
	}
	if !errors.Is(a.ReviewRequest(ctx, finance, r.ID, "Disetujui", "", r.Revision), ErrForbidden) {
		t.Fatal("finance bypassed manager")
	}
	if !errors.Is(a.ReviewRequest(ctx, employee, r.ID, "Disetujui", "", r.Revision), ErrForbidden) {
		t.Fatal("self approval accepted")
	}
	must(t, a.ReviewRequest(ctx, lead, r.ID, "Disetujui", "setuju", r.Revision))
	r = requestByTitle(t, a, employee, input.Title)
	if r.Status != "Menunggu" || r.CurrentStep != 1 {
		t.Fatal("manager finalized reimbursement")
	}
	var e domain.Employee
	must(t, a.Store.Get(ctx, "employees", employee.EmployeeID, &e))
	e.BankAccountNumber = "999999"
	e.Name = "Nama berubah"
	must(t, a.SaveEmployee(ctx, lead, e))
	must(t, a.ReviewRequest(ctx, finance, r.ID, "Disetujui", "lengkap", r.Revision))
	final, err := a.ReimbursementDocument(ctx, employee, r.ID)
	must(t, err)
	workbook, err := a.ReimbursementFile(ctx, employee, r.ID, "xlsx")
	must(t, err)
	if len(workbook) < 10000 {
		t.Fatal("final workbook was not frozen")
	}
	if final.Snapshot.Name == e.Name || final.Snapshot.BankAccountNumber == e.BankAccountNumber || final.FinalizedAt == "" {
		t.Fatal("historical snapshot mutated")
	}
	outsider := domain.Actor{EmployeeID: "EMP-004", Role: "employee"}
	if _, err := a.ReimbursementDocument(ctx, outsider, r.ID); !errors.Is(err, ErrForbidden) {
		t.Fatal("document leaked")
	}
	if _, err := a.RequestReceipt(ctx, outsider, r.ID, input.Items[0].ReceiptID); !errors.Is(err, ErrForbidden) {
		t.Fatal("receipt leaked")
	}
	f, err := a.RequestReceipt(ctx, finance, r.ID, input.Items[0].ReceiptID)
	must(t, err)
	if len(f.Data) == 0 {
		t.Fatal("receipt bytes missing")
	}
	own, err := a.Employees(ctx, finance)
	must(t, err)
	if len(own) != 1 || own[0].ID != finance.EmployeeID {
		t.Fatal("finance sees other employee payroll profile")
	}
}
func TestRevisionRestartsApprovalsAndStaleActionsFail(t *testing.T) {
	a, lead, employee := setup(t)
	input := expenseFixture(t, a, employee)
	must(t, a.SubmitRequest(ctx, employee, input))
	r := requestByTitle(t, a, employee, input.Title)
	if a.ReviewRequest(ctx, lead, r.ID, "Disetujui", "", r.Revision+1) == nil {
		t.Fatal("stale revision accepted")
	}
	if a.ReviewRequest(ctx, lead, r.ID, "Perlu revisi", "", r.Revision) == nil {
		t.Fatal("revision without reason accepted")
	}
	must(t, a.ReviewRequest(ctx, lead, r.ID, "Perlu revisi", "Perbaiki rincian", r.Revision))
	r = requestByTitle(t, a, employee, input.Title)
	input.ID = r.ID
	input.Revision = r.Revision
	input.Items[0].Amount = 20000
	must(t, a.SubmitRequest(ctx, employee, input))
	r = requestByTitle(t, a, employee, input.Title)
	if r.Status != "Menunggu" || r.CurrentStep != 0 || len(r.Steps[0].Decisions) != 0 || len(r.History) < 3 || r.Amount != 120000 {
		t.Fatal("resubmission did not restart approval with audit")
	}
}
func TestMultipleApproversAllAnyAndManagerOwnRoute(t *testing.T) {
	for _, mode := range []string{"all", "any"} {
		t.Run(mode, func(t *testing.T) {
			a, admin, employee := setup(t)
			finance := financeActor(t, a)
			must(t, a.Provision(ctx, admin, "EMP-004", "TestPassword2026!", "employee"))
			_, manager, err := a.Login(ctx, "karyawan4@mdm.local", "TestPassword2026!")
			must(t, err)
			policy := domain.ApprovalPolicy{ID: "Cuti", Stages: []domain.ApprovalStage{{Name: "Dua peninjau", Source: "employees", Mode: mode, EmployeeIDs: []string{admin.EmployeeID, manager.EmployeeID}}}}
			must(t, a.SaveApprovalPolicy(ctx, admin, policy))
			r := domain.Request{Kind: "Cuti", Title: "Cuti berlapis", Description: "Keluarga", StartDate: "2027-03-01", EndDate: "2027-03-02"}
			must(t, a.SubmitRequest(ctx, employee, r))
			saved := requestByTitle(t, a, employee, r.Title)
			must(t, a.ReviewRequest(ctx, manager, saved.ID, "Disetujui", "", saved.Revision))
			saved = requestByTitle(t, a, employee, r.Title)
			var e domain.Employee
			must(t, a.Store.Get(ctx, "employees", employee.EmployeeID, &e))
			if mode == "all" {
				if saved.Status != "Menunggu" || e.LeaveBalance != 12 {
					t.Fatal("all approved prematurely")
				}
				must(t, a.ReviewRequest(ctx, admin, saved.ID, "Disetujui", "", saved.Revision))
			} else if saved.Status != "Disetujui" {
				t.Fatal("any did not finish")
			}
			_ = finance
			// A lead's own request is assigned above them, using the same employee identity.
			var top domain.Employee
			must(t, a.Store.Get(ctx, "employees", manager.EmployeeID, &top))
			top.ManagerID = ""
			must(t, a.SaveEmployee(ctx, admin, top))
			var lead domain.Employee
			must(t, a.Store.Get(ctx, "employees", admin.EmployeeID, &lead))
			lead.ManagerID = manager.EmployeeID
			must(t, a.SaveEmployee(ctx, admin, lead))
			must(t, a.SaveApprovalPolicy(ctx, admin, defaultPolicy("Cuti")))
			r.Title = "Cuti lead"
			must(t, a.SubmitRequest(ctx, admin, r))
			saved = requestByTitle(t, a, admin, r.Title)
			if saved.Steps[0].Approvers[0].EmployeeID != manager.EmployeeID {
				t.Fatal("lead did not route above")
			}
			if a.SaveEmployee(ctx, admin, domain.Employee{}) == nil {
				t.Fatal("invalid employee saved")
			}
		})
	}
}
func TestApprovalConcurrencyAndValidation(t *testing.T) {
	a, lead, employee := setup(t)
	input := expenseFixture(t, a, employee)
	bad := input
	bad.Items = append([]domain.ExpenseItem{}, input.Items...)
	bad.Items[0].ReceiptID = "unowned"
	if a.SubmitRequest(ctx, employee, bad) == nil {
		t.Fatal("unowned evidence accepted")
	}
	bad.Items[0] = input.Items[0]
	bad.Items[0].Date = "2099-01-01"
	if a.SubmitRequest(ctx, employee, bad) == nil {
		t.Fatal("future expense accepted")
	}
	must(t, a.SubmitRequest(ctx, employee, input))
	r := requestByTitle(t, a, employee, input.Title)
	var wg sync.WaitGroup
	results := make(chan error, 2)
	for i := 0; i < 2; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			results <- New(a.Store, a.Face).ReviewRequest(ctx, lead, r.ID, "Disetujui", "", r.Revision)
		}()
	}
	wg.Wait()
	close(results)
	success := 0
	for err := range results {
		if err == nil {
			success++
		}
	}
	if success != 1 {
		t.Fatal("concurrent approval was not serialized")
	}
	var root domain.Employee
	must(t, a.Store.Get(ctx, "employees", lead.EmployeeID, &root))
	root.ManagerID = employee.EmployeeID
	if a.SaveEmployee(ctx, lead, root) == nil {
		t.Fatal("hierarchy cycle accepted")
	}
}
