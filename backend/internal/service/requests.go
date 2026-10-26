package service

import (
	"context"
	"errors"
	"hrismdm/backend/internal/document"
	"hrismdm/backend/internal/domain"
	"sort"
	"strings"
	"time"
)

func (a *App) Requests(ctx context.Context, actor domain.Actor) ([]domain.Request, error) {
	var all []domain.Request
	if err := a.Store.List(ctx, "requests", &all); err != nil {
		return nil, err
	}
	out := []domain.Request{}
	for _, r := range all {
		if canSeeRequest(actor, r) {
			r.Unread = false
			r.CanReview = canReviewRequest(actor, r)
			r.CanDownload = r.Version >= 2 && r.Kind == "Reimbursement" && r.Status == "Disetujui" && r.FinalizedAt != ""
			r.PendingWith = pendingWith(r)
			r.UpdateToken = requestUpdateToken(r)
			if r.EmployeeID == actor.EmployeeID && requestHasUpdate(r) {
				var seen map[string]string
				if err := a.Store.Get(ctx, "request_seen", actor.ID+"/"+r.ID, &seen); err != nil || seen["token"] != r.UpdateToken {
					r.Unread = true
				}
			}
			out = append(out, r)
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].CreatedAt > out[j].CreatedAt })
	return out, nil
}
func (a *App) SubmitRequest(ctx context.Context, actor domain.Actor, input domain.Request) error {
	if !requestKinds[input.Kind] || strings.TrimSpace(input.Title) == "" || len(input.Title) > 160 || strings.TrimSpace(input.Description) == "" || len(input.Description) > 3000 {
		return errors.New("jenis, judul (maks. 160), dan keperluan (maks. 3000) wajib diisi")
	}
	if len(input.Items) > 150 {
		return errors.New("maksimal 150 rincian per pengajuan")
	}
	start, err := time.Parse("2006-01-02", input.StartDate)
	if err != nil {
		return errors.New("tanggal mulai wajib diisi")
	}
	end, err := time.Parse("2006-01-02", input.EndDate)
	if err != nil || end.Before(start) {
		return errors.New("tanggal selesai tidak valid")
	}
	if err = money(input.Amount); err != nil {
		return err
	}
	if input.Kind == "Lembur" && (input.Hours <= 0 || input.Hours > 24 || input.StartDate != input.EndDate) {
		return errors.New("lembur 0–24 jam, satu tanggal per pengajuan")
	}
	if input.Kind == "Petty Cash" && input.Amount <= 0 {
		return errors.New("nominal harus lebih dari nol")
	}
	return a.write(ctx, func(s domain.Store) error {
		var emp domain.Employee
		if err := s.Get(ctx, "employees", actor.EmployeeID, &emp); err != nil {
			return err
		}
		if emp.Status == "Nonaktif" {
			return ErrForbidden
		}
		r := domain.Request{ID: ID(), Version: 2, Revision: 1, EmployeeID: emp.ID, EmployeeName: emp.Name, Kind: input.Kind, Title: strings.TrimSpace(input.Title), Description: strings.TrimSpace(input.Description), StartDate: input.StartDate, EndDate: input.EndDate, Amount: input.Amount, Hours: input.Hours, CreatedAt: now(), Status: "Menunggu", History: []domain.ApprovalEvent{}}
		if input.ID != "" {
			var old domain.Request
			if s.Get(ctx, "requests", input.ID, &old) != nil || old.EmployeeID != actor.EmployeeID {
				return ErrForbidden
			}
			if old.Status != "Perlu revisi" || old.Version != 2 {
				return errors.New("hanya pengajuan yang diminta revisi dapat dikirim ulang")
			}
			if input.Revision != old.Revision {
				return errors.New("pengajuan berubah; segarkan data sebelum mengirim ulang")
			}
			r.ID = old.ID
			r.CreatedAt = old.CreatedAt
			r.Revision = old.Revision + 1
			r.History = old.History
		}
		settings := domain.Settings{}
		if err := s.Get(ctx, "settings", "company", &settings); err != nil {
			return err
		}
		r.Snapshot = domain.RequestSnapshot{EmployeeID: emp.ID, Name: emp.Name, Department: emp.Department, Position: emp.Position, Phone: emp.Phone, BankName: emp.BankName, BankAccountName: emp.BankAccountName, BankAccountNumber: emp.BankAccountNumber, SubmittedAt: now(), Timezone: settings.Timezone, TemplateVersion: "mdm-reimburse-v1"}
		if r.Kind == "Reimbursement" {
			if emp.BankName == "" || emp.BankAccountName == "" || emp.BankAccountNumber == "" || emp.Phone == "" {
				return errors.New("data rekening dan telepon belum lengkap. Hubungi HR sebelum mengajukan reimbursement")
			}
			if len(input.Items) == 0 {
				return errors.New("tambahkan rincian dan bukti pengeluaran")
			}
			r.Amount = 0
			r.Hours = 0
			r.Items = input.Items
			today := time.Now().UTC().Format("2006-01-02")
			if zone, e := time.LoadLocation(settings.Timezone); e == nil {
				today = time.Now().In(zone).Format("2006-01-02")
			}
			for _, item := range r.Items {
				if _, err := time.Parse("2006-01-02", item.Date); err != nil || item.Date > today {
					return errors.New("tanggal transaksi tidak valid atau di masa depan")
				}
				if domain.ExpenseLineUnits(item) > 15 {
					return errors.New("deskripsi terlalu panjang untuk template; ringkas deskripsi atau pisahkan rincian")
				}
				if strings.TrimSpace(item.Description) == "" || len(item.Description) > 500 || strings.TrimSpace(item.Category) == "" || len(item.Category) > 80 || item.Amount <= 0 || money(item.Amount) != nil {
					return errors.New("tanggal, deskripsi, kategori, dan nominal rincian wajib valid")
				}
				var receipt domain.RequestReceipt
				if s.Get(ctx, "request_receipts", item.ReceiptID, &receipt) != nil || receipt.EmployeeID != emp.ID {
					return errors.New("setiap rincian wajib memiliki bukti transaksi milik pemohon")
				}
				r.Amount += item.Amount
				if money(r.Amount) != nil {
					return errors.New("total klaim melebihi batas nominal")
				}
			}
			r.StartDate = r.Items[0].Date
			r.EndDate = r.Items[0].Date
			for _, item := range r.Items {
				if item.Date < r.StartDate {
					r.StartDate = item.Date
				}
				if item.Date > r.EndDate {
					r.EndDate = item.Date
				}
			}
		}
		if r.Kind == "Cuti" {
			r.Amount = 0
			r.Hours = 0
			r.Days = int(end.Sub(start).Hours()/24) + 1
			if r.Days > emp.LeaveBalance {
				return errors.New("saldo cuti tidak cukup")
			}
		}
		steps, err := resolveSteps(ctx, s, emp, r.Kind)
		if err != nil {
			return err
		}
		r.Steps = steps
		r.History = append(r.History, domain.ApprovalEvent{Revision: r.Revision, Step: -1, EmployeeID: emp.ID, Name: emp.Name, Decision: "Diajukan", At: r.Snapshot.SubmittedAt})
		if err := s.Put(ctx, "requests", r.ID, r); err != nil {
			return err
		}
		return audit(ctx, s, actor, "request.submit", r.ID)
	})
}
func (a *App) ReviewRequest(ctx context.Context, actor domain.Actor, id, status, note string, expected ...int) error {
	if status != "Disetujui" && status != "Ditolak" && status != "Perlu revisi" {
		return errors.New("keputusan tidak valid")
	}
	if len(note) > 2000 || (status != "Disetujui" && strings.TrimSpace(note) == "") {
		return errors.New("catatan wajib diisi untuk penolakan/revisi (maksimal 2000 karakter)")
	}
	return a.write(ctx, func(s domain.Store) error {
		var r domain.Request
		if s.Get(ctx, "requests", id, &r) != nil {
			return errors.New("pengajuan tidak ditemukan")
		}
		if !canReviewRequest(actor, r) {
			return ErrForbidden
		}
		if r.Version < 2 && status == "Perlu revisi" {
			return errors.New("pengajuan lama hanya dapat disetujui atau ditolak; gunakan pengajuan baru untuk formulir dan alur terbaru")
		}
		if r.Version >= 2 && len(expected) > 0 && expected[0] != r.Revision {
			return errors.New("pengajuan sudah berubah; segarkan data sebelum memutuskan")
		}
		var reviewer domain.Employee
		if s.Get(ctx, "employees", actor.EmployeeID, &reviewer) != nil || reviewer.Status == "Nonaktif" {
			return ErrForbidden
		}
		if r.Version >= 2 && r.Steps[r.CurrentStep].Source == "finance" && !reviewer.FinanceVerifier {
			return ErrForbidden
		}
		final := status == "Disetujui"
		if r.Version >= 2 {
			step := &r.Steps[r.CurrentStep]
			event := domain.ApprovalEvent{Revision: r.Revision, Step: r.CurrentStep, EmployeeID: actor.EmployeeID, Name: reviewer.Name, Decision: status, Note: note, At: now()}
			step.Decisions = append(step.Decisions, event)
			r.History = append(r.History, event)
			if status == "Disetujui" {
				done := step.Mode == "any" || len(step.Decisions) == len(step.Approvers)
				if done {
					step.Status = "Disetujui"
					r.CurrentStep++
				}
				final = done && r.CurrentStep == len(r.Steps)
				if !final {
					status = "Menunggu"
				}
			} else {
				step.Status = status
			}
		}
		if final && r.Kind == "Cuti" {
			if err := approveLeave(ctx, s, &r); err != nil {
				return err
			}
		}
		r.Status = status
		r.ReviewedBy = reviewer.Name
		r.ReviewNote = note
		r.Revision++
		r.CanReview = false
		r.CanDownload = false
		if final && r.Version >= 2 {
			r.FinalizedAt = now()
			if r.Kind == "Reimbursement" {
				workbook, err := document.Reimbursement(r)
				if err != nil {
					return err
				}
				if err = s.Put(ctx, "request_documents", r.ID, domain.RequestDocument{ID: r.ID, Workbook: workbook}); err != nil {
					return err
				}
			}
		}
		if err := s.Put(ctx, "requests", id, r); err != nil {
			return err
		}
		return audit(ctx, s, actor, "request."+status, id)
	})
}
func approveLeave(ctx context.Context, s domain.Store, r *domain.Request) error {
	var emp domain.Employee
	if err := s.Get(ctx, "employees", r.EmployeeID, &emp); err != nil {
		return err
	}
	if emp.LeaveBalance < r.Days {
		return errors.New("saldo cuti tidak cukup")
	}
	var requests []domain.Request
	if err := s.List(ctx, "requests", &requests); err != nil {
		return err
	}
	for _, other := range requests {
		if other.ID != r.ID && other.EmployeeID == r.EmployeeID && other.Kind == "Cuti" && other.Status == "Disetujui" && r.StartDate <= other.EndDate && r.EndDate >= other.StartDate {
			return errors.New("tanggal cuti bertumpang tindih")
		}
	}
	emp.LeaveBalance -= r.Days
	return s.Put(ctx, "employees", emp.ID, emp)
}
