import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../../modules/subscription/subscription_models.dart';
import '../../modules/plan_enforcement/plan_guard_service.dart';

/// Widget to display plan usage indicator with progress bar
class PlanLimitIndicator extends StatelessWidget {
  final PlanType currentPlan;
  final PlanAction action;
  final int currentCount;
  final String label;
  final bool showUpgradeButton;
  final VoidCallback? onUpgradePressed;

  const PlanLimitIndicator({
    super.key,
    required this.currentPlan,
    required this.action,
    required this.currentCount,
    required this.label,
    this.showUpgradeButton = false,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    final maxCount = _getMaxCount(entitlements);
    final percentage = PlanGuardService.getUsagePercentage(
      currentPlan: currentPlan,
      action: action,
      currentCount: currentCount,
    );
    final isAtLimit = percentage >= 1.0;
    final isApproachingLimit = PlanGuardService.isApproachingLimit(
      currentPlan: currentPlan,
      action: action,
      currentCount: currentCount,
    );

    Color progressColor;
    if (isAtLimit) {
      progressColor = AppColors.error;
    } else if (isApproachingLimit) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAtLimit
              ? AppColors.error.withOpacity(0.3)
              : AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$currentCount / ${maxCount == 1000 ? '∞' : maxCount}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isAtLimit
                          ? AppColors.error
                          : isApproachingLimit
                              ? Colors.orange
                              : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showUpgradeButton &&
                      (isAtLimit || isApproachingLimit)) ...[
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: onUpgradePressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Upgrade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          if (isAtLimit) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Limit reached. Upgrade your plan to add more.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ] else if (isApproachingLimit) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Approaching limit. Consider upgrading soon.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getMaxCount(PlanEntitlements entitlements) {
    switch (action) {
      case PlanAction.createTemplate:
        return entitlements.maxTemplates;
      case PlanAction.addApprovalLevel:
        return entitlements.maxApprovalLevels;
      case PlanAction.createWorkspace:
        return entitlements.maxWorkspaces;
      case PlanAction.inviteTeamMember:
        return entitlements.maxTeamMembers;
      default:
        return 0;
    }
  }
}

/// Compact version for inline display
class PlanLimitBadge extends StatelessWidget {
  final PlanType currentPlan;
  final PlanAction action;
  final int currentCount;

  const PlanLimitBadge({
    super.key,
    required this.currentPlan,
    required this.action,
    required this.currentCount,
  });

  @override
  Widget build(BuildContext context) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    final maxCount = _getMaxCount(entitlements);
    final percentage = PlanGuardService.getUsagePercentage(
      currentPlan: currentPlan,
      action: action,
      currentCount: currentCount,
    );

    Color backgroundColor;
    Color textColor;
    if (percentage >= 1.0) {
      backgroundColor = AppColors.error.withOpacity(0.1);
      textColor = AppColors.error;
    } else if (percentage >= 0.8) {
      backgroundColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
    } else {
      backgroundColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$currentCount/${maxCount == 1000 ? '∞' : maxCount}',
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  int _getMaxCount(PlanEntitlements entitlements) {
    switch (action) {
      case PlanAction.createTemplate:
        return entitlements.maxTemplates;
      case PlanAction.addApprovalLevel:
        return entitlements.maxApprovalLevels;
      case PlanAction.createWorkspace:
        return entitlements.maxWorkspaces;
      case PlanAction.inviteTeamMember:
        return entitlements.maxTeamMembers;
      default:
        return 0;
    }
  }
}

/// Widget to show when limit is reached
class PlanLimitReachedWidget extends StatelessWidget {
  final String resourceName;
  final VoidCallback? onUpgrade;

  const PlanLimitReachedWidget({
    super.key,
    required this.resourceName,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$resourceName Limit Reached',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You\'ve reached the maximum number of $resourceName for your current plan. Upgrade to add more.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (onUpgrade != null)
            ElevatedButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
