package transport

import (
	"bytes"
	"context"
	"encoding/json"
	"hrismdm/backend/internal/domain"
	"hrismdm/backend/internal/service"
	"hrismdm/backend/internal/testutil"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestHTTPAuthenticationCSRFAndAuthorization(t *testing.T) {
	store := testutil.Store(t)
	var err error
	app := service.New(store, &service.HTTPFaceProvider{})
	if err = app.Initialize(context.Background(), true); err != nil {
		t.Fatal(err)
	}
	if err = app.EnsureMasterData(context.Background()); err != nil {
		t.Fatal(err)
	}
	h := (&Server{App: app, Origin: "https://hr.example", Secure: true, Demo: true}).Handler()
	request := func(method, path, body, origin string, cookie *http.Cookie) *httptest.ResponseRecorder {
		r := httptest.NewRequest(method, path, bytes.NewBufferString(body))
		if body != "" {
			r.Header.Set("Content-Type", "application/json")
		}
		if origin != "" {
			r.Header.Set("Origin", origin)
		}
		if cookie != nil {
			r.AddCookie(cookie)
		}
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		return w
	}
	if w := request("GET", "/api/workspace", "", "", nil); w.Code != 401 {
		t.Fatalf("unauthenticated workspace %d", w.Code)
	}
	login := `{"email":"nadia@mdm.local","password":"DemoHris2026!"}`
	if w := request("POST", "/api/auth/login", login, "https://evil.example", nil); w.Code != 403 {
		t.Fatalf("cross-origin login %d", w.Code)
	}
	w := request("POST", "/api/auth/login", login, "https://hr.example", nil)
	if w.Code != 200 {
		t.Fatalf("login %d: %s", w.Code, w.Body.String())
	}
	cookies := w.Result().Cookies()
	if len(cookies) != 1 || !cookies[0].HttpOnly || !cookies[0].Secure || cookies[0].SameSite != http.SameSiteStrictMode {
		t.Fatal("session cookie attributes missing")
	}
	cookie := cookies[0]
	w = request("GET", "/api/workspace", "", "", cookie)
	if w.Code != 200 {
		t.Fatalf("workspace %d", w.Code)
	}
	var payload struct {
		AttendanceDate string           `json:"attendanceDate"`
		Employees      []map[string]any `json:"employees"`
		Inventory      []map[string]any `json:"inventory"`
	}
	if err = json.Unmarshal(w.Body.Bytes(), &payload); err != nil {
		t.Fatal(err)
	}
	if len(payload.Employees) != 1 || len(payload.Inventory) != 0 {
		t.Fatal("employee data leaked")
	}
	companyZone, err := time.LoadLocation("Asia/Jakarta")
	if err != nil {
		t.Fatal(err)
	}
	if payload.AttendanceDate != time.Now().In(companyZone).Format("2006-01-02") {
		t.Fatalf("workspace attendance date does not follow company timezone: %s", payload.AttendanceDate)
	}
	if err = app.GeneratePayroll(context.Background(), domain.Actor{ID: "admin", Role: "admin"}, "2026-11"); err != nil {
		t.Fatal(err)
	}
	if result := request("GET", "/api/payroll/2026-11-EMP-001/pdf", "", "", cookie); result.Code != 403 {
		t.Fatal("employee can download colleague PDF")
	}
	if result := request("GET", "/api/payroll/2026-11-EMP-002/pdf", "", "", cookie); result.Code != 200 || result.Header().Get("Content-Type") != "application/pdf" || !bytes.HasPrefix(result.Body.Bytes(), []byte("%PDF-")) {
		t.Fatal("employee PDF download failed")
	}
	if result := request("GET", "/api/payroll/tax-template?period=2026-12", "", "", cookie); result.Code != 403 {
		t.Fatal("employee can export HR tax template")
	}
	if w = request("POST", "/api/payroll/generate", `{"period":"2026-10"}`, "https://hr.example", cookie); w.Code != 403 {
		t.Fatalf("employee payroll mutation %d", w.Code)
	}
	if w = request("POST", "/api/requests", `{"kind":"Cuti","unknown":true}`, "https://hr.example", cookie); w.Code != 400 {
		t.Fatalf("unknown fields accepted %d", w.Code)
	}
	if w = request("POST", "/api/auth/logout", `{}`, "https://hr.example", cookie); w.Code != 200 {
		t.Fatalf("logout %d", w.Code)
	}
	if w = request("GET", "/api/workspace", "", "", cookie); w.Code != 401 {
		t.Fatalf("logged-out session accepted %d", w.Code)
	}
}
