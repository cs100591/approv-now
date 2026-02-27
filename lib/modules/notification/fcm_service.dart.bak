import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';

/// Background message handler - MUST be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background message
  await Firebase.initializeApp();
  AppLogger.info(
      '📨 Background message received: ${message.notification?.title}');
}

/// FCM Service - Handles Firebase Cloud Messaging integration
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static StreamSubscription? _foregroundSubscription;
  static StreamSubscription? _tokenRefreshSubscription;

  /// Initialize FCM service - MUST be called after Firebase.initializeApp()
  static Future<bool> initialize() async {
    if (_isInitialized) {
      AppLogger.info('🔔 FCM Service already initialized');
      return true;
    }

    try {
      AppLogger.info('🔔 Initializing FCM Service...');

      // Verify Firebase is initialized
      if (Firebase.apps.isEmpty) {
        AppLogger.error(
            '❌ Firebase not initialized! Call Firebase.initializeApp() first');
        return false;
      }
      AppLogger.info('✅ Firebase apps verified');

      // Initialize local notifications first
      await _initLocalNotifications();

      // Request permission
      final permissionGranted = await requestPermission();
      if (!permissionGranted) {
        AppLogger.warning('⚠️ Notification permission not granted');
        // Continue anyway - user might grant later
      }

      // Get initial token to verify APNs is working
      final token = await _messaging.getToken();
      if (token == null) {
        AppLogger.warning('⚠️ FCM Token is null - APNs may not be configured');
      } else {
        AppLogger.info('✅ FCM Token obtained: ${token.substring(0, 20)}...');
      }

      // Set up foreground message handler
      _setupForegroundHandler();

      // Set up token refresh listener
      _setupTokenRefreshListener();

      // Handle notification taps when app is in background/terminated
      _setupNotificationTapHandler();

      _isInitialized = true;
      AppLogger.info('✅ FCM Service initialized successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to initialize FCM Service: $e');
      AppLogger.error('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  /// Initialize local notifications plugin
  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'approv_now_channel',
        'Approval Notifications',
        description: 'Notifications for approval requests and updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    AppLogger.info('✅ Local notifications initialized');
  }

  /// Check current notification permission status
  static Future<bool> checkPermission() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      AppLogger.info('🔔 Permission status: ${settings.authorizationStatus}');
      return authorized;
    } catch (e) {
      AppLogger.error('❌ Failed to check permission: $e');
      return false;
    }
  }

  /// Request notification permission from user
  static Future<bool> requestPermission() async {
    try {
      AppLogger.info('🔔 Requesting notification permission...');

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
        announcement: false,
        carPlay: false,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      AppLogger.info(
          '🔔 Permission result: ${settings.authorizationStatus} (granted: $granted)');
      return granted;
    } catch (e) {
      AppLogger.error('❌ Failed to request permission: $e');
      return false;
    }
  }

  /// Get FCM token for current device
  static Future<String?> getToken() async {
    try {
      AppLogger.info('🔔 Getting FCM token...');

      final token = await _messaging.getToken();

      if (token != null && token.isNotEmpty) {
        AppLogger.info(
            '✅ FCM Token: ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
        AppLogger.info('📱 Token length: ${token.length}');
      } else {
        AppLogger.warning('⚠️ FCM Token is null or empty');
        AppLogger.warning(
            '⚠️ This usually means APNs is not configured correctly');
        AppLogger.warning(
            '⚠️ Check: 1) Apple Developer APNs key 2) Firebase Console APNs upload');
      }

      return token;
    } catch (e) {
      AppLogger.error('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token (for testing)
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      AppLogger.info('🗑️ FCM Token deleted');
    } catch (e) {
      AppLogger.error('❌ Failed to delete token: $e');
    }
  }

  /// Save FCM token to Supabase backend
  static Future<bool> saveTokenToBackend(String userId, String token) async {
    try {
      AppLogger.info('💾 Saving FCM token to backend for user: $userId');

      final supabase = SupabaseService();

      final result = await supabase.client
          .from('profiles')
          .update({
            'fcm_token': token,
            'fcm_token_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select();

      if (result.isNotEmpty) {
        AppLogger.info('✅ FCM token saved to backend');
        return true;
      } else {
        AppLogger.warning('⚠️ No rows updated - user may not exist');
        return false;
      }
    } catch (e) {
      AppLogger.error('❌ Failed to save FCM token to backend: $e');
      return false;
    }
  }

  /// Delete FCM token from backend (on logout)
  static Future<void> deleteTokenFromBackend(String userId) async {
    try {
      final supabase = SupabaseService();
      await supabase.client.from('profiles').update({
        'fcm_token': null,
        'fcm_token_updated_at': null,
      }).eq('id', userId);

      AppLogger.info('🗑️ FCM token removed from backend');
    } catch (e) {
      AppLogger.error('❌ Failed to delete FCM token: $e');
    }
  }

  /// Set up foreground message handler
  static void _setupForegroundHandler() {
    _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        AppLogger.info('📨 Foreground message: ${message.notification?.title}');
        AppLogger.info('📨 Message data: ${message.data}');
        _showLocalNotification(message);
      },
      onError: (error) {
        AppLogger.error('❌ Foreground message error: $error');
      },
    );
  }

  /// Set up token refresh listener
  static void _setupTokenRefreshListener() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (String token) {
        AppLogger.info('🔄 FCM Token refreshed');
        // Token will be saved by the caller via subscribeToTokenRefresh
      },
      onError: (error) {
        AppLogger.error('❌ Token refresh error: $error');
      },
    );
  }

  /// Subscribe to token refresh - call this with userId to auto-save
  static void subscribeToTokenRefresh(String userId) {
    _messaging.onTokenRefresh.listen((String token) async {
      AppLogger.info('🔄 FCM token refreshed, saving to backend...');
      await saveTokenToBackend(userId, token);
    });
  }

  /// Unsubscribe from token refresh
  static void unsubscribeFromTokenRefresh() {
    _tokenRefreshSubscription?.cancel();
    AppLogger.info('🔕 Unsubscribed from token refresh');
  }

  /// Show local notification (when app is in foreground)
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) {
      AppLogger.warning('⚠️ Message has no notification payload');
      return;
    }

    AppLogger.info('📱 Showing local notification: ${notification.title}');

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'approv_now_channel',
          'Approval Notifications',
          channelDescription: 'Notifications for approval requests and updates',
          importance: Importance.max,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('🔔 Notification tapped');
    AppLogger.info('🔔 Payload: ${response.payload}');
  }

  /// Setup handler for notification taps when app is in background
  static void _setupNotificationTapHandler() {
    // Handle notification tap when app was in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info(
          '📨 App opened from background notification: ${message.notification?.title}');
      AppLogger.info('📨 Data: ${message.data}');
    });

    // Handle notification tap when app was terminated
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.info(
            '📨 App opened from terminated state: ${message.notification?.title}');
        AppLogger.info('📨 Data: ${message.data}');
      }
    });
  }

  /// Dispose and cleanup
  static Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    _foregroundSubscription = null;
    _tokenRefreshSubscription = null;
    _isInitialized = false;
    AppLogger.info('🔕 FCM Service disposed');
  }
}
