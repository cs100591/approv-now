import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/stream_helper.dart';
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

  /// Stream notifications for user with safe lifecycle management
  Stream<List<AppNotification>> streamUserNotifications(String userId) {
    return StreamHelper.createPollingStream(
      fetchData: () => getUserNotifications(userId),
      interval: const Duration(seconds: 30),
    );
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
/// Note: Email notifications have been removed
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
    String? recipientEmail,
  }) async {
    AppNotification? notification;

    try {
      notification = await _repository.createNotification(
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
    } catch (e) {
      AppLogger.warning('⚠️ Failed to create database notification (RLS?): $e');
    }

    await _pushService.sendPushNotification(
      userId: userId,
      title: 'Workspace Invitation',
      body: '$inviterName invited you to join "$workspaceName"',
      data: {
        'type': 'workspace_invitation',
        'workspace_id': workspaceId,
        'notification_id': notification?.id,
      },
    );

    return notification ??
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: false,
        );
  }

  /// Create pending request notification
  Future<AppNotification> createPendingRequestNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String submitterName,
    required String workspaceName,
  }) async {
    AppNotification? notification;

    try {
      notification = await _repository.createNotification(
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
    } catch (e) {
      AppLogger.warning('⚠️ Failed to create database notification (RLS?): $e');
    }

    await _pushService.sendPushNotification(
      userId: userId,
      title: 'New Approval Request',
      body: '$submitterName submitted "$requestTitle" for approval',
      data: {
        'type': 'pending_request',
        'request_id': requestId,
        'notification_id': notification?.id,
      },
    );

    return notification ??
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
          actionData: {'request_id': requestId},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: false,
        );
  }

  /// Create request approved notification
  Future<AppNotification> createRequestApprovedNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String approverName,
    required String workspaceName,
  }) async {
    AppNotification? notification;

    // Try to create database notification (may fail due to RLS)
    try {
      notification = await _repository.createNotification(
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
    } catch (e) {
      AppLogger.warning('⚠️ Failed to create database notification (RLS?): $e');
      // Continue to send push even if database fails
    }

    // Always send push notification regardless of database success
    await _pushService.sendPushNotification(
      userId: userId,
      title: 'Request Approved',
      body: '$approverName approved "$requestTitle"',
      data: {
        'type': 'request_approved',
        'request_id': requestId,
        'notification_id': notification?.id,
      },
    );

    return notification ??
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
          actionData: {'request_id': requestId},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: false,
        );
  }

  /// Create request rejected notification
  Future<AppNotification> createRequestRejectedNotification({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String requestTitle,
    required String rejectorName,
    required String workspaceName,
    String? reason,
  }) async {
    final message =
        '$rejectorName rejected "$requestTitle"${reason != null ? ': $reason' : ''}';

    AppNotification? notification;

    try {
      notification = await _repository.createNotification(
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
    } catch (e) {
      AppLogger.warning('⚠️ Failed to create database notification (RLS?): $e');
    }

    await _pushService.sendPushNotification(
      userId: userId,
      title: 'Request Rejected',
      body: message,
      data: {
        'type': 'request_rejected',
        'request_id': requestId,
        'notification_id': notification?.id,
      },
    );

    return notification ??
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
          actionData: {'request_id': requestId},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: false,
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
    AppNotification? notification;

    try {
      notification = await _repository.createNotification(
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
    } catch (e) {
      AppLogger.warning('⚠️ Failed to create database notification (RLS?): $e');
    }

    await _pushService.sendPushNotification(
      userId: userId,
      title: 'Request Updated',
      body: '$editorName updated "$requestTitle". Approval process restarted.',
      data: {
        'type': 'request_revision',
        'request_id': requestId,
        'notification_id': notification?.id,
      },
    );

    return notification ??
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
          actionData: {'request_id': requestId},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: false,
        );
  }

  /// Create invitation accepted notification (for inviter)
  Future<AppNotification> createInvitationAcceptedNotification({
    required String inviterId,
    required String workspaceId,
    required String workspaceName,
    required String accepterName,
  }) async {
    AppNotification? notification;

    try {
      notification = await _repository.createNotification(
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
    } catch (e) {
      AppLogger.warning('⚠️ Failed to create database notification (RLS?): $e');
    }

    await _pushService.sendPushNotification(
      userId: inviterId,
      title: 'Invitation Accepted',
      body: '$accepterName accepted your invitation to join "$workspaceName"',
      data: {
        'type': 'invitation_accepted',
        'workspace_id': workspaceId,
        'notification_id': notification?.id,
      },
    );

    return notification ??
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
          actionData: {'workspace_id': workspaceId},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: false,
        );
  }
}

/// PushService - Handles FCM push notifications via Supabase Edge Functions
class PushService {
  final SupabaseService _supabase;
  final List<PendingPush> _pendingPushes = [];

  PushService({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  void initialize(String userId) {
    // Track userId for future push routing if needed
    AppLogger.info('PushService initialized for user: $userId');
  }

  /// Send push notification to user via Supabase Edge Function
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    AppLogger.info('📨 ==================================================');
    AppLogger.info('📨 PUSH NOTIFICATION: Starting send process');
    AppLogger.info('📨 ==================================================');
    AppLogger.info('📨 Target User ID: $userId');
    AppLogger.info('📨 Title: $title');
    AppLogger.info('📨 Body: $body');
    AppLogger.info('📨 Data: $data');

    try {
      AppLogger.info('📨 Calling Edge Function: send-push-notification');

      // Call Supabase Edge Function to send FCM notification
      final payload = {
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
      };

      AppLogger.info('📨 Sending payload: ${jsonEncode(payload)}');

      final response = await _supabase.client.functions.invoke(
        'send-push-notification',
        body: payload,
      );

      AppLogger.info('📨 Edge Function Response Status: ${response.status}');
      AppLogger.info('📨 Edge Function Response Data: ${response.data}');

      if (response.status == 200) {
        AppLogger.info('✅ Push notification API call succeeded');
        AppLogger.info('✅ Response: ${response.data}');
      } else {
        AppLogger.error('❌ Push notification API call failed');
        AppLogger.error('❌ Status: ${response.status}');
        AppLogger.error('❌ Response: ${response.data}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Exception during push notification send');
      AppLogger.error('❌ Error: $e');
      AppLogger.error('❌ StackTrace: $stackTrace');
      // Don't throw - notification failure shouldn't break the app
    }

    AppLogger.info('📨 ==================================================');
    AppLogger.info('📨 PUSH NOTIFICATION: Send process completed');
    AppLogger.info('📨 ==================================================');

    // Keep local tracking for testing/debugging
    _pendingPushes.add(PendingPush(
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

  /// Save FCM token to local storage (legacy, use FCMService for backend storage)
  Future<void> saveFcmToken(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token_$userId', token);
    AppLogger.info('FCM token saved locally for user $userId');
  }

  /// Get FCM token from local storage
  Future<String?> getFcmToken(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token_$userId');
  }

  /// Get pending pushes for user (for debugging)
  List<PendingPush> getPendingPushesForUser(String userId) {
    return _pendingPushes.where((p) => p.userId == userId).toList();
  }
}

class PendingPush {
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime sentAt;

  PendingPush({
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
    required this.sentAt,
  });
}
