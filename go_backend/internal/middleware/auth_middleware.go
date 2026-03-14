package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// AuthMiddleware verifies Firebase ID tokens from the Authorization header.
// TODO: Integrate Firebase Admin SDK for real token verification.
// For now, this is a stub that extracts the token and sets a placeholder user ID.
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "Authorization header required",
			})
			return
		}

		// Expect "Bearer <token>"
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid authorization format. Use: Bearer <token>",
			})
			return
		}

		token := parts[1]
		if token == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "Token is empty",
			})
			return
		}

		// TODO: Verify token with Firebase Admin SDK
		// auth, err := firebaseApp.Auth(context.Background())
		// decodedToken, err := auth.VerifyIDToken(c, token)
		// userID := decodedToken.UID

		// Stub: set a placeholder user ID from token
		// In production, this would be the decoded Firebase UID
		c.Set("userID", "stub-user-id")
		c.Set("token", token)

		c.Next()
	}
}
