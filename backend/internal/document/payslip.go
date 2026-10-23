package document

import (
	"bytes"
	_ "embed"
	"encoding/base64"
	"fmt"
	"github.com/go-pdf/fpdf"
	"hrismdm/backend/internal/domain"
	"strconv"
	"strings"
)

//go:embed assets/Lato-Regular.ttf
var regular []byte

//go:embed assets/Lato-Bold.ttf
var bold []byte

func rupiah(n int64) string {
	sign := ""
	if n < 0 {
		sign = "-"
		n = -n
	}
	s := strconv.FormatInt(n, 10)
	for i := len(s) - 3; i > 0; i -= 3 {
		s = s[:i] + "." + s[i:]
	}
	return sign + "Rp " + s
}
func Payslip(p domain.Payroll) ([]byte, error) {
	f := fpdf.New("P", "mm", "A4", "")
	f.SetMargins(19, 17, 19)
	f.SetAutoPageBreak(true, 40)
	f.AddUTF8FontFromBytes("Lato", "", regular)
	f.AddUTF8FontFromBytes("Lato", "B", bold)
	f.SetTitle("Slip Gaji - "+p.EmployeeName+" - "+p.Period, true)
	f.SetAuthor(p.CompanyName, true)
	f.SetCreator("PeopleOS HRIS", true)
	f.SetCompression(true)
	f.AddPage()
	f.SetFillColor(37, 86, 163)
	f.Rect(0, 0, 210, 5, "F")
	text := func(x, y, w float64, value string, size float64, b bool) {
		style := ""
		if b {
			style = "B"
		}
		f.SetFont("Lato", style, size)
		f.SetXY(x, y)
		f.MultiCell(w, 5, value, "", "L", false)
	}
	x := 19.0
	if parts := strings.SplitN(p.CompanyLogo, ",", 2); len(parts) == 2 {
		if data, err := base64.StdEncoding.DecodeString(parts[1]); err == nil {
			typ := "PNG"
			if strings.Contains(parts[0], "jpeg") {
				typ = "JPG"
			}
			info := f.RegisterImageOptionsReader("company-logo", fpdf.ImageOptions{ImageType: typ}, bytes.NewReader(data))
			if info != nil {
				w, h := info.Extent()
				height := 17.0
				if h > 0 {
					width := height * w / h
					if width > 25 {
						width = 25
						height = width * h / w
					}
					f.ImageOptions("company-logo", 19, 19, width, height, false, fpdf.ImageOptions{ImageType: typ}, 0, "")
					x = 49
				}
			}
		}
	}
	f.SetTextColor(31, 48, 76)
	text(x, 19, 140-(x-19), p.CompanyName, 16, true)
	headerBottom := f.GetY()
	if headerBottom < 29 {
		headerBottom = 29
	}
	if p.CompanyAddress != "" {
		f.SetTextColor(103, 119, 143)
		text(x, headerBottom+2, 172-(x-19), p.CompanyAddress, 9, false)
		headerBottom = f.GetY()
	}
	y := headerBottom + 12
	f.SetTextColor(31, 48, 76)
	text(19, y, 110, "SLIP GAJI KARYAWAN", 14, true)
	f.SetTextColor(80, 103, 142)
	text(154, y, 37, strings.ToUpper(p.Status), 10, true)
	y += 10
	f.SetDrawColor(222, 230, 240)
	f.Line(19, y, 191, y)
	y += 8
	text(19, y, 110, p.EmployeeName, 13, true)
	text(137, y, 54, "PERIODE "+p.Period, 11, true)
	y = f.GetY() + 3
	f.SetTextColor(104, 119, 142)
	text(19, y, 172, "ID Karyawan: "+p.EmployeeID, 9, false)
	y = f.GetY() + 2
	text(19, y, 172, "Departemen: "+p.Department+"  |  Jabatan: "+p.Position, 9, false)
	y = f.GetY() + 2
	text(19, y, 172, "Status PTKP: "+empty(p.PTKP)+"  |  Kategori TER: "+empty(p.TaxCategory), 9, false)
	y = f.GetY() + 10
	section := func(x float64, title string) {
		f.SetFillColor(239, 244, 252)
		f.Rect(x, y, 82, 9, "F")
		f.SetTextColor(51, 81, 126)
		text(x+3, y+2, 76, title, 10, true)
	}
	section(19, "PENDAPATAN")
	section(109, "POTONGAN")
	y += 13
	income := [][2]string{{"Gaji pokok", rupiah(p.BaseSalary)}, {"Tunjangan", rupiah(p.Allowance)}, {"Lembur", rupiah(p.Overtime)}, {"Bonus", rupiah(p.Bonus)}}
	deduction := [][2]string{{"PPh21", rupiah(p.PPh21)}, {"BPJS Kesehatan (1%)", rupiah(p.BPJSHealth)}, {"JHT (2%)", rupiah(p.JHT)}, {"JP (1%)", rupiah(p.JP)}}
	if !p.TaxReady && p.Version >= 2 {
		deduction[0][1] = "Belum diisi"
	}
	if p.Version < 2 {
		income = append(income, [2]string{"Reimbursement historis", rupiah(p.Reimbursement)})
		deduction = [][2]string{{"Potongan historis", rupiah(p.Deductions)}}
	}
	line := func(x, y float64, label, amount string, b bool) {
		f.SetTextColor(100, 116, 140)
		text(x, y, 43, label, 8.5, b)
		f.SetFont("Lato", "B", 9)
		f.SetTextColor(39, 58, 88)
		f.SetXY(x+42, y)
		f.CellFormat(40, 5, amount, "", 0, "R", false, 0, "")
	}
	count := len(income)
	if len(deduction) > count {
		count = len(deduction)
	}
	for i := 0; i < count; i++ {
		if i < len(income) {
			line(19, y, income[i][0], income[i][1], false)
		}
		if i < len(deduction) {
			line(109, y, deduction[i][0], deduction[i][1], false)
		}
		y += 9
	}
	f.Line(19, y, 101, y)
	f.Line(109, y, 191, y)
	y += 5
	gross := p.GrossSalary
	if p.Version < 2 {
		gross = p.BaseSalary + p.Overtime + p.Reimbursement
	}
	line(19, y, "Total pendapatan", rupiah(gross), true)
	line(109, y, "Total potongan", rupiah(p.Deductions), true)
	y += 18
	f.SetFillColor(235, 243, 255)
	f.RoundedRect(19, y, 172, 22, 3, "1234", "F")
	f.SetTextColor(48, 82, 137)
	text(25, y+8, 70, "TAKE-HOME PAY", 11, true)
	f.SetFont("Lato", "B", 20)
	f.SetXY(96, y+7)
	f.CellFormat(88, 9, rupiah(p.NetSalary), "", 0, "R", false, 0, "")
	y += 31
	f.SetTextColor(111, 125, 147)
	taxInfo := "PPh21 dihitung otomatis dari bruto pendapatan dengan TER " + fmt.Sprintf("%.2f%%", float64(p.TaxRateBps)/100) + "."
	if p.TaxMode == "manual" {
		taxInfo = "PPh21 manual HR untuk periode ini. " + short(p.TaxNote, 240)
	}
	if !p.TaxReady && p.Version >= 2 {
		taxInfo = "PPh21 belum lengkap. Nilai take-home pay masih dapat berubah setelah data pajak dilengkapi."
	}
	if p.Version < 2 {
		taxInfo = "Slip historis memakai perhitungan sebelum pembaruan komponen payroll."
	}
	text(19, y, 172, taxInfo, 9, false)
	y = f.GetY() + 3
	text(19, y, 172, "Potongan BPJS Kesehatan, JHT dan JP menggunakan gaji pokok. Nilai PPh21 negatif merupakan pengembalian dan menambah take-home pay.", 8, false)
	y = f.GetY() + 8
	if p.Status != "Final" {
		f.SetTextColor(174, 123, 36)
		text(19, y, 172, "DRAFT - Belum difinalkan HR. Status pajak: "+map[bool]string{true: "lengkap", false: "perlu dilengkapi"}[p.TaxReady], 10, true)
	} else {
		f.SetTextColor(92, 111, 139)
		text(19, y, 172, "Difinalkan oleh: "+p.FinalizedBy+" | "+p.FinalizedAt, 8, false)
	}
	f.SetFooterFunc(func() {
		f.SetY(266)
		f.SetDrawColor(224, 231, 241)
		f.Line(19, 265, 191, 265)
		f.SetTextColor(128, 142, 163)
		f.SetFont("Lato", "", 8)
		f.MultiCell(172, 4, "Dokumen ini diterbitkan secara elektronik oleh "+p.CompanyName+". Slip gaji merupakan rincian penghasilan dan tidak menggantikan bukti transfer.", "", "L", false)
		f.SetFont("Lato", "", 7)
		f.CellFormat(172, 6, "No. dokumen: "+p.ID+" | Revisi "+strconv.Itoa(p.Revision)+fmt.Sprintf(" | Halaman %d", f.PageNo()), "", 0, "L", false, 0, "")
	})
	var out bytes.Buffer
	if err := f.Output(&out); err != nil {
		return nil, err
	}
	return out.Bytes(), nil
}
func empty(s string) string {
	if s == "" {
		return "Belum diisi"
	}
	return s
}
func short(s string, n int) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n]) + "... (catatan lengkap di aplikasi)"
}
