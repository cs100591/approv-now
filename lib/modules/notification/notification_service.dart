import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';
import 'notification_models.dart';

/// NotificationRepository - Database operations for notifications
class NotificationRepository {
  final SupabaseService _supabase;

  NotificationRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  /// Create notification in database
  Future<AppNotification> createNotification({
    required String userId,
    String? workspaceId,
    required NotificationType type,
    required String title,
    String? message,
    Map<String, dynamic>? data,
    NotificationActionType actionType = NotificationActionType.none,
    Map<String, dynamic>? actionData,
  }) async {
    try {
      final response = await _supabase.client
          .from('notifications')
          .insert({
            'user_id': userId,
            'workspace_id': workspaceId,
            'type': type.name,
            'title': title,
            'message': message,
            'data': data ?? {},
            'action_type': actionType.name,
            'action_data': actionData ?? {},
          })
          .select()
          .single();

      return AppNotification.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to create notification', e);
      rethrow;
    }
  }

  /// Get notifications for user
  Future<List<AppNotification>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      var query =
          _supabase.client.from('notifications').select().eq('user_id', userId);

      if (unreadOnly) {
        query = query.eq('is_read', false).eq('is_dismissed', false);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return response
          .map<AppNotification>((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get notifications', e);
      return [];
    }
  }

  /// Stream notifications for user
  Stream<List<AppNotification>> streamUserNotifications(String userId) {
    final controller = StreamController<List<AppNotification>>();
    Timer? timer;

    getUserNotifications(userId).then((notifications) {
      if (!controller.isClosed) {
        controller.add(notifications);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });

    timer = Timer.periodic(const Duration(seconds: 30), (t) async {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      try {
        final notifications = await getUserNotifications(userId);
        if (!controller.isClosed) {
          controller.add(notifications);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });

    controller.onCancel = () {
      timer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.client.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      AppLogger.error('Failed to mark notification as read', e);
      rethrow;
    }
  }

  /// Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase.client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read', e);
      rethrow;
    }
  }

  /// Dismiss notification
  Future<void> dismissNotification(String notificationId) async {
    try {
      await _supabase.client.from('notifications').update({
        'is_dismissed': true,
        'dismissed_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      AppLogger.error('Failed to dismiss notification', e);
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      AppLogger.error('Failed to delete notification', e);
      rethrow;
    }
  }

  /// Delete old notifications (cleanup)
  Future<int> deleteOldNotifications(int daysOld) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final response = await _supabase.client
          .from('notifications')
          .delete()
          .lt('created_at', cutoffDate.toIso8601String())
          .select('id');

      return response.length;
    } catch (e) {
      AppLogger.error('Failed to delete old notifications', e);
      return 0;
    }
  }

  /// Get unread count for user
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase.client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .eq('is_dismissed', false);

      return response.length;
    } catch (e) {
      AppLogger.error('Failed to get unread count', e);
      return 0;
    }
  }
}

/// NotificationService - Business logic for notifications
class NotificationService {
  final NotificationRepository _repository;
  final PushService _pushService;

  NotificationService({
    NotificationRepository? repository,
    PushService? pushService,
  })  : _repository = repository ?? NotificationRepository(),
        _pushService = pushService ?? PushService();

  /// Create invitation notification
  Future<AppNotification> createInvitationNotification({
    required String userId,
    required String workspaceId,
    required String workspaceName,
    required String inviterName,
    required String invitationToken,
  }) async {
    final notification = await _repository.createNotification(
      userId: userId,
      workspaceId: workspaceId,
      type: NotificationType.workspaceInvitation,
      title: 'Workspace Invitation',
      message: '$inviterName invited you to join "$workspaceName"',
      data: {
        'workspace_name': workspaceName,
        'inviter_name': inviterName,
      },
      actionType: NotificationActionType.acceptInvitation,
      actionData: {
        'invitation_token': invitationToken,
        'workspace_id': workspaceId,
      },
    );

    await _pushService.sendPushNotification(
      userId: userId,
      title: notification.title,
      body: notification.message ?? '',
      data: {
        'type': 'workspace_invitation',
        'workspace_id': workspaceId,
        'notification_id': notification.id,
      },
    );

    return notification;
  }

  /// Create pending request notification
  Future<AppNotification> createPendingRequestNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String submitterName,
  }) async {
    final notification = await _repository.createNotification(
      userId: userId,
      workspaceId: workspaceId,
      type: NotificationType.pendingRequest,
      title: 'New Approval Request',
      message: '$submitterName submitted "$requestTitle" for approval',
      data: {
        'request_id': requestId,
        'request_title': requestTitle,
        'submitter_name': submitterName,
      },
      actionType: NotificationActionType.viewRequest,
      actionData: {
        'request_id': requestId,
      },
    );

    await _pushService.sendPushNotification(
      userId: userId,
      title: notification.title,
      body: notification.message ?? '',
      data: {
        'type': 'pending_request',
        'request_id': requestId,
        'notification_id': notification.id,
      },
    );

    return notification;
  }

  /// Create request approved notification
  Future<AppNotification> createRequestApprovedNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String approverName,
  }) async {
    final notification = await _repository.createNotification(
      userId: userId,
      workspaceId: workspaceId,
      type: NotificationType.requestApproved,
      title: 'Request Approved',
      message: '$approverName approved "$requestTitle"',
      data: {
        'request_id': requestId,
        'request_title': requestTitle,
        'approver_name': approverName,
      },
      actionType: NotificationActionType.viewRequest,
      actionData: {
        'request_id': requestId,
      },
    );

    await _pushService.sendPushNotification(
      userId: userId,
      title: notification.title,
      body: notification.message ?? '',
      data: {
        'type': 'request_approved',
        'request_id': requestId,
        'notification_id': notification.id,
      },
    );

    return notification;
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
    final message =
        '$rejectorName rejected "$requestTitle"${reason != null ? ': $reason' : ''}';

    final notification = await _repository.createNotification(
      userId: userId,
      workspaceId: workspaceId,
      type: NotificationType.requestRejected,
      title: 'Request Rejected',
      message: message,
      data: {
        'request_id': requestId,
        'request_title': requestTitle,
        'rejector_name': rejectorName,
        'reason': reason,
      },
      actionType: NotificationActionType.viewRequest,
      actionData: {
        'request_id': requestId,
      },
    );

    await _pushService.sendPushNotification(
      userId: userId,
      title: notification.title,
      body: notification.message ?? '',
      data: {
        'type': 'request_rejected',
        'request_id': requestId,
        'notification_id': notification.id,
      },
    );

    return notification;
  }

  /// Create request revision notification
  Future<AppNotification> createRequestRevisionNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String editorName,
  }) async {
    final notification = await _repository.createNotification(
      userId: userId,
      workspaceId: workspaceId,
      type: NotificationType.requestRevision,
      title: 'Request Updated',
      message:
          '$editorName updated "$requestTitle". Approval process restarted.',
      data: {
        'request_id': requestId,
        'request_title': requestTitle,
        'editor_name': editorName,
      },
      actionType: NotificationActionType.viewRequest,
      actionData: {
        'request_id': requestId,
      },
    );

    await _pushService.sendPushNotification(
      userId: userId,
      title: notification.title,
      body: notification.message ?? '',
      data: {
        'type': 'request_revision',
        'request_id': requestId,
        'notification_id': notification.id,
      },
    );

    return notification;
  }

  /// Create invitation accepted notification (for inviter)
  Future<AppNotification> createInvitationAcceptedNotification({
    required String inviterId,
    required String workspaceId,
    required String workspaceName,
    required String accepterName,
  }) async {
    return await _repository.createNotification(
      userId: inviterId,
      workspaceId: workspaceId,
      type: NotificationType.invitationAccepted,
      title: 'Invitation Accepted',
      message:
          '$accepterName accepted your invitation to join "$workspaceName"',
      data: {
        'workspace_name': workspaceName,
        'accepter_name': accepterName,
      },
      actionType: NotificationActionType.viewWorkspace,
      actionData: {
        'workspace_id': workspaceId,
      },
    );
  }
}

/// PushService - Handles FCM push notifications
class PushService {
  final List<_PendingPush> _pendingPushes = [];
  String? _currentUserId;

  void initialize(String userId) {
    _currentUserId = userId;
  }

  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    AppLogger.info('Push notification for $userId: $title - $body');

    _pendingPushes.add(_PendingPush(
      userId: userId,
      title: title,
      body: body,
      data: data ?? {},
      sentAt: DateTime.now(),
    ));

    if (_pendingPushes.length > 100) {
      _pendingPushes.removeRange(0, _pendingPushes.length - 100);
    }
  }

  Future<void> saveFcmToken(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token_$userId', token);
    AppLogger.info('FCM token saved for user $userId');
  }

  Future<String?> getFcmToken(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token_$userId');
  }

  List<_PendingPush> getPendingPushesForUser(String userId) {
    return _pendingPushes.where((p) => p.userId == userId).toList();
  }
}

class _PendingPush {
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime sentAt;

  _PendingPush({
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
    required this.sentAt,
  });
}
