import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/auth_provider.dart';
import '../../../request/request_provider.dart';
import '../../../request/request_models.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RequestProvider, AuthProvider>(
      builder: (context, requestProvider, authProvider, child) {
        final currentUser = authProvider.user;
        if (currentUser == null) return const SizedBox.shrink();

        // My requests stats
        final myRequests = requestProvider.requests
            .where((r) => r.submittedBy == currentUser.id)
            .toList();

        final myPending =
            myRequests.where((r) => r.status == RequestStatus.pending).length;
        final myApproved =
            myRequests.where((r) => r.status == RequestStatus.approved).length;

        // Pending approvals for me
        final pendingApprovals = requestProvider.state.pendingCount;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // First row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'My Pending',
                      myPending.toString(),
                      Icons.hourglass_empty,
                      AppColors.warning,
                      () => Navigator.pushNamed(context, RouteNames.myRequests),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 80,
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'To Approve',
                      pendingApprovals.toString(),
                      Icons.check_circle_outline,
                      AppColors.success,
                      () =>
                          Navigator.pushNamed(context, RouteNames.approvalView),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 1,
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
              // Second row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'My Approved',
                      myApproved.toString(),
                      Icons.check_circle,
                      AppColors.success,
                      () => Navigator.pushNamed(context, RouteNames.myRequests),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 80,
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total',
                      myRequests.length.toString(),
                      Icons.folder_outlined,
                      AppColors.primary,
                      () => Navigator.pushNamed(context, RouteNames.myRequests),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
