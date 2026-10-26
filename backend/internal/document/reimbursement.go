package document

import (
	"archive/zip"
	"bytes"
	"context"
	_ "embed"
	"encoding/xml"
	"errors"
	"fmt"
	"hrismdm/backend/internal/domain"
	"image"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/xuri/excelize/v2"
)

// The original office workbook is versioned with the application, never fetched
// from a client or changed in place. Final requests retain its version.
//
//go:embed assets/reimburse-v1.xlsx
var reimbursementTemplate []byte

func Reimbursement(r domain.Request) ([]byte, error) {
	if r.Version != 2 || r.Kind != "Reimbursement" || r.Status != "Disetujui" || r.FinalizedAt == "" || r.Snapshot.TemplateVersion != "mdm-reimburse-v1" {
		return nil, errors.New("dokumen reimbursement belum final atau versi template tidak tersedia")
	}
	f, err := excelize.OpenReader(bytes.NewReader(reimbursementTemplate))
	if err != nil {
		return nil, err
	}
	defer f.Close()
	approvals := []domain.ApprovalEvent{}
	finance := []domain.ApprovalEvent{}
	for _, st := range r.Steps {
		if st.Status != "Disetujui" {
			return nil, errors.New("persetujuan belum lengkap")
		}
		for _, d := range st.Decisions {
			if d.Decision == "Disetujui" {
				if st.Source == "finance" {
					finance = append(finance, d)
				} else {
					approvals = append(approvals, d)
				}
			}
		}
	}
	if len(approvals) == 0 || len(finance) == 0 {
		return nil, errors.New("persetujuan atasan dan finance belum lengkap")
	}
	type placement struct{ index, row, span int }
	layout := [][]placement{{}}
	used := 0
	for index, item := range r.Items {
		span := domain.ExpenseLineUnits(item)
		if span > 15 {
			return nil, errors.New("deskripsi pengeluaran melebihi kapasitas template")
		}
		if used+span > 15 {
			layout = append(layout, []placement{})
			used = 0
		}
		layout[len(layout)-1] = append(layout[len(layout)-1], placement{index, 11 + used, span})
		used += span
	}
	pages := len(layout)

	if n := (len(approvals) + 1) / 2; n > pages {
		pages = n
	}
	if n := len(finance); n > pages {
		pages = n
	}
	if pages < 1 {
		pages = 1
	}
	pictureCells, err := f.GetPictureCells("Sheet1")
	if err != nil {
		return nil, err
	}
	pictures := map[string][]excelize.Picture{}
	for _, cell := range pictureCells {
		pics, e := f.GetPictures("Sheet1", cell)
		if e != nil {
			return nil, e
		}
		pictures[cell] = pics
	}
	sheets := []string{"Sheet1"}
	for page := 1; page < pages; page++ {
		name := fmt.Sprintf("Lanjutan %d", page+1)
		idx, e := f.NewSheet(name)
		if e != nil {
			return nil, e
		}
		if e = f.CopySheet(0, idx); e != nil {
			return nil, e
		}
		for cell, pics := range pictures {
			for _, pic := range pics {
				// GetPictures omits the drawing's scale and offsets. These EMU
				// measurements belong to the embedded mdm-reimburse-v1 logo;
				// preserve them when copying it to continuation sheets.
				size, _, imageErr := image.DecodeConfig(bytes.NewReader(pic.File))
				if imageErr != nil {
					return nil, imageErr
				}
				pic.Format = &excelize.GraphicOptions{
					OffsetX: 241, OffsetY: 5, Positioning: "oneCell",
					ScaleX:          2558344.0 / 9525 / float64(size.Width),
					ScaleY:          365991.0 / 9525 / float64(size.Height),
					LockAspectRatio: true,
				}
				if e = f.AddPictureFromBytes(name, cell, &pic); e != nil {
					return nil, e
				}
			}
		}
		sheets = append(sheets, name)
	}
	zone, _ := time.LoadLocation(r.Snapshot.Timezone)
	if zone == nil {
		zone = time.UTC
	}
	date := func(value string) string {
		if t, e := time.Parse(time.RFC3339, value); e == nil {
			return t.In(zone).Format("02-01-2006 15:04")
		}
		if t, e := time.Parse("2006-01-02", value); e == nil {
			return t.Format("02-01-2006")
		}
		return value
	}
	var failure error
	check := func(e error) {
		if failure == nil {
			failure = e
		}
	}
	for page, sheet := range sheets {
		str := func(cell, value string) { check(f.SetCellStr(sheet, cell, value)) }
		str("C5", ": "+r.Snapshot.Name)
		str("C6", ": "+r.Snapshot.EmployeeID)
		str("C7", ": "+r.Snapshot.Position)
		str("E5", ": "+date(r.Snapshot.SubmittedAt))
		str("E6", ": "+r.Snapshot.Department)
		str("E7", ": "+r.Snapshot.Phone)
		str("C30", ": "+r.Snapshot.BankName)
		str("C31", ": "+r.Snapshot.BankAccountName)
		str("C32", ": "+r.Snapshot.BankAccountNumber)
		check(f.MergeCell(sheet, "A29", "E29"))
		check(f.MergeCell(sheet, "A33", "E33"))
		wrap, e := f.NewStyle(&excelize.Style{Font: &excelize.Font{Family: "Calibri", Size: 10}, Alignment: &excelize.Alignment{WrapText: true, Vertical: "center"}, Border: []excelize.Border{{Type: "left", Color: "000000", Style: 1}, {Type: "right", Color: "000000", Style: 1}, {Type: "top", Color: "000000", Style: 1}, {Type: "bottom", Color: "000000", Style: 1}}})
		check(e)
		check(f.SetCellStyle(sheet, "A11", "E25", wrap))
		for row := 11; row <= 25; row++ {
			check(f.SetRowHeight(sheet, row, 18))
		}
		if page < len(layout) {
			for _, pos := range layout[page] {
				row, idx := pos.row, pos.index
				item := r.Items[idx]
				if pos.span > 1 {
					for _, column := range []string{"A", "B", "C", "D", "E"} {
						check(f.MergeCell(sheet, fmt.Sprintf("%s%d", column, row), fmt.Sprintf("%s%d", column, row+pos.span-1)))
					}
				}
				check(f.SetCellInt(sheet, fmt.Sprintf("A%d", row), int64(idx+1)))
				str(fmt.Sprintf("B%d", row), date(item.Date))
				str(fmt.Sprintf("C%d", row), item.Description)
				str(fmt.Sprintf("D%d", row), item.Category)
				check(f.SetCellInt(sheet, fmt.Sprintf("E%d", row), item.Amount))
			}
		}

		check(f.SetCellInt(sheet, "E27", r.Amount))
		if pages > 1 {
			str("A27", "TOTAL KLAIM (SEMUA HALAMAN)")
		}
		for _, cell := range []string{"A35", "C35", "D35", "E35", "C37", "D37", "E37", "C38", "D38", "E38"} {
			str(cell, "")
		}
		str("A35", "DIAJUKAN")
		check(f.MergeCell(sheet, "A35", "B35"))
		str("A37", r.Snapshot.Name)
		str("A38", "Tgl: "+date(r.Snapshot.SubmittedAt))
		for n, cell := range []string{"C", "D"} {
			idx := page*2 + n
			if idx < len(approvals) {
				d := approvals[idx]
				str(cell+"35", "DISETUJUI")
				str(cell+"37", d.Name)
				str(cell+"38", "Tgl: "+date(d.At))
			}
		}
		if page < len(finance) {
			d := finance[page]
			str("E35", "DIVERIFIKASI")
			str("E37", d.Name)
			str("E38", "Tgl: "+date(d.At))
		}
		stamp, e := f.NewStyle(&excelize.Style{Font: &excelize.Font{Family: "Calibri", Bold: true, Size: 10, Color: "08745D"}, Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center", WrapText: true}, Border: []excelize.Border{{Type: "left", Color: "08745D", Style: 1}, {Type: "right", Color: "08745D", Style: 1}, {Type: "top", Color: "08745D", Style: 1}, {Type: "bottom", Color: "08745D", Style: 1}}})
		check(e)
		for _, cell := range []string{"A35", "C35", "D35", "E35"} {
			check(f.SetCellStyle(sheet, cell, cell, stamp))
		}
		small, e := f.NewStyle(&excelize.Style{Font: &excelize.Font{Family: "Calibri", Size: 9}, Alignment: &excelize.Alignment{WrapText: true, Vertical: "center"}})
		check(e)
		check(f.SetCellStyle(sheet, "A37", "E38", small))
		check(f.SetRowHeight(sheet, 37, 30))
		check(f.SetRowHeight(sheet, 38, 30))
		check(f.SetCellStyle(sheet, "C5", "C7", small))
		check(f.SetCellStyle(sheet, "E5", "E7", small))
		check(f.SetCellStyle(sheet, "C30", "C32", small))
		for row := 5; row <= 7; row++ {
			check(f.SetRowHeight(sheet, row, 28))
		}
		for row := 30; row <= 32; row++ {
			check(f.MergeCell(sheet, fmt.Sprintf("C%d", row), fmt.Sprintf("E%d", row)))
			check(f.SetRowHeight(sheet, row, 22))
		}
		size := 9
		orientation := "portrait"
		one := 1
		enable := true
		check(f.SetSheetProps(sheet, &excelize.SheetPropsOptions{FitToPage: &enable}))
		check(f.SetPageLayout(sheet, &excelize.PageLayoutOptions{Size: &size, Orientation: &orientation, FitToWidth: &one, FitToHeight: &one}))
		if page == 0 {
			_ = f.DeleteDefinedName(&excelize.DefinedName{Name: "_xlnm.Print_Area", Scope: sheet})
		}
		check(f.SetDefinedName(&excelize.DefinedName{Name: "_xlnm.Print_Area", Scope: sheet, RefersTo: "'" + sheet + "'!$A$1:$E$43"}))
		check(f.SetHeaderFooter(sheet, &excelize.HeaderFooterOptions{OddFooter: fmt.Sprintf("&L%s&RHalaman %d/%d", r.ID, page+1, pages)}))
	}
	if failure != nil {
		return nil, failure
	}
	out, err := f.WriteToBuffer()
	if err != nil {
		return nil, err
	}
	return removeOrphanCalculationRelationship(out.Bytes())
}

// Excelize 2.9 removes the last formula's calcChain part, but can retain its
// relationship. Final documents contain server-calculated totals; remove only
// that orphan so strict OpenXML readers can open the otherwise unchanged file.
func removeOrphanCalculationRelationship(data []byte) ([]byte, error) {
	reader, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		return nil, err
	}
	for _, f := range reader.File {
		if f.Name == "xl/calcChain.xml" {
			return data, nil
		}
	}
	type relationship struct {
		ID         string `xml:"Id,attr"`
		Type       string `xml:"Type,attr"`
		Target     string `xml:"Target,attr"`
		TargetMode string `xml:"TargetMode,attr,omitempty"`
	}
	type relationships struct {
		XMLName xml.Name       `xml:"http://schemas.openxmlformats.org/package/2006/relationships Relationships"`
		Rows    []relationship `xml:"Relationship"`
	}
	var output bytes.Buffer
	writer := zip.NewWriter(&output)
	for _, f := range reader.File {
		source, e := f.Open()
		if e != nil {
			return nil, e
		}
		body, e := io.ReadAll(source)
		source.Close()
		if e != nil {
			return nil, e
		}
		if f.Name == "xl/_rels/workbook.xml.rels" {
			var rels relationships
			if e = xml.Unmarshal(body, &rels); e != nil {
				return nil, e
			}
			kept := []relationship{}
			for _, r := range rels.Rows {
				if !strings.HasSuffix(r.Type, "/calcChain") {
					kept = append(kept, r)
				}
			}
			rels.Rows = kept
			body, e = xml.Marshal(rels)
			if e != nil {
				return nil, e
			}
			body = append([]byte(xml.Header), body...)
		}
		header := f.FileHeader
		target, e := writer.CreateHeader(&header)
		if e != nil {
			return nil, e
		}
		if _, e = target.Write(body); e != nil {
			return nil, e
		}
	}
	if err = writer.Close(); err != nil {
		return nil, err
	}
	return output.Bytes(), nil
}

var conversionSlots = make(chan struct{}, 2)

func ReimbursementPDF(ctx context.Context, xlsx []byte) ([]byte, error) {
	ctx, cancel := context.WithTimeout(ctx, 90*time.Second)
	defer cancel()
	select {
	case conversionSlots <- struct{}{}:
		defer func() { <-conversionSlots }()
	case <-ctx.Done():
		return nil, errors.New("konversi dokumen sedang sibuk, coba lagi")
	}
	dir, err := os.MkdirTemp("", "hris-reimburse-")
	if err != nil {
		return nil, err
	}
	defer os.RemoveAll(dir)
	source := filepath.Join(dir, "reimbursement.xlsx")
	if err = os.WriteFile(source, xlsx, 0600); err != nil {
		return nil, err
	}
	profile := "file://" + filepath.ToSlash(filepath.Join(dir, "profile"))
	if !strings.HasPrefix(profile, "file:///") {
		profile = "file:///" + strings.TrimPrefix(profile, "file://")
	}
	cmd := exec.CommandContext(ctx, "libreoffice", "-env:UserInstallation="+profile, "--headless", "--convert-to", "pdf", "--outdir", dir, source)
	if err = cmd.Run(); err != nil {
		return nil, errors.New("PDF belum dapat dibuat. Coba lagi atau unduh Excel")
	}
	data, err := os.ReadFile(filepath.Join(dir, "reimbursement.pdf"))
	if err != nil || !bytes.HasPrefix(data, []byte("%PDF-")) {
		return nil, errors.New("hasil konversi PDF tidak valid")
	}
	return data, nil
}
