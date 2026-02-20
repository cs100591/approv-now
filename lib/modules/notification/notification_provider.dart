import 'package:flutter/foundation.dart';
import 'notification_models.dart';
import 'notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  NotificationState _state = const NotificationState();

  NotificationProvider({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  NotificationState get state => _state;
  List<AppNotification> get notifications => _state.notifications;
  int get unreadCount => _state.unreadCount;
  bool get isLoading => _state.isLoading;

  /// Initialize with user ID
  void initialize(String userId) {
    _notificationService.initialize(userId);
    loadNotifications(userId);
  }

  /// Load notifications for user
  void loadNotifications(String userId) {
    final notifications = _notificationService.getNotificationsForUser(userId);
    final unreadCount = _notificationService.getUnreadCount(userId);

    _state = _state.copyWith(
      notifications: notifications,
      unreadCount: unreadCount,
    );
    notifyListeners();
  }

  /// Notify new request
  Future<void> notifyNewRequest({
    required String recipientId,
    required String requestTitle,
    required String submitterName,
    required String requestId,
    required String workspaceId,
  }) async {
    await _notificationService.notifyNewRequest(
      recipientId: recipientId,
      requestTitle: requestTitle,
      submitterName: submitterName,
      requestId: requestId,
      workspaceId: workspaceId,
    );

    if (_notificationService.currentUserId == recipientId) {
      loadNotifications(recipientId);
    }
  }

  /// Notify approval
  Future<void> notifyApproval({
    required String recipientId,
    required String requestTitle,
    required String approverName,
    required String requestId,
    required String workspaceId,
  }) async {
    await _notificationService.notifyApproval(
      recipientId: recipientId,
      requestTitle: requestTitle,
      approverName: approverName,
      requestId: requestId,
      workspaceId: workspaceId,
    );

    if (_notificationService.currentUserId == recipientId) {
      loadNotifications(recipientId);
    }
  }

  /// Notify rejection
  Future<void> notifyRejection({
    required String recipientId,
    required String requestTitle,
    required String rejectorName,
    required String requestId,
    required String workspaceId,
    String? reason,
  }) async {
    await _notificationService.notifyRejection(
      recipientId: recipientId,
      requestTitle: requestTitle,
      rejectorName: rejectorName,
      requestId: requestId,
      workspaceId: workspaceId,
      reason: reason,
    );

    if (_notificationService.currentUserId == recipientId) {
      loadNotifications(recipientId);
    }
  }

  /// Notify revision restart
  Future<void> notifyRevisionRestart({
    required List<String> approverIds,
    required String requestTitle,
    required String editorName,
    required String requestId,
    required String workspaceId,
  }) async {
    await _notificationService.notifyRevisionRestart(
      approverIds: approverIds,
      requestTitle: requestTitle,
      editorName: editorName,
      requestId: requestId,
      workspaceId: workspaceId,
    );

    // Reload if current user is affected
    final currentUserId = _notificationService.currentUserId;
    if (currentUserId != null && approverIds.contains(currentUserId)) {
      loadNotifications(currentUserId);
    }
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    _notificationService.markAsRead(notificationId);

    // Update local state
    final notifications = _state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final unreadCount = _state.unreadCount > 0 ? _state.unreadCount - 1 : 0;

    _state = _state.copyWith(
      notifications: notifications,
      unreadCount: unreadCount,
    );
    notifyListeners();
  }

  /// Mark all as read
  void markAllAsRead(String userId) {
    _notificationService.markAllAsRead(userId);

    final notifications =
        _state.notifications.map((n) => n.copyWith(isRead: true)).toList();

    _state = _state.copyWith(
      notifications: notifications,
      unreadCount: 0,
    );
    notifyListeners();
  }

  /// Save FCM token
  Future<void> saveFcmToken(String userId, String token) async {
    await _notificationService.saveFcmToken(userId, token);
  }
}

/// State for notification provider
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
