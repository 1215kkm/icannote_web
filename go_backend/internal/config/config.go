package config

import "os"

type Config struct {
	Port            string
	Environment     string
	FirebaseProject string
	TossSecretKey   string
}

func Load() *Config {
	return &Config{
		Port:            getEnv("PORT", "8080"),
		Environment:     getEnv("ENVIRONMENT", "development"),
		FirebaseProject: getEnv("FIREBASE_PROJECT", ""),
		TossSecretKey:   getEnv("TOSS_SECRET_KEY", ""),
	}
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}
