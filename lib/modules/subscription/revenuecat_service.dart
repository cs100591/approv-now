import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'subscription_models.dart';
import 'subscription_service.dart';
import 'revenuecat_config.dart';

/// RevenueCat service - Handles all in-app purchase operations
///
/// This service is designed to fail gracefully - if RevenueCat fails to
/// initialize, the app will continue to work with the free plan.
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  static RevenueCatService get instance => _instance;

  RevenueCatService._internal();

  SubscriptionService? _subscriptionService;
  bool _isInitialized = false;
  bool _initializationFailed = false;

  /// Check if RevenueCat is initialized
  bool get isInitialized => _isInitialized;

  /// Check if initialization failed (app can still function)
  bool get initializationFailed => _initializationFailed;

  /// Initialize RevenueCat SDK
  ///
  /// This method is safe to call multiple times and will not crash the app
  /// if RevenueCat fails to initialize. The app will continue to work
  /// with the free plan.
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;
    if (_initializationFailed) {
      debugPrint(
          '⚠️ RevenueCat initialization was previously failed. Skipping.');
      return;
    }

    try {
      // Verify configuration before initializing
      RevenueCatConfig.verifyProductionConfiguration();

      // Attempt to initialize
      final success = await RevenueCatConfig.initialize(userId: userId);

      if (!success) {
        _initializationFailed = true;
        debugPrint(
            '⚠️ RevenueCat initialization failed. App will use free plan.');
        return;
      }

      // Set up listener for purchase updates
      Purchases.addCustomerInfoUpdateListener(_handlePurchaseUpdate);

      _isInitialized = true;
      debugPrint('✅ RevenueCat fully initialized for user: $userId');
    } catch (e, stackTrace) {
      _initializationFailed = true;
      debugPrint('❌ RevenueCat initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint(
          'ℹ️ App will continue with free plan. Subscriptions unavailable.');

      // Don't rethrow - app should continue to function
    }
  }

  /// Handle purchase status updates
  void _handlePurchaseUpdate(CustomerInfo customerInfo) {
    if (_subscriptionService == null) return;

    try {
      // Get entitlements
      final entitlementInfo = customerInfo.entitlements.all['pro'];

      if (entitlementInfo != null && entitlementInfo.isActive) {
        // User has active Pro subscription
        _subscriptionService?.upgradePlan(
          userId: customerInfo.originalAppUserId,
          newPlan: PlanType.pro,
          expiresAt: entitlementInfo.expirationDate != null
              ? DateTime.parse(entitlementInfo.expirationDate!)
              : null,
          revenueCatId: customerInfo.originalAppUserId,
        );
      } else {
        // Check for Starter entitlement
        final starterEntitlement = customerInfo.entitlements.all['starter'];
        if (starterEntitlement != null && starterEntitlement.isActive) {
          _subscriptionService?.upgradePlan(
            userId: customerInfo.originalAppUserId,
            newPlan: PlanType.starter,
            expiresAt: starterEntitlement.expirationDate != null
                ? DateTime.parse(starterEntitlement.expirationDate!)
                : null,
            revenueCatId: customerInfo.originalAppUserId,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling purchase update: $e');
    }
  }

  /// Get available products/offerings
  ///
  /// Returns null if RevenueCat is not initialized or failed to initialize
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized. Cannot fetch offerings.');
      return null;
    }

    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  ///
  /// Returns false if RevenueCat is not initialized or purchase failed
  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized. Cannot purchase.');
      return false;
    }

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all.values.any((e) => e.isActive);
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      return false;
    }
  }

  /// Restore purchases
  ///
  /// Returns false if RevenueCat is not initialized or restore failed
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized. Cannot restore purchases.');
      return false;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all.values.any((e) => e.isActive);
    } catch (e) {
      debugPrint('❌ Restore error: $e');
      return false;
    }
  }

  /// Get current customer info
  ///
  /// Returns null if RevenueCat is not initialized
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized. Cannot get customer info.');
      return null;
    }

    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('❌ Error getting customer info: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  ///
  /// Returns false if RevenueCat is not initialized
  Future<bool> hasActiveSubscription() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized. Cannot check subscription.');
      return false;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all.values.any((e) => e.isActive);
    } catch (e) {
      debugPrint('❌ Error checking subscription: $e');
      return false;
    }
  }

  /// Log out user (clear RevenueCat data)
  Future<void> logout() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized. Nothing to log out.');
      return;
    }

    try {
      await Purchases.logOut();
      _isInitialized = false;
      _initializationFailed = false;
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }

  /// Dispose and cleanup
  void dispose() {
    if (_isInitialized) {
      Purchases.removeCustomerInfoUpdateListener(_handlePurchaseUpdate);
    }
  }

  /// Set subscription service for callbacks
  void setSubscriptionService(SubscriptionService service) {
    _subscriptionService = service;
  }
}
