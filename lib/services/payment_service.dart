import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/subscription_model.dart';

/// Service for interacting with the payment backend (TossPayments via Go API).
class PaymentService {
  // Base URL for the Go backend API
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  String? _authToken;

  /// Set the auth token for authenticated requests.
  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Create a billing key for recurring payments.
  /// Returns the TossPayments customer key on success.
  Future<String?> createBillingKey({
    required String customerKey,
    required String authKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/billing-key'),
        headers: _headers,
        body: jsonEncode({
          'customer_key': customerKey,
          'auth_key': authKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['customer_key'] as String?;
      }
      debugPrint('Create billing key failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Create billing key error: $e');
      return null;
    }
  }

  /// Subscribe to a plan.
  Future<SubscriptionInfo?> subscribe({
    required String customerKey,
    required SubscriptionPlan plan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/subscribe'),
        headers: _headers,
        body: jsonEncode({
          'customer_key': customerKey,
          'plan': plan.name,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['subscription'] != null) {
          return SubscriptionInfo.fromJson(
              data['subscription'] as Map<String, dynamic>);
        }
        // Return a basic active subscription if server doesn't return full info
        return SubscriptionInfo(
          plan: plan,
          status: SubscriptionStatus.active,
          customerKey: customerKey,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        );
      }
      debugPrint('Subscribe failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Subscribe error: $e');
      return null;
    }
  }

  /// Cancel the current subscription.
  Future<bool> cancelSubscription({required String customerKey}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/cancel'),
        headers: _headers,
        body: jsonEncode({
          'customer_key': customerKey,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Cancel subscription error: $e');
      return false;
    }
  }

  /// Get current subscription status.
  Future<SubscriptionInfo?> getSubscriptionStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/subscription'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SubscriptionInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Get subscription status error: $e');
      return null;
    }
  }

  /// Get the TossPayments client key for frontend widget.
  Future<String?> getTossClientKey() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/client-key'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['client_key'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Get client key error: $e');
      return null;
    }
  }
}
