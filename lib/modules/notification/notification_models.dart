/// Notification types
enum NotificationType {
  newRequest,
  requestApproved,
  requestRejected,
  revisionRestart,
  mention,
  reminder,
}

/// Notification model
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? requestId;
  final String? workspaceId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.requestId,
    this.workspaceId,
    this.isRead = false,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? requestId,
    String? workspaceId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      requestId: requestId ?? this.requestId,
      workspaceId: workspaceId ?? this.workspaceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type.name,
        'requestId': requestId,
        'workspaceId': workspaceId,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.newRequest,
        ),
        requestId: json['requestId'] as String?,
        workspaceId: json['workspaceId'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
