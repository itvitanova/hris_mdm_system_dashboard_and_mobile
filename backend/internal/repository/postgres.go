package repository

import (
	"context"
	"database/sql"
	_ "embed"
	"encoding/json"
	"fmt"
	"hrismdm/backend/internal/domain"
	"regexp"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/stdlib"
)

//go:embed migrations/001_records.sql
var initialMigration string

type executor interface {
	ExecContext(context.Context, string, ...any) (sql.Result, error)
	QueryContext(context.Context, string, ...any) (*sql.Rows, error)
	QueryRowContext(context.Context, string, ...any) *sql.Row
}

type Postgres struct {
	db *sql.DB
	q  executor
}

func Open(dsn string) (*Postgres, error) { return OpenSchema(dsn, "") }

// OpenSchema supports isolated test schemas. The application defaults to public.
func OpenSchema(dsn, schema string) (*Postgres, error) {
	if dsn == "" {
		return nil, fmt.Errorf("DATABASE_URL wajib diisi untuk PostgreSQL")
	}
	config, err := pgx.ParseConfig(dsn)
	if err != nil {
		return nil, fmt.Errorf("konfigurasi PostgreSQL tidak valid")
	}
	if schema == "" {
		schema = "public"
	}
	if !regexp.MustCompile(`^[a-z][a-z0-9_]{0,62}$`).MatchString(schema) {
		return nil, fmt.Errorf("nama schema tidak valid")
	}
	config.RuntimeParams["search_path"] = schema
	config.RuntimeParams["application_name"] = "hrismdm"
	db := stdlib.OpenDB(*config)
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(30 * time.Minute)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	fail := func(err error) (*Postgres, error) { db.Close(); return nil, err }
	if err = db.PingContext(ctx); err != nil {
		return fail(fmt.Errorf("PostgreSQL tidak dapat dihubungi: %w", err))
	}
	if schema != "public" {
		if _, err = db.ExecContext(ctx, `CREATE SCHEMA IF NOT EXISTS "`+schema+`"`); err != nil {
			return fail(err)
		}
	}
	s := &Postgres{db: db, q: db}
	if err = s.Within(ctx, func(store domain.Store) error {
		tx := store.(*Postgres)
		if _, err := tx.q.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS schema_migrations(version INTEGER PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT now())`); err != nil {
			return err
		}
		var exists bool
		if err := tx.q.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM schema_migrations WHERE version=1)`).Scan(&exists); err != nil {
			return err
		}
		if exists {
			return nil
		}
		if _, err := tx.q.ExecContext(ctx, initialMigration); err != nil {
			return err
		}
		_, err := tx.q.ExecContext(ctx, `INSERT INTO schema_migrations(version) VALUES(1)`)
		return err
	}); err != nil {
		return fail(err)
	}
	return s, nil
}

func (s *Postgres) Close() error { return s.db.Close() }
func (s *Postgres) List(ctx context.Context, collection string, out any) error {
	rows, err := s.q.QueryContext(ctx, `SELECT data FROM records WHERE collection=$1 ORDER BY id`, collection)
	if err != nil {
		return err
	}
	defer rows.Close()
	data := []json.RawMessage{}
	for rows.Next() {
		var b []byte
		if err = rows.Scan(&b); err != nil {
			return err
		}
		data = append(data, json.RawMessage(b))
	}
	if err = rows.Err(); err != nil {
		return err
	}
	b, err := json.Marshal(data)
	if err != nil {
		return err
	}
	return json.Unmarshal(b, out)
}
func (s *Postgres) Get(ctx context.Context, collection, id string, out any) error {
	var b []byte
	if err := s.q.QueryRowContext(ctx, `SELECT data FROM records WHERE collection=$1 AND id=$2`, collection, id).Scan(&b); err != nil {
		return err
	}
	return json.Unmarshal(b, out)
}
func (s *Postgres) Put(ctx context.Context, collection, id string, v any) error {
	b, err := json.Marshal(v)
	if err != nil {
		return err
	}
	_, err = s.q.ExecContext(ctx, `INSERT INTO records(collection,id,data) VALUES($1,$2,$3::jsonb) ON CONFLICT(collection,id) DO UPDATE SET data=EXCLUDED.data, updated_at=now()`, collection, id, string(b))
	return err
}
func (s *Postgres) Delete(ctx context.Context, collection, id string) error {
	_, err := s.q.ExecContext(ctx, `DELETE FROM records WHERE collection=$1 AND id=$2`, collection, id)
	return err
}
func (s *Postgres) Within(ctx context.Context, fn func(domain.Store) error) error {
	if _, ok := s.q.(*sql.Tx); ok {
		return fmt.Errorf("nested transactions unsupported")
	}
	tx, err := s.db.BeginTx(ctx, &sql.TxOptions{Isolation: sql.LevelReadCommitted})
	if err != nil {
		return err
	}
	defer tx.Rollback()
	// Schema-scoped, transaction-level lock protects read-modify-write operations
	// across API instances, rather than relying solely on an in-process mutex.
	if _, err = tx.ExecContext(ctx, `SELECT pg_advisory_xact_lock(hashtextextended(current_schema(), 474938))`); err != nil {
		return err
	}
	if err = fn(&Postgres{db: s.db, q: tx}); err != nil {
		return err
	}
	return tx.Commit()
}
