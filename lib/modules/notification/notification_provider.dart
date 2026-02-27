import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/utils/app_logger.dart';
import 'notification_models.dart';
import 'notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  final NotificationService _service;
  final PushService _pushService;

  NotificationState _state = const NotificationState();
  StreamSubscription<List<AppNotification>>? _subscription;
  String? _currentUserId;

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

  /// Initialize with user ID - sets up push notifications and notification streams
  Future<void> initialize(String userId) async {
    if (_currentUserId == userId) return;

    AppLogger.info(
        '🔔 NotificationProvider.initialize() called for user: $userId');
    _currentUserId = userId;

    // Note: Push notifications are handled by Pusher Beams (native iOS)
    // No Flutter-side FCM initialization needed
    AppLogger.info('🔔 Using Pusher Beams for push notifications (native iOS)');

    _pushService.initialize(userId);
    _subscribeToNotifications(userId);
    loadNotifications();
  }

  /// Clear state (on logout)
  Future<void> clear() async {
    _currentUserId = null;
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
