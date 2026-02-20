import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';
import '../notification_provider.dart';
import '../notification_models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  void _loadNotifications() {
    final authProvider = context.read<AuthProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    if (authProvider.user != null) {
      notificationProvider.initialize(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () {
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.user != null) {
                    notificationProvider.markAllAsRead(authProvider.user!.id);
                  }
                },
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              message: 'No Notifications',
              subMessage: 'You\'re all caught up!',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadNotifications(),
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final iconData = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // Delete notification would go here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification dismissed')),
        );
      },
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppSpacing.md),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xs),
              Text(
                notification.body,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatTime(notification.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          onTap: () {
            if (!notification.isRead) {
              context.read<NotificationProvider>().markAsRead(notification.id);
            }
            // Navigate to related request if available
            if (notification.requestId != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening request...')),
              );
            }
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newRequest:
        return Icons.description;
      case NotificationType.requestApproved:
        return Icons.check_circle;
      case NotificationType.requestRejected:
        return Icons.cancel;
      case NotificationType.revisionRestart:
        return Icons.refresh;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.reminder:
        return Icons.access_time;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newRequest:
        return AppColors.info;
      case NotificationType.requestApproved:
        return AppColors.success;
      case NotificationType.requestRejected:
        return AppColors.error;
      case NotificationType.revisionRestart:
        return AppColors.warning;
      case NotificationType.mention:
        return AppColors.primary;
      case NotificationType.reminder:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
