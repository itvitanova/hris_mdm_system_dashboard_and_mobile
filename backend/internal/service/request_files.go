package service

import (
	"context"
	"errors"
	"hrismdm/backend/internal/document"
	"hrismdm/backend/internal/domain"
	"net/http"
	"strings"
)

// Unsubmitted attachments can be previewed only by their owner.
func (a *App) OwnReceipt(ctx context.Context, actor domain.Actor, id string) (domain.RequestReceipt, error) {
	var receipt domain.RequestReceipt
	if a.Store.Get(ctx, "request_receipts", id, &receipt) != nil || receipt.EmployeeID != actor.EmployeeID {
		return receipt, ErrForbidden
	}
	return receipt, nil
}

func (a *App) UploadReceipt(ctx context.Context, actor domain.Actor, name string, data []byte) (domain.RequestReceipt, error) {
	receipt := domain.RequestReceipt{}
	if len(data) == 0 || len(data) > 2*1024*1024 || len(name) > 160 {
		return receipt, errors.New("bukti transaksi maksimal 2 MB per file")
	}
	mime := http.DetectContentType(data)
	if mime != "image/jpeg" && mime != "image/png" && mime != "application/pdf" {
		return receipt, errors.New("bukti harus berupa JPEG, PNG, atau PDF")
	}
	name = strings.ReplaceAll(strings.ReplaceAll(name, "\\", "_"), "/", "_")
	receipt = domain.RequestReceipt{ID: ID(), EmployeeID: actor.EmployeeID, Name: name, ContentType: mime, Data: data}
	err := a.write(ctx, func(s domain.Store) error {
		var emp domain.Employee
		if s.Get(ctx, "employees", actor.EmployeeID, &emp) != nil || emp.Status == "Nonaktif" {
			return ErrForbidden
		}
		if err := s.Put(ctx, "request_receipts", receipt.ID, receipt); err != nil {
			return err
		}
		return audit(ctx, s, actor, "receipt.upload", receipt.ID)
	})
	receipt.Data = nil
	return receipt, err
}
func (a *App) RequestReceipt(ctx context.Context, actor domain.Actor, id, receiptID string) (domain.RequestReceipt, error) {
	var r domain.Request
	var f domain.RequestReceipt
	if a.Store.Get(ctx, "requests", id, &r) != nil || !canSeeRequest(actor, r) {
		return f, ErrForbidden
	}
	linked := false
	for _, i := range r.Items {
		if i.ReceiptID == receiptID {
			linked = true
		}
	}
	if !linked {
		return f, ErrForbidden
	}
	err := a.Store.Get(ctx, "request_receipts", receiptID, &f)
	return f, err
}
func (a *App) ReimbursementDocument(ctx context.Context, actor domain.Actor, id string) (domain.Request, error) {
	var r domain.Request
	if a.Store.Get(ctx, "requests", id, &r) != nil || !canSeeRequest(actor, r) {
		return r, ErrForbidden
	}
	if r.Version != 2 || r.Kind != "Reimbursement" || r.Status != "Disetujui" || r.FinalizedAt == "" {
		return r, errors.New("dokumen final tersedia setelah seluruh persetujuan dan verifikasi finance selesai")
	}
	return r, nil
}

func (a *App) ReimbursementFile(ctx context.Context, actor domain.Actor, id, format string) ([]byte, error) {
	if _, err := a.ReimbursementDocument(ctx, actor, id); err != nil {
		return nil, err
	}
	var stored domain.RequestDocument
	if err := a.Store.Get(ctx, "request_documents", id, &stored); err != nil {
		return nil, errors.New("dokumen final tidak ditemukan")
	}
	if format == "xlsx" {
		return stored.Workbook, nil
	}
	if format != "pdf" {
		return nil, errors.New("format dokumen tidak tersedia")
	}
	if len(stored.PDF) > 0 {
		return stored.PDF, nil
	}
	converted, err := document.ReimbursementPDF(ctx, stored.Workbook)
	if err != nil {
		return nil, err
	}
	err = a.write(ctx, func(s domain.Store) error {
		var current domain.RequestDocument
		if err := s.Get(ctx, "request_documents", id, &current); err != nil {
			return err
		}
		if len(current.PDF) > 0 {
			converted = current.PDF
			return nil
		}
		current.PDF = converted
		if err := s.Put(ctx, "request_documents", id, current); err != nil {
			return err
		}
		return audit(ctx, s, actor, "request.pdf.generate", id)
	})
	return converted, err
}
