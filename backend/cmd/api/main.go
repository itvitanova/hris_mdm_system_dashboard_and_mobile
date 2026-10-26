package main

import (
	"context"
	"hrismdm/backend/internal/repository"
	"hrismdm/backend/internal/service"
	"hrismdm/backend/internal/transport"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
	_ "time/tzdata"
)

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
func main() {
	store, err := repository.OpenSchema(os.Getenv("DATABASE_URL"), os.Getenv("DATABASE_SCHEMA"))
	if err != nil {
		log.Fatal(err)
	}
	defer store.Close()
	face := &service.HTTPFaceProvider{URL: os.Getenv("FACE_PROVIDER_URL"), Key: os.Getenv("FACE_PROVIDER_KEY"), Client: &http.Client{Timeout: 20 * time.Second}}
	app := service.New(store, face)
	demo := os.Getenv("DEMO_SEED") == "true"
	if err = app.Initialize(context.Background(), demo); err != nil {
		log.Fatal(err)
	}
	if err = app.BootstrapAdmin(context.Background(), os.Getenv("BOOTSTRAP_ADMIN_EMAIL"), os.Getenv("BOOTSTRAP_ADMIN_PASSWORD")); err != nil {
		log.Fatal(err)
	}
	if err = app.EnsureMasterData(context.Background()); err != nil {
		log.Fatal(err)
	}
	if err = app.EnsurePayrollV2(context.Background()); err != nil {
		log.Fatal(err)
	}
	handler := (&transport.Server{App: app, Origin: env("APP_ORIGIN", "http://localhost:3000"), Secure: os.Getenv("COOKIE_SECURE") == "true", Demo: demo}).Handler()
	server := &http.Server{Addr: env("LISTEN_ADDR", "127.0.0.1:8080"), Handler: handler, ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 30 * time.Second, WriteTimeout: 120 * time.Second, IdleTimeout: 60 * time.Second}
	go func() {
		log.Printf("HRIS API listening on %s (demo=%v)", server.Addr, demo)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal(err)
		}
	}()
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, os.Interrupt, syscall.SIGTERM)
	<-sig
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		log.Print(err)
	}
}
