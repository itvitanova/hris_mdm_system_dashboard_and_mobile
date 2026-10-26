package service

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/xuri/excelize/v2"
	"hrismdm/backend/internal/domain"
)

var employeeHeaders = []string{"NIK", "Nama", "Email", "Kode Departemen", "Kode Jabatan", "Kode Service Point", "Hubungan Kerja", "Status", "Telepon", "Alamat", "Tanggal Lahir", "Tanggal Bergabung", "Gaji Pokok", "PTKP", "Saldo Cuti", "Nama Bank", "Pemilik Rekening", "Nomor Rekening", "ID Atasan", "Petugas Finance", "Absensi Bebas Lokasi"}

func (a *App) EmployeeWorkbook(ctx context.Context, actor domain.Actor, template bool) ([]byte, error) {
	if actor.Role != "admin" {
		return nil, ErrForbidden
	}
	f := excelize.NewFile()
	defer f.Close()
	const sheet = "Karyawan"
	f.SetSheetName("Sheet1", sheet)
	headers := append([]string{}, employeeHeaders...)
	if !template {
		headers = append(headers, "ID Sistem", "Departemen", "Jabatan", "Lokasi Penugasan", "Nama Atasan", "Wajah Terdaftar")
	}
	for i, h := range headers {
		cell, _ := excelize.CoordinatesToCellName(i+1, 1)
		f.SetCellStr(sheet, cell, h)
	}
	departments, err := a.MasterData(ctx, actor, "departments")
	if err != nil {
		return nil, err
	}
	positions, err := a.MasterData(ctx, actor, "positions")
	if err != nil {
		return nil, err
	}
	points, err := a.ServicePoints(ctx, actor)
	if err != nil {
		return nil, err
	}
	employees, err := a.Employees(ctx, actor)
	if err != nil {
		return nil, err
	}
	dm := map[string]domain.MasterData{}
	pm := map[string]domain.MasterData{}
	sm := map[string]domain.ServicePoint{}
	em := map[string]domain.Employee{}
	for _, v := range departments {
		dm[v.ID] = v
	}
	for _, v := range positions {
		pm[v.ID] = v
	}
	for _, v := range points {
		sm[v.ID] = v
	}
	for _, v := range employees {
		em[v.ID] = v
	}
	yes := func(v bool) string {
		if v {
			return "YA"
		}
		return "TIDAK"
	}
	if !template {
		for i, e := range employees {
			values := []any{e.EmployeeNumber, e.Name, e.Email, dm[e.DepartmentID].Code, pm[e.PositionID].Code, sm[e.ServicePointID].Code, e.EmploymentType, e.Status, e.Phone, e.Address, e.BirthDate, e.JoinDate, e.Salary, e.PTKP, e.LeaveBalance, e.BankName, e.BankAccountName, e.BankAccountNumber, e.ManagerID, yes(e.FinanceVerifier), yes(e.AllowAnyLocation), e.ID, e.Department, e.Position, sm[e.ServicePointID].Name, em[e.ManagerID].Name, yes(e.FaceEnrolled)}
			for col, v := range values {
				cell, _ := excelize.CoordinatesToCellName(col+1, i+2)
				if s, ok := v.(string); ok {
					f.SetCellStr(sheet, cell, s)
				} else {
					f.SetCellValue(sheet, cell, v)
				}
			}
		}
	}
	headerStyle, _ := f.NewStyle(&excelize.Style{Font: &excelize.Font{Bold: true, Color: "FFFFFF"}, Fill: excelize.Fill{Type: "pattern", Pattern: 1, Color: []string{"182B49"}}, Alignment: &excelize.Alignment{WrapText: true}})
	last, _ := excelize.ColumnNumberToName(len(headers))
	f.SetCellStyle(sheet, "A1", last+"1", headerStyle)
	f.SetRowHeight(sheet, 1, 32)
	f.SetColWidth(sheet, "A", last, 23)
	f.SetColWidth(sheet, "B", "C", 30)
	f.SetColWidth(sheet, "J", "J", 42)
	textStyle, _ := f.NewStyle(&excelize.Style{NumFmt: 49})
	for _, col := range []string{"A", "I", "K", "L", "R", "S", "V"} {
		f.SetCellStyle(sheet, col+"2", col+"501", textStyle)
	}
	f.SetPanes(sheet, &excelize.Panes{Freeze: true, YSplit: 1, TopLeftCell: "A2", ActivePane: "bottomLeft"})
	if !template && len(employees) > 0 {
		f.AutoFilter(sheet, fmt.Sprintf("A1:%s%d", last, len(employees)+1), nil)
	}
	if template {
		f.NewSheet("Panduan")
		notes := []string{
			"TEMPLATE IMPOR KARYAWAN — hanya menambah karyawan; tidak mengubah akun/data lama.",
			"Isi sheet Karyawan mulai baris 2. Jangan ubah header. Maksimal 500 karyawan per file, XLSX maksimal 2 MB.",
			"Wajib: NIK unik, nama, email unik, kode departemen/jabatan/lokasi aktif, PKWT/PKWTT, status, gaji, PTKP, saldo cuti, dan seluruh data rekening.",
			"Gunakan kode dari sheet Referensi. Jabatan harus milik departemen yang dipilih.",
			"Status: Aktif / Probation / Nonaktif. Hubungan kerja: PKWT / PKWTT. Tanggal: YYYY-MM-DD atau kosong.",
			"PTKP: TK/0, TK/1, TK/2, TK/3, K/0, K/1, K/2, K/3. Gaji: angka bulat 0–1000000000000. Saldo cuti: 0–365.",
			"NIK, telepon, dan rekening adalah TEKS. Pertahankan nol di depan. Jangan gunakan formula atau pemisah ribuan untuk angka.",
			"ID Atasan opsional: ID sistem atasan yang sudah terdaftar (lihat Referensi). Impor pimpinan lebih dulu jika diperlukan.",
			"Petugas Finance dan Absensi Bebas Lokasi: YA / TIDAK (kosong berarti TIDAK). Hak finance memerlukan akun aktif yang dibuat terpisah.",
			"Klik Periksa file, perbaiki seluruh kesalahan, lalu Impor. Tidak ada baris disimpan bila satu baris gagal.",
			"Akun login dan password tidak dibuat/diganti oleh impor. Buat akun melalui detail karyawan.",
		}
		for i, n := range notes {
			f.SetCellStr("Panduan", fmt.Sprintf("A%d", i+1), n)
		}
		f.SetColWidth("Panduan", "A", "A", 125)
		guideStyle, _ := f.NewStyle(&excelize.Style{Alignment: &excelize.Alignment{WrapText: true, Vertical: "center"}, Font: &excelize.Font{Color: "182B49"}})
		f.SetCellStyle("Panduan", "A2", fmt.Sprintf("A%d", len(notes)), guideStyle)
		f.SetCellStyle("Panduan", "A1", "A1", headerStyle)
		for i := range notes {
			f.SetRowHeight("Panduan", i+1, 42)
		}
		f.NewSheet("Referensi")
		refs := [][]any{{"Jenis", "Kode / ID", "Nama", "Departemen"}}
		for _, v := range departments {
			if v.Active {
				refs = append(refs, []any{"Departemen", v.Code, v.Name, ""})
			}
		}
		for _, v := range positions {
			if v.Active {
				refs = append(refs, []any{"Jabatan", v.Code, v.Name, dm[v.DepartmentID].Name})
			}
		}
		for _, v := range points {
			if v.Active {
				refs = append(refs, []any{"Lokasi", v.Code, v.Name, ""})
			}
		}
		for _, v := range employees {
			if v.Status != "Nonaktif" {
				refs = append(refs, []any{"Atasan", v.ID, v.Name, v.Department})
			}
		}
		for i, row := range refs {
			for j, v := range row {
				cell, _ := excelize.CoordinatesToCellName(j+1, i+1)
				f.SetCellStr("Referensi", cell, fmt.Sprint(v))
			}
		}
		f.SetColWidth("Referensi", "A", "D", 36)
		f.SetCellStyle("Referensi", "A1", "D1", headerStyle)
	}
	b, err := f.WriteToBuffer()
	if err != nil {
		return nil, err
	}
	return b.Bytes(), nil
}

type EmployeeImportRow struct {
	Row   int    `json:"row"`
	Name  string `json:"name"`
	Email string `json:"email"`
	Error string `json:"error,omitempty"`
}
type EmployeeImportResult struct {
	Rows     []EmployeeImportRow `json:"rows"`
	Valid    bool                `json:"valid"`
	Imported int                 `json:"imported"`
}

var errImportPreview = errors.New("rollback employee import preview")

func (a *App) ImportEmployees(ctx context.Context, actor domain.Actor, data []byte, commit bool) (EmployeeImportResult, error) {
	result := EmployeeImportResult{Rows: []EmployeeImportRow{}}
	if actor.Role != "admin" {
		return result, ErrForbidden
	}
	if len(data) == 0 || len(data) > 2*1024*1024 {
		return result, errors.New("unggah XLSX maksimal 2 MB")
	}
	f, err := excelize.OpenReader(bytes.NewReader(data), excelize.Options{UnzipSizeLimit: 20 * 1024 * 1024, UnzipXMLSizeLimit: 10 * 1024 * 1024})
	if err != nil {
		return result, errors.New("file XLSX tidak dapat dibaca")
	}
	defer f.Close()
	rows, err := f.GetRows("Karyawan")
	if err != nil || len(rows) < 2 {
		return result, errors.New("sheet Karyawan belum berisi data")
	}
	if len(rows) > 501 {
		return result, errors.New("maksimal 500 baris karyawan")
	}
	if len(rows[0]) != len(employeeHeaders) {
		return result, errors.New("gunakan template impor karyawan terbaru; jangan ubah header")
	}
	for i, h := range employeeHeaders {
		if rows[0][i] != h {
			return result, fmt.Errorf("kolom %d harus %s", i+1, h)
		}
	}
	err = a.write(ctx, func(s domain.Store) error {
		var ds, ps []domain.MasterData
		var sites []domain.ServicePoint
		if e := s.List(ctx, "master_departments", &ds); e != nil {
			return e
		}
		if e := s.List(ctx, "master_positions", &ps); e != nil {
			return e
		}
		if e := s.List(ctx, "service_points", &sites); e != nil {
			return e
		}
		lookup := func(rows []domain.MasterData, code string) string {
			for _, v := range rows {
				if v.Active && strings.EqualFold(v.Code, code) {
					return v.ID
				}
			}
			return ""
		}
		for index, row := range rows[1:] {
			if strings.TrimSpace(strings.Join(row, "")) == "" {
				continue
			}
			get := func(i int) string {
				if i < len(row) {
					return strings.TrimSpace(row[i])
				}
				return ""
			}
			e := domain.Employee{EmployeeNumber: get(0), Name: get(1), Email: get(2), DepartmentID: lookup(ds, get(3)), PositionID: lookup(ps, get(4)), EmploymentType: get(6), Status: get(7), Phone: get(8), Address: get(9), BirthDate: get(10), JoinDate: get(11), PTKP: get(13), BankName: get(15), BankAccountName: get(16), BankAccountNumber: get(17), ManagerID: get(18)}
			for _, v := range sites {
				if v.Active && strings.EqualFold(v.Code, get(5)) {
					e.ServicePointID = v.ID
				}
			}
			report := EmployeeImportRow{Row: index + 2, Name: e.Name, Email: e.Email}
			for col := range employeeHeaders {
				cell, _ := excelize.CoordinatesToCellName(col+1, index+2)
				formula, _ := f.GetCellFormula("Karyawan", cell)
				if formula != "" {
					report.Error = "formula tidak diizinkan; gunakan nilai teks/angka"
					break
				}
			}
			salary, salaryErr := strconv.ParseInt(get(12), 10, 64)
			leave, leaveErr := strconv.Atoi(get(14))
			e.Salary = salary
			e.LeaveBalance = leave
			flag := func(v string) (bool, bool) {
				switch strings.ToUpper(v) {
				case "YA":
					return true, true
				case "TIDAK", "":
					return false, true
				}
				return false, false
			}
			var financeOK, locationOK bool
			e.FinanceVerifier, financeOK = flag(get(19))
			e.AllowAnyLocation, locationOK = flag(get(20))
			if report.Error == "" {
				switch {
				case e.EmployeeNumber == "":
					report.Error = "NIK wajib diisi"
				case e.EmploymentType != "PKWT" && e.EmploymentType != "PKWTT":
					report.Error = "hubungan kerja harus PKWT atau PKWTT"
				case e.PTKP == "":
					report.Error = "status PTKP wajib diisi"
				case e.ServicePointID == "":
					report.Error = "kode lokasi tidak ditemukan/nonaktif"
				case salaryErr != nil || leaveErr != nil:
					report.Error = "gaji dan saldo cuti harus angka bulat tanpa pemisah"
				case !financeOK || !locationOK:
					report.Error = "pilihan finance/bebas lokasi harus YA atau TIDAK"
				default:
					if saveErr := a.saveEmployee(ctx, s, actor, e); saveErr != nil {
						report.Error = saveErr.Error()
					}
				}
			}
			result.Rows = append(result.Rows, report)
		}
		result.Valid = len(result.Rows) > 0
		for _, r := range result.Rows {
			if r.Error != "" {
				result.Valid = false
			}
		}
		if !commit || !result.Valid {
			return errImportPreview
		}
		result.Imported = len(result.Rows)
		return nil
	})
	if errors.Is(err, errImportPreview) {
		return result, nil
	}
	return result, err
}
