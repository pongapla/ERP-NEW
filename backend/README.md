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
