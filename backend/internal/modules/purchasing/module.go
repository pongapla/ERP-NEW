package purchasing

import (
	"net/http"

	"erp-backend/internal/http/response"

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
