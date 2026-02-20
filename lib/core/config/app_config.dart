/// Configuration flags for feature toggles
class AppConfig {
  AppConfig._();

  // Email notifications
  static bool enableEmailNotifications =
      false; // Set to true when ready to use email

  // Firebase Functions
  static bool useFirebaseFunctions =
      false; // Set to true when functions are deployed

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
