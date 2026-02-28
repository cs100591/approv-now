import UIKit
import Flutter
import UserNotifications
import OneSignalFramework

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  private var flutterResult: FlutterResult?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    NSLog("🚀 [AppDelegate] Application starting...")
    
    // Set UNUserNotificationCenter delegate for iOS 10+
    UNUserNotificationCenter.current().delegate = self
    
    // Initialize Flutter FIRST so window/rootViewController is available
    GeneratedPluginRegistrant.register(with: self)
    NSLog("🚀 [AppDelegate] Flutter plugins registered")
    
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Set up MethodChannel AFTER super.application() so window is ready
    setupOneSignalMethodChannel()
    
    return result
  }
  
  private func setupOneSignalMethodChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      NSLog("❌ [AppDelegate] Failed to get FlutterViewController")
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "com.approvenow.onesignal",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "getPlayerId":
        self?.handleGetPlayerId(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    NSLog("✅ [AppDelegate] OneSignal MethodChannel registered")
  }
  
  private func handleGetPlayerId(result: @escaping FlutterResult) {
    // Get the Player ID directly from OneSignal native SDK
    if let playerId = OneSignal.User.pushSubscription.id {
      NSLog("✅ [AppDelegate] Returning Player ID to Flutter: \(playerId)")
      result(playerId)
    } else {
      NSLog("⚠️ [AppDelegate] Player ID not available yet")
      result(nil)
    }
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
