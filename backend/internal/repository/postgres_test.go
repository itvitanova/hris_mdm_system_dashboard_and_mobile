package repository_test

import (
	"context"
	"errors"
	"hrismdm/backend/internal/domain"
	"hrismdm/backend/internal/repository"
	"hrismdm/backend/internal/testutil"
	"testing"
)

func TestPostgresAtomicRollbackAndJSONBUpsert(t *testing.T) {
	s := testutil.Store(t)
	ctx := context.Background()
	sentinel := errors.New("rollback")
	err := s.Within(ctx, func(tx domain.Store) error {
		if err := tx.Put(ctx, "test", "item", map[string]any{"stock": 10, "name": "Kertas"}); err != nil {
			return err
		}
		return sentinel
	})
	if !errors.Is(err, sentinel) {
		t.Fatalf("unexpected transaction result: %v", err)
	}
	var result map[string]any
	if s.Get(ctx, "test", "item", &result) == nil {
		t.Fatal("rolled-back row was committed")
	}
	if err = s.Within(ctx, func(tx domain.Store) error {
		return tx.Put(ctx, "test", "item", map[string]any{"stock": 10, "name": "Kertas"})
	}); err != nil {
		t.Fatal(err)
	}
	if err = s.Put(ctx, "test", "item", map[string]any{"stock": 8, "name": "Kertas"}); err != nil {
		t.Fatal(err)
	}
	if err = s.Get(ctx, "test", "item", &result); err != nil {
		t.Fatal(err)
	}
	if result["stock"] != float64(8) {
		t.Fatal("JSONB upsert did not replace record")
	}
	var rows []map[string]any
	if err = s.List(ctx, "test", &rows); err != nil {
		t.Fatal(err)
	}
	if len(rows) != 1 {
		t.Fatal("duplicate upsert record")
	}
	if err = s.Put(ctx, "test", "bad", "not-an-object"); err == nil {
		t.Fatal("JSONB object constraint not enforced")
	}
}

func TestPostgresRequiresConfiguration(t *testing.T) {
	if s, err := repository.Open(""); err == nil {
		s.Close()
		t.Fatal("empty DSN accepted")
	}
}
