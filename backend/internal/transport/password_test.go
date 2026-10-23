package transport

import (
	"bytes"
	"context"
	"hrismdm/backend/internal/service"
	"hrismdm/backend/internal/testutil"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestPasswordEndpointClearsCookieAndInvalidatesSession(t *testing.T) {
	app := service.New(testutil.Store(t), &service.HTTPFaceProvider{})
	ctx := context.Background()
	if err := app.Initialize(ctx, true); err != nil {
		t.Fatal(err)
	}
	token, _, err := app.Login(ctx, "nadia@mdm.local", "DemoHris2026!")
	if err != nil {
		t.Fatal(err)
	}
	handler := (&Server{App: app, Origin: "https://hr.example", Secure: true}).Handler()
	req := httptest.NewRequest("POST", "/api/auth/password", bytes.NewBufferString(`{"currentPassword":"DemoHris2026!","newPassword":"NewPassword123!"}`))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Origin", "https://hr.example")
	req.AddCookie(&http.Cookie{Name: "hris_session", Value: token})
	result := httptest.NewRecorder()
	handler.ServeHTTP(result, req)
	if result.Code != http.StatusOK {
		t.Fatalf("password change: %d %s", result.Code, result.Body.String())
	}
	cookies := result.Result().Cookies()
	if len(cookies) != 1 || cookies[0].MaxAge != -1 || !cookies[0].HttpOnly || !cookies[0].Secure {
		t.Fatal("session cookie not cleared securely")
	}
	if _, err := app.Authenticate(ctx, token); err == nil {
		t.Fatal("old session accepted after password change")
	}
}
