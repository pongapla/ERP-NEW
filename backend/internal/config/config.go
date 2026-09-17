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
