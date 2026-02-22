import 'subscription_models.dart';

/// SubscriptionService - Handles subscription management and plan validation
class SubscriptionService {
  Subscription? _currentSubscription;
  PlanType _overridePlan = PlanType.free;
  bool _hasOverride = false;

  void checkOverride(String email) {
    // Developer override email — always Pro
    if (email.trim() == 'cs1005.91@gmail.com') {
      _overridePlan = PlanType.pro;
      _hasOverride = true;
    } else {
      _overridePlan = PlanType.free;
      _hasOverride = false;
    }
  }

  /// Initialize with a subscription
  void initialize(Subscription subscription) {
    _currentSubscription = subscription;
  }

  /// Get current subscription
  Subscription? get currentSubscription => _currentSubscription;

  /// Get current plan type (override takes precedence)
  PlanType get currentPlan {
    if (_hasOverride) return _overridePlan;
    if (_currentSubscription?.isValid == true) {
      return _currentSubscription!.plan;
    }
    return PlanType.free;
  }

  /// Get entitlements for current plan
  PlanEntitlements get entitlements => PlanEntitlements.forPlan(currentPlan);

  /// Check if subscription is valid
  bool get isValid => _currentSubscription?.isValid ?? true;

  // ── Template guards ────────────────────────────────────────────────────────

  bool canCreateTemplate(int currentTemplateCount) {
    final limit = entitlements.maxTemplates;
    if (limit == -1) return true; // unlimited
    return currentTemplateCount < limit;
  }

  // ── Workspace guards ───────────────────────────────────────────────────────

  bool canCreateWorkspace(int currentWorkspaceCount) {
    final limit = entitlements.maxWorkspaces;
    if (limit == -1) return true;
    return currentWorkspaceCount < limit;
  }

  // ── Approval level guards ──────────────────────────────────────────────────

  bool canAddApprovalLevel(int currentLevelCount) {
    return currentLevelCount < entitlements.maxApprovalLevels;
  }

  // ── Team member guards ─────────────────────────────────────────────────────

  bool canInviteTeamMember(int currentMemberCount) {
    final limit = entitlements.maxTeamMembers;
    if (limit == -1) return true;
    return currentMemberCount < limit;
  }

  // ── PDF / Header entitlements ──────────────────────────────────────────────

  /// Should the PDF show the large Approv Now brand header?
  bool get showBrandHeader => entitlements.showBrandHeader;

  /// Can the user set a fully custom header (Pro)?
  bool get canUseCustomHeader => entitlements.customHeader;

  // ── Feature entitlements ───────────────────────────────────────────────────

  bool get hasHash => entitlements.hasHash;
  bool get canUseEmailNotification => entitlements.emailNotification;
  bool get canExportExcel => entitlements.excelExport;
  bool get canUseAnalytics => entitlements.analytics;

  // ── Plan operations ────────────────────────────────────────────────────────

  /// Upgrade plan and persist in service
  Future<Subscription> upgradePlan({
    required String userId,
    required PlanType newPlan,
    DateTime? expiresAt,
    String? revenueCatId,
  }) async {
    final subscription = Subscription(
      userId: userId,
      plan: newPlan,
      expiresAt: expiresAt,
      isActive: true,
      revenueCatId: revenueCatId,
      createdAt: _currentSubscription?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _currentSubscription = subscription;
    return subscription;
  }

  /// Cancel subscription (downgrade to free at period end)
  Future<void> cancelSubscription() async {
    if (_currentSubscription != null) {
      _currentSubscription = _currentSubscription!.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Restore purchases (RevenueCat integration point)
  Future<Subscription?> restorePurchases(String userId) async {
    // TODO: call RevenueCat SDK to restore
    return null;
  }
}
