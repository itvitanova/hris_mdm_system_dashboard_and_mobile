package testutil

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"hrismdm/backend/internal/repository"
	"os"
	"testing"
)

// Every integration test gets an isolated schema in an explicitly configured DB.
func Store(t *testing.T) *repository.Postgres {
	t.Helper()
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL belum diisi; jalankan docker compose --profile test run --rm backend-test")
	}
	var random [12]byte
	if _, err := rand.Read(random[:]); err != nil {
		t.Fatal(err)
	}
	schema := "test_" + hex.EncodeToString(random[:])
	store, err := repository.OpenSchema(dsn, schema)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		store.Close()
		db, err := sql.Open("pgx", dsn)
		if err != nil {
			t.Error(err)
			return
		}
		defer db.Close()
		if _, err = db.ExecContext(context.Background(), `DROP SCHEMA "`+schema+`" CASCADE`); err != nil {
			t.Error(err)
		}
	})
	return store
}
