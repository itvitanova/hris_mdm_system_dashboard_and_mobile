package document

import (
	"archive/zip"
	"bytes"
	"encoding/xml"
	"hrismdm/backend/internal/domain"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"

	"github.com/xuri/excelize/v2"
)

func sampleReimbursement() domain.Request {
	r := domain.Request{ID: "SAMPLE-REIMBURSE", Version: 2, Status: "Disetujui", Kind: "Reimbursement", FinalizedAt: "2026-10-24T01:00:00Z", Snapshot: domain.RequestSnapshot{EmployeeID: "CONTOH-001", Name: "Pemohon contoh", Department: "IT", Position: "Staf IT", Phone: "0800000000", BankName: "Bank contoh", BankAccountName: "Pemohon contoh", BankAccountNumber: "0012345678", SubmittedAt: "2026-10-23T01:00:00Z", Timezone: "Asia/Jakarta", TemplateVersion: "mdm-reimburse-v1"}}
	for i := 0; i < 20; i++ {
		r.Items = append(r.Items, domain.ExpenseItem{Date: "2026-10-22", Description: "Biaya parkir kunjungan kantor contoh " + strconv.Itoa(i+1), Category: "Transportasi", Amount: 15000})
		r.Amount += 15000
	}
	for _, name := range []string{"Lead contoh", "GM contoh", "Direktur contoh"} {
		r.Steps = append(r.Steps, domain.ApprovalStep{Source: "manager", Status: "Disetujui", Decisions: []domain.ApprovalEvent{{Name: name, Decision: "Disetujui", At: "2026-10-23T02:00:00Z"}}})
	}
	r.Steps = append(r.Steps, domain.ApprovalStep{Source: "finance", Status: "Disetujui", Decisions: []domain.ApprovalEvent{{Name: "Finance contoh", Decision: "Disetujui", At: "2026-10-24T01:00:00Z"}}})
	return r
}
func TestReimbursementTemplatePaginationAndFinalOnly(t *testing.T) {
	r := sampleReimbursement()
	data, err := Reimbursement(r)
	if err != nil {
		t.Fatal(err)
	}
	f, err := excelize.OpenReader(bytes.NewReader(data))
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	z, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		t.Fatal(err)
	}
	for _, part := range z.File {
		if part.Name == "xl/drawings/drawing2.xml" {
			source, e := part.Open()
			if e != nil {
				t.Fatal(e)
			}
			decoder := xml.NewDecoder(source)
			extents := 0
			for {
				token, e := decoder.Token()
				if e == io.EOF {
					break
				}
				if e != nil {
					t.Fatal(e)
				}
				if element, ok := token.(xml.StartElement); ok && element.Name.Local == "ext" {
					for _, attr := range element.Attr {
						if attr.Name.Local != "cx" && attr.Name.Local != "cy" {
							continue
						}
						value, e := strconv.Atoi(attr.Value)
						limit := 300 * 9525
						if attr.Name.Local == "cy" {
							limit = 50 * 9525
						}
						if e != nil || value < 1 || value > limit {
							t.Fatal("continuation logo exceeds original header dimensions", attr)
						}
						extents++
					}
				}
			}
			source.Close()
			if extents == 0 {
				t.Fatal("continuation logo dimensions missing")
			}
		}
		if part.Name == "xl/_rels/workbook.xml.rels" {
			source, e := part.Open()
			if e != nil {
				t.Fatal(e)
			}
			body, e := io.ReadAll(source)
			source.Close()
			if e != nil {
				t.Fatal(e)
			}
			if strings.Contains(string(body), "calcChain") {
				t.Fatal("orphan calculation relationship retained")
			}
		}
	}
	if len(f.GetSheetList()) != 2 {
		t.Fatal("missing continuation page")
	}
	for _, sheet := range f.GetSheetList() {
		total, _ := f.GetCellValue(sheet, "E27", excelize.Options{RawCellValue: true})
		if total != "300000" {
			t.Fatal("wrong total", total)
		}
		bank, _ := f.GetCellValue(sheet, "C32")
		if bank != ": 0012345678" {
			t.Fatal("bank leading zero lost")
		}
		cells, err := f.GetPictureCells(sheet)
		if err != nil || len(cells) == 0 {
			t.Fatal("original logo missing")
		}
	}
	last, _ := f.GetCellValue("Lanjutan 2", "A15")
	if last != "20" {
		t.Fatal("missing expense continuation")
	}
	name, _ := f.GetCellValue("Lanjutan 2", "C37")
	if name != "Direktur contoh" {
		t.Fatal("missing additional approver")
	}
	if out := os.Getenv("REIMBURSE_PREVIEW_DIR"); out != "" {
		if err = os.MkdirAll(out, 0755); err != nil {
			t.Fatal(err)
		}
		if err = os.WriteFile(filepath.Join(out, "reimbursement-sample.xlsx"), data, 0600); err != nil {
			t.Fatal(err)
		}
	}
	r.Status = "Menunggu"
	if _, err = Reimbursement(r); err == nil {
		t.Fatal("non-final document produced")
	}
}

func TestLongExpenseDescriptionsContinueWithoutShrinkingRows(t *testing.T) {
	r := sampleReimbursement()
	r.Items = r.Items[:2]
	r.Items[0].Description = strings.Repeat("Keperluan ", 48)
	r.Items[1].Description = strings.Repeat("Perjalanan ", 43)
	r.Amount = 30000
	data, err := Reimbursement(r)
	if err != nil {
		t.Fatal(err)
	}
	f, err := excelize.OpenReader(bytes.NewReader(data))
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	if len(f.GetSheetList()) != 2 {
		t.Fatal("long descriptions not paginated")
	}
	for _, sheet := range f.GetSheetList() {
		height, _ := f.GetRowHeight(sheet, 11)
		if height != 18 {
			t.Fatal("template row rhythm changed")
		}
	}
	r.Items[0].Description = strings.Repeat("a\n", 20)
	if _, err = Reimbursement(r); err == nil {
		t.Fatal("unprintable description accepted")
	}
}
