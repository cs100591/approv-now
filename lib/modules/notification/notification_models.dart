/// Notification types for persistent storage
enum NotificationType {
  workspaceInvitation,
  invitationAccepted,
  invitationDeclined,
  pendingRequest,
  requestApproved,
  requestRejected,
  requestRevision,
  memberAdded,
  memberRemoved,
  mention,
}

/// Notification action types
enum NotificationActionType {
  acceptInvitation,
  declineInvitation,
  viewRequest,
  viewWorkspace,
  none,
}

/// Notification model for persistent storage
class AppNotification {
  final String id;
  final String userId;
  final String? workspaceId;
  final NotificationType type;
  final String title;
  final String? message;
  final Map<String, dynamic> data;
  final NotificationActionType actionType;
  final Map<String, dynamic> actionData;
  final bool isRead;
  final bool isDismissed;
  final DateTime? readAt;
  final DateTime? dismissedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppNotification({
    required this.id,
    required this.userId,
    this.workspaceId,
    required this.type,
    required this.title,
    this.message,
    this.data = const {},
    this.actionType = NotificationActionType.none,
    this.actionData = const {},
    this.isRead = false,
    this.isDismissed = false,
    this.readAt,
    this.dismissedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get requiresAction => !isRead && !isDismissed && !isExpired;

  bool get isInvitation => type == NotificationType.workspaceInvitation;

  bool get isRequestRelated =>
      type == NotificationType.pendingRequest ||
      type == NotificationType.requestApproved ||
      type == NotificationType.requestRejected ||
      type == NotificationType.requestRevision;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? workspaceId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    NotificationActionType? actionType,
    Map<String, dynamic>? actionData,
    bool? isRead,
    bool? isDismissed,
    DateTime? readAt,
    DateTime? dismissedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workspaceId: workspaceId ?? this.workspaceId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      readAt: readAt ?? this.readAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workspace_id': workspaceId,
      'type': type.name,
      'title': title,
      'message': message,
      'data': data,
      'action_type': actionType.name,
      'action_data': actionData,
      'is_read': isRead,
      'is_dismissed': isDismissed,
      'read_at': readAt?.toIso8601String(),
      'dismissed_at': dismissedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString(),
      type: _parseNotificationType(json['type']?.toString()),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString(),
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
      actionType: _parseNotificationActionType(json['action_type']?.toString()),
      actionData: json['action_data'] != null
          ? Map<String, dynamic>.from(json['action_data'] as Map)
          : {},
      isRead: json['is_read'] as bool? ?? false,
      isDismissed: json['is_dismissed'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      dismissedAt: json['dismissed_at'] != null
          ? DateTime.tryParse(json['dismissed_at'].toString())
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  static NotificationType _parseNotificationType(String? value) {
    if (value == null) return NotificationType.pendingRequest;
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.pendingRequest,
    );
  }

  static NotificationActionType _parseNotificationActionType(String? value) {
    if (value == null) return NotificationActionType.none;
    return NotificationActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationActionType.none,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Notification state for provider
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  List<AppNotification> get pendingInvitations =>
      notifications.where((n) => n.isInvitation && !n.isRead).toList();

  List<AppNotification> get unreadNotifications =>
      notifications.where((n) => !n.isRead && !n.isDismissed).toList();

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
