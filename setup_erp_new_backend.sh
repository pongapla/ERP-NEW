#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# ERP-NEW Backend Bootstrap
#
# Run this script from the ERP-NEW repository root:
#
#   chmod +x setup_backend.sh
#   ./setup_backend.sh
#
# Expected repository layout:
#
# ERP-NEW/
# ├── backend/
# ├── database/
# ├── docs/
# └── frontend/
#
# This script ONLY writes inside ./backend
# =============================================================================

ROOT_DIR="$(pwd)"
BACKEND_DIR="${ROOT_DIR}/backend"
MODULE_NAME="${GO_MODULE_NAME:-erp-backend}"

echo "============================================================"
echo "ERP Backend Foundation"
echo "Root    : ${ROOT_DIR}"
echo "Backend : ${BACKEND_DIR}"
echo "Module  : ${MODULE_NAME}"
echo "============================================================"

# -----------------------------------------------------------------------------
# Safety checks
# -----------------------------------------------------------------------------

if [ ! -d "${ROOT_DIR}/frontend" ]; then
  echo "ERROR: ./frontend was not found."
  echo "Run this script from the ERP-NEW repository root."
  exit 1
fi

mkdir -p "${BACKEND_DIR}"

# Prevent accidentally overwriting an existing backend implementation.
for f in \
  "${BACKEND_DIR}/go.mod" \
  "${BACKEND_DIR}/cmd/api/main.go" \
  "${BACKEND_DIR}/internal/config/config.go"
do
  if [ -e "$f" ]; then
    echo "ERROR: Existing backend implementation detected:"
    echo "  $f"
    echo
    echo "Nothing was changed."
    echo "Review the existing backend before running a bootstrap script."
    exit 1
  fi
done

if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: Go is not installed or is not available in PATH."
  exit 1
fi

cd "${BACKEND_DIR}"

# -----------------------------------------------------------------------------
# Go module
# -----------------------------------------------------------------------------

echo "==> Initializing Go module"
go mod init "${MODULE_NAME}"

echo "==> Installing dependencies"
go get github.com/go-chi/chi/v5
go get github.com/go-chi/cors
go get github.com/jackc/pgx/v5
go get github.com/jackc/pgx/v5/pgxpool
go get github.com/joho/godotenv

# -----------------------------------------------------------------------------
# Directories
# -----------------------------------------------------------------------------

echo "==> Creating backend directories"

mkdir -p \
  cmd/api \
  internal/config \
  internal/database \
  internal/http/router \
  internal/http/response \
  internal/middleware \
  internal/modules/purchasing \
  internal/modules/purchasing/supplier \
  internal/modules/purchasing/quotation \
  internal/modules/purchasing/pr \
  internal/modules/purchasing/approval \
  internal/modules/purchasing/po \
  internal/modules/purchasing/gr \
  migrations \
  scripts

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------

cat > .env.example <<'EOF'
APP_ENV=development
APP_PORT=4000

DATABASE_URL=postgres://postgres:postgres@localhost:5432/erp_new?sslmode=disable

CORS_ALLOWED_ORIGINS=http://localhost:3000
EOF

if [ ! -f .env ]; then
  cp .env.example .env
fi

# -----------------------------------------------------------------------------
# Backend .gitignore
# -----------------------------------------------------------------------------

cat > .gitignore <<'EOF'
.env
.env.*
!.env.example

bin/
dist/
tmp/
coverage.out

.DS_Store
.idea/
.vscode/
EOF

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------

cat > internal/config/config.go <<'EOF'
package config

import (
	"fmt"
	"os"
)

type Config struct {
	AppEnv             string
	AppPort            string
	DatabaseURL        string
	CORSAllowedOrigins string
}

func Load() Config {
	cfg := Config{
		AppEnv:             getEnv("APP_ENV", "development"),
		AppPort:            getEnv("APP_PORT", "4000"),
		DatabaseURL:        getEnv("DATABASE_URL", ""),
		CORSAllowedOrigins: getEnv("CORS_ALLOWED_ORIGINS", "http://localhost:3000"),
	}

	if cfg.DatabaseURL == "" {
		panic("DATABASE_URL is required")
	}

	return cfg
}

func (c Config) Address() string {
	return fmt.Sprintf(":%s", c.AppPort)
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}

	return fallback
}
EOF

# -----------------------------------------------------------------------------
# PostgreSQL / pgx
# -----------------------------------------------------------------------------

cat > internal/database/postgres.go <<'EOF'
package database

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

func NewPool(ctx context.Context, databaseURL string) (*pgxpool.Pool, error) {
	cfg, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return nil, fmt.Errorf("parse database config: %w", err)
	}

	cfg.MaxConns = 20
	cfg.MinConns = 2
	cfg.MaxConnLifetime = time.Hour
	cfg.MaxConnIdleTime = 30 * time.Minute

	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("create database pool: %w", err)
	}

	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	if err := pool.Ping(pingCtx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("ping database: %w", err)
	}

	return pool, nil
}
EOF

# -----------------------------------------------------------------------------
# JSON response helper
# -----------------------------------------------------------------------------

cat > internal/http/response/json.go <<'EOF'
package response

import (
	"encoding/json"
	"net/http"
)

func JSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}
EOF

# -----------------------------------------------------------------------------
# Health endpoint
# -----------------------------------------------------------------------------

cat > internal/http/router/health.go <<'EOF'
package router

import (
	"context"
	"net/http"
	"time"

	"__MODULE__/internal/http/response"

	"github.com/jackc/pgx/v5/pgxpool"
)

type HealthHandler struct {
	DB *pgxpool.Pool
}

func (h HealthHandler) Handle(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()

	if err := h.DB.Ping(ctx); err != nil {
		response.JSON(w, http.StatusServiceUnavailable, map[string]any{
			"status":   "error",
			"database": "error",
		})
		return
	}

	response.JSON(w, http.StatusOK, map[string]any{
		"status":   "ok",
		"database": "ok",
	})
}
EOF

# -----------------------------------------------------------------------------
# Purchasing module placeholder
# -----------------------------------------------------------------------------

cat > internal/modules/purchasing/module.go <<'EOF'
package purchasing

import (
	"net/http"

	"__MODULE__/internal/http/response"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Module struct {
	DB *pgxpool.Pool
}

func New(db *pgxpool.Pool) Module {
	return Module{DB: db}
}

func (m Module) Routes() http.Handler {
	r := chi.NewRouter()

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		response.JSON(w, http.StatusOK, map[string]any{
			"module": "purchasing",
			"status": "ready",
		})
	})

	return r
}
EOF

# -----------------------------------------------------------------------------
# Router
# -----------------------------------------------------------------------------

cat > internal/http/router/router.go <<'EOF'
package router

import (
	"net/http"
	"strings"

	"__MODULE__/internal/modules/purchasing"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"github.com/jackc/pgx/v5/pgxpool"
)

func New(db *pgxpool.Pool, allowedOrigins string) http.Handler {
	r := chi.NewRouter()

	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	origins := []string{"http://localhost:3000"}

	if strings.TrimSpace(allowedOrigins) != "" {
		parts := strings.Split(allowedOrigins, ",")
		origins = make([]string, 0, len(parts))

		for _, origin := range parts {
			origin = strings.TrimSpace(origin)
			if origin != "" {
				origins = append(origins, origin)
			}
		}
	}

	r.Use(cors.Handler(cors.Options{
		AllowedOrigins: origins,
		AllowedMethods: []string{
			http.MethodGet,
			http.MethodPost,
			http.MethodPut,
			http.MethodPatch,
			http.MethodDelete,
			http.MethodOptions,
		},
		AllowedHeaders: []string{
			"Accept",
			"Authorization",
			"Content-Type",
			"X-Request-ID",
		},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	health := HealthHandler{DB: db}
	r.Get("/health", health.Handle)

	purchasingModule := purchasing.New(db)
	r.Mount("/api/v1/purchasing", purchasingModule.Routes())

	return r
}
EOF

# -----------------------------------------------------------------------------
# Main API
# -----------------------------------------------------------------------------

cat > cmd/api/main.go <<'EOF'
package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"__MODULE__/internal/config"
	"__MODULE__/internal/database"
	httprouter "__MODULE__/internal/http/router"

	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()

	cfg := config.Load()

	ctx := context.Background()

	db, err := database.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("database connection failed: %v", err)
	}
	defer db.Close()

	handler := httprouter.New(db, cfg.CORSAllowedOrigins)

	server := &http.Server{
		Addr:              cfg.Address(),
		Handler:           handler,
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	go func() {
		log.Printf("ERP API listening on http://localhost%s", cfg.Address())

		if err := server.ListenAndServe(); err != nil &&
			!errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("server failed: %v", err)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	shutdownCtx, cancel := context.WithTimeout(
		context.Background(),
		10*time.Second,
	)
	defer cancel()

	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Printf("server shutdown error: %v", err)
	}

	log.Println("ERP API stopped")
}
EOF

# -----------------------------------------------------------------------------
# Replace module placeholder
# -----------------------------------------------------------------------------

echo "==> Applying module path"

find cmd internal -type f -name '*.go' -print0 |
while IFS= read -r -d '' file; do
  sed "s|__MODULE__|${MODULE_NAME}|g" "$file" > "${file}.tmp"
  mv "${file}.tmp" "$file"
done

# -----------------------------------------------------------------------------
# Migrations placeholder
# -----------------------------------------------------------------------------

cat > migrations/README.md <<'EOF'
# ERP Database Migrations

No Purchasing business tables are created yet.

Planned order:

1. Foundation
2. Suppliers
3. Supplier Quotations
4. Purchase Requisitions
5. Approval
6. Purchase Orders
7. Goods Receipts
8. Views
9. Functions
10. Triggers
11. Seeds / Permissions

Do not add a migration until the current project database structure has been
reviewed, especially existing companies/users tables.
EOF

# -----------------------------------------------------------------------------
# Development runner
# -----------------------------------------------------------------------------

cat > scripts/dev.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

go run ./cmd/api
EOF

chmod +x scripts/dev.sh

# -----------------------------------------------------------------------------
# README
# -----------------------------------------------------------------------------

cat > README.md <<'EOF'
# ERP Backend

Go backend for ERP-NEW.

## Stack

- Go
- Chi
- pgx v5
- PostgreSQL

## Current state

Backend foundation only.

No Purchasing business tables or migrations have been applied yet.

## Environment

Copy/edit:

```bash
cp .env.example .env
```

Example:

```env
APP_ENV=development
APP_PORT=4000
DATABASE_URL=postgres://postgres:postgres@localhost:5432/erp_new?sslmode=disable
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

## Run

```bash
./scripts/dev.sh
```

## Health check

```bash
curl http://localhost:4000/health
```

Expected when PostgreSQL is reachable:

```json
{
  "status": "ok",
  "database": "ok"
}
```

## Purchasing placeholder

```bash
curl http://localhost:4000/api/v1/purchasing
```

Expected:

```json
{
  "module": "purchasing",
  "status": "ready"
}
```
EOF

# -----------------------------------------------------------------------------
# Format and compile
# -----------------------------------------------------------------------------

echo "==> Formatting Go code"
gofmt -w cmd internal

echo "==> Tidying dependencies"
go mod tidy

echo "==> Compile/test check"
go test ./...

echo
echo "============================================================"
echo "Backend foundation created successfully."
echo
echo "Created inside:"
echo "  ${BACKEND_DIR}"
echo
echo "Next:"
echo "  cd backend"
echo "  edit .env"
echo "  ./scripts/dev.sh"
echo
echo "Then test:"
echo "  curl http://localhost:4000/health"
echo "============================================================"
