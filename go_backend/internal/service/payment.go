package service

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/icannote/go_backend/internal/model"
)

const tossPaymentsBaseURL = "https://api.tosspayments.com/v1"

// PaymentService handles TossPayments API interactions.
type PaymentService struct {
	secretKey  string
	httpClient *http.Client
}

// NewPaymentService creates a new PaymentService.
func NewPaymentService(secretKey string) *PaymentService {
	return &PaymentService{
		secretKey: secretKey,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// authHeader returns the Basic auth header for TossPayments API.
func (s *PaymentService) authHeader() string {
	return "Basic " + base64.StdEncoding.EncodeToString(
		[]byte(s.secretKey+":"),
	)
}

// IssueBillingKeyRequest represents the request to issue a billing key.
type IssueBillingKeyRequest struct {
	CustomerKey string `json:"customerKey"`
	AuthKey     string `json:"authKey"`
}

// IssueBillingKeyResponse represents the TossPayments billing key response.
type IssueBillingKeyResponse struct {
	BillingKey  string `json:"billingKey"`
	CustomerKey string `json:"customerKey"`
	CardCompany string `json:"cardCompany"`
	CardNumber  string `json:"cardNumber"`
}

// IssueBillingKey creates a billing key for recurring payments.
func (s *PaymentService) IssueBillingKey(req IssueBillingKeyRequest) (*IssueBillingKeyResponse, error) {
	body, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	httpReq, err := http.NewRequest(
		"POST",
		tossPaymentsBaseURL+"/billing/authorizations/issue",
		bytes.NewReader(body),
	)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	httpReq.Header.Set("Authorization", s.authHeader())
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := s.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("http request: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("toss API error (%d): %s", resp.StatusCode, string(respBody))
	}

	var result IssueBillingKeyResponse
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("unmarshal response: %w", err)
	}

	return &result, nil
}

// ChargeRequest represents a billing charge request.
type ChargeRequest struct {
	BillingKey  string `json:"billingKey"`
	CustomerKey string `json:"customerKey"`
	Amount      int    `json:"amount"`
	OrderID     string `json:"orderId"`
	OrderName   string `json:"orderName"`
}

// ChargeResponse represents the TossPayments charge response.
type ChargeResponse struct {
	PaymentKey string `json:"paymentKey"`
	OrderID    string `json:"orderId"`
	Status     string `json:"status"`
	TotalAmount int   `json:"totalAmount"`
}

// ChargeBilling charges a billing key for a subscription payment.
func (s *PaymentService) ChargeBilling(req ChargeRequest) (*ChargeResponse, error) {
	body, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	httpReq, err := http.NewRequest(
		"POST",
		tossPaymentsBaseURL+"/billing/"+req.BillingKey,
		bytes.NewReader(body),
	)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	httpReq.Header.Set("Authorization", s.authHeader())
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := s.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("http request: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("toss API error (%d): %s", resp.StatusCode, string(respBody))
	}

	var result ChargeResponse
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("unmarshal response: %w", err)
	}

	return &result, nil
}

// SubscriptionService manages subscription lifecycle.
type SubscriptionService struct {
	payment *PaymentService
	// In production, this would be backed by Firestore.
	// For now, in-memory store for development.
	subscriptions map[string]*model.Subscription
}

// NewSubscriptionService creates a new SubscriptionService.
func NewSubscriptionService(payment *PaymentService) *SubscriptionService {
	return &SubscriptionService{
		payment:       payment,
		subscriptions: make(map[string]*model.Subscription),
	}
}

// GetSubscription returns the subscription for a user.
func (s *SubscriptionService) GetSubscription(userID string) *model.Subscription {
	sub, ok := s.subscriptions[userID]
	if !ok {
		return &model.Subscription{
			UserID: userID,
			Plan:   model.PlanFree,
			Status: model.StatusNone,
		}
	}
	return sub
}

// CreateSubscription creates or updates a subscription after billing key is issued.
func (s *SubscriptionService) CreateSubscription(
	userID string,
	plan model.SubscriptionPlan,
	billingKey string,
	customerKey string,
) *model.Subscription {
	now := time.Now()
	periodEnd := now.AddDate(0, 1, 0) // +1 month

	sub := &model.Subscription{
		UserID:             userID,
		Plan:               plan,
		Status:             model.StatusActive,
		BillingKey:         billingKey,
		CustomerKey:        customerKey,
		CurrentPeriodStart: &now,
		CurrentPeriodEnd:   &periodEnd,
		CreatedAt:          now,
		UpdatedAt:          now,
	}

	s.subscriptions[userID] = sub
	return sub
}

// CancelSubscription cancels a user's subscription.
func (s *SubscriptionService) CancelSubscription(userID string) *model.Subscription {
	sub, ok := s.subscriptions[userID]
	if !ok {
		return nil
	}

	now := time.Now()
	sub.Status = model.StatusCancelled
	sub.CancelledAt = &now
	sub.UpdatedAt = now

	return sub
}
