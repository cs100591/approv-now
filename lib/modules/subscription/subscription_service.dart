import 'subscription_models.dart';

/// SubscriptionService - Handles subscription management and plan validation
class SubscriptionService {
  Subscription? _currentSubscription;

  /// Initialize with a subscription
  void initialize(Subscription subscription) {
    _currentSubscription = subscription;
  }

  /// Get current subscription
  Subscription? get currentSubscription => _currentSubscription;

  /// Get current plan type
  PlanType get currentPlan => _currentSubscription?.plan ?? PlanType.free;

  /// Get entitlements for current plan
  PlanEntitlements get entitlements => PlanEntitlements.forPlan(currentPlan);

  /// Check if subscription is valid
  bool get isValid => _currentSubscription?.isValid ?? true;

  /// Validate if user can create a template
  bool canCreateTemplate(int currentTemplateCount) {
    return currentTemplateCount < entitlements.maxTemplates;
  }

  /// Validate if user can create a workspace
  bool canCreateWorkspace(int currentWorkspaceCount) {
    return currentWorkspaceCount < entitlements.maxWorkspaces;
  }

  /// Validate if user can add an approval level
  bool canAddApprovalLevel(int currentLevelCount) {
    return currentLevelCount < entitlements.maxApprovalLevels;
  }

  /// Check if custom header is available
  bool get canUseCustomHeader => entitlements.customHeader;

  /// Check if watermark should be applied
  bool get shouldApplyWatermark => entitlements.watermark;

  /// Check if analytics is available
  bool get canUseAnalytics => entitlements.analytics;

  /// Upgrade plan
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _currentSubscription = subscription;
    return subscription;
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    if (_currentSubscription != null) {
      _currentSubscription = _currentSubscription!.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Restore purchases
  Future<Subscription?> restorePurchases(String userId) async {
    // This would integrate with RevenueCat to restore purchases
    // For now, return null
    return null;
  }

  /// Get plan limits display string
  String getPlanLimits(PlanType plan) {
    final entitlements = PlanEntitlements.forPlan(plan);
    return 'Templates: ${entitlements.maxTemplates}, '
        'Levels: ${entitlements.maxApprovalLevels}, '
        'Workspaces: ${entitlements.maxWorkspaces}';
  }
}
