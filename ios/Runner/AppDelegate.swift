import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Initialize Firebase
    FirebaseApp.configure()
    print("✅ Firebase configured in AppDelegate")
    
    // Register for remote notifications
    UNUserNotificationCenter.current().delegate = self
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { granted, error in
        if granted {
          print("✅ Push notification permission granted")
        } else {
          print("❌ Push notification permission denied: \(error?.localizedDescription ?? "unknown")")
        }
      }
    )
    
    application.registerForRemoteNotifications()
    print("✅ Registered for remote notifications")
    
    // Set Messaging delegate
    Messaging.messaging().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle APNs token registration
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("✅ APNs Device Token: \(token)")
    
    // Set APNs token for Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    print("✅ APNs token set for Firebase Messaging")
    
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Handle APNs registration failure
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    print("❌ Error details: \(error)")
    
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
  
  // Handle incoming notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    
    print("📨 Received notification in foreground")
    print("📨 UserInfo: \(userInfo)")
    
    // Show notification even when app is in foreground
    // Use banner for iOS 14+, fallback to alert for older versions
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
  
  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    
    print("📨 Notification tapped")
    print("📨 UserInfo: \(userInfo)")
    
    completionHandler()
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    if let token = fcmToken {
      print("✅ FCM Token received in AppDelegate: \(token)")
      
      // Send token to Flutter via MethodChannel if needed
      // Or it will be handled by the Flutter firebase_messaging plugin
    } else {
      print("❌ FCM Token is nil")
    }
  }
}
