import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/app_logger.dart';
import '../../auth/auth_provider.dart';
import '../../workspace/workspace_provider.dart';
import '../notification_provider.dart';
import '../notification_models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationFilter _filter = NotificationFilter.all;

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
        title: Text(AppLocalizations.of(context)!.notifications),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () {
                  notificationProvider.markAllAsRead();
                },
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                if (notificationProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (notificationProvider.error != null) {
                  return ErrorState(
                    message: notificationProvider.error!,
                    onRetry: _loadNotifications,
                  );
                }

                final notifications =
                    _getFilteredNotifications(notificationProvider);

                if (notifications.isEmpty) {
                  return EmptyState(
                    icon: Icons.notifications_none,
                    message: 'No Notifications',
                    subMessage: _filter == NotificationFilter.all
                        ? "You're all caught up!"
                        : 'No ${_filter.name} notifications',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadNotifications(),
                  child: ListView.builder(
                    padding: AppSpacing.screenPadding,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      if (notification.isInvitation) {
                        return _buildInvitationCard(
                            notification, notificationProvider);
                      }
                      return _buildNotificationCard(
                          notification, notificationProvider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: NotificationFilter.values.map((filter) {
            final isSelected = _filter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(_getFilterLabel(filter)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _filter = filter);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterLabel(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return AppLocalizations.of(context)!.all;
      case NotificationFilter.invitations:
        return 'Invitations';
      case NotificationFilter.requests:
        return AppLocalizations.of(context)!.requests;
    }
  }

  List<AppNotification> _getFilteredNotifications(
      NotificationProvider provider) {
    switch (_filter) {
      case NotificationFilter.invitations:
        return provider.notifications.where((n) => n.isInvitation).toList();
      case NotificationFilter.requests:
        return provider.notifications.where((n) => n.isRequestRelated).toList();
      case NotificationFilter.all:
        return provider.notifications;
    }
  }

  Widget _buildInvitationCard(
    AppNotification notification,
    NotificationProvider notificationProvider,
  ) {
    final workspaceName =
        notification.data['workspace_name'] ?? 'Unknown Workspace';
    final inviterName = notification.data['inviter_name'] ?? 'Someone';

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        notificationProvider.dismissNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation dismissed')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.mail, color: AppColors.warning),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workspace Invitation',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatTime(notification.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspaceName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$inviterName invited you to join this workspace',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _declineInvitation(
                          notification, notificationProvider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _acceptInvitation(notification, notificationProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    AppNotification notification,
    NotificationProvider notificationProvider,
  ) {
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
        notificationProvider.dismissNotification(notification.id);
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
              color: iconColor.withValues(alpha: 0.1),
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
              if (notification.message != null)
                Text(
                  notification.message!,
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
              notificationProvider.markAsRead(notification.id);
            }
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    switch (notification.actionType) {
      case NotificationActionType.viewRequest:
        final requestId = notification.actionData['request_id'];
        if (requestId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening request $requestId...')),
          );
        }
        break;
      case NotificationActionType.viewWorkspace:
        final workspaceId = notification.actionData['workspace_id'];
        if (workspaceId != null) {
          final workspaceProvider = context.read<WorkspaceProvider>();
          workspaceProvider.switchWorkspace(workspaceId);
          Navigator.of(context).pop();
        }
        break;
      default:
        break;
    }
  }

  Future<void> _acceptInvitation(
    AppNotification notification,
    NotificationProvider notificationProvider,
  ) async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final authProvider = context.read<AuthProvider>();

    final inviteToken = notification.actionData['invitation_token'];
    final userId = authProvider.user?.id;

    if (inviteToken == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to accept invitation'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await workspaceProvider.acceptInvitation(
        inviteToken: inviteToken,
        userId: userId,
        displayName: authProvider.user?.displayName,
      );

      await notificationProvider.markAsRead(notification.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation accepted!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to accept invitation', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept invitation: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _declineInvitation(
    AppNotification notification,
    NotificationProvider notificationProvider,
  ) async {
    final inviteToken = notification.actionData['invitation_token'];

    if (inviteToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to decline invitation'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final workspaceProvider = context.read<WorkspaceProvider>();
      await workspaceProvider.declineInvitation(inviteToken);
      await notificationProvider.dismissNotification(notification.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation declined')),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to decline invitation', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to decline invitation: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.workspaceInvitation:
        return Icons.mail;
      case NotificationType.invitationAccepted:
        return Icons.person_add;
      case NotificationType.invitationDeclined:
        return Icons.person_remove;
      case NotificationType.pendingRequest:
        return Icons.description;
      case NotificationType.requestApproved:
        return Icons.check_circle;
      case NotificationType.requestRejected:
        return Icons.cancel;
      case NotificationType.requestRevision:
        return Icons.refresh;
      case NotificationType.memberAdded:
        return Icons.group_add;
      case NotificationType.memberRemoved:
        return Icons.group_remove;
      case NotificationType.mention:
        return Icons.alternate_email;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.workspaceInvitation:
        return AppColors.warning;
      case NotificationType.invitationAccepted:
        return AppColors.success;
      case NotificationType.invitationDeclined:
        return AppColors.error;
      case NotificationType.pendingRequest:
        return AppColors.info;
      case NotificationType.requestApproved:
        return AppColors.success;
      case NotificationType.requestRejected:
        return AppColors.error;
      case NotificationType.requestRevision:
        return AppColors.warning;
      case NotificationType.memberAdded:
        return AppColors.primary;
      case NotificationType.memberRemoved:
        return AppColors.textSecondary;
      case NotificationType.mention:
        return AppColors.primary;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
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

enum NotificationFilter {
  all,
  invitations,
  requests,
}
