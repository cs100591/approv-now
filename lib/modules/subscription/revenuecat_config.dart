import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat configuration and initialization
///
/// IMPORTANT: For production builds, you MUST set the API key via --dart-define:
/// --dart-define=REVENUECAT_IOS_KEY=your_ios_key
/// --dart-define=REVENUECAT_ANDROID_KEY=your_android_key
///
/// API Keys:
/// - iOS: starts with 'appl_' (Sandbox) or 'appl_' (Production)
/// - Android: starts with 'goog_'
class RevenueCatConfig {
  /// iOS API Key - from environment or fallback to test key
  static String get iosApiKey {
    const key = String.fromEnvironment('REVENUECAT_IOS_KEY');
    if (key.isNotEmpty) return key;

    // Fallback for development - TEST KEY ONLY
    // DO NOT use this in production App Store builds
    return 'appl_rbDFMjFEccCpjTqajpmrXQVFNNR';
  }

  /// Android API Key - from environment or fallback to test key
  static String get androidApiKey {
    const key = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
    if (key.isNotEmpty) return key;

    // Fallback for development - TEST KEY ONLY
    return 'goog_YOUR_TEST_KEY_HERE';
  }

  /// Get platform-specific API key
  static String get apiKey {
    if (kIsWeb) {
      throw UnsupportedError('RevenueCat does not support web');
    }

    if (Platform.isIOS) {
      return iosApiKey;
    } else if (Platform.isAndroid) {
      return androidApiKey;
    }

    throw UnsupportedError('Unsupported platform');
  }

  /// Check if using production API key
  /// Production keys typically have specific patterns
  static bool get isProductionKey {
    final key = apiKey;
    // Test keys often have 'test' in the identifier or are publicly known
    // Production keys should be kept secret
    return !key.contains('rbDFMjFEccCpjTqajpmrXQVFNNR'); // Not the test key
  }

  /// Initialize RevenueCat SDK with error handling
  ///
  /// [userId] - Optional user ID to identify the customer
  /// Returns true if initialization succeeded
  static Future<bool> initialize({String? userId}) async {
    if (kIsWeb) {
      debugPrint('⚠️ RevenueCat does not support web');
      return false;
    }

    try {
      final key = apiKey;

      // Log which environment we're using (without exposing the full key)
      final keyPrefix = key.substring(0, key.length > 8 ? 8 : key.length);
      debugPrint('🔑 Initializing RevenueCat with key prefix: $keyPrefix...');

      if (!isProductionKey) {
        debugPrint(
            '⚠️ WARNING: Using RevenueCat TEST key. In-app purchases will not work in production.');
      }

      // Configure log level based on build mode
      await Purchases.setLogLevel(
        kReleaseMode ? LogLevel.info : LogLevel.debug,
      );

      // Create configuration
      final configuration = PurchasesConfiguration(key);
      if (userId != null) {
        configuration.appUserID = userId;
      }

      await Purchases.configure(configuration);

      debugPrint('✅ RevenueCat initialized successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ RevenueCat initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');

      // Don't crash the app - RevenueCat is optional for core functionality
      return false;
    }
  }

  /// Check if RevenueCat is properly configured for production
  static void verifyProductionConfiguration() {
    if (!isProductionKey) {
      debugPrint('''
╔══════════════════════════════════════════════════════════════════╗
║                    ⚠️  WARNING  ⚠️                               ║
╠══════════════════════════════════════════════════════════════════╣
║  RevenueCat is using a TEST API key!                             ║
║                                                                  ║
║  For App Store / TestFlight builds, you must:                    ║
║  1. Get your production API key from RevenueCat Dashboard        ║
║  2. Set it via --dart-define when building:                      ║
║                                                                  ║
║     flutter build ios --release                                  ║
║       --dart-define=REVENUECAT_IOS_KEY=your_production_key       ║
║                                                                  ║
║  Without this, in-app purchases WILL FAIL!                       ║
╚══════════════════════════════════════════════════════════════════╝
      ''');
    }
  }

  /// Product IDs for your subscription plans
  /// These must match the product IDs configured in App Store Connect
  static const Map<String, String> productIds = {
    'starter_monthly': 'approv_now_starter_monthly',
    'starter_yearly': 'approvnow_starter_yearly',
    'pro_monthly': 'approv_now_pro_monthly',
    'pro_yearly': 'approv_now_pro_yearly',
  };

  /// Offering identifier - must match your RevenueCat dashboard
  static const String offeringIdentifier = 'default';
}
