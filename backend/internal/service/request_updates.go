package service

import (
	"context"
	"crypto/sha256"
	"fmt"
	"hrismdm/backend/internal/domain"
	"strings"
	"time"
)

func requestUpdateToken(r domain.Request) string {
	last := ""
	if len(r.History) > 0 {
		h := r.History[len(r.History)-1]
		last = h.At + "|" + h.Decision
	}
	sum := sha256.Sum256([]byte(fmt.Sprintf("%s|%d|%s|%d|%d|%s", r.ID, r.Revision, r.Status, r.CurrentStep, len(r.History), last)))
	return fmt.Sprintf("%x", sum[:])
}
func requestHasUpdate(r domain.Request) bool {
	if len(r.History) > 0 {
		return r.History[len(r.History)-1].Decision != "Diajukan"
	}
	return r.ReviewedBy != ""
}
func pendingWith(r domain.Request) string {
	if r.Status != "Menunggu" {
		return ""
	}
	if r.CurrentStep < 0 || r.CurrentStep >= len(r.Steps) {
		return "Menunggu peninjauan admin"
	}
	stage := r.Steps[r.CurrentStep]
	decided := map[string]bool{}
	for _, d := range stage.Decisions {
		if d.Decision == "Disetujui" {
			decided[d.EmployeeID] = true
		}
	}
	names := []string{}
	for _, p := range stage.Approvers {
		if !decided[p.EmployeeID] {
			names = append(names, p.Name)
		}
	}
	prefix := "Menunggu persetujuan"
	if stage.Source == "finance" {
		prefix = "Menunggu verifikasi finance"
	}
	if len(names) > 0 {
		return prefix + " · " + strings.Join(names, ", ")
	}
	return prefix
}
func (a *App) MarkRequestSeen(ctx context.Context, actor domain.Actor, id, token string) error {
	if len(token) != 64 {
		return fmt.Errorf("penanda pembaruan tidak valid")
	}
	return a.write(ctx, func(s domain.Store) error {
		var r domain.Request
		if s.Get(ctx, "requests", id, &r) != nil || r.EmployeeID != actor.EmployeeID {
			return ErrForbidden
		}
		// Save the displayed token, not a newer event that arrived while opening.
		return s.Put(ctx, "request_seen", actor.ID+"/"+id, map[string]string{"token": token})
	})
}

type LeaveCalendarEntry struct {
	RequestID        string `json:"requestId"`
	EmployeeID       string `json:"employeeId"`
	Name             string `json:"name"`
	Department       string `json:"department"`
	ServicePointID   string `json:"servicePointId"`
	ServicePointName string `json:"servicePointName"`
	StartDate        string `json:"startDate"`
	EndDate          string `json:"endDate"`
}

func (a *App) LeaveCalendar(ctx context.Context, actor domain.Actor, month string) ([]LeaveCalendarEntry, error) {
	out := []LeaveCalendarEntry{}
	start, err := time.Parse("2006-01", month)
	if err != nil {
		return out, fmt.Errorf("bulan harus YYYY-MM")
	}
	end := start.AddDate(0, 1, -1).Format("2006-01-02")
	var me domain.Employee
	if a.Store.Get(ctx, "employees", actor.EmployeeID, &me) != nil {
		return out, ErrForbidden
	}
	var employees []domain.Employee
	var requests []domain.Request
	var sites []domain.ServicePoint
	if err = a.Store.List(ctx, "employees", &employees); err != nil {
		return out, err
	}
	if err = a.Store.List(ctx, "requests", &requests); err != nil {
		return out, err
	}
	if err = a.Store.List(ctx, "service_points", &sites); err != nil {
		return out, err
	}
	byID := map[string]domain.Employee{}
	siteNames := map[string]string{}
	for _, e := range employees {
		byID[e.ID] = e
	}
	for _, p := range sites {
		siteNames[p.ID] = p.Name
	}
	for _, r := range requests {
		if r.Kind != "Cuti" || r.Status != "Disetujui" || r.StartDate > end || r.EndDate < start.Format("2006-01-02") {
			continue
		}
		e, ok := byID[r.EmployeeID]
		if !ok || e.Status == "Nonaktif" || e.ServicePointID == "" || e.ServicePointID != me.ServicePointID {
			continue
		}
		out = append(out, LeaveCalendarEntry{RequestID: r.ID, EmployeeID: e.ID, Name: e.Name, Department: e.Department, ServicePointID: e.ServicePointID, ServicePointName: siteNames[e.ServicePointID], StartDate: r.StartDate, EndDate: r.EndDate})
	}
	return out, nil
}
