package service

import (
	"errors"
	"hrismdm/backend/internal/domain"
	"testing"
)

func TestSelfEnrollmentAndReferencePrivacy(t *testing.T) {
	a, admin, employee := setup(t)
	if !errors.Is(a.Enroll(ctx, employee, admin.EmployeeID, photo(t)), ErrForbidden) {
		t.Fatal("enrolled another identity")
	}
	a.Face = &fakeFace{allowed: false}
	if a.Enroll(ctx, employee, employee.EmployeeID, photo(t)) == nil {
		t.Fatal("rejected face saved")
	}
	rows, err := a.Employees(ctx, employee)
	must(t, err)
	if rows[0].FaceEnrolled {
		t.Fatal("rejected enrollment marked complete")
	}
	a.Face = &fakeFace{allowed: true}
	must(t, a.Enroll(ctx, employee, employee.EmployeeID, photo(t)))
	ref, err := a.FaceReference(ctx, admin, employee.EmployeeID)
	must(t, err)
	if ref.Photo != photo(t) || ref.EnrolledAt == "" {
		t.Fatal("reference not persisted")
	}
	if _, err := a.FaceReference(ctx, employee, admin.EmployeeID); !errors.Is(err, ErrForbidden) {
		t.Fatal("another reference readable")
	}
	if a.Enroll(ctx, employee, employee.EmployeeID, photo(t)) == nil {
		t.Fatal("employee replaced enrolled identity")
	}
	must(t, a.Enroll(ctx, admin, employee.EmployeeID, photo(t)))
	if !errors.Is(a.Provision(ctx, employee, employee.EmployeeID, "Password12345!", "admin"), ErrForbidden) {
		t.Fatal("employee provisioned account")
	}
}

func TestPasswordChangeVerifiesOldPasswordAndRevokesSessions(t *testing.T) {
	a, _, employee := setup(t)
	token, _, err := a.Login(ctx, employee.Email, "DemoHris2026!")
	must(t, err)
	if a.ChangePassword(ctx, employee, "wrong", "NewPassword123!") == nil {
		t.Fatal("wrong old password accepted")
	}
	if a.ChangePassword(ctx, employee, "DemoHris2026!", "short") == nil {
		t.Fatal("short password accepted")
	}
	_, err = a.Authenticate(ctx, token)
	must(t, err)
	must(t, a.ChangePassword(ctx, employee, "DemoHris2026!", "NewPassword123!"))
	if _, err = a.Authenticate(ctx, token); err == nil {
		t.Fatal("old session remains active")
	}
	if _, _, err = a.Login(ctx, employee.Email, "DemoHris2026!"); err == nil {
		t.Fatal("old password works")
	}
	_, _, err = a.Login(ctx, employee.Email, "NewPassword123!")
	must(t, err)
	var user domain.User
	must(t, a.Store.Get(ctx, "users", employee.ID, &user))
	if user.PasswordHash == "NewPassword123!" {
		t.Fatal("plaintext password stored")
	}
}
