import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_models.dart';

/// NotificationService - Handles push and in-app notifications
class NotificationService {
  final List<AppNotification> _notifications = [];
  String? _currentUserId;

  /// Initialize with user ID
  void initialize(String userId) {
    _currentUserId = userId;
  }

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Create notification for new request
  Future<void> notifyNewRequest({
    required String recipientId,
    required String requestTitle,
    required String submitterName,
    required String requestId,
    required String workspaceId,
  }) async {
    final notification = AppNotification(
      id: _generateId(),
      userId: recipientId,
      title: 'New Approval Request',
      body: '$submitterName submitted "$requestTitle" for approval',
      type: NotificationType.newRequest,
      requestId: requestId,
      workspaceId: workspaceId,
      createdAt: DateTime.now(),
    );

    _notifications.add(notification);
    await _sendPushNotification(notification);
  }

  /// Create notification for approval
  Future<void> notifyApproval({
    required String recipientId,
    required String requestTitle,
    required String approverName,
    required String requestId,
    required String workspaceId,
  }) async {
    final notification = AppNotification(
      id: _generateId(),
      userId: recipientId,
      title: 'Request Approved',
      body: '$approverName approved "$requestTitle"',
      type: NotificationType.requestApproved,
      requestId: requestId,
      workspaceId: workspaceId,
      createdAt: DateTime.now(),
    );

    _notifications.add(notification);
    await _sendPushNotification(notification);
  }

  /// Create notification for rejection
  Future<void> notifyRejection({
    required String recipientId,
    required String requestTitle,
    required String rejectorName,
    required String requestId,
    required String workspaceId,
    String? reason,
  }) async {
    final notification = AppNotification(
      id: _generateId(),
      userId: recipientId,
      title: 'Request Rejected',
      body:
          '$rejectorName rejected "$requestTitle"${reason != null ? ': $reason' : ''}',
      type: NotificationType.requestRejected,
      requestId: requestId,
      workspaceId: workspaceId,
      createdAt: DateTime.now(),
    );

    _notifications.add(notification);
    await _sendPushNotification(notification);
  }

  /// Create notification for revision restart
  Future<void> notifyRevisionRestart({
    required List<String> approverIds,
    required String requestTitle,
    required String editorName,
    required String requestId,
    required String workspaceId,
  }) async {
    for (final approverId in approverIds) {
      final notification = AppNotification(
        id: _generateId(),
        userId: approverId,
        title: 'Request Updated',
        body:
            '$editorName updated "$requestTitle". Approval process restarted.',
        type: NotificationType.revisionRestart,
        requestId: requestId,
        workspaceId: workspaceId,
        createdAt: DateTime.now(),
      );

      _notifications.add(notification);
      await _sendPushNotification(notification);
    }
  }

  /// Get notifications for user
  List<AppNotification> getNotificationsForUser(String userId) {
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get unread count for user
  int getUnreadCount(String userId) {
    return _notifications.where((n) => n.userId == userId && !n.isRead).length;
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  /// Mark all as read for user
  void markAllAsRead(String userId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  /// Send push notification (mock implementation)
  Future<void> _sendPushNotification(AppNotification notification) async {
    // In real implementation, this would use FCM
    // For now, just log
    print('Push notification: ${notification.title} - ${notification.body}');
  }

  /// Save FCM token
  Future<void> saveFcmToken(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token_$userId', token);
  }

  /// Get FCM token
  Future<String?> getFcmToken(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token_$userId');
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
