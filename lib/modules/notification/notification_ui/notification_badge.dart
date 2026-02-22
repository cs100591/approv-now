import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../notification_provider.dart';
import 'notifications_screen.dart';

class NotificationBadge extends StatelessWidget {
  final Color? badgeColor;
  final double size;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    this.badgeColor,
    this.size = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;
        final hasPendingInvitations =
            notificationProvider.hasPendingInvitations;

        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: size,
                color: hasPendingInvitations
                    ? AppColors.warning
                    : AppColors.textPrimary,
              ),
              onPressed: onTap ??
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class NotificationBanner extends StatelessWidget {
  const NotificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final pendingInvitations = notificationProvider.pendingInvitations;

        if (pendingInvitations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.mail_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You have ${pendingInvitations.length} pending workspace invitation${pendingInvitations.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warning,
                ),
                child: const Text('View'),
              ),
            ],
          ),
        );
      },
    );
  }
}
