import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/app_logger.dart';
import 'notification_models.dart';

/// NotificationService - Handles push notifications via FCM
class NotificationService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  // Stream controller for notification tap events
  final _notificationTapController = StreamController<String>.broadcast();
  Stream<String> get onNotificationTap => _notificationTapController.stream;

  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      AppLogger.info('FCM permission status: ${settings.authorizationStatus}');

      // Configure foreground presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize local notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null) {
            _notificationTapController.add(response.payload!);
          }
        },
      );

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen to background/terminated messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      AppLogger.info('Notification service initialized');
    } catch (e) {
      AppLogger.error('Error initializing notification service', e);
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      AppLogger.info('FCM token retrieved: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      AppLogger.error('Error getting FCM token', e);
      return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.info('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Error subscribing to topic: $topic', e);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic: $topic', e);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground message received: ${message.messageId}');

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: jsonEncode(data),
      );
    }
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.info('Background message received: ${message.messageId}');

    final data = message.data;
    if (data['route'] != null) {
      _notificationTapController.add(data['route']);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'approv_now_channel',
      'Approv Now Notifications',
      channelDescription: 'Notifications for approval requests',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Dispose
  void dispose() {
    _notificationTapController.close();
  }
}

/// Background message handler (must be top-level function)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Handling background message: ${message.messageId}');
  // Handle background message logic here
}
