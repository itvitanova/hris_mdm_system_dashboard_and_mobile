package service

import (
	"bytes"
	"errors"
	"github.com/xuri/excelize/v2"
	"hrismdm/backend/internal/domain"
	"testing"
	"time"
)

func TestEarlyDepartureRequiresReasonAndPreservesSchedule(t *testing.T) {
	zone, _ := time.LoadLocation("Asia/Jakarta")
	at := time.Date(2026, 10, 25, 17, 15, 0, 0, zone)
	policy := domain.AttendancePolicy{ServicePoint: domain.ServicePoint{WorkStart: "09:00", WorkEnd: "18:00"}}
	row := domain.Attendance{Date: "2026-10-25"}
	if applyDeparture(&row, at, policy, "") == nil {
		t.Fatal("early departure accepted without a reason")
	}
	must(t, applyDeparture(&row, at, policy, "Keperluan keluarga"))
	if !row.EarlyDeparture || row.EarlyMinutes != 45 || row.EarlyReason != "Keperluan keluarga" || row.ScheduledEnd != "2026-10-25T18:00:00+07:00" {
		t.Fatalf("incorrect departure: %+v", row)
	}
	row = domain.Attendance{Date: "2026-10-25"}
	must(t, applyDeparture(&row, at.Add(time.Hour), policy, ""))
	if row.EarlyDeparture {
		t.Fatal("late checkout classified as early")
	}
	policy.WorkEnd = ""
	row = domain.Attendance{}
	must(t, applyDeparture(&row, at, policy, ""))
	if row.ScheduledEnd != "" {
		t.Fatal("legacy schedule guessed")
	}
}

func TestEmployeeImportAtomicPreviewAndTextExport(t *testing.T) {
	a, admin, actor := setup(t)
	before, err := a.Employees(ctx, admin)
	must(t, err)
	var staff domain.Employee
	must(t, a.Store.Get(ctx, "employees", actor.EmployeeID, &staff))
	var dept, pos domain.MasterData
	must(t, a.Store.Get(ctx, "master_departments", staff.DepartmentID, &dept))
	must(t, a.Store.Get(ctx, "master_positions", staff.PositionID, &pos))
	workbook, err := a.EmployeeWorkbook(ctx, admin, true)
	must(t, err)
	f, err := excelize.OpenReader(bytes.NewReader(workbook))
	must(t, err)
	defer f.Close()
	values := []any{"000123", "Import User", "import-user@example.test", dept.Code, pos.Code, "HQ", "PKWT", "Aktif", "0812345678", "Jakarta", "1990-01-01", "2026-10-25", 7000000, "TK/0", 12, "Bank Test", "Import User", "0000123456", "", "TIDAK", "TIDAK"}
	must(t, f.SetSheetRow("Karyawan", "A2", &values))
	buf, err := f.WriteToBuffer()
	must(t, err)
	result, err := a.ImportEmployees(ctx, admin, buf.Bytes(), false)
	must(t, err)
	if !result.Valid || result.Imported != 0 {
		t.Fatalf("preview: %+v", result)
	}
	after, err := a.Employees(ctx, admin)
	must(t, err)
	if len(after) != len(before) {
		t.Fatal("preview persisted employee")
	}
	bad := append([]any{}, values...)
	bad[0] = "000124"
	bad[2] = "invalid-email"
	must(t, f.SetSheetRow("Karyawan", "A3", &bad))
	buf, err = f.WriteToBuffer()
	must(t, err)
	result, err = a.ImportEmployees(ctx, admin, buf.Bytes(), true)
	must(t, err)
	if result.Valid || result.Imported != 0 || result.Rows[1].Error == "" {
		t.Fatalf("partial invalid import: %+v", result)
	}
	after, err = a.Employees(ctx, admin)
	must(t, err)
	if len(after) != len(before) {
		t.Fatal("failed batch partially persisted")
	}
	must(t, f.RemoveRow("Karyawan", 3))
	must(t, f.SetCellStr("Karyawan", "N2", ""))
	buf, err = f.WriteToBuffer()
	must(t, err)
	result, err = a.ImportEmployees(ctx, admin, buf.Bytes(), true)
	must(t, err)
	if result.Valid || result.Imported != 0 || result.Rows[0].Error != "status PTKP wajib diisi" {
		t.Fatal("missing PTKP accepted", result)
	}
	must(t, f.SetCellStr("Karyawan", "N2", "TK/0"))
	buf, err = f.WriteToBuffer()
	must(t, err)
	result, err = a.ImportEmployees(ctx, admin, buf.Bytes(), true)
	must(t, err)
	if result.Imported != 1 {
		t.Fatalf("commit: %+v", result)
	}
	exported, err := a.EmployeeWorkbook(ctx, admin, false)
	must(t, err)
	out, err := excelize.OpenReader(bytes.NewReader(exported))
	must(t, err)
	defer out.Close()
	rows, err := out.GetRows("Karyawan")
	must(t, err)
	found := false
	for _, r := range rows[1:] {
		if r[0] == "000123" {
			found = true
			if r[17] != "0000123456" || r[13] != "TK/0" || r[6] != "PKWT" {
				t.Fatal("text fields or employment type changed")
			}
		}
	}
	if !found {
		t.Fatal("export omitted imported employee")
	}
	if _, err = a.EmployeeWorkbook(ctx, actor, false); !errors.Is(err, ErrForbidden) {
		t.Fatal("employee exported all employee data")
	}
}

func TestCalendarAndReadStateAreScopedToEmployee(t *testing.T) {
	a, admin, actor := setup(t)
	var person domain.Employee
	must(t, a.Store.Get(ctx, "employees", actor.EmployeeID, &person))
	var peer domain.Employee
	must(t, a.Store.Get(ctx, "employees", "EMP-003", &peer))
	entry := domain.Request{ID: "CALENDAR", EmployeeID: peer.ID, EmployeeName: peer.Name, Kind: "Cuti", Status: "Disetujui", StartDate: "2026-10-24", EndDate: "2026-10-27", Description: "Private health information"}
	must(t, a.Store.Put(ctx, "requests", entry.ID, entry))
	list, err := a.LeaveCalendar(ctx, actor, "2026-10")
	must(t, err)
	found := false
	for _, r := range list {
		if r.RequestID == entry.ID {
			found = true
		}
	}
	if !found {
		t.Fatal("approved colleague leave missing")
	}
	peer.ServicePointID = "OTHER"
	must(t, a.Store.Put(ctx, "employees", peer.ID, peer))
	list, err = a.LeaveCalendar(ctx, actor, "2026-10")
	must(t, err)
	for _, r := range list {
		if r.RequestID == entry.ID {
			t.Fatal("other location exposed")
		}
	}
	r := domain.Request{ID: "UPDATES", EmployeeID: actor.EmployeeID, Status: "Perlu revisi", Revision: 2, ReviewedBy: "Lead", History: []domain.ApprovalEvent{{Decision: "Perlu revisi", At: "2026-10-25T10:00:00Z"}}}
	must(t, a.Store.Put(ctx, "requests", r.ID, r))
	rows, err := a.Requests(ctx, actor)
	must(t, err)
	var token string
	for _, v := range rows {
		if v.ID == r.ID {
			if !v.Unread {
				t.Fatal("revision not unread")
			}
			token = v.UpdateToken
		}
	}
	must(t, a.MarkRequestSeen(ctx, actor, r.ID, token))
	rows, err = a.Requests(ctx, actor)
	must(t, err)
	for _, v := range rows {
		if v.ID == r.ID && v.Unread {
			t.Fatal("read state not saved")
		}
	}
	if err = a.MarkRequestSeen(ctx, admin, r.ID, token); !errors.Is(err, ErrForbidden) {
		t.Fatal("another user acknowledged employee notification")
	}
	r.Revision++
	must(t, a.Store.Put(ctx, "requests", r.ID, r))
	must(t, a.MarkRequestSeen(ctx, actor, r.ID, token))
	rows, err = a.Requests(ctx, actor)
	must(t, err)
	for _, v := range rows {
		if v.ID == r.ID && !v.Unread {
			t.Fatal("stale acknowledgement hid newer update")
		}
	}
}

func TestPendingWithMovesFromLeadToFinance(t *testing.T) {
	r := domain.Request{Status: "Menunggu", CurrentStep: 1, Steps: []domain.ApprovalStep{{Source: "manager", Status: "Disetujui", Approvers: []domain.Approver{{Name: "Aries"}}}, {Source: "finance", Approvers: []domain.Approver{{Name: "Alicia"}}}}}
	if got := pendingWith(r); got != "Menunggu verifikasi finance · Alicia" {
		t.Fatal(got)
	}
}

func TestUnsubmittedReceiptPreviewIsOwnerOnly(t *testing.T) {
	a, admin, actor := setup(t)
	f := domain.RequestReceipt{ID: "PRIVATE-PROOF", EmployeeID: actor.EmployeeID, ContentType: "image/png", Data: []byte("private-test")}
	must(t, a.Store.Put(ctx, "request_receipts", f.ID, f))
	file, err := a.OwnReceipt(ctx, actor, f.ID)
	must(t, err)
	if string(file.Data) != "private-test" {
		t.Fatal("proof changed")
	}
	if _, err = a.OwnReceipt(ctx, admin, f.ID); !errors.Is(err, ErrForbidden) {
		t.Fatal("unsubmitted proof exposed to another employee")
	}
}

func TestLegacySharedPositionSplitsByDepartmentAndRemainsStable(t *testing.T) {
	a, admin, actor := setup(t)
	var manager, staff domain.Employee
	must(t, a.Store.Get(ctx, "employees", admin.EmployeeID, &manager))
	must(t, a.Store.Get(ctx, "employees", actor.EmployeeID, &staff))
	staff.PositionID = manager.PositionID
	staff.Position = manager.Position
	must(t, a.Store.Put(ctx, "employees", staff.ID, staff))
	must(t, a.EnsureMasterData(ctx))
	must(t, a.Store.Get(ctx, "employees", staff.ID, &staff))
	if staff.PositionID == manager.PositionID {
		t.Fatal("shared position was not split")
	}
	var position domain.MasterData
	must(t, a.Store.Get(ctx, "master_positions", staff.PositionID, &position))
	if position.DepartmentID != staff.DepartmentID || position.Name != manager.Position {
		t.Fatal("position relationship lost")
	}
	before, err := a.MasterData(ctx, admin, "positions")
	must(t, err)
	must(t, a.EnsureMasterData(ctx))
	after, err := a.MasterData(ctx, admin, "positions")
	must(t, err)
	if len(before) != len(after) {
		t.Fatal("position migration is not idempotent")
	}
}
