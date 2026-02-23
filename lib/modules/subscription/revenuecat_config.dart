import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../auth/auth_provider.dart';

/// RevenueCat configuration and initialization
class RevenueCatConfig {
  // RevenueCat API keys
  static const String _iosApiKey = 'appl_rbDFMjFEccCpjTqajpmrXQVFNNR';
  static const String _androidApiKey = 'appl_rbDFMjFEccCpjTqajpmrXQVFNNR';
  static const String _webApiKey = 'appl_rbDFMjFEccCpjTqajpmrXQVFNNR';

  /// Get the appropriate API key for the platform
  static String get apiKey {
    if (kIsWeb) return _webApiKey;
    // Note: Use dart:io Platform for mobile detection
    // This will be handled in the initialization method
    return _iosApiKey; // Default fallback
  }

  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    try {
      String apiKey;

      // Platform-specific API keys
      if (kIsWeb) {
        apiKey = _webApiKey;
      } else {
        // For mobile, we'll detect platform in the service
        apiKey = _iosApiKey; // Default to iOS, will be overridden in service
      }

      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));

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
