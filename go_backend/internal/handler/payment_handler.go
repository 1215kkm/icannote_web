package handler

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/icannote/go_backend/internal/model"
	"github.com/icannote/go_backend/internal/service"
)

var (
	paymentSvc      *service.PaymentService
	subscriptionSvc *service.SubscriptionService
)

// InitPaymentHandlers initializes the payment service dependencies.
func InitPaymentHandlers(tossSecretKey string) {
	paymentSvc = service.NewPaymentService(tossSecretKey)
	subscriptionSvc = service.NewSubscriptionService(paymentSvc)
}

// CreateBillingKey issues a billing key via TossPayments and activates a subscription.
func CreateBillingKey(c *gin.Context) {
	var req struct {
		CustomerKey string `json:"customer_key" binding:"required"`
		AuthKey     string `json:"auth_key" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	// Issue billing key via TossPayments
	if paymentSvc != nil {
		result, err := paymentSvc.IssueBillingKey(service.IssueBillingKeyRequest{
			CustomerKey: req.CustomerKey,
			AuthKey:     req.AuthKey,
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   "Failed to issue billing key",
				"details": err.Error(),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":      "Billing key created",
			"customer_key": result.CustomerKey,
			"billing_key":  result.BillingKey,
		})
		_ = userID // will be used when persisting to Firestore
		return
	}

	// Fallback: stub response for development
	c.JSON(http.StatusOK, gin.H{
		"message":      "Billing key created (dev mode)",
		"customer_key": req.CustomerKey,
		"billing_key":  fmt.Sprintf("billing_%s_%d", req.CustomerKey, time.Now().Unix()),
	})
}

// Subscribe activates a subscription for the authenticated user.
func Subscribe(c *gin.Context) {
	var req struct {
		CustomerKey string `json:"customer_key" binding:"required"`
		Plan        string `json:"plan" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate plan
	plan := model.SubscriptionPlan(req.Plan)
	if plan != model.PlanPro && plan != model.PlanEnterprise {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid plan. Must be 'pro' or 'enterprise'."})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	if subscriptionSvc != nil {
		sub := subscriptionSvc.CreateSubscription(
			userID.(string),
			plan,
			"", // billing key would come from CreateBillingKey step
			req.CustomerKey,
		)

		c.JSON(http.StatusOK, gin.H{
			"message":      "Subscription activated",
			"subscription": sub,
		})
		return
	}

	// Fallback stub
	c.JSON(http.StatusOK, gin.H{
		"message": "Subscription activated",
		"plan":    req.Plan,
	})
}

// GetSubscription returns the current subscription for the authenticated user.
func GetSubscription(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	if subscriptionSvc != nil {
		sub := subscriptionSvc.GetSubscription(userID.(string))
		c.JSON(http.StatusOK, sub)
		return
	}

	// Fallback: free plan
	c.JSON(http.StatusOK, gin.H{
		"plan":   "free",
		"status": "none",
	})
}

// CancelSubscription cancels the authenticated user's subscription.
func CancelSubscription(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	if subscriptionSvc != nil {
		sub := subscriptionSvc.CancelSubscription(userID.(string))
		if sub == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "No active subscription found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":      "Subscription cancelled",
			"subscription": sub,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Subscription cancelled",
	})
}

// PaymentWebhook handles TossPayments webhook callbacks.
func PaymentWebhook(c *gin.Context) {
	var payload map[string]interface{}
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Verify webhook signature
	// TODO: Process payment events (success, failure, refund)
	// TODO: Update subscription status in Firestore

	eventType, _ := payload["eventType"].(string)
	fmt.Printf("Received webhook event: %s\n", eventType)

	c.JSON(http.StatusOK, gin.H{
		"message": "Webhook received",
	})
}

// GetClientKey returns the TossPayments client key for frontend.
func GetClientKey(c *gin.Context) {
	// In production, this would come from config
	// The client key is safe to expose to the frontend
	clientKey := "test_ck_dummy_client_key"

	c.JSON(http.StatusOK, gin.H{
		"client_key": clientKey,
	})
}
