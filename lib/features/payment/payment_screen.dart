import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Payment screen for completing a subscription purchase.
///
/// On web, TossPayments is loaded via JavaScript SDK (iframe).
/// This screen handles the payment flow UI and result callback.
class PaymentScreen extends ConsumerStatefulWidget {
  final String planName;

  const PaymentScreen({super.key, required this.planName});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late SubscriptionPlan _selectedPlan;
  bool _isProcessing = false;
  String? _error;
  bool _paymentComplete = false;

  @override
  void initState() {
    super.initState();
    _selectedPlan = SubscriptionPlan.fromString(widget.planName);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please log in to subscribe.'),
              const SizedBox(height: AppDimensions.spacingXL),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      );
    }

    if (_paymentComplete) {
      return _PaymentSuccess(
        plan: _selectedPlan,
        onDone: () => context.go('/dashboard'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/subscription'),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(AppDimensions.spacingXXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order summary
              _OrderSummary(plan: _selectedPlan),
              const SizedBox(height: AppDimensions.spacingXXXL),

              // Payment method section
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingXXL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMD),
                  border: Border.all(color: AppColors.panelBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: AppDimensions.fontSizeLG,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // TossPayments widget placeholder
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.canvasBackground,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusSM),
                        border: Border.all(color: AppColors.panelBorder),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: AppDimensions.spacingXL),
                            Text(
                              'TossPayments Widget',
                              style: TextStyle(
                                fontSize: AppDimensions.fontSizeLG,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacingMD),
                            Text(
                              'Payment form will be loaded here\n'
                              'via TossPayments JavaScript SDK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppDimensions.fontSizeSM,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // For demo: direct activate button
                    Text(
                      'For testing, use the button below to simulate payment:',
                      style: TextStyle(
                        fontSize: AppDimensions.fontSizeSM,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXXL),

              // Error
              if (_error != null)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.spacingXL),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.accent),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Pay button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Pay ${_planPrice(_selectedPlan)}/month',
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSizeLG,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXL),

              // Terms
              Text(
                'By subscribing, you agree to our Terms of Service. '
                'Your subscription will automatically renew each month. '
                'You can cancel at any time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeXS,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    // For now, directly activate the plan (simulating payment success)
    // In production, this would:
    // 1. Call TossPayments JS SDK to get authKey
    // 2. Send authKey to Go backend to create billing key
    // 3. Backend activates subscription
    ref.read(subscriptionProvider.notifier).activatePlan(_selectedPlan);

    // Simulate brief processing delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _paymentComplete = true;
      });
    }
  }

  String _planPrice(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.pro:
        return '₩9,900';
      case SubscriptionPlan.enterprise:
        return '₩29,900';
      default:
        return 'Free';
    }
  }
}

class _OrderSummary extends StatelessWidget {
  final SubscriptionPlan plan;

  const _OrderSummary({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: AppDimensions.fontSizeLG,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ICanNote ${plan.name.toUpperCase()} Plan',
                style: const TextStyle(fontSize: AppDimensions.fontSizeMD),
              ),
              Text(
                _price(plan),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMD,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: AppDimensions.spacingXXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total (monthly)',
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeLG,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _price(plan),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeLG,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _price(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.pro:
        return '₩9,900';
      case SubscriptionPlan.enterprise:
        return '₩29,900';
      default:
        return 'Free';
    }
  }
}

class _PaymentSuccess extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback onDone;

  const _PaymentSuccess({required this.plan, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            Text(
              'Your ${plan.name.toUpperCase()} plan is now active.',
              style: TextStyle(
                fontSize: AppDimensions.fontSizeLG,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXXXL),
            ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXXXL,
                  vertical: AppDimensions.spacingLG,
                ),
              ),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
