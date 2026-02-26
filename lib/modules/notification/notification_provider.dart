import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/utils/app_logger.dart';
import 'notification_models.dart';
import 'notification_service.dart';
import 'fcm_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  final NotificationService _service;
  final PushService _pushService;

  NotificationState _state = const NotificationState();
  StreamSubscription<List<AppNotification>>? _subscription;
  String? _currentUserId;
  bool _isFcmInitialized = false;

  NotificationProvider({
    NotificationRepository? repository,
    NotificationService? service,
    PushService? pushService,
  })  : _repository = repository ?? NotificationRepository(),
        _service = service ?? NotificationService(),
        _pushService = pushService ?? PushService();

  NotificationState get state => _state;
  List<AppNotification> get notifications => _state.notifications;
  List<AppNotification> get pendingInvitations => _state.pendingInvitations;
  List<AppNotification> get unreadNotifications => _state.unreadNotifications;
  int get unreadCount => _state.unreadCount;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  bool get hasPendingInvitations => pendingInvitations.isNotEmpty;

  /// Initialize with user ID - sets up FCM and notification streams
  Future<void> initialize(String userId) async {
    if (_currentUserId == userId && _isFcmInitialized) return;

    AppLogger.info(
        '🔔 NotificationProvider.initialize() called for user: $userId');
    _currentUserId = userId;

    // Setup FCM token for user (FCM should already be initialized in main.dart)
    if (!kIsWeb) {
      await _setupFcmToken(userId);
    }

    _pushService.initialize(userId);
    _subscribeToNotifications(userId);
    loadNotifications();
  }

  /// Setup FCM token for user
  Future<void> _setupFcmToken(String userId) async {
    try {
      AppLogger.info('🔔 Setting up FCM token for user: $userId');

      // Check permission status
      final hasPermission = await FCMService.checkPermission();
      AppLogger.info('🔔 Notification permission: $hasPermission');

      if (!hasPermission) {
        // Request permission
        AppLogger.info('🔔 Requesting notification permission...');
        final granted = await FCMService.requestPermission();
        if (!granted) {
          AppLogger.warning('⚠️ User denied notification permission');
          // Continue anyway - user might enable later in Settings
        }
      }

      // Get FCM token
      final token = await FCMService.getToken();

      if (token != null && token.isNotEmpty) {
        AppLogger.info('📱 Got FCM token, saving to backend...');
        AppLogger.info(
            '📱 Token preview: ${token.substring(0, token.length > 30 ? 30 : token.length)}...');

        // Save to backend
        final saved = await FCMService.saveTokenToBackend(userId, token);
        if (saved) {
          AppLogger.info('✅ FCM token saved to backend successfully');

          // Subscribe to token refresh
          FCMService.subscribeToTokenRefresh(userId);
          _isFcmInitialized = true;
        } else {
          AppLogger.warning('⚠️ Failed to save FCM token to backend');
        }
      } else {
        AppLogger.error('❌ FCM token is null or empty');
        AppLogger.error('❌ This usually means APNs is not configured');
        AppLogger.error('❌ Check:');
        AppLogger.error(
            '   1. Apple Developer APNs key is uploaded to Firebase Console');
        AppLogger.error('   2. Runner.entitlements has aps-environment');
        AppLogger.error(
            '   3. AppDelegate.swift registers for remote notifications');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to setup FCM token: $e');
      AppLogger.error('❌ Stack trace: $stackTrace');
    }
  }

  /// Clear state (on logout)
  Future<void> clear() async {
    final userId = _currentUserId;

    // Cleanup FCM
    if (userId != null && !kIsWeb) {
      try {
        await FCMService.deleteTokenFromBackend(userId);
        FCMService.unsubscribeFromTokenRefresh();
        await FCMService.dispose();
      } catch (e) {
        AppLogger.error('❌ Error during FCM cleanup', e);
      }
    }

    _currentUserId = null;
    _isFcmInitialized = false;
    _subscription?.cancel();
    _subscription = null;
    _state = const NotificationState();
    notifyListeners();
  }

  /// Subscribe to real-time notification updates
  void _subscribeToNotifications(String userId) {
    _subscription?.cancel();
    _subscription = _repository.streamUserNotifications(userId).listen(
      (notifications) {
        _updateNotifications(notifications);
      },
      onError: (error) {
        AppLogger.error('Error in notification stream', error);
        _state = _state.copyWith(
          error: error.toString(),
          isLoading: false,
        );
        notifyListeners();
      },
    );
  }

  /// Update notifications state
  void _updateNotifications(List<AppNotification> notifications) {
    final unreadCount =
        notifications.where((n) => !n.isRead && !n.isDismissed).length;

    _state = _state.copyWith(
      notifications: notifications,
      unreadCount: unreadCount,
      isLoading: false,
    );

    notifyListeners();
  }

  /// Load all notifications
  Future<void> loadNotifications() async {
    if (_currentUserId == null) return;

    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final notifications =
          await _repository.getUserNotifications(_currentUserId!);
      _updateNotifications(notifications);
    } catch (e) {
      AppLogger.error('Error loading notifications', e);
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      await loadNotifications();
    } catch (e) {
      AppLogger.error('Error marking notification as read', e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      await _repository.markAllAsRead(_currentUserId!);
      await loadNotifications();
    } catch (e) {
      AppLogger.error('Error marking all notifications as read', e);
    }
  }

  /// Dismiss notification
  Future<void> dismissNotification(String notificationId) async {
    try {
      await _repository.dismissNotification(notificationId);
      await loadNotifications();
    } catch (e) {
      AppLogger.error('Error dismissing notification', e);
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    if (_currentUserId == null) return;

    try {
      // Mark all as dismissed instead
      for (final notification in _state.notifications) {
        await _repository.dismissNotification(notification.id);
      }
      _state = _state.copyWith(
        notifications: [],
        unreadCount: 0,
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error clearing notifications', e);
    }
  }
}
