import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart' show Consumer2;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/plan_limit_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../subscription/subscription_provider.dart';
import '../../subscription/subscription_models.dart';
import '../../subscription/plan_upgrade_dialog.dart';
import '../../plan_enforcement/plan_guard_service.dart';
import '../workspace_provider.dart';
import '../workspace_models.dart';

class WorkspaceSwitchScreen extends StatefulWidget {
  const WorkspaceSwitchScreen({super.key});

  @override
  State<WorkspaceSwitchScreen> createState() => _WorkspaceSwitchScreenState();
}

class _WorkspaceSwitchScreenState extends State<WorkspaceSwitchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkspaces();
    });
  }

  Future<void> _loadWorkspaces() async {
    await context.read<WorkspaceProvider>().loadWorkspaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Switch Workspace'),
      ),
      body: Consumer2<WorkspaceProvider, SubscriptionProvider>(
        builder: (context, workspaceProvider, subscriptionProvider, child) {
          if (workspaceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final workspaces = workspaceProvider.workspaces;
          final currentWorkspace = workspaceProvider.currentWorkspace;
          final currentPlan = subscriptionProvider.currentPlan;
          final workspaceCount = workspaces.length;
          final canCreate = PlanGuardService.canCreateWorkspace(
            currentPlan: currentPlan,
            currentWorkspaceCount: workspaceCount,
          );

          if (workspaces.isEmpty) {
            return EmptyState(
              icon: Icons.business_outlined,
              message: 'No Workspaces',
              subMessage: 'Create your first workspace to get started',
              action: PrimaryButton(
                text: 'Create Workspace',
                onPressed: () => _handleCreatePressed(),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadWorkspaces,
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount:
                  workspaces.length + 2, // +2 for header and create button
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Plan limit indicator at the top
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlanLimitIndicator(
                        currentPlan: currentPlan,
                        action: PlanAction.createWorkspace,
                        currentCount: workspaceCount,
                        label: 'Workspaces',
                        showUpgradeButton: true,
                        onUpgradePressed: () => _showUpgradeDialog(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                }

                if (index == workspaces.length + 1) {
                  // Create workspace button at the bottom
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: canCreate
                        ? SecondaryButton(
                            text: 'Create New Workspace',
                            onPressed: () => _showCreateWorkspaceDialog(),
                          )
                        : PlanLimitReachedWidget(
                            resourceName: 'Workspace',
                            onUpgrade: () => _showUpgradeDialog(context),
                          ),
                  );
                }

                final workspace = workspaces[index - 1];
                final isSelected = currentWorkspace?.id == workspace.id;

                return _buildWorkspaceCard(workspace, isSelected);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleCreatePressed() async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    final currentPlan = subscriptionProvider.currentPlan;
    final workspaceCount = workspaceProvider.workspaces.length;

    final canCreate = PlanGuardService.canCreateWorkspace(
      currentPlan: currentPlan,
      currentWorkspaceCount: workspaceCount,
    );

    if (!canCreate) {
      await _showUpgradeDialog(context);
      return;
    }

    _showCreateWorkspaceDialog();
  }

  Future<void> _showUpgradeDialog(BuildContext context) async {
    await PlanUpgradeDialog.show(
      context: context,
      title: 'Workspace Limit Reached',
      message:
          'You\'ve reached the maximum number of workspaces for your current plan.',
      currentPlan: context.read<SubscriptionProvider>().currentPlan,
    );
  }

  Widget _buildWorkspaceCard(Workspace workspace, bool isSelected) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary)
                : Border.all(color: AppColors.divider),
          ),
          child: Center(
            child: workspace.logoUrl != null
                ? Image.network(
                    workspace.logoUrl!,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.business),
                  )
                : Icon(
                    Icons.business,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                workspace.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Active',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (workspace.description != null &&
                workspace.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  workspace.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _getPlanColor(workspace.plan).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                workspace.plan.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: _getPlanColor(workspace.plan),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.chevron_right),
        onTap: isSelected ? null : () => _switchWorkspace(workspace),
      ),
    );
  }

  Color _getPlanColor(String plan) {
    switch (plan.toLowerCase()) {
      case 'free':
        return AppColors.textSecondary;
      case 'starter':
        return AppColors.info;
      case 'pro':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _switchWorkspace(Workspace workspace) async {
    final workspaceProvider = context.read<WorkspaceProvider>();

    try {
      await workspaceProvider.switchWorkspace(workspace.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to ${workspace.name}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showCreateWorkspaceDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameController,
              label: 'Workspace Name',
              hint: 'My Company',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: descriptionController,
              label: 'Description (Optional)',
              hint: 'Brief description',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final authProvider = context.read<AuthProvider>();
              final workspaceProvider = context.read<WorkspaceProvider>();

              if (authProvider.user == null) return;

              Navigator.pop(context);

              try {
                await workspaceProvider.createWorkspace(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  createdBy: authProvider.user!.id,
                  creatorEmail: authProvider.user!.email,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Workspace created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
