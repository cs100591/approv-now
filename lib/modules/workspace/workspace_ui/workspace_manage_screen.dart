import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/plan_limit_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../subscription/subscription_provider.dart';
import '../../subscription/plan_upgrade_dialog.dart';
import '../../plan_enforcement/plan_guard_service.dart';
import '../workspace_provider.dart';
import '../workspace_models.dart';

class WorkspaceManageScreen extends StatefulWidget {
  const WorkspaceManageScreen({super.key});

  @override
  State<WorkspaceManageScreen> createState() => _WorkspaceManageScreenState();
}

class _WorkspaceManageScreenState extends State<WorkspaceManageScreen> {
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
    final currentUser = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageWorkspaces),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.dashboard,
                (route) => false,
              );
            },
            icon: const Icon(Icons.home),
            label: const Text('Home'),
          ),
        ],
      ),
      body: Consumer2<WorkspaceProvider, SubscriptionProvider>(
        builder: (context, workspaceProvider, subscriptionProvider, child) {
          if (workspaceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final workspaces = workspaceProvider.workspaces;
          final currentWorkspace = workspaceProvider.currentWorkspace;
          final currentPlan = subscriptionProvider.currentPlan;
          // Only owned workspaces count towards limit
          final ownedCount = currentUser != null
              ? PlanGuardService.countOwnedWorkspaces(
                  workspaces, currentUser.id)
              : workspaces.length;

          if (workspaces.isEmpty) {
            return EmptyState(
              icon: Icons.business_outlined,
              message: 'No Workspaces',
              subMessage: 'Create your first workspace to get started',
              action: PrimaryButton(
                text: AppLocalizations.of(context)!.createWorkspace,
                onPressed: () => _showCreateWorkspaceDialog(),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadWorkspaces,
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount:
                  workspaces.length + 2, // +2 for quota header + create button
              itemBuilder: (context, index) {
                // Quota indicator at the top
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlanLimitIndicator(
                        currentPlan: currentPlan,
                        action: PlanAction.createWorkspace,
                        currentCount: ownedCount,
                        label: AppLocalizations.of(context)!.workspaces,
                        showUpgradeButton: true,
                        onUpgradePressed: () => _showUpgradeDialog(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                }

                // Create workspace button at the bottom
                if (index == workspaces.length + 1) {
                  final canCreate = PlanGuardService.canCreateWorkspace(
                    currentPlan: currentPlan,
                    currentWorkspaceCount: ownedCount,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: canCreate
                        ? SecondaryButton(
                            text: 'Create New Workspace',
                            onPressed: () => _showCreateWorkspaceDialog(),
                          )
                        : PlanLimitReachedWidget(
                            resourceName:
                                AppLocalizations.of(context)!.workspace,
                            onUpgrade: () => _showUpgradeDialog(context),
                          ),
                  );
                }

                final workspace = workspaces[index - 1];
                final isSelected = currentWorkspace?.id == workspace.id;
                final isOwner = workspace.createdBy == currentUser?.id ||
                    workspace.ownerId == currentUser?.id;

                return _buildWorkspaceCard(workspace, isSelected, isOwner);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkspaceCard(
      Workspace workspace, bool isSelected, bool isOwner) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _openWorkspaceDetail(workspace),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppSpacing.md),
          leading: _buildWorkspaceLogo(workspace, isSelected),
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.active,
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
              const SizedBox(height: 4),
              Text(
                '${workspace.members.length} members',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (workspace.plan.isNotEmpty)
                Text(
                  workspace.plan.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.photo_camera_outlined, size: 20),
                  tooltip: 'Upload logo',
                  onPressed: () => _pickAndUploadLogo(workspace.id),
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceLogo(Workspace workspace, bool isSelected) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.primary)
            : Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: workspace.logoUrl != null
            ? Image.network(
                workspace.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => _logoFallback(isSelected),
              )
            : _logoFallback(isSelected),
      ),
    );
  }

  Widget _logoFallback(bool isSelected) {
    return Center(
      child: Icon(
        Icons.business,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Future<void> _pickAndUploadLogo(String workspaceId) async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    // Logo upload is available for Starter+ (non-brand-header plans)
    if (subscriptionProvider.showBrandHeader) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Workspace logos are available on Starter and Pro plans.',
          ),
          action: SnackBarAction(
            label: 'Upgrade',
            onPressed: () => _showUpgradeDialog(context),
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    final fileName =
        'logo_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading logo…')),
    );

    if (!mounted) return;
    final url = await context.read<WorkspaceProvider>().uploadWorkspaceLogo(
          workspaceId: workspaceId,
          imageBytes: bytes,
          fileName: fileName,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(url != null
            ? 'Logo updated successfully!'
            : 'Failed to upload logo. Please try again.'),
        backgroundColor: url != null ? AppColors.success : AppColors.error,
      ),
    );
  }

  void _openWorkspaceDetail(Workspace workspace) {
    Navigator.pushNamed(
      context,
      RouteNames.workspaceDetail,
      arguments: {'workspaceId': workspace.id},
    );
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

  Future<void> _showCreateWorkspaceDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createWorkspace),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Workspace Name',
                hintText: 'Enter workspace name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter description',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final workspaceProvider = context.read<WorkspaceProvider>();
        final authProvider = context.read<AuthProvider>();

        await workspaceProvider.createWorkspace(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          createdBy: authProvider.user!.id,
          creatorEmail: authProvider.user!.email ?? '',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workspace created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating workspace: $e')),
          );
        }
      }
    }
  }
}
