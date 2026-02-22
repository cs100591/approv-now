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

  /// Initialize with user ID
  void initialize(String userId) {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    _pushService.initialize(userId);
    _subscribeToNotifications(userId);
    loadNotifications();
  }

  /// Clear state (on logout)
  void clear() {
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
      error: null,
    );
    notifyListeners();
  }

  /// Load notifications for current user
  Future<void> loadNotifications({bool unreadOnly = false}) async {
    if (_currentUserId == null) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final notifications = await _repository
          .getUserNotifications(_currentUserId!, unreadOnly: unreadOnly);
      _updateNotifications(notifications);
    } catch (e) {
      AppLogger.error('Failed to load notifications', e);
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

      final notifications = _state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      final unreadCount = _state.unreadCount > 0 ? _state.unreadCount - 1 : 0;

      _state = _state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to mark notification as read', e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      await _repository.markAllAsRead(_currentUserId!);

      final notifications = _state.notifications
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();

      _state = _state.copyWith(
        notifications: notifications,
        unreadCount: 0,
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read', e);
    }
  }

  /// Dismiss notification
  Future<void> dismissNotification(String notificationId) async {
    try {
      await _repository.dismissNotification(notificationId);

      final notifications = _state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isDismissed: true, dismissedAt: DateTime.now());
        }
        return n;
      }).toList();

      _state = _state.copyWith(notifications: notifications);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to dismiss notification', e);
    }
  }

  /// Create invitation notification
  Future<AppNotification> createInvitationNotification({
    required String userId,
    required String workspaceId,
    required String workspaceName,
    required String inviterName,
    required String invitationToken,
  }) async {
    return await _service.createInvitationNotification(
      userId: userId,
      workspaceId: workspaceId,
      workspaceName: workspaceName,
      inviterName: inviterName,
      invitationToken: invitationToken,
    );
  }

  /// Create pending request notification
  Future<AppNotification> createPendingRequestNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String submitterName,
  }) async {
    return await _service.createPendingRequestNotification(
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      requestTitle: requestTitle,
      submitterName: submitterName,
    );
  }

  /// Create request approved notification
  Future<AppNotification> createRequestApprovedNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String approverName,
  }) async {
    return await _service.createRequestApprovedNotification(
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      requestTitle: requestTitle,
      approverName: approverName,
    );
  }

  /// Create request rejected notification
  Future<AppNotification> createRequestRejectedNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String rejectorName,
    String? reason,
  }) async {
    return await _service.createRequestRejectedNotification(
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      requestTitle: requestTitle,
      rejectorName: rejectorName,
      reason: reason,
    );
  }

  /// Create request revision notification
  Future<AppNotification> createRequestRevisionNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String editorName,
  }) async {
    return await _service.createRequestRevisionNotification(
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      requestTitle: requestTitle,
      editorName: editorName,
    );
  }

  /// Cleanup expired notifications
  Future<void> cleanupExpiredNotifications() async {
    await _repository.deleteOldNotifications(30);
  }

  /// Save FCM token
  Future<void> saveFcmToken(String userId, String token) async {
    await _pushService.saveFcmToken(userId, token);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
