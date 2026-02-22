import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../request/request_provider.dart';

class PendingApprovalBanner extends StatelessWidget {
  const PendingApprovalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestProvider>(
      builder: (context, requestProvider, child) {
        // Use pendingRequests from provider which is already filtered
        final pendingCount = requestProvider.state.pendingCount;

        if (pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withValues(alpha: 0.15),
                AppColors.warning.withValues(alpha: 0.05),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pendingCount == 1
                          ? '1 request needs your approval'
                          : '$pendingCount requests need your approval',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to review and approve',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  RouteNames.approvalView,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
