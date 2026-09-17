package router

import (
	"net/http"
	"strings"

	"erp-backend/internal/modules/purchasing"

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
