// Import a one-time legacy export into an empty PostgreSQL database.
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"hrismdm/backend/internal/domain"
	"hrismdm/backend/internal/repository"
	"io"
	"log"
	"os"
)

type record struct {
	Collection string          `json:"collection"`
	ID         string          `json:"id"`
	Data       json.RawMessage `json:"data"`
}

func main() {
	store, err := repository.Open(os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}
	defer store.Close()
	var records []record
	decoder := json.NewDecoder(io.LimitReader(os.Stdin, 128<<20))
	if err = decoder.Decode(&records); err != nil {
		log.Fatal(err)
	}
	collections := []string{"employees", "users", "requests", "inventory", "stock_movements", "attendance", "payroll", "settings", "audit", "sessions"}
	valid := map[string]bool{}
	for _, c := range collections {
		valid[c] = true
	}
	count := 0
	err = store.Within(context.Background(), func(s domain.Store) error {
		for _, c := range collections {
			var rows []json.RawMessage
			if err := s.List(context.Background(), c, &rows); err != nil {
				return err
			}
			if len(rows) > 0 {
				return errors.New("target harus kosong; impor dibatalkan tanpa mengubah data")
			}
		}
		for _, r := range records {
			if !valid[r.Collection] || r.ID == "" {
				return fmt.Errorf("record ekspor tidak valid")
			}
			if r.Collection == "sessions" {
				continue
			}
			if err := s.Put(context.Background(), r.Collection, r.ID, r.Data); err != nil {
				return err
			}
			count++
		}
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("Imported %d records into PostgreSQL. Legacy sessions were not imported.", count)
}
