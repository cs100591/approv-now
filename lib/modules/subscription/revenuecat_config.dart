import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../auth/auth_provider.dart';

/// RevenueCat configuration and initialization
class RevenueCatConfig {
  // RevenueCat API key (same for iOS and Android)
  static const String _apiKey = 'appl_rbDFMjFEccCpjTqajpmrXQVFNNR';

  /// Get the API key
  static String get apiKey => _apiKey;

  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(_apiKey));

      debugPrint('✅ RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('❌ RevenueCat initialization failed: $e');
    }
  }

  /// Product IDs for your subscription plans
  static const Map<String, String> productIds = {
    'starter_monthly': 'approv_now_starter_monthly',
    'starter_yearly': 'approvnow_starter_yearly',
    'pro_monthly': 'approv_now_pro_monthly',
    'pro_yearly': 'approv_now_pro_yearly',
  };

  /// Get offering identifier
  static const String offeringIdentifier = 'default';
}
