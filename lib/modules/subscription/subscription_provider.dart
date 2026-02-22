import 'package:flutter/foundation.dart';
import 'subscription_models.dart';
import 'subscription_service.dart';
import 'subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService;
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionState _state = const SubscriptionState();

  SubscriptionProvider({
    required SubscriptionService subscriptionService,
    required SubscriptionRepository subscriptionRepository,
  })  : _subscriptionService = subscriptionService,
        _subscriptionRepository = subscriptionRepository;

  SubscriptionState get state => _state;
  Subscription? get subscription => _subscriptionService.currentSubscription;
  PlanType get currentPlan => _subscriptionService.currentPlan;
  PlanEntitlements get entitlements => _subscriptionService.entitlements;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  // ── Convenience entitlement getters ─────────────────────────────────────

  bool get showBrandHeader => _subscriptionService.showBrandHeader;
  bool get canUseCustomHeader => _subscriptionService.canUseCustomHeader;
  bool get hasHash => _subscriptionService.hasHash;
  bool get canUseEmailNotification =>
      _subscriptionService.canUseEmailNotification;
  bool get canExportExcel => _subscriptionService.canExportExcel;
  bool get canUseAnalytics => _subscriptionService.canUseAnalytics;

  void checkOverride(String email) {
    _subscriptionService.checkOverride(email);
    notifyListeners();
  }

  /// Load subscription for user from local cache
  Future<void> loadSubscription(String userId) async {
    _setLoading(true);

    try {
      final subscription =
          await _subscriptionRepository.getSubscription(userId);
      if (subscription != null) {
        _subscriptionService.initialize(subscription);
        _state = _state.copyWith(subscription: subscription);
      } else {
        // Default to free plan
        final freeSub = Subscription(
          userId: userId,
          plan: PlanType.free,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _subscriptionService.initialize(freeSub);
        _state = _state.copyWith(subscription: freeSub);
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }

    _setLoading(false);
  }

  /// Upgrade plan
  Future<void> upgradePlan({
    required String userId,
    required PlanType newPlan,
    DateTime? expiresAt,
    String? revenueCatId,
  }) async {
    _setLoading(true);

    try {
      final subscription = await _subscriptionService.upgradePlan(
        userId: userId,
        newPlan: newPlan,
        expiresAt: expiresAt,
        revenueCatId: revenueCatId,
      );

      await _subscriptionRepository.saveSubscription(subscription);
      _state = _state.copyWith(subscription: subscription);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }

    _setLoading(false);
  }

  // ── Plan-action guards ────────────────────────────────────────────────────

  bool canCreateTemplate(int currentCount) =>
      _subscriptionService.canCreateTemplate(currentCount);

  bool canCreateWorkspace(int currentCount) =>
      _subscriptionService.canCreateWorkspace(currentCount);

  bool canAddApprovalLevel(int currentCount) =>
      _subscriptionService.canAddApprovalLevel(currentCount);

  bool canInviteTeamMember(int currentCount) =>
      _subscriptionService.canInviteTeamMember(currentCount);

  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }

  void reset() {
    _subscriptionService.initialize(Subscription(
      userId: '',
      plan: PlanType.free,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    _state = const SubscriptionState();
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }
}

/// State for subscription provider
class SubscriptionState {
  final Subscription? subscription;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
