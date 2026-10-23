package service

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"github.com/xuri/excelize/v2"
	"hrismdm/backend/internal/domain"
	"strconv"
	"strings"
	"time"
)

var taxHeaders = []string{"ID Karyawan", "Nama Karyawan", "Periode", "PTKP", "PPh21", "Catatan", "Revisi"}

func (a *App) TaxTemplate(ctx context.Context, actor domain.Actor, period string) ([]byte, error) {
	if actor.Role != "admin" {
		return nil, ErrForbidden
	}
	if _, err := time.Parse("2006-01", period); err != nil {
		return nil, errors.New("pilih satu periode payroll")
	}
	rows, err := a.Payroll(ctx, actor)
	if err != nil {
		return nil, err
	}
	f := excelize.NewFile()
	defer f.Close()
	sheet := "PPh21 Manual"
	f.SetSheetName("Sheet1", sheet)
	f.SetCellValue(sheet, "A1", "INPUT PPh21 MASA PAJAK TERAKHIR - "+period)
	f.MergeCell(sheet, "A1", "G1")
	f.SetCellValue(sheet, "A2", "Isi PPh21 periode ini (0 wajib diisi jika nihil; negatif = pengembalian), PTKP dan catatan. Jangan ubah ID, periode atau revisi.")
	f.MergeCell(sheet, "A2", "G2")
	for i, h := range taxHeaders {
		cell, _ := excelize.CoordinatesToCellName(i+1, 3)
		f.SetCellValue(sheet, cell, h)
	}
	row := 4
	for _, p := range rows {
		if p.Period != period || p.Status != "Draft" || p.Version != 2 || (!strings.HasSuffix(period, "-12") && !p.LastTaxPeriod) {
			continue
		}
		var tax any
		if p.ManualPPh21 != nil {
			tax = *p.ManualPPh21
		}
		values := []any{p.EmployeeID, p.EmployeeName, p.Period, p.PTKP, tax, p.TaxNote, p.Revision}
		cell := fmt.Sprintf("A%d", row)
		f.SetSheetRow(sheet, cell, &values)
		row++
	}
	if row == 4 {
		return nil, errors.New("tidak ada draft masa pajak terakhir pada periode ini")
	}
	header, _ := f.NewStyle(&excelize.Style{Font: &excelize.Font{Bold: true, Color: "FFFFFF"}, Fill: excelize.Fill{Type: "pattern", Color: []string{"2459A9"}, Pattern: 1}})
	f.SetCellStyle(sheet, "A3", "G3", header)
	input, _ := f.NewStyle(&excelize.Style{Font: &excelize.Font{Color: "205BB0"}, Fill: excelize.Fill{Type: "pattern", Color: []string{"EDF5FF"}, Pattern: 1}})
	f.SetCellStyle(sheet, "D4", fmt.Sprintf("F%d", row-1), input)
	num, _ := f.NewStyle(&excelize.Style{NumFmt: 3})
	f.SetCellStyle(sheet, "E4", fmt.Sprintf("E%d", row-1), num)
	f.SetColWidth(sheet, "A", "A", 38)
	f.SetColWidth(sheet, "B", "B", 28)
	f.SetColWidth(sheet, "C", "D", 15)
	f.SetColWidth(sheet, "E", "E", 20)
	f.SetColWidth(sheet, "F", "F", 48)
	f.SetColWidth(sheet, "G", "G", 10)
	f.SetRowHeight(sheet, 1, 28)
	f.SetRowHeight(sheet, 2, 34)
	wrap, _ := f.NewStyle(&excelize.Style{Alignment: &excelize.Alignment{WrapText: true, Vertical: "center"}, Font: &excelize.Font{Size: 10, Color: "526580"}})
	f.SetCellStyle(sheet, "A2", "G2", wrap)
	f.SetPanes(sheet, &excelize.Panes{Freeze: true, YSplit: 3, TopLeftCell: "A4", ActivePane: "bottomLeft"})
	f.SetSheetDimension(sheet, fmt.Sprintf("A1:G%d", row-1))
	buffer, err := f.WriteToBuffer()
	if err != nil {
		return nil, err
	}
	return buffer.Bytes(), nil
}
func (a *App) ImportTax(ctx context.Context, actor domain.Actor, period string, data []byte) (int, error) {
	if actor.Role != "admin" {
		return 0, ErrForbidden
	}
	if _, err := time.Parse("2006-01", period); err != nil {
		return 0, errors.New("periode tidak valid")
	}
	if len(data) > 3<<20 {
		return 0, errors.New("file maksimal 3 MB")
	}
	f, err := excelize.OpenReader(bytes.NewReader(data), excelize.Options{UnzipSizeLimit: 32 << 20, UnzipXMLSizeLimit: 8 << 20})
	if err != nil {
		return 0, errors.New("file XLSX tidak dapat dibaca")
	}
	defer f.Close()
	sheet := "PPh21 Manual"
	rows, err := f.GetRows(sheet, excelize.Options{RawCellValue: true})
	if err != nil || len(rows) < 4 || len(rows) > 5003 {
		return 0, errors.New("gunakan template PPh21 dari aplikasi (maksimal 5000 karyawan)")
	}
	if len(rows[2]) != len(taxHeaders) {
		return 0, errors.New("header template tidak sesuai")
	}
	for i, h := range taxHeaders {
		if rows[2][i] != h {
			return 0, errors.New("header template tidak sesuai")
		}
	}
	count := 0
	err = a.write(ctx, func(s domain.Store) error {
		seen := map[string]bool{}
		for i := 3; i < len(rows); i++ {
			row := rows[i]
			if len(row) == 0 {
				continue
			}
			if len(row) < 7 {
				return fmt.Errorf("baris %d belum lengkap", i+1)
			}
			for col := 1; col <= 7; col++ {
				cell, _ := excelize.CoordinatesToCellName(col, i+1)
				formula, err := f.GetCellFormula(sheet, cell)
				if err != nil || formula != "" {
					return fmt.Errorf("baris %d harus berupa nilai, bukan formula", i+1)
				}
			}
			id := strings.TrimSpace(row[0])
			if row[2] != period || seen[id] {
				return fmt.Errorf("baris %d: periode berbeda atau ID duplikat", i+1)
			}
			seen[id] = true
			value, err := strconv.ParseInt(strings.TrimSpace(row[4]), 10, 64)
			if err != nil {
				return fmt.Errorf("baris %d: isi PPh21 sebagai rupiah bulat, termasuk 0 bila nihil", i+1)
			}
			revision, err := strconv.Atoi(row[6])
			if err != nil {
				return fmt.Errorf("baris %d: revisi tidak valid", i+1)
			}
			var p domain.Payroll
			key := period + "-" + id
			if err := s.Get(ctx, "payroll", key, &p); err != nil {
				return fmt.Errorf("baris %d: payroll tidak ditemukan", i+1)
			}
			if !strings.HasSuffix(period, "-12") && !p.LastTaxPeriod {
				return fmt.Errorf("baris %d: tandai masa pajak terakhir sebelum impor", i+1)
			}
			input := PayrollInput{Revision: revision, Allowance: p.Allowance, Bonus: p.Bonus, PTKP: row[3], TaxMode: "manual", ManualPPh21: &value, TaxNote: row[5], LastTaxPeriod: p.LastTaxPeriod}
			if err := updatePayroll(ctx, s, actor, key, input); err != nil {
				return fmt.Errorf("baris %d (%s): %w", i+1, p.EmployeeName, err)
			}
			count++
		}
		if count == 0 {
			return errors.New("tidak ada baris untuk diimpor")
		}
		return audit(ctx, s, actor, "payroll.tax_import", period)
	})
	if err != nil {
		return 0, err
	}
	return count, nil
}
