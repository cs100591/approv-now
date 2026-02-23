/// Configuration flags for feature toggles
class AppConfig {
  AppConfig._();

  // Email notifications
  static bool enableEmailNotifications = true; // Enabled for Pro users

  // Cloud Functions
  static bool useFirebaseFunctions =
      true; // Note: using Supabase edge functions

  // Deep links
  static bool enableDeepLinks = false; // Set to true when domain is configured

  // Analytics
  static bool enableAnalytics = true;

  // Push notifications
  static bool enablePushNotifications = false;

  /// Check if email features are enabled
  static bool get emailsEnabled =>
      enableEmailNotifications && useFirebaseFunctions;
}
