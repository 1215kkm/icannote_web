import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_model.dart';
import '../services/payment_service.dart';
import 'auth_provider.dart';

class SubscriptionState {
  final SubscriptionInfo subscription;
  final bool isLoading;
  final String? errorMessage;

  const SubscriptionState({
    this.subscription = const SubscriptionInfo(),
    this.isLoading = false,
    this.errorMessage,
  });

  SubscriptionState copyWith({
    SubscriptionInfo? subscription,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  SubscriptionPlan get currentPlan => subscription.plan;
  PlanLimits get limits => PlanLimits.forPlan(subscription.plan);
  bool get isActive => subscription.isActive;
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final Ref _ref;
  final PaymentService _paymentService = PaymentService();

  SubscriptionNotifier(this._ref) : super(const SubscriptionState()) {
    _init();
  }

  void _init() {
    // Listen to auth changes to update payment service token
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.isAuthenticated) {
        _loadSubscription();
      } else {
        state = const SubscriptionState();
      }
    });

    // Check initial auth state
    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated) {
      _loadSubscription();
    }
  }

  /// Load subscription status from backend.
  Future<void> _loadSubscription() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final info = await _paymentService.getSubscriptionStatus();
      if (info != null) {
        state = state.copyWith(subscription: info, isLoading: false);
      } else {
        // Default to free plan
        state = state.copyWith(
          subscription: const SubscriptionInfo(),
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Load subscription error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load subscription.',
      );
    }
  }

  /// Subscribe to a plan after payment is completed.
  Future<bool> subscribe({
    required SubscriptionPlan plan,
    required String customerKey,
    required String authKey,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Step 1: Create billing key
      final billingResult = await _paymentService.createBillingKey(
        customerKey: customerKey,
        authKey: authKey,
      );

      if (billingResult == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to register payment method.',
        );
        return false;
      }

      // Step 2: Subscribe
      final subscriptionInfo = await _paymentService.subscribe(
        customerKey: customerKey,
        plan: plan,
      );

      if (subscriptionInfo != null) {
        state = state.copyWith(
          subscription: subscriptionInfo,
          isLoading: false,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to activate subscription.',
      );
      return false;
    } catch (e) {
      debugPrint('Subscribe error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Subscription failed: $e',
      );
      return false;
    }
  }

  /// Directly activate a plan (for demo/testing without real payment).
  void activatePlan(SubscriptionPlan plan) {
    state = state.copyWith(
      subscription: SubscriptionInfo(
        plan: plan,
        status: SubscriptionStatus.active,
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
      ),
    );
  }

  /// Cancel current subscription.
  Future<bool> cancelSubscription() async {
    final customerKey = state.subscription.customerKey;
    if (customerKey == null) {
      // If no customer key, just reset to free locally
      state = state.copyWith(
        subscription: const SubscriptionInfo(),
      );
      return true;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final success =
        await _paymentService.cancelSubscription(customerKey: customerKey);

    if (success) {
      state = state.copyWith(
        subscription: state.subscription.copyWith(
          status: SubscriptionStatus.cancelled,
          cancelledAt: DateTime.now(),
        ),
        isLoading: false,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Failed to cancel subscription.',
    );
    return false;
  }

  /// Refresh subscription from backend.
  Future<void> refresh() => _loadSubscription();

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref);
});
