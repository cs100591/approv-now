/// Plan types available
enum PlanType {
  free,
  starter,
  pro,
}

extension PlanTypeExt on PlanType {
  String get displayName {
    switch (this) {
      case PlanType.free:
        return 'Free';
      case PlanType.starter:
        return 'Starter';
      case PlanType.pro:
        return 'Pro';
    }
  }

  String get price {
    switch (this) {
      case PlanType.free:
        return 'Free';
      case PlanType.starter:
        return '\$5.99/mo';
      case PlanType.pro:
        return '\$15.99/mo';
    }
  }
}

/// Feature entitlements by plan
/// All limits are enforced per-user (subscription owner), not per-workspace.
class PlanEntitlements {
  // Workspace & Template limits
  final int maxTemplates; // -1 = unlimited
  final int maxApprovalLevels;
  final int maxWorkspaces; // owned workspaces
  final int maxTeamMembers; // per workspace

  // PDF Header behaviour
  /// true  → PDF shows full "Approv Now" brand header (large)
  /// false → PDF shows workspace-name header (Starter) or custom (Pro)
  final bool showBrandHeader;

  /// true  → Pro plan: full custom header with logo + description
  final bool customHeader;

  // Verification hash on PDF
  final bool hasHash;

  // Email notifications
  final bool emailNotification;

  // Excel export
  final bool excelExport;

  // Analytics / stats
  final bool analytics;

  const PlanEntitlements({
    required this.maxTemplates,
    required this.maxApprovalLevels,
    required this.maxWorkspaces,
    required this.maxTeamMembers,
    required this.showBrandHeader,
    required this.customHeader,
    required this.hasHash,
    required this.emailNotification,
    required this.excelExport,
    required this.analytics,
  });

  factory PlanEntitlements.forPlan(PlanType plan) {
    switch (plan) {
      // ── Free ────────────────────────────────────────────────────────────
      case PlanType.free:
        return const PlanEntitlements(
          maxTemplates: 1,
          maxApprovalLevels: 3,
          maxWorkspaces: 1,
          maxTeamMembers: 5,
          showBrandHeader: true, // small "Approv Now" header
          customHeader: false,
          hasHash: true,
          emailNotification: false,
          excelExport: false,
          analytics: false,
        );

      // ── Starter ─────────────────────────────────────────────────────────
      case PlanType.starter:
        return const PlanEntitlements(
          maxTemplates: 5,
          maxApprovalLevels: 5,
          maxWorkspaces: 3,
          maxTeamMembers: 15,
          showBrandHeader: false, // workspace name header instead
          customHeader: false,
          hasHash: true,
          emailNotification: true,
          excelExport: true,
          analytics: true,
        );

      // ── Pro ──────────────────────────────────────────────────────────────
      case PlanType.pro:
        return const PlanEntitlements(
          maxTemplates: -1, // unlimited
          maxApprovalLevels: 10,
          maxWorkspaces: -1, // unlimited
          maxTeamMembers: -1, // unlimited
          showBrandHeader: false,
          customHeader: true, // workspace name + description + logo
          hasHash: true,
          emailNotification: true,
          excelExport: true,
          analytics: true,
        );
    }
  }

  bool get hasUnlimitedTemplates => maxTemplates == -1;
  bool get hasUnlimitedWorkspaces => maxWorkspaces == -1;
  bool get hasUnlimitedTeamMembers => maxTeamMembers == -1;

  String get templatesDisplay =>
      hasUnlimitedTemplates ? 'Unlimited' : '$maxTemplates';
  String get workspacesDisplay =>
      hasUnlimitedWorkspaces ? 'Unlimited' : '$maxWorkspaces';
  String get teamMembersDisplay =>
      hasUnlimitedTeamMembers ? 'Unlimited' : '$maxTeamMembers';
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
