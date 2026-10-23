package transport

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"hrismdm/backend/internal/document"
	"hrismdm/backend/internal/domain"
	"hrismdm/backend/internal/service"
	"io"
	"log"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

type Server struct {
	App      *service.App
	Origin   string
	Secure   bool
	Demo     bool
	mu       sync.Mutex
	attempts map[string][]time.Time
}
type handler func(http.ResponseWriter, *http.Request, domain.Actor) error

func respond(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
func decode(r *http.Request, v any) error {
	d := json.NewDecoder(r.Body)
	d.DisallowUnknownFields()
	if err := d.Decode(v); err != nil {
		return errors.New("format data tidak valid")
	}
	if err := d.Decode(&struct{}{}); err != io.EOF {
		return errors.New("body hanya boleh satu objek JSON")
	}
	return nil
}
func token(r *http.Request) string {
	c, err := r.Cookie("hris_session")
	if err != nil {
		return ""
	}
	return c.Value
}
func (s *Server) protect(fn handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		actor, err := s.App.Authenticate(r.Context(), token(r))
		if err != nil {
			respond(w, 401, map[string]string{"error": "Sesi berakhir. Silakan masuk kembali."})
			return
		}
		if err = fn(w, r, actor); err != nil {
			status := 400
			if errors.Is(err, service.ErrForbidden) {
				status = 403
			}
			respond(w, status, map[string]string{"error": err.Error()})
		}
	}
}
func (s *Server) Handler() http.Handler {
	m := http.NewServeMux()
	s.attempts = map[string][]time.Time{}
	m.HandleFunc("GET /api/health", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
		defer cancel()
		if _, err := s.App.Settings(ctx); err != nil {
			respond(w, 503, map[string]string{"status": "unavailable", "database": "postgresql"})
			return
		}
		respond(w, 200, map[string]any{"status": "ok", "database": "postgresql", "demo": s.Demo})
	})
	m.HandleFunc("POST /api/auth/login", s.login)
	m.HandleFunc("POST /api/auth/logout", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		if err := s.App.Logout(r.Context(), token(r)); err != nil {
			return err
		}
		http.SetCookie(w, &http.Cookie{Name: "hris_session", Value: "", Path: "/", HttpOnly: true, Secure: s.Secure, SameSite: http.SameSiteStrictMode, MaxAge: -1})
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("GET /api/auth/me", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error { respond(w, 200, a); return nil }))
	m.HandleFunc("GET /api/workspace", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		ctx := r.Context()
		employees, err := s.App.Employees(ctx, a)
		if err != nil {
			return err
		}
		requests, err := s.App.Requests(ctx, a)
		if err != nil {
			return err
		}
		attendance, err := s.App.Attendance(ctx, a)
		if err != nil {
			return err
		}
		payroll, err := s.App.Payroll(ctx, a)
		if err != nil {
			return err
		}
		settings, err := s.App.Settings(ctx)
		if err != nil {
			return err
		}
		inventory := []domain.Inventory{}
		masters := map[string][]domain.MasterData{}
		movements := []domain.StockMovement{}
		if a.Role == "admin" {
			for _, kind := range []string{"departments", "positions"} {
				rows, err := s.App.MasterData(ctx, a, kind)
				if err != nil {
					return err
				}
				masters[kind] = rows
			}
			inventory, err = s.App.Inventory(ctx, a)
			if err != nil {
				return err
			}
			if err = s.App.Store.List(ctx, "stock_movements", &movements); err != nil {
				return err
			}
		}
		points, err := s.App.ServicePoints(ctx, a)
		if err != nil {
			return err
		}
		policy, policyErr := s.App.AttendancePolicy(ctx, a)
		zone := settings.Timezone
		if policyErr == nil {
			zone = policy.Timezone
		}
		officeLocation, err := time.LoadLocation(zone)
		if err != nil {
			return err
		}
		attendanceDate := time.Now().In(officeLocation).Format("2006-01-02")
		respond(w, 200, map[string]any{"actor": a, "employees": employees, "requests": requests, "attendance": attendance, "attendanceDate": attendanceDate, "servicePoints": points, "attendancePolicy": policy, "payroll": payroll, "inventory": inventory, "stockMovements": movements, "settings": settings, "faceAvailable": s.App.Face.Available(), "demo": s.Demo, "masterData": masters})
		return nil
	}))
	m.HandleFunc("GET /api/service-points", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		rows, err := s.App.ServicePoints(r.Context(), a)
		if err != nil {
			return err
		}
		respond(w, 200, rows)
		return nil
	}))
	m.HandleFunc("POST /api/service-points", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v domain.ServicePoint
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.SaveServicePoint(r.Context(), a, v); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("DELETE /api/service-points/{id}", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		if err := s.App.DeleteServicePoint(r.Context(), a, r.PathValue("id")); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("GET /api/master-data/{kind}", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		rows, err := s.App.MasterData(r.Context(), a, r.PathValue("kind"))
		if err != nil {
			return err
		}
		respond(w, 200, rows)
		return nil
	}))
	m.HandleFunc("POST /api/master-data/{kind}", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v domain.MasterData
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.SaveMasterData(r.Context(), a, r.PathValue("kind"), v); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("DELETE /api/master-data/{kind}/{id}", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		if err := s.App.DeleteMasterData(r.Context(), a, r.PathValue("kind"), r.PathValue("id")); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/employees", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v domain.Employee
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.SaveEmployee(r.Context(), a, v); err != nil {
			return err
		}
		respond(w, 201, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/accounts", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v struct {
			EmployeeID string `json:"employeeId"`
			Password   string `json:"password"`
			Role       string `json:"role"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.Provision(r.Context(), a, v.EmployeeID, v.Password, v.Role); err != nil {
			return err
		}
		respond(w, 201, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/requests", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v domain.Request
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.SubmitRequest(r.Context(), a, v); err != nil {
			return err
		}
		respond(w, 201, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/requests/{id}/review", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v struct {
			Status string `json:"status"`
			Note   string `json:"note"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.ReviewRequest(r.Context(), a, r.PathValue("id"), v.Status, v.Note); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/inventory", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v domain.Inventory
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.SaveInventory(r.Context(), a, v); err != nil {
			return err
		}
		respond(w, 201, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/inventory/{id}/adjust", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v struct {
			Quantity int    `json:"quantity"`
			Note     string `json:"note"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.AdjustStock(r.Context(), a, r.PathValue("id"), v.Quantity, v.Note); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/payroll/generate", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v struct {
			Period string `json:"period"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.GeneratePayroll(r.Context(), a, v.Period); err != nil {
			return err
		}
		respond(w, 201, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/payroll/{id}/update", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var input service.PayrollInput
		if err := decode(r, &input); err != nil {
			return err
		}
		if err := s.App.UpdatePayroll(r.Context(), a, r.PathValue("id"), input); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("GET /api/payroll/{id}/pdf", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		p, err := s.App.PayrollSlip(r.Context(), a, r.PathValue("id"))
		if err != nil {
			return err
		}
		if p.CompanyName == "" {
			settings, err := s.App.Settings(r.Context())
			if err != nil {
				return err
			}
			p.CompanyName = settings.Company
		}
		data, err := document.Payslip(p)
		if err != nil {
			return err
		}
		w.Header().Set("Content-Type", "application/pdf")
		w.Header().Set("Content-Disposition", `attachment; filename="slip-`+p.Period+`.pdf"`)
		w.WriteHeader(200)
		_, err = w.Write(data)
		return err
	}))
	m.HandleFunc("GET /api/payroll/tax-template", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		data, err := s.App.TaxTemplate(r.Context(), a, r.URL.Query().Get("period"))
		if err != nil {
			return err
		}
		w.Header().Set("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
		w.Header().Set("Content-Disposition", `attachment; filename="template-pph21.xlsx"`)
		w.WriteHeader(200)
		_, err = w.Write(data)
		return err
	}))
	m.HandleFunc("POST /api/payroll/import-tax", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		if a.Role != "admin" {
			return service.ErrForbidden
		}
		var v struct {
			Period     string `json:"period"`
			FileBase64 string `json:"fileBase64"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		data, err := base64.StdEncoding.DecodeString(v.FileBase64)
		if err != nil {
			return errors.New("file tidak valid")
		}
		count, err := s.App.ImportTax(r.Context(), a, v.Period, data)
		if err != nil {
			return err
		}
		respond(w, 200, map[string]int{"count": count})
		return nil
	}))
	m.HandleFunc("POST /api/payroll/{id}/finalize", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v struct {
			Revision int `json:"revision"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.FinalizePayroll(r.Context(), a, r.PathValue("id"), v.Revision); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("PUT /api/settings", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v domain.Settings
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.SaveSettings(r.Context(), a, v); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/auth/password", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v struct {
			Current string `json:"currentPassword"`
			Next    string `json:"newPassword"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.ChangePassword(r.Context(), a, v.Current, v.Next); err != nil {
			return err
		}
		http.SetCookie(w, &http.Cookie{Name: "hris_session", Path: "/", MaxAge: -1, HttpOnly: true, Secure: s.Secure, SameSite: http.SameSiteStrictMode})
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("POST /api/attendance/punch", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v service.Punch
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.Punch(r.Context(), a, v); err != nil {
			return err
		}
		respond(w, 201, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("GET /api/employees/{id}/face", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		ref, err := s.App.FaceReference(r.Context(), a, r.PathValue("id"))
		if err != nil {
			return err
		}
		respond(w, 200, ref)
		return nil
	}))
	m.HandleFunc("POST /api/employees/{id}/face", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		var v struct {
			Photo string `json:"photo"`
		}
		if err := decode(r, &v); err != nil {
			return err
		}
		if err := s.App.Enroll(r.Context(), a, r.PathValue("id"), v.Photo); err != nil {
			return err
		}
		respond(w, 200, map[string]bool{"ok": true})
		return nil
	}))
	m.HandleFunc("GET /api/audit", s.protect(func(w http.ResponseWriter, r *http.Request, a domain.Actor) error {
		if a.Role != "admin" {
			return service.ErrForbidden
		}
		var out []domain.Audit
		if err := s.App.Store.List(r.Context(), "audit", &out); err != nil {
			return err
		}
		respond(w, 200, out)
		return nil
	}))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		defer func() {
			if err := recover(); err != nil {
				log.Printf("handler panic: %v", err)
				respond(w, 500, map[string]string{"error": "Terjadi kesalahan internal"})
			}
		}()
		if r.Method != "GET" && r.Method != "HEAD" {
			if origin := r.Header.Get("Origin"); origin != "" && origin != s.Origin {
				respond(w, 403, map[string]string{"error": "Origin tidak diizinkan"})
				return
			}
			if !strings.HasPrefix(r.Header.Get("Content-Type"), "application/json") {
				respond(w, 415, map[string]string{"error": "Gunakan application/json"})
				return
			}
		}
		r.Body = http.MaxBytesReader(w, r.Body, 5*1024*1024)
		m.ServeHTTP(w, r)
	})
}
func (s *Server) login(w http.ResponseWriter, r *http.Request) {
	ip, _, _ := net.SplitHostPort(r.RemoteAddr)
	s.mu.Lock()
	cutoff := time.Now().Add(-time.Minute)
	for key, list := range s.attempts {
		recent := list[:0]
		for _, t := range list {
			if t.After(cutoff) {
				recent = append(recent, t)
			}
		}
		if len(recent) == 0 {
			delete(s.attempts, key)
		} else {
			s.attempts[key] = recent
		}
	}
	if len(s.attempts[ip]) >= 10 {
		s.mu.Unlock()
		respond(w, 429, map[string]string{"error": "Terlalu banyak percobaan. Coba dalam satu menit."})
		return
	}
	s.attempts[ip] = append(s.attempts[ip], time.Now())
	s.mu.Unlock()
	var v struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := decode(r, &v); err != nil {
		respond(w, 400, map[string]string{"error": err.Error()})
		return
	}
	t, a, err := s.App.Login(r.Context(), v.Email, v.Password)
	if err != nil {
		respond(w, 401, map[string]string{"error": "Email atau kata sandi salah"})
		return
	}
	http.SetCookie(w, &http.Cookie{Name: "hris_session", Value: t, Path: "/", HttpOnly: true, Secure: s.Secure, SameSite: http.SameSiteStrictMode, MaxAge: 43200})
	respond(w, 200, a)
}
