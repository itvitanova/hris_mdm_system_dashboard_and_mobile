package domain

import (
	"strings"
	"unicode/utf8"
)

// ExpenseLineUnits shares the template's line capacity between submission
// validation and export, so an approved item cannot become unprintable later.
func ExpenseLineUnits(item ExpenseItem) int {
	lines := func(value string, width int) int {
		n := 0
		for _, line := range strings.Split(value, "\n") {
			count := (utf8.RuneCountInString(line) + width - 1) / width
			if count < 1 {
				count = 1
			}
			n += count
		}
		return n
	}
	a, b := lines(item.Description, 43), lines(item.Category, 21)
	if b > a {
		return b
	}
	return a
}
