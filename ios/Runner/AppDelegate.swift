import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    NSLog("🚀 [AppDelegate] Application starting...")
    
    // Set UNUserNotificationCenter delegate for iOS 10+
    UNUserNotificationCenter.current().delegate = self
    
    // Initialize Flutter
    GeneratedPluginRegistrant.register(with: self)
    NSLog("🚀 [AppDelegate] Flutter plugins registered")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    NSLog("✅ [AppDelegate] APNs device token received: \(token)")
    
    // Note: OneSignal handles token registration automatically via Flutter SDK
    NSLog("✅ [AppDelegate] Device token will be sent to OneSignal")
  }
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    NSLog("❌ [AppDelegate] Failed to register for remote notifications: \(error.localizedDescription)")
    NSLog("❌ [AppDelegate] Error domain: \((error as NSError).domain)")
    NSLog("❌ [AppDelegate] Error code: \((error as NSError).code)")
  }
  
  // MARK: - UNUserNotificationCenterDelegate
  
  // Called when notification arrives while app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification, 
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    NSLog("📱 [AppDelegate] Notification received in foreground: \(notification.request.content.title)")
    
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
  
  // Called when user taps on notification
  override func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              didReceive response: UNNotificationResponse, 
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    NSLog("👆 [AppDelegate] User tapped notification: \(response.notification.request.content.title)")
    
    // Handle the notification tap
    let userInfo = response.notification.request.content.userInfo
    NSLog("📱 [AppDelegate] Notification data: \(userInfo)")
    
    completionHandler()
  }
}
