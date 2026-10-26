package service

import (
	"bytes"
	"context"
	"encoding/base64"
	"errors"
	"hrismdm/backend/internal/domain"
	"hrismdm/backend/internal/testutil"
	"image"
	"image/jpeg"
	"math"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"
	"time"
)

type fakeFace struct{ allowed bool }

func (f *fakeFace) Available() bool { return true }
func (f *fakeFace) Enroll(context.Context, string, string) error {
	if !f.allowed {
		return errors.New("rejected")
	}
	return nil
}
func (f *fakeFace) Verify(context.Context, string, string) error {
	if !f.allowed {
		return errors.New("rejected")
	}
	return nil
}

var ctx = context.Background()

func setup(t *testing.T) (*App, domain.Actor, domain.Actor) {
	t.Helper()
	store := testutil.Store(t)
	a := New(store, &fakeFace{allowed: true})
	if err := a.Initialize(ctx, true); err != nil {
		t.Fatal(err)
	}
	if err := a.EnsureMasterData(ctx); err != nil {
		t.Fatal(err)
	}
	_, admin, err := a.Login(ctx, "admin@mdm.local", "DemoHris2026!")
	if err != nil {
		t.Fatal(err)
	}
	_, employee, err := a.Login(ctx, "nadia@mdm.local", "DemoHris2026!")
	if err != nil {
		t.Fatal(err)
	}
	return a, admin, employee
}
func must(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatal(err)
	}
}
func TestEmployeePrivacyAndSessionRevocation(t *testing.T) {
	a, admin, employee := setup(t)
	own, err := a.Employees(ctx, employee)
	must(t, err)
	if len(own) != 1 || own[0].ID != employee.EmployeeID {
		t.Fatal("employee sees other employee records")
	}
	if !errors.Is(a.SaveEmployee(ctx, employee, own[0]), ErrForbidden) {
		t.Fatal("employee can mutate HR")
	}
	if !errors.Is(a.GeneratePayroll(ctx, employee, "2026-10"), ErrForbidden) {
		t.Fatal("employee can generate payroll")
	}
	must(t, a.GeneratePayroll(ctx, admin, "2026-10"))
	payroll, err := a.Payroll(ctx, employee)
	must(t, err)
	if len(payroll) != 1 || payroll[0].EmployeeID != employee.EmployeeID {
		t.Fatal("payroll leaked")
	}
	token, _, err := a.Login(ctx, employee.Email, "DemoHris2026!")
	must(t, err)
	_, err = a.Authenticate(ctx, token)
	must(t, err)
	must(t, a.Logout(ctx, token))
	if _, err = a.Authenticate(ctx, token); err == nil {
		t.Fatal("revoked token accepted")
	}
}
func TestLeaveReviewAtomicAndCannotSelfApprove(t *testing.T) {
	a, admin, employee := setup(t)
	r := domain.Request{Kind: "Cuti", Title: "Cuti test", Description: "Keluarga", StartDate: "2027-01-04", EndDate: "2027-01-05"}
	must(t, a.SubmitRequest(ctx, employee, r))
	rows, err := a.Requests(ctx, employee)
	must(t, err)
	var id string
	for _, row := range rows {
		if row.Title == r.Title {
			id = row.ID
		}
	}
	if err = a.ReviewRequest(ctx, employee, id, "Disetujui", ""); !errors.Is(err, ErrForbidden) {
		t.Fatal("employee approved a request")
	}
	must(t, a.ReviewRequest(ctx, admin, id, "Disetujui", "ok"))
	if err = a.ReviewRequest(ctx, admin, id, "Disetujui", ""); err == nil {
		t.Fatal("double review accepted")
	}
	own, err := a.Employees(ctx, employee)
	must(t, err)
	if own[0].LeaveBalance != 10 {
		t.Fatalf("leave balance %d, want 10", own[0].LeaveBalance)
	}
	if a.SubmitRequest(ctx, admin, r) == nil {
		t.Fatal("root employee without a configured route submitted a request")
	}
	rows, err = a.Requests(ctx, admin)
	must(t, err)
	for _, row := range rows {
		if row.EmployeeID == admin.EmployeeID {
			if err = a.ReviewRequest(ctx, admin, row.ID, "Disetujui", ""); err == nil {
				t.Fatal("self approval accepted")
			}
		}
	}
}
func TestConcurrentStockCannotBecomeNegative(t *testing.T) {
	a, admin, _ := setup(t)
	var wg sync.WaitGroup
	results := make(chan error, 2)
	for i := 0; i < 2; i++ {
		wg.Add(1)
		writer := New(a.Store, a.Face) // independent service mutexes: PostgreSQL must serialize the writes.
		go func() { defer wg.Done(); results <- writer.AdjustStock(ctx, admin, "GA-001", -20, "issued") }()
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
		t.Fatalf("successful issues %d, want 1", success)
	}
	var item domain.Inventory
	must(t, a.Store.Get(ctx, "inventory", "GA-001", &item))
	if item.Stock != 4 {
		t.Fatalf("stock %d, want 4", item.Stock)
	}
	var movements []domain.StockMovement
	must(t, a.Store.List(ctx, "stock_movements", &movements))
	if len(movements) != 1 {
		t.Fatal("failed transaction left a movement")
	}
}
func TestPayrollDraftRefreshAndFinalLock(t *testing.T) {
	a, admin, employee := setup(t)
	r := domain.Request{Kind: "Reimbursement", Title: "Taxi", Description: "Client visit", Amount: 100000, StartDate: "2026-01-03", EndDate: "2026-01-03"}
	receipt, err := a.UploadReceipt(ctx, employee, "nota.pdf", []byte("%PDF-1.4\nfixture"))
	must(t, err)
	r.Items = []domain.ExpenseItem{{Date: "2026-01-02", Description: "Client visit", Category: "Transportasi", Amount: 100000, ReceiptID: receipt.ID}}
	must(t, a.SubmitRequest(ctx, employee, r))
	requests, err := a.Requests(ctx, employee)
	must(t, err)
	for _, row := range requests {
		if row.Title == "Taxi" {
			must(t, a.ReviewRequest(ctx, admin, row.ID, "Disetujui", ""))
			pending := requestByTitle(t, a, employee, r.Title)
			must(t, a.ReviewRequest(ctx, financeActor(t, a), row.ID, "Disetujui", "", pending.Revision))
		}
	}
	must(t, a.GeneratePayroll(ctx, admin, "2026-01"))
	must(t, a.GeneratePayroll(ctx, admin, "2026-01"))
	rows, err := a.Payroll(ctx, employee)
	must(t, err)
	if len(rows) != 1 || rows[0].Reimbursement != 0 {
		t.Fatal("reimbursement must be paid outside payroll")
	}
	p := rows[0]
	must(t, a.FinalizePayroll(ctx, admin, p.ID, p.Revision))
	if a.GeneratePayroll(ctx, admin, "2026-01") == nil {
		t.Fatal("final payroll overwritten")
	}
	if a.FinalizePayroll(ctx, admin, p.ID, 0) == nil {
		t.Fatal("final slip mutable")
	}
	rows, err = a.Payroll(ctx, employee)
	must(t, err)
	if rows[0].NetSalary != p.GrossSalary-p.PPh21-p.BPJSHealth-p.JHT-p.JP {
		t.Fatal("deduction mismatch")
	}
}
func photo(t *testing.T) string {
	t.Helper()
	var b bytes.Buffer
	must(t, jpeg.Encode(&b, image.NewRGBA(image.Rect(0, 0, 320, 320)), nil))
	return "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(b.Bytes())
}
func TestAttendanceGeofenceFaceAndDuplicate(t *testing.T) {
	a, admin, employee := setup(t)
	var all []domain.Attendance
	must(t, a.Store.List(ctx, "attendance", &all))
	for _, row := range all {
		must(t, a.Store.Delete(ctx, "attendance", row.ID))
	}
	settings, err := a.Settings(ctx)
	must(t, err)
	must(t, a.Enroll(ctx, admin, employee.EmployeeID, photo(t)))
	p := Punch{Type: "in", Latitude: settings.Latitude, Longitude: settings.Longitude, Accuracy: 5, Photo: photo(t)}
	bad := p
	bad.Latitude += .002
	if a.Punch(ctx, employee, bad) == nil {
		t.Fatal("outside radius accepted")
	}
	bad = p
	bad.Accuracy = 51
	if a.Punch(ctx, employee, bad) == nil {
		t.Fatal("poor accuracy accepted")
	}
	a.Face = &fakeFace{allowed: false}
	if a.Punch(ctx, employee, p) == nil {
		t.Fatal("face mismatch accepted")
	}
	a.Face = &fakeFace{allowed: true}
	must(t, a.Punch(ctx, employee, p))
	if a.Punch(ctx, employee, p) == nil {
		t.Fatal("double check-in accepted")
	}
	p.Type = "out"
	must(t, a.Punch(ctx, employee, p))
	if a.Punch(ctx, employee, p) == nil {
		t.Fatal("double checkout accepted")
	}
	rows, err := a.Attendance(ctx, employee)
	must(t, err)
	if len(rows) != 1 || !rows[0].FaceVerified || rows[0].CheckOut == "" {
		t.Fatal("attendance not persisted")
	}
	if math.Abs(DistanceMeters(0, 0, 0, .001)-111.195) > 0.1 {
		t.Fatal("geofence formula incorrect")
	}
}
func TestFaceProviderFailsClosed(t *testing.T) {
	f := &HTTPFaceProvider{Client: &http.Client{Timeout: time.Second}}
	if f.Verify(ctx, "emp", "photo") == nil {
		t.Fatal("unconfigured provider accepted")
	}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer secret" {
			t.Error("provider key missing")
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"success":true,"matched":true,"live":false}`))
	}))
	defer srv.Close()
	f.URL = srv.URL
	f.Key = "secret"
	if f.Verify(ctx, "emp", "photo") == nil {
		t.Fatal("liveness failure accepted")
	}
}
func TestAccountEmailTracksEmployeeAndProvisionRole(t *testing.T) {
	a, admin, employee := setup(t)
	rows, err := a.Employees(ctx, employee)
	must(t, err)
	emp := rows[0]
	emp.Email = "new@mdm.local"
	must(t, a.SaveEmployee(ctx, admin, emp))
	if _, _, err = a.Login(ctx, emp.Email, "DemoHris2026!"); err != nil {
		t.Fatal("updated email cannot log in")
	}
	var third domain.Employee
	must(t, a.Store.Get(ctx, "employees", "EMP-003", &third))
	must(t, a.Provision(ctx, admin, third.ID, "StrongPassword2026!", "admin"))
	_, actor, err := a.Login(ctx, third.Email, "StrongPassword2026!")
	must(t, err)
	if actor.Role != "admin" {
		t.Fatal("provisioned wrong role")
	}
}
