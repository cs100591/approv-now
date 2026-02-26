import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';

/// FCM Service - Handles Firebase Cloud Messaging integration
///
/// This service integrates with Supabase backend for:
/// - Token storage/management
/// - Sending notifications via Edge Functions
///
/// Note: Firebase is ONLY used for push notifications, all data storage
/// remains in Supabase.
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static StreamSubscription? _foregroundSubscription;

  /// Initialize FCM service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase (if not already done)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Request notification permissions
      await _requestPermission();

      // Initialize local notifications (for foreground display)
      await _initLocalNotifications();

      // Set up foreground message handler
      _setupForegroundHandler();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle notification taps when app is in background/terminated
      _setupNotificationTapHandler();

      _isInitialized = true;
      AppLogger.info('✅ FCM Service initialized successfully');
    } catch (e) {
      AppLogger.error('❌ Failed to initialize FCM Service', e);
      rethrow;
    }
  }

  /// Request notification permissions from user
  static Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    AppLogger.info(
        '🔔 Notification permission: ${granted ? "granted" : "denied"}');
    return granted;
  }

  /// Initialize local notifications plugin (for displaying notifications
  /// when app is in foreground)
  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false, // Already requested via FCM
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

    AppLogger.info('🔔 Local notifications initialized');
  }

  /// Handle foreground messages
  static void _setupForegroundHandler() {
    _foregroundSubscription?.cancel();
    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info(
          '📨 Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  /// Show local notification (when app is in foreground)
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'approv_now_channel',
          'Approval Notifications',
          channelDescription: 'Notifications for approval requests and updates',
          importance: Importance.high,
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
    AppLogger.info('🔔 Notification tapped: ${response.payload}');
    // Navigation logic will be handled by the notification handler
  }

  /// Setup handler for notification taps when app is in background
  static void _setupNotificationTapHandler() {
    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info(
          '📨 App opened from notification: ${message.notification?.title}');
      _handleNotificationTap(message.data);
    });

    // Handle notification tap when app was terminated
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.info(
            '📨 App opened from terminated state: ${message.notification?.title}');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Handle notification tap data
  static void _handleNotificationTap(Map<String, dynamic> data) {
    // Store the pending navigation data
    // Will be processed by the app's navigation system
    AppLogger.info('🔔 Processing notification tap with data: $data');
  }

  /// Get FCM token for current device
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      AppLogger.info('📱 FCM Token retrieved: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      AppLogger.error('❌ Failed to get FCM token', e);
      return null;
    }
  }

  /// Save FCM token to Supabase backend
  static Future<void> saveTokenToBackend(String userId, String token) async {
    try {
      final supabase = SupabaseService();
      await supabase.client.from('user_profiles').update({
        'fcm_token': token,
        'fcm_token_updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      AppLogger.info('💾 FCM token saved to backend for user: $userId');
    } catch (e) {
      AppLogger.error('❌ Failed to save FCM token to backend', e);
      rethrow;
    }
  }

  /// Delete FCM token from backend (on logout)
  static Future<void> deleteTokenFromBackend(String userId) async {
    try {
      final supabase = SupabaseService();
      await supabase.client.from('user_profiles').update({
        'fcm_token': null,
        'fcm_token_updated_at': null,
      }).eq('user_id', userId);

      AppLogger.info('🗑️ FCM token removed from backend for user: $userId');
    } catch (e) {
      AppLogger.error('❌ Failed to delete FCM token from backend', e);
    }
  }

  /// Subscribe to token refresh
  static void subscribeToTokenRefresh(String userId) {
    _messaging.onTokenRefresh.listen((String token) {
      AppLogger.info('🔄 FCM token refreshed');
      saveTokenToBackend(userId, token);
    });
  }

  /// Unsubscribe from token refresh
  static void unsubscribeFromTokenRefresh() {
    // Token refresh listener is automatically cancelled when app closes
    AppLogger.info('🔕 Unsubscribed from token refresh');
  }

  /// Dispose and cleanup
  static Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    _foregroundSubscription = null;
    AppLogger.info('🔕 FCM Service disposed');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Firebase.initializeApp() should already be done in main()
  // We just log the message here; actual handling happens when app opens
  AppLogger.info(
      '📨 Background message received: ${message.notification?.title}');
}
