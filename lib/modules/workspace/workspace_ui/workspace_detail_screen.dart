import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/app_logger.dart';
import '../../auth/auth_provider.dart';
import '../workspace_provider.dart';
import '../workspace_models.dart';
import '../workspace_member.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final String workspaceId;

  const WorkspaceDetailScreen({
    super.key,
    required this.workspaceId,
  });

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = context.watch<WorkspaceProvider>();
    final currentUser = context.watch<AuthProvider>().user;

    final workspace = workspaceProvider.workspaces.firstWhere(
      (w) => w.id == widget.workspaceId,
      orElse: () => workspaceProvider.currentWorkspace!,
    );

    final isOwner = workspace.createdBy == currentUser?.id ||
        workspace.ownerId == currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(workspace.name),
        actions: [
          if (isOwner)
            TextButton.icon(
              onPressed: () => _deleteWorkspace(workspace),
              icon: Icon(Icons.delete, color: AppColors.error),
              label: Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Workspace Info Header
          Container(
            padding: AppSpacing.screenPadding,
            color: AppColors.surface,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: workspace.logoUrl != null
                        ? Image.network(
                            workspace.logoUrl!,
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.business),
                          )
                        : const Icon(Icons.business, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workspace.name,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (workspace.description != null)
                        Text(
                          workspace.description!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${workspace.members.length} members • ${workspace.plan.toUpperCase() ?? 'FREE'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _selectedTab == 0
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Info',
                            style: TextStyle(
                              color: _selectedTab == 0
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: _selectedTab == 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: _selectedTab == 1
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Members',
                            style: TextStyle(
                              color: _selectedTab == 1
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: _selectedTab == 1
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 2
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            color: _selectedTab == 2
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.settings,
                            style: TextStyle(
                              color: _selectedTab == 2
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: _selectedTab == 2
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildInfoTab(workspace, isOwner),
                _buildMembersTab(workspace, isOwner),
                _buildSettingsTab(workspace, isOwner),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(Workspace workspace, bool isOwner) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workspace Information',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(AppLocalizations.of(context)!.name, workspace.name),
              if (workspace.description != null)
                _buildInfoRow(AppLocalizations.of(context)!.description, workspace.description!),
              _buildInfoRow('Created',
                  workspace.createdAt.toLocal().toString().split(' ')[0]),
              _buildInfoRow('Plan', workspace.plan.toUpperCase() ?? 'FREE'),
              _buildInfoRow('Members', '${workspace.members.length}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isOwner)
          PrimaryButton(
            text: 'Edit Workspace',
            onPressed: () => _editWorkspace(workspace),
          ),
      ],
    );
  }

  Widget _buildMembersTab(Workspace workspace, bool isOwner) {
    return Column(
      children: [
        if (isOwner)
          Padding(
            padding: AppSpacing.screenPadding,
            child: PrimaryButton(
              text: 'Invite Members',
              onPressed: () => _inviteMembers(workspace),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: workspace.members.length,
            itemBuilder: (context, index) {
              final member = workspace.members[index];
              return _buildMemberCard(member, isOwner);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(WorkspaceMember member, bool isOwner) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            (member.displayName ?? member.email)[0].toUpperCase(),
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(member.displayName ?? member.email),
        subtitle: Text(
          '${member.role.name.toUpperCase()} • ${member.status.name}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: isOwner && member.role != WorkspaceRole.owner
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeMember(member);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.remove),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildSettingsTab(Workspace workspace, bool isOwner) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        if (isOwner) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danger Zone',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Deleting this workspace will remove all data including templates, requests, and member information.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteWorkspace(workspace),
                    icon: Icon(Icons.delete_forever, color: AppColors.error),
                    label: Text(
                      'Delete Workspace',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else
          Center(
            child: Text('Only workspace owner can change settings'),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Future<void> _editWorkspace(Workspace workspace) async {
    final nameController = TextEditingController(text: workspace.name);
    final descriptionController =
        TextEditingController(text: workspace.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
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
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final workspaceProvider = context.read<WorkspaceProvider>();
        await workspaceProvider.updateWorkspaceHeader(
          workspaceId: workspace.id,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workspace updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _inviteMembers(Workspace workspace) async {
    // Navigate to team members screen
    Navigator.pushNamed(context, RouteNames.teamMembers);
  }

  Future<void> _removeMember(WorkspaceMember member) async {
    // Show confirmation and remove member
  }

  Future<void> _deleteWorkspace(Workspace workspace) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workspace'),
        content: Text(
          'Are you sure you want to delete "${workspace.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(child: CircularProgressIndicator()),
        );

        final workspaceProvider = context.read<WorkspaceProvider>();
        await workspaceProvider.deleteWorkspace();

        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Go back to manage screen

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workspace deleted')),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
