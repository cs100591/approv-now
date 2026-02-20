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

  /// Load subscription for user
  Future<void> loadSubscription(String userId) async {
    _setLoading(true);

    try {
      final subscription =
          await _subscriptionRepository.getSubscription(userId);
      if (subscription != null) {
        _subscriptionService.initialize(subscription);
        _state = _state.copyWith(subscription: subscription);
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
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
    }

    _setLoading(false);
  }

  /// Validate template creation
  bool canCreateTemplate(int currentCount) {
    return _subscriptionService.canCreateTemplate(currentCount);
  }

  /// Validate workspace creation
  bool canCreateWorkspace(int currentCount) {
    return _subscriptionService.canCreateWorkspace(currentCount);
  }

  /// Validate approval level addition
  bool canAddApprovalLevel(int currentCount) {
    return _subscriptionService.canAddApprovalLevel(currentCount);
  }

  /// Check custom header availability
  bool get canUseCustomHeader => _subscriptionService.canUseCustomHeader;

  /// Check if watermark should be applied
  bool get shouldApplyWatermark => _subscriptionService.shouldApplyWatermark;

  /// Check analytics availability
  bool get canUseAnalytics => _subscriptionService.canUseAnalytics;

  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
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
