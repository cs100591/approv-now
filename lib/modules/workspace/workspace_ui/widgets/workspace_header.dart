import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../subscription/subscription_provider.dart';
import '../../../template/template_provider.dart';
import '../../../request/request_provider.dart';
import '../../../auth/auth_provider.dart';
import '../../workspace_provider.dart';

class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkspaceProvider, SubscriptionProvider>(
      builder: (context, workspaceProvider, subscriptionProvider, child) {
        final currentWorkspace = workspaceProvider.currentWorkspace;
        final currentPlan = subscriptionProvider.currentPlan;

        if (currentWorkspace == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Workspace Icon/Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Workspace Name and Plan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (workspaceId) async {
                        final authUser = context.read<AuthProvider>().user;
                        if (authUser == null) return;

                        await workspaceProvider.switchWorkspace(workspaceId);
                        if (context.mounted) {
                          context
                              .read<TemplateProvider>()
                              .setCurrentWorkspace(workspaceId);
                          context.read<RequestProvider>().setCurrentWorkspace(
                                workspaceId,
                                approverId: authUser.id,
                              );
                        }
                      },
                      offset: const Offset(0, 40),
                      itemBuilder: (context) {
                        return workspaceProvider.workspaces.map((ws) {
                          final isSelected = ws.id == currentWorkspace.id;
                          return PopupMenuItem<String>(
                            value: ws.id,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ws.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              currentWorkspace.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPlanColor(currentPlan.name)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _capitalizeFirst(currentPlan.name),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getPlanColor(currentPlan.name),
                            ),
                          ),
                        ),
                        if (currentPlan.name == 'free') ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.workspaceSwitch,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.upgrade,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  AppLocalizations.of(context)!.upgrade,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Member Count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${currentWorkspace.members.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPlanColor(String planName) {
    switch (planName.toLowerCase()) {
      case 'free':
        return AppColors.textSecondary;
      case 'starter':
        return AppColors.info;
      case 'pro':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
