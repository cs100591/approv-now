import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'subscription_models.dart';
import 'subscription_service.dart';
import 'revenuecat_config.dart';

/// RevenueCat service - Handles all in-app purchase operations
class RevenueCatService {
  final SubscriptionService _subscriptionService;
  bool _isInitialized = false;

  RevenueCatService(this._subscriptionService);

  /// Initialize RevenueCat SDK
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      // Get platform-specific API key
      String apiKey;
      if (kIsWeb) {
        apiKey = 'YOUR_WEB_API_KEY_HERE';
      } else {
        // Use dart:io Platform for mobile
        if (Platform.isIOS) {
          apiKey = 'YOUR_IOS_API_KEY_HERE';
        } else if (Platform.isAndroid) {
          apiKey = 'YOUR_ANDROID_API_KEY_HERE';
        } else {
          apiKey = 'YOUR_IOS_API_KEY_HERE'; // Fallback
        }
      }

      // Configure RevenueCat
      await Purchases.setLogLevel(LogLevel.debug);
      final configuration = PurchasesConfiguration(apiKey)..appUserID = userId;

      await Purchases.configure(configuration);

      // Set up listener for purchase updates
      Purchases.addCustomerInfoUpdateListener(_handlePurchaseUpdate);

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized for user: $userId');
    } catch (e) {
      debugPrint('❌ RevenueCat initialization error: $e');
      rethrow;
    }
  }

  /// Handle purchase status updates
  void _handlePurchaseUpdate(CustomerInfo customerInfo) {
    try {
      // Get entitlements
      final entitlementInfo = customerInfo.entitlements.all['pro'];

      if (entitlementInfo != null && entitlementInfo.isActive) {
        // User has active Pro subscription
        _subscriptionService.upgradePlan(
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
          _subscriptionService.upgradePlan(
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
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all.values.any((e) => e.isActive);
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all.values.any((e) => e.isActive);
    } catch (e) {
      debugPrint('❌ Restore error: $e');
      return false;
    }
  }

  /// Get current customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('❌ Error getting customer info: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
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
    try {
      await Purchases.logOut();
      _isInitialized = false;
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }

  /// Dispose
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_handlePurchaseUpdate);
  }
}
