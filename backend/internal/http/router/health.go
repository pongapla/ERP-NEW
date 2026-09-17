package router

import (
	"context"
	"net/http"
	"time"

	"erp-backend/internal/http/response"

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
