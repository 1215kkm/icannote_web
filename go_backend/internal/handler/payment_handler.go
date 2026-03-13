package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func CreateBillingKey(c *gin.Context) {
	var req struct {
		CustomerKey string `json:"customer_key" binding:"required"`
		AuthKey     string `json:"auth_key" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Call TossPayments API to issue billing key
	c.JSON(http.StatusOK, gin.H{
		"message": "Billing key created",
	})
}

func Subscribe(c *gin.Context) {
	var req struct {
		CustomerKey string `json:"customer_key" binding:"required"`
		Plan        string `json:"plan" binding:"required"` // "free", "pro", "enterprise"
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Process subscription with TossPayments
	c.JSON(http.StatusOK, gin.H{
		"message": "Subscription activated",
		"plan":    req.Plan,
	})
}

func PaymentWebhook(c *gin.Context) {
	// TODO: Handle TossPayments webhook
	c.JSON(http.StatusOK, gin.H{
		"message": "Webhook received",
	})
}
