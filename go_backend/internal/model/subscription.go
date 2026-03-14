package model

import "time"

// SubscriptionPlan represents available subscription tiers.
type SubscriptionPlan string

const (
	PlanFree       SubscriptionPlan = "free"
	PlanPro        SubscriptionPlan = "pro"
	PlanEnterprise SubscriptionPlan = "enterprise"
)

// SubscriptionStatus represents the current state of a subscription.
type SubscriptionStatus string

const (
	StatusActive    SubscriptionStatus = "active"
	StatusCancelled SubscriptionStatus = "cancelled"
	StatusPastDue   SubscriptionStatus = "past_due"
	StatusExpired   SubscriptionStatus = "expired"
	StatusNone      SubscriptionStatus = "none"
)

// Subscription holds subscription data for a user.
type Subscription struct {
	UserID             string             `json:"user_id"`
	Plan               SubscriptionPlan   `json:"plan"`
	Status             SubscriptionStatus `json:"status"`
	BillingKey         string             `json:"billing_key,omitempty"`
	CustomerKey        string             `json:"customer_key,omitempty"`
	CurrentPeriodStart *time.Time         `json:"current_period_start,omitempty"`
	CurrentPeriodEnd   *time.Time         `json:"current_period_end,omitempty"`
	CancelledAt        *time.Time         `json:"cancelled_at,omitempty"`
	CreatedAt          time.Time          `json:"created_at"`
	UpdatedAt          time.Time          `json:"updated_at"`
}

// PlanPrice returns the monthly price in KRW for a given plan.
func PlanPrice(plan SubscriptionPlan) int {
	switch plan {
	case PlanPro:
		return 9900
	case PlanEnterprise:
		return 29900
	default:
		return 0
	}
}
