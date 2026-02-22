import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../workspace/workspace_provider.dart';

class WorkspaceSettingsScreen extends StatefulWidget {
  const WorkspaceSettingsScreen({super.key});

  @override
  State<WorkspaceSettingsScreen> createState() =>
      _WorkspaceSettingsScreenState();
}

class _WorkspaceSettingsScreenState extends State<WorkspaceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final workspaceProvider = context.watch<WorkspaceProvider>();
    final currentWorkspace = workspaceProvider.currentWorkspace;
    final currentUser = context.watch<AuthProvider>().user;

    if (currentWorkspace == null || currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No workspace selected')),
      );
    }

    // Only owner can delete workspace
    final isOwner = currentWorkspace.createdBy == currentUser.id ||
        currentWorkspace.ownerId == currentUser.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workspace Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // Workspace Info Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace Information',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(AppLocalizations.of(context)!.name, currentWorkspace.name),
                if (currentWorkspace.description != null)
                  _buildInfoRow(AppLocalizations.of(context)!.description, currentWorkspace.description!),
                _buildInfoRow(
                  'Created',
                  currentWorkspace.createdAt.toLocal().toString().split(' ')[0],
                ),
                _buildInfoRow(
                  'Members',
                  '${currentWorkspace.members.length} members',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Danger Zone
          if (isOwner) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Danger Zone',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Deleting a workspace will permanently remove all data including templates, requests, and member information. This action cannot be undone.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context),
                        icon:
                            Icon(Icons.delete_forever, color: AppColors.error),
                        label: Text(
                          'Delete Workspace',
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permissions',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Only the workspace owner can delete this workspace. Contact the owner if you need to make changes.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final currentWorkspace = workspaceProvider.currentWorkspace;

    if (currentWorkspace == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Delete Workspace'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${currentWorkspace.name}"?',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This will permanently delete:',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildBulletPoint('All templates'),
            _buildBulletPoint('All requests and approvals'),
            _buildBulletPoint('All member data'),
            _buildBulletPoint('Workspace settings'),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This action cannot be undone.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_forever),
            label: Text(AppLocalizations.of(context)!.delete),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      await _deleteWorkspace(context);
    }
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWorkspace(BuildContext context) async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final navigator = Navigator.of(context);

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      await workspaceProvider.deleteWorkspace();

      if (!mounted) return;

      // Hide loading
      navigator.pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workspace deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to workspace switch or dashboard
      navigator.pushNamedAndRemoveUntil(
        RouteNames.workspaceSwitch,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      // Hide loading if showing
      if (navigator.canPop()) {
        navigator.pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete workspace: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
