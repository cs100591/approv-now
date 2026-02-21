import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/auth_provider.dart';
import '../../../request/request_provider.dart';
import '../../../request/request_models.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RequestProvider, AuthProvider>(
      builder: (context, requestProvider, authProvider, child) {
        final currentUser = authProvider.user;
        if (currentUser == null) return const SizedBox.shrink();

        // Get recent activity (submitted by me or pending approvals for me)
        final myRequests = requestProvider.requests
            .where((r) => r.submittedBy == currentUser.id)
            .toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        final pendingForMe = requestProvider.state.pendingRequests.toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        // Combine and take top 5
        final recentActivity =
            [...pendingForMe, ...myRequests].take(5).toList();

        if (recentActivity.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent activity',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your requests and approvals will appear here',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.approvalView,
                    ),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Activity items
            ...recentActivity
                .map((request) => _buildActivityCard(context, request)),
          ],
        );
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, ApprovalRequest request) {
    final isPendingApproval = request.status == RequestStatus.pending;
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          RouteNames.approvalView,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.templateName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _getStatusText(request.status),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        Text(
                          _formatDate(request.submittedAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppColors.warning;
      case RequestStatus.approved:
        return AppColors.success;
      case RequestStatus.rejected:
        return AppColors.error;
      case RequestStatus.draft:
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.hourglass_empty;
      case RequestStatus.approved:
        return Icons.check_circle;
      case RequestStatus.rejected:
        return Icons.cancel;
      case RequestStatus.draft:
        return Icons.edit;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.draft:
        return 'Draft';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
