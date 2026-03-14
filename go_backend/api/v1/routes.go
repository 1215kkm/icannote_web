package v1

import (
	"github.com/gin-gonic/gin"
	"github.com/icannote/go_backend/internal/handler"
	"github.com/icannote/go_backend/internal/middleware"
)

func RegisterRoutes(r *gin.Engine) {
	api := r.Group("/api/v1")

	// Public endpoints
	api.POST("/payments/webhook", handler.PaymentWebhook)

	// Protected endpoints — require valid Firebase auth token
	protected := api.Group("")
	protected.Use(middleware.AuthMiddleware())
	{
		// File endpoints
		protected.POST("/files/upload", handler.UploadFile)
		protected.POST("/files/convert", handler.ConvertFile)

		// Lecture endpoints
		protected.GET("/lectures", handler.ListLectures)
		protected.POST("/lectures", handler.CreateLecture)
		protected.GET("/lectures/:id", handler.GetLecture)
		protected.PUT("/lectures/:id", handler.UpdateLecture)
		protected.DELETE("/lectures/:id", handler.DeleteLecture)

		// Payment endpoints
		protected.POST("/payments/billing-key", handler.CreateBillingKey)
		protected.POST("/payments/subscribe", handler.Subscribe)
	}
}
