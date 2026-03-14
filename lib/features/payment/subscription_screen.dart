import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Subscription plan selection and management screen.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXXL),
        child: Column(
          children: [
            // Header
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            Text(
              'Unlock the full potential of ICanNote',
              style: TextStyle(
                fontSize: AppDimensions.fontSizeLG,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXXXL),

            // Current plan indicator
            if (subState.isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXL,
                  vertical: AppDimensions.spacingMD,
                ),
                margin:
                    const EdgeInsets.only(bottom: AppDimensions.spacingXXL),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMD),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.secondary, size: 20),
                    const SizedBox(width: AppDimensions.spacingMD),
                    Text(
                      'Current plan: ${subState.currentPlan.name.toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Plan cards
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth > 900
                    ? (constraints.maxWidth - 48) / 3
                    : constraints.maxWidth > 600
                        ? (constraints.maxWidth - 24) / 2
                        : constraints.maxWidth;

                return Wrap(
                  spacing: AppDimensions.spacingXXL,
                  runSpacing: AppDimensions.spacingXXL,
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _PlanCard(
                        plan: SubscriptionPlan.free,
                        currentPlan: subState.currentPlan,
                        isAuthenticated: authState.isAuthenticated,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _PlanCard(
                        plan: SubscriptionPlan.pro,
                        currentPlan: subState.currentPlan,
                        isAuthenticated: authState.isAuthenticated,
                        isPopular: true,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _PlanCard(
                        plan: SubscriptionPlan.enterprise,
                        currentPlan: subState.currentPlan,
                        isAuthenticated: authState.isAuthenticated,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppDimensions.spacingXXXL),

            // Subscription management
            if (subState.isActive) ...[
              const Divider(),
              const SizedBox(height: AppDimensions.spacingXL),
              _SubscriptionManagement(subState: subState),
            ],

            // Loading overlay
            if (subState.isLoading)
              const Padding(
                padding: EdgeInsets.all(AppDimensions.spacingXXL),
                child: CircularProgressIndicator(),
              ),

            // Error message
            if (subState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingXL),
                child: Text(
                  subState.errorMessage!,
                  style: const TextStyle(color: AppColors.accent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final SubscriptionPlan plan;
  final SubscriptionPlan currentPlan;
  final bool isAuthenticated;
  final bool isPopular;

  const _PlanCard({
    required this.plan,
    required this.currentPlan,
    required this.isAuthenticated,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrentPlan = plan == currentPlan;
    final limits = PlanLimits.forPlan(plan);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
        border: Border.all(
          color: isPopular ? AppColors.primary : AppColors.panelBorder,
          width: isPopular
              ? AppDimensions.borderWidthThick
              : AppDimensions.borderWidthThin,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: AppDimensions.shadowBlurMD,
            offset: const Offset(0, AppDimensions.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Popular badge
          if (isPopular)
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: AppDimensions.spacingMD),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.borderRadiusMD - 1),
                  topRight: Radius.circular(AppDimensions.borderRadiusMD - 1),
                ),
              ),
              child: const Text(
                'MOST POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontSizeSM,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingXXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name
                Text(
                  _planName(plan),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMD),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _planPrice(plan),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plan != SubscriptionPlan.free)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          '/month',
                          style: TextStyle(
                            fontSize: AppDimensions.fontSizeMD,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMD),

                // Description
                Text(
                  _planDescription(plan),
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeMD,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXXL),
                const Divider(),
                const SizedBox(height: AppDimensions.spacingXL),

                // Features
                _FeatureItem(
                  text: limits.isUnlimitedLectures
                      ? 'Unlimited lectures'
                      : '${limits.maxLectures} lectures',
                  included: true,
                ),
                _FeatureItem(
                  text: limits.isUnlimitedPages
                      ? 'Unlimited pages'
                      : '${limits.maxPagesPerLecture} pages/lecture',
                  included: true,
                ),
                _FeatureItem(
                  text: limits.isUnlimitedCollaborators
                      ? 'Unlimited collaborators'
                      : limits.maxCollaborators > 0
                          ? 'Up to ${limits.maxCollaborators} collaborators'
                          : 'No collaboration',
                  included: limits.maxCollaborators != 0,
                ),
                _FeatureItem(
                  text: '${limits.storageDisplay} storage',
                  included: true,
                ),
                _FeatureItem(
                  text: 'File import (PDF, PPT, HWP)',
                  included: limits.canImportFiles,
                ),
                _FeatureItem(
                  text: 'Lecture recording',
                  included: limits.canRecord,
                ),
                if (plan == SubscriptionPlan.enterprise)
                  const _FeatureItem(
                    text: 'Priority support',
                    included: true,
                  ),

                const SizedBox(height: AppDimensions.spacingXXL),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => _handleSelect(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPopular ? AppColors.primary : null,
                      foregroundColor:
                          isPopular ? Colors.white : null,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spacingLG),
                    ),
                    child: Text(
                      isCurrentPlan
                          ? 'Current Plan'
                          : plan == SubscriptionPlan.free
                              ? 'Get Started'
                              : 'Subscribe',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSelect(BuildContext context, WidgetRef ref) {
    if (!isAuthenticated) {
      context.go('/login');
      return;
    }

    if (plan == SubscriptionPlan.free) {
      // Downgrade to free
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Downgrade to Free?'),
          content: const Text(
            'You will lose access to premium features. '
            'Your subscription will remain active until the end of the current billing period.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(subscriptionProvider.notifier).cancelSubscription();
                Navigator.pop(ctx);
              },
              child: const Text('Downgrade'),
            ),
          ],
        ),
      );
    } else {
      // Navigate to payment screen
      context.go('/payment/${plan.name}');
    }
  }

  String _planName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  String _planPrice(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.pro:
        return '₩9,900';
      case SubscriptionPlan.enterprise:
        return '₩29,900';
    }
  }

  String _planDescription(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Perfect for getting started';
      case SubscriptionPlan.pro:
        return 'For instructors and teams';
      case SubscriptionPlan.enterprise:
        return 'For organizations and schools';
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  final bool included;

  const _FeatureItem({required this.text, required this.included});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSM),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            size: AppDimensions.iconSizeSM,
            color: included ? AppColors.secondary : Colors.grey.shade400,
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppDimensions.fontSizeMD,
                color: included ? Colors.black87 : Colors.grey.shade400,
                decoration:
                    included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionManagement extends ConsumerWidget {
  final SubscriptionState subState;

  const _SubscriptionManagement({required this.subState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = subState.subscription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subscription Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXL),
        _InfoRow('Plan', sub.plan.name.toUpperCase()),
        _InfoRow('Status', sub.status.toJson()),
        if (sub.currentPeriodEnd != null)
          _InfoRow(
            'Next billing date',
            '${sub.currentPeriodEnd!.year}-${sub.currentPeriodEnd!.month.toString().padLeft(2, '0')}-${sub.currentPeriodEnd!.day.toString().padLeft(2, '0')}',
          ),
        if (sub.cancelledAt != null)
          _InfoRow(
            'Cancelled on',
            '${sub.cancelledAt!.year}-${sub.cancelledAt!.month.toString().padLeft(2, '0')}-${sub.cancelledAt!.day.toString().padLeft(2, '0')}',
          ),
        const SizedBox(height: AppDimensions.spacingXL),
        if (sub.status == SubscriptionStatus.active)
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cancel Subscription?'),
                  content: const Text(
                    'Your subscription will remain active until the end '
                    'of the current billing period.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      onPressed: () {
                        ref
                            .read(subscriptionProvider.notifier)
                            .cancelSubscription();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Cancel Subscription'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Cancel Subscription'),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSM),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: AppDimensions.fontSizeMD,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: AppDimensions.fontSizeMD,
            ),
          ),
        ],
      ),
    );
  }
}
