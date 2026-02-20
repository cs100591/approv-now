/// Plan types available
enum PlanType {
  free,
  starter,
  pro,
}

/// Feature entitlements by plan
class PlanEntitlements {
  final int maxTemplates;
  final int maxApprovalLevels;
  final int maxWorkspaces;
  final bool customHeader;
  final bool watermark;
  final bool analytics;

  const PlanEntitlements({
    required this.maxTemplates,
    required this.maxApprovalLevels,
    required this.maxWorkspaces,
    required this.customHeader,
    required this.watermark,
    required this.analytics,
  });

  factory PlanEntitlements.forPlan(PlanType plan) {
    switch (plan) {
      case PlanType.free:
        return const PlanEntitlements(
          maxTemplates: 3,
          maxApprovalLevels: 2,
          maxWorkspaces: 1,
          customHeader: false,
          watermark: true,
          analytics: false,
        );
      case PlanType.starter:
        return const PlanEntitlements(
          maxTemplates: 10,
          maxApprovalLevels: 5,
          maxWorkspaces: 3,
          customHeader: false,
          watermark: false,
          analytics: true,
        );
      case PlanType.pro:
        return const PlanEntitlements(
          maxTemplates: 100,
          maxApprovalLevels: 10,
          maxWorkspaces: 10,
          customHeader: true,
          watermark: false,
          analytics: true,
        );
    }
  }
}

/// Subscription model
class Subscription {
  final String userId;
  final PlanType plan;
  final DateTime? expiresAt;
  final bool isActive;
  final String? revenueCatId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.userId,
    required this.plan,
    this.expiresAt,
    required this.isActive,
    this.revenueCatId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isValid => isActive && !isExpired;

  Subscription copyWith({
    String? userId,
    PlanType? plan,
    DateTime? expiresAt,
    bool? isActive,
    String? revenueCatId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      revenueCatId: revenueCatId ?? this.revenueCatId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'plan': plan.name,
        'expiresAt': expiresAt?.toIso8601String(),
        'isActive': isActive,
        'revenueCatId': revenueCatId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        userId: json['userId'] as String,
        plan: PlanType.values.firstWhere(
          (e) => e.name == json['plan'],
          orElse: () => PlanType.free,
        ),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
        revenueCatId: json['revenueCatId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
