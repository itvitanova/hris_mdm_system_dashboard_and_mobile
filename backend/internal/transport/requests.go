package transport

import (
	"encoding/base64"
	"errors"
	"hrismdm/backend/internal/domain"
	"net/http"
)

func (s *Server) requestRoutes(m *http.ServeMux) {
	m.HandleFunc("POST /api/approval-policies", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var p domain.ApprovalPolicy
		if err := decode(r, &p); err != nil {
			return err
		}
		if err := s.App.SaveApprovalPolicy(r.Context(), a, p); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/request-receipts", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var input struct {
			Name       string `json:"name"`
			FileBase64 string `json:"fileBase64"`
		}
		if err := decode(r, &input); err != nil {
			return err
		}
		data, err := base64.StdEncoding.DecodeString(input.FileBase64)
		if err != nil {
			return errors.New("file bukti tidak valid")
		}
		f, err := s.App.UploadReceipt(r.Context(), a, input.Name, data)
		if err != nil {
			return err
		}
		respond(w, 201, f)
		return nil
	}))
	m.HandleFunc("GET /api/requests/{id}/receipts/{receiptID}", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		f, err := s.App.RequestReceipt(r.Context(), a, r.PathValue("id"), r.PathValue("receiptID"))
		if err != nil {
			return err
		}
		w.Header().Set("Content-Type", f.ContentType)
		w.Header().Set("Cache-Control", "no-store")
		w.Header().Set("Content-Disposition", `attachment; filename="bukti-transaksi"`)
		_, err = w.Write(f.Data)
		return err
	}))
	m.HandleFunc("GET /api/requests/{id}/document/{format}", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		format := r.PathValue("format")
		if format != "xlsx" && format != "pdf" {
			return errors.New("format dokumen tidak tersedia")
		}
		req, err := s.App.ReimbursementDocument(r.Context(), a, r.PathValue("id"))
		if err != nil {
			return err
		}
		data, err := s.App.ReimbursementFile(r.Context(), a, req.ID, format)
		if err != nil {
			return err
		}
		mime := "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
		if format == "pdf" {
			mime = "application/pdf"
		}

		w.Header().Set("Content-Type", mime)
		w.Header().Set("Cache-Control", "no-store")
		w.Header().Set("Content-Disposition", `attachment; filename="reimbursement-`+req.ID+`.`+format+`"`)
		_, err = w.Write(data)
		return err
	}))
}
