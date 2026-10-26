package service

import (
	"context"
	"fmt"
	"golang.org/x/crypto/bcrypt"
	"hrismdm/backend/internal/domain"
	"time"
)

func (a *App) Initialize(ctx context.Context, demo bool) error {
	var settings []domain.Settings
	if err := a.Store.List(ctx, "settings", &settings); err != nil {
		return err
	}
	if len(settings) == 0 {
		if err := a.Store.Put(ctx, "settings", "company", domain.Settings{ID: "company", Company: "MDM Indonesia", LocationName: "Kantor Pusat · Jakarta", Latitude: -6.2088, Longitude: 106.8456, Radius: 100, WorkStart: "09:00", Timezone: "Asia/Jakarta"}); err != nil {
			return err
		}
	}
	if !demo {
		return nil
	}
	var users []domain.User
	if err := a.Store.List(ctx, "users", &users); err != nil {
		return err
	}
	if len(users) > 0 {
		return nil
	}
	hash, err := bcrypt.GenerateFromPassword([]byte("DemoHris2026!"), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	loc, _ := time.LoadLocation("Asia/Jakarta")
	today := time.Now().In(loc)
	return a.write(ctx, func(s domain.Store) error {
		names := []string{"Aditya Pratama", "Nadia Putri", "Rizky Ramadhan", "Sarah Wijaya", "Dimas Saputra", "Ayu Lestari", "Fajar Hidayat", "Intan Permata", "Bima Santoso", "Citra Maharani", "Eko Prasetyo", "Dewi Anggraini", "Gilang Maulana", "Hana Safitri", "Irfan Hakim", "Jessica Tan", "Kevin Alexander", "Laras Puspita"}
		depts := []string{"People & Culture", "Engineering", "Finance", "Marketing", "Operations", "General Affair"}
		positions := []string{"HR Manager", "Software Engineer", "Finance Analyst", "Brand Specialist", "Operations Lead", "GA Officer"}
		for i, name := range names {
			id := fmt.Sprintf("EMP-%03d", i+1)
			email := fmt.Sprintf("karyawan%d@mdm.local", i+1)
			if i == 0 {
				email = "admin@mdm.local"
			}
			if i == 1 {
				email = "nadia@mdm.local"
			}
			birth := fmt.Sprintf("199%d-%s-%02d", i%9, today.Format("01"), (today.Day()+i*2-1)%28+1)
			e := domain.Employee{ID: id, Name: name, Email: email, Department: depts[i%6], Position: positions[i%6], Status: "Aktif", Phone: fmt.Sprintf("0812%08d", 12340000+i), Address: "Jakarta Selatan, DKI Jakarta", BirthDate: birth, JoinDate: fmt.Sprintf("202%d-02-01", 2+i%4), Salary: int64(6500000 + i%6*1500000), LeaveBalance: 12}
			e.PTKP = "TK/0" // Demo fixture only. Existing real profiles are never assigned a guessed PTKP.
			if i > 0 {
				e.ManagerID = "EMP-001"
			}
			e.BankName = "Bank contoh"
			e.BankAccountName = name
			e.BankAccountNumber = fmt.Sprintf("000000%06d", i+1)
			e.FinanceVerifier = i == 14
			if i == 6 || i == 12 {
				e.Status = "Probation"
			}
			if err := s.Put(ctx, "employees", id, e); err != nil {
				return err
			}
			if i < 2 || i == 14 {
				role := "employee"
				if i == 0 {
					role = "admin"
				}
				u := domain.User{ID: fmt.Sprintf("USR-%d", i+1), EmployeeID: id, Email: email, Role: role, PasswordHash: string(hash)}
				if err := s.Put(ctx, "users", u.ID, u); err != nil {
					return err
				}
			}
			for day := 0; day < 7; day++ {
				d := today.AddDate(0, 0, -day)
				if (i+day)%9 == 0 {
					continue
				}
				late := (i+day)%7 == 0
				hour, minute := 8, 35+i%20
				status := "Hadir"
				if late {
					hour = 9
					minute = 10 + i%20
					status = "Terlambat"
				}
				cin := time.Date(d.Year(), d.Month(), d.Day(), hour, minute, 0, 0, loc)
				cout := ""
				if day > 0 {
					cout = time.Date(d.Year(), d.Month(), d.Day(), 17, 15+i%25, 0, 0, loc).Format(time.RFC3339)
				}
				att := domain.Attendance{ID: d.Format("2006-01-02") + "-" + id, EmployeeID: id, EmployeeName: name, Date: d.Format("2006-01-02"), CheckIn: cin.Format(time.RFC3339), CheckOut: cout, Status: status, Distance: 35, Accuracy: 8, FaceVerified: false}
				if err := s.Put(ctx, "attendance", att.ID, att); err != nil {
					return err
				}
			}
		}
		kinds := []string{"Cuti", "Reimbursement", "Lembur", "General Affair", "Petty Cash", "Cuti"}
		titles := []string{"Cuti keperluan keluarga", "Transportasi kunjungan klien", "Deployment sistem internal", "Pengadaan alat tulis tim", "Kebutuhan operasional kantor", "Cuti tahunan"}
		for i, kind := range kinds {
			idx := i + 1
			id := fmt.Sprintf("REQ-%03d", i+1)
			r := domain.Request{ID: id, EmployeeID: fmt.Sprintf("EMP-%03d", idx+1), EmployeeName: names[idx], Kind: kind, Title: titles[i], Description: "Mohon persetujuan untuk " + titles[i], Amount: 0, StartDate: today.AddDate(0, 0, i+1).Format("2006-01-02"), EndDate: today.AddDate(0, 0, i+1).Format("2006-01-02"), Status: "Menunggu", CreatedAt: today.Add(-time.Duration(i+1) * time.Hour).Format(time.RFC3339)}
			if kind == "Reimbursement" {
				r.Amount = 275000
			}
			if kind == "Petty Cash" {
				r.Amount = 1500000
			}
			if kind == "Lembur" {
				r.Hours = 3
			}
			if kind == "Cuti" {
				r.Days = 1
			}
			if err := s.Put(ctx, "requests", id, r); err != nil {
				return err
			}
		}
		items := []domain.Inventory{{ID: "GA-001", Name: "Kertas A4 80 gsm", Category: "Alat tulis", Unit: "rim", Stock: 24, Minimum: 10}, {ID: "GA-002", Name: "Tinta printer Epson", Category: "Alat tulis", Unit: "botol", Stock: 4, Minimum: 5}, {ID: "GA-003", Name: "Kopi Arabika", Category: "Pantry", Unit: "pak", Stock: 12, Minimum: 5}, {ID: "GA-004", Name: "Tisu wajah", Category: "Kebersihan", Unit: "box", Stock: 8, Minimum: 10}, {ID: "GA-005", Name: "Air mineral 600 ml", Category: "Pantry", Unit: "dus", Stock: 32, Minimum: 8}, {ID: "GA-006", Name: "Hand soap refill", Category: "Kebersihan", Unit: "pouch", Stock: 15, Minimum: 5}}
		for _, v := range items {
			if err := s.Put(ctx, "inventory", v.ID, v); err != nil {
				return err
			}
		}
		return nil
	})
}

// BootstrapAdmin is used for a fresh non-demo installation. No default password.
func (a *App) BootstrapAdmin(ctx context.Context, email, password string) error {
	var users []domain.User
	if err := a.Store.List(ctx, "users", &users); err != nil {
		return err
	}
	if len(users) > 0 {
		return nil
	}
	if len(password) < 12 || email == "" {
		return fmt.Errorf("set BOOTSTRAP_ADMIN_EMAIL dan BOOTSTRAP_ADMIN_PASSWORD (minimal 12 karakter), atau DEMO_SEED=true untuk demo")
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	return a.write(ctx, func(s domain.Store) error {
		e := domain.Employee{ID: ID(), Name: "Administrator", Email: email, Department: "People & Culture", Position: "Administrator", Status: "Aktif", LeaveBalance: 12}
		if err := s.Put(ctx, "employees", e.ID, e); err != nil {
			return err
		}
		u := domain.User{ID: ID(), EmployeeID: e.ID, Email: email, Role: "admin", PasswordHash: string(hash)}
		return s.Put(ctx, "users", u.ID, u)
	})
}
