/// Subscription plan tiers.
enum SubscriptionPlan {
  free,
  pro,
  enterprise;

  static SubscriptionPlan fromString(String value) {
    switch (value) {
      case 'pro':
        return SubscriptionPlan.pro;
      case 'enterprise':
        return SubscriptionPlan.enterprise;
      default:
        return SubscriptionPlan.free;
    }
  }
}

/// Subscription status.
enum SubscriptionStatus {
  active,
  cancelled,
  pastDue,
  expired,
  none;

  static SubscriptionStatus fromString(String value) {
    switch (value) {
      case 'active':
        return SubscriptionStatus.active;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.none;
    }
  }

  String toJson() {
    switch (this) {
      case SubscriptionStatus.active:
        return 'active';
      case SubscriptionStatus.cancelled:
        return 'cancelled';
      case SubscriptionStatus.pastDue:
        return 'past_due';
      case SubscriptionStatus.expired:
        return 'expired';
      case SubscriptionStatus.none:
        return 'none';
    }
  }
}

/// Details of a user's subscription.
class SubscriptionInfo {
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final String? billingKey;
  final String? customerKey;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? cancelledAt;

  const SubscriptionInfo({
    this.plan = SubscriptionPlan.free,
    this.status = SubscriptionStatus.none,
    this.billingKey,
    this.customerKey,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelledAt,
  });

  bool get isActive =>
      status == SubscriptionStatus.active && plan != SubscriptionPlan.free;

  bool get isPro => plan == SubscriptionPlan.pro && isActive;
  bool get isEnterprise => plan == SubscriptionPlan.enterprise && isActive;
  bool get isFree => plan == SubscriptionPlan.free || !isActive;

  SubscriptionInfo copyWith({
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    String? billingKey,
    String? customerKey,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? cancelledAt,
  }) {
    return SubscriptionInfo(
      plan: plan ?? this.plan,
      status: status ?? this.status,
      billingKey: billingKey ?? this.billingKey,
      customerKey: customerKey ?? this.customerKey,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan': plan.name,
        'status': status.toJson(),
        'billingKey': billingKey,
        'customerKey': customerKey,
        'currentPeriodStart': currentPeriodStart?.toIso8601String(),
        'currentPeriodEnd': currentPeriodEnd?.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
      };

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      plan: SubscriptionPlan.fromString(json['plan'] as String? ?? 'free'),
      status: SubscriptionStatus.fromString(
          json['status'] as String? ?? 'none'),
      billingKey: json['billingKey'] as String?,
      customerKey: json['customerKey'] as String?,
      currentPeriodStart: json['currentPeriodStart'] != null
          ? DateTime.parse(json['currentPeriodStart'] as String)
          : null,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.parse(json['currentPeriodEnd'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
    );
  }
}

/// Plan feature limits.
class PlanLimits {
  final int maxLectures;
  final int maxPagesPerLecture;
  final int maxCollaborators;
  final int storageBytes; // in bytes
  final bool canImportFiles;
  final bool canRecord;

  const PlanLimits({
    required this.maxLectures,
    required this.maxPagesPerLecture,
    required this.maxCollaborators,
    required this.storageBytes,
    required this.canImportFiles,
    required this.canRecord,
  });

  static const free = PlanLimits(
    maxLectures: 3,
    maxPagesPerLecture: 5,
    maxCollaborators: 0,
    storageBytes: 100 * 1024 * 1024, // 100MB
    canImportFiles: false,
    canRecord: false,
  );

  static const pro = PlanLimits(
    maxLectures: -1, // unlimited
    maxPagesPerLecture: -1,
    maxCollaborators: 30,
    storageBytes: 10 * 1024 * 1024 * 1024, // 10GB
    canImportFiles: true,
    canRecord: false,
  );

  static const enterprise = PlanLimits(
    maxLectures: -1,
    maxPagesPerLecture: -1,
    maxCollaborators: -1,
    storageBytes: -1, // unlimited
    canImportFiles: true,
    canRecord: true,
  );

  static PlanLimits forPlan(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.pro:
        return pro;
      case SubscriptionPlan.enterprise:
        return enterprise;
      default:
        return free;
    }
  }

  bool get isUnlimitedLectures => maxLectures < 0;
  bool get isUnlimitedPages => maxPagesPerLecture < 0;
  bool get isUnlimitedCollaborators => maxCollaborators < 0;
  bool get isUnlimitedStorage => storageBytes < 0;

  String get storageDisplay {
    if (isUnlimitedStorage) return 'Unlimited';
    if (storageBytes >= 1024 * 1024 * 1024) {
      return '${storageBytes ~/ (1024 * 1024 * 1024)}GB';
    }
    return '${storageBytes ~/ (1024 * 1024)}MB';
  }
}
