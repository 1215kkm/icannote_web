package v1

import (
	"github.com/gin-gonic/gin"
	"github.com/icannote/go_backend/internal/handler"
)

func RegisterRoutes(r *gin.Engine) {
	api := r.Group("/api/v1")
	{
		// File endpoints
		api.POST("/files/upload", handler.UploadFile)
		api.POST("/files/convert", handler.ConvertFile)

		// Lecture endpoints
		api.GET("/lectures", handler.ListLectures)
		api.POST("/lectures", handler.CreateLecture)
		api.GET("/lectures/:id", handler.GetLecture)
		api.PUT("/lectures/:id", handler.UpdateLecture)
		api.DELETE("/lectures/:id", handler.DeleteLecture)

		// Payment endpoints
		api.POST("/payments/billing-key", handler.CreateBillingKey)
		api.POST("/payments/subscribe", handler.Subscribe)
		api.POST("/payments/webhook", handler.PaymentWebhook)
	}
}
