package service

import (
	_ "embed"
	"encoding/json"
	"strings"
)

//go:embed tax/ter.json
var terJSON []byte

type taxBand struct {
	Threshold int64 `json:"threshold"`
	RateBps   int64 `json:"rateBps"`
}

var terBands = func() map[string][]taxBand {
	var table struct {
		Categories map[string][]taxBand `json:"categories"`
	}
	if err := json.Unmarshal(terJSON, &table); err != nil {
		panic(err)
	}
	return table.Categories
}()

func PTKPCategory(status string) string {
	switch strings.ToUpper(status) {
	case "TK/0", "TK/1", "K/0":
		return "A"
	case "TK/2", "TK/3", "K/1", "K/2":
		return "B"
	case "K/3":
		return "C"
	}
	return ""
}

// Workbook thresholds are exclusive lower bounds: exactly Rp5,400,000 in A is 0%.
func CalculateTER(gross int64, category string) (int64, int64) {
	rate := int64(0)
	for _, band := range terBands[category] {
		if gross > band.Threshold {
			rate = band.RateBps
		} else {
			break
		}
	}
	return (gross*rate + 5000) / 10000, rate
}
