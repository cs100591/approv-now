import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/plan_limit_widgets.dart';
import '../../subscription/subscription_provider.dart';
import '../../subscription/plan_upgrade_dialog.dart';
import '../../plan_enforcement/plan_guard_service.dart';
import '../workspace_provider.dart';
import '../workspace_member.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
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
        title: Text(AppLocalizations.of(context)!.teamMembers),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _handleInvitePressed(),
          ),
        ],
      ),
      body: Consumer2<WorkspaceProvider, SubscriptionProvider>(
        builder: (context, workspaceProvider, subscriptionProvider, child) {
          if (workspaceProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final currentWorkspace = workspaceProvider.currentWorkspace;

          if (currentWorkspace == null) {
            return const EmptyState(
              icon: Icons.business_outlined,
              message: 'No Workspace Selected',
              subMessage: 'Please select a workspace first',
            );
          }

          final members = currentWorkspace.members;
          final currentPlan = subscriptionProvider.currentPlan;
          final memberCount = members.length;
          final canInvite = PlanGuardService.canInviteTeamMember(
            currentPlan: currentPlan,
            currentMemberCount: memberCount,
          );

          // Calculate proper indices accounting for email banner
          final hasEmailBanner = !AppConfig.emailsEnabled;
          final headerIndex = 0;
          final inviteButtonIndex =
              1 + (hasEmailBanner ? 1 : 0) + members.length;

          return RefreshIndicator(
            onRefresh: _loadWorkspaces,
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: (hasEmailBanner ? 1 : 0) + 2 + members.length,
              itemBuilder: (context, index) {
                if (index == headerIndex) {
                  // Plan limit indicator header (with optional email banner)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasEmailBanner) _buildEmailDisabledBanner(),
                      PlanLimitIndicator(
                        currentPlan: currentPlan,
                        action: PlanAction.inviteTeamMember,
                        currentCount: memberCount,
                        label: AppLocalizations.of(context)!.teamMembers,
                        showUpgradeButton: true,
                        onUpgradePressed: () => _showUpgradeDialog(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                }

                if (index == inviteButtonIndex) {
                  // Invite button at the bottom
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: canInvite
                        ? SecondaryButton(
                            text: AppLocalizations.of(context)!.inviteNewMember,
                            onPressed: () => _showInviteCodeDialog(),
                          )
                        : PlanLimitReachedWidget(
                            resourceName: 'Team Member',
                            onUpgrade: () => _showUpgradeDialog(context),
                          ),
                  );
                }

                // Member cards are between header and invite button
                final memberIndex = index - 1 - (hasEmailBanner ? 1 : 0);
                if (memberIndex >= 0 && memberIndex < members.length) {
                  return _buildMemberCard(members[memberIndex]);
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleInvitePressed() async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    final currentWorkspace = workspaceProvider.currentWorkspace;
    if (currentWorkspace == null) return;

    final currentPlan = subscriptionProvider.currentPlan;
    final memberCount = currentWorkspace.members.length;

    final canInvite = PlanGuardService.canInviteTeamMember(
      currentPlan: currentPlan,
      currentMemberCount: memberCount,
    );

    if (!canInvite) {
      await _showUpgradeDialog(context);
      return;
    }

    _showInviteCodeDialog();
  }

  Future<void> _showUpgradeDialog(BuildContext context) async {
    await PlanUpgradeDialog.show(
      context: context,
      title: 'Team Member Limit Reached',
      message:
          'You\'ve reached the maximum number of team members for your current plan.',
      currentPlan: context.read<SubscriptionProvider>().currentPlan,
    );
  }

  Widget _buildEmailDisabledBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email_outlined,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Email notifications are currently disabled. Share the invitation link manually.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(WorkspaceMember member) {
    final isPending = member.isPending;
    final displayName = member.displayName ?? member.email;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: CircleAvatar(
          backgroundColor: isPending
              ? AppColors.textSecondary.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            displayName[0].toUpperCase(),
            style: TextStyle(
              color: isPending ? AppColors.textSecondary : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildRoleBadge(member.role),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.email,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (isPending)
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Pending Invitation',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: member.role == WorkspaceRole.owner
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) => _onMemberAction(value, member),
                itemBuilder: (context) => [
                  if (member.userId != null && member.userId!.isNotEmpty)
                    PopupMenuItem(
                      value: 'change_role',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Change Role'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.remove,
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRoleBadge(WorkspaceRole role) {
    Color color;
    switch (role) {
      case WorkspaceRole.owner:
        color = AppColors.primary;
        break;
      case WorkspaceRole.admin:
        color = Colors.blue;
        break;
      case WorkspaceRole.editor:
        color = Colors.green;
        break;
      case WorkspaceRole.viewer:
        color = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.displayName,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _onMemberAction(String action, WorkspaceMember member) async {
    switch (action) {
      case 'remove':
        _showRemoveDialog(member);
        break;
      case 'change_role':
        _showChangeRoleDialog(member);
        break;
    }
  }

  void _showRemoveDialog(WorkspaceMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (member.userId == null) {
                // Pending invitation - can't remove via userId
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot remove pending invitation from here'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              final provider = context.read<WorkspaceProvider>();
              await provider.removeMember(member.userId!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${member.email} removed')),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.remove,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(WorkspaceMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${member.email}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WorkspaceRole.values
              .where((r) => r != WorkspaceRole.owner)
              .map((role) => ListTile(
                    title: Text(role.displayName),
                    subtitle: Text(role.description),
                    leading: Radio<WorkspaceRole>(
                      value: role,
                      groupValue: member.role,
                      onChanged: (value) async {
                        if (member.userId == null) {
                          // Pending invitation - can't change role
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Cannot change role of pending invitation'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        if (value != null) {
                          final provider = context.read<WorkspaceProvider>();
                          await provider.updateMemberRole(
                              member.userId!, value);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Role updated to ${role.displayName}'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _showInviteCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Invite Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate a 6-character invite code that anyone can use to join this workspace.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Code Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Valid for 24 hours\n'
                    '• Can be used by multiple people\n'
                    '• New members join as Viewer role',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<WorkspaceProvider>();
              final result = await provider.generateInviteCode();

              if (mounted) {
                Navigator.pop(context);
                if (result != null) {
                  _showInviteCodeResultDialog(result);
                } else if (provider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error!),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Generate Code'),
          ),
        ],
      ),
    );
  }

  void _showInviteCodeResultDialog(Map<String, dynamic> inviteCode) {
    final code = inviteCode['code'] as String;
    final expiresAt = DateTime.parse(inviteCode['expires_at'] as String);
    final formattedDate =
        '${expiresAt.day}/${expiresAt.month}/${expiresAt.year}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Code Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expires: $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Share this code with team members. They can use it to join this workspace.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Copy to clipboard
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code copied to clipboard'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Copy Code'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.done),
          ),
        ],
      ),
    );
  }
}
