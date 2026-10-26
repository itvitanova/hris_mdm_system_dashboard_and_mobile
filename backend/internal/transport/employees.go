package transport

import (
	"encoding/base64"
	"errors"
	"hrismdm/backend/internal/domain"
	"hrismdm/backend/internal/service"
	"net/http"
)

func (s *Server) employeeRoutes(m *http.ServeMux) {
	m.HandleFunc("GET /api/request-receipts/{id}", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		file, err := s.App.OwnReceipt(r.Context(), a, r.PathValue("id"))
		if err != nil {
			return err
		}
		w.Header().Set("Content-Type", file.ContentType)
		w.Header().Set("Cache-Control", "no-store")
		_, err = w.Write(file.Data)
		return err
	}))
	for _, route := range []string{"export", "template"} {
		route := route
		m.HandleFunc("GET /api/employees/"+route, s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
			data, err := s.App.EmployeeWorkbook(r.Context(), a, route == "template")
			if err != nil {
				return err
			}
			w.Header().Set("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
			w.Header().Set("Content-Disposition", `attachment; filename="karyawan-`+route+`.xlsx"`)
			w.Header().Set("Cache-Control", "no-store")
			_, err = w.Write(data)
			return err
		}))
	}
	m.HandleFunc("POST /api/employees/import", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		if a.Role != "admin" {
			return service.ErrForbidden
		}
		var v struct {
			FileBase64 string `json:"fileBase64"`
			Commit     bool   `json:"commit"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		data, err := base64.StdEncoding.DecodeString(v.FileBase64)
		if err != nil {
			return errors.New("file tidak valid")
		}
		result, err := s.App.ImportEmployees(r.Context(), a, data, v.Commit)
		if err != nil {
			return err
		}
		respond(w, 200, result)
		return nil
	}))
	m.HandleFunc("GET /api/leave-calendar", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		entries, err := s.App.LeaveCalendar(r.Context(), a, r.URL.Query().Get("month"))
		if err != nil {
			return err
		}
		respond(w, 200, entries)
		return nil
	}))
	m.HandleFunc("POST /api/requests/{id}/seen", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v struct {
			Token string `json:"token"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.MarkRequestSeen(r.Context(), a, r.PathValue("id"), v.Token); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
}
