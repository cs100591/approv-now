import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart' show Consumer2;
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/plan_limit_widgets.dart';
import '../../subscription/subscription_models.dart';
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
        title: const Text('Team Members'),
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
            return const Center(child: CircularProgressIndicator());
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
                        label: 'Team Members',
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
                            text: 'Invite New Member',
                            onPressed: () => _showInviteDialog(),
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

    _showInviteDialog();
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
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
              ? AppColors.textSecondary.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
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
                  color: Colors.orange.withOpacity(0.1),
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
                  if (member.isActive)
                    const PopupMenuItem(
                      value: 'change_role',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Change Role'),
                        ],
                      ),
                    ),
                  if (member.isPending && AppConfig.emailsEnabled)
                    const PopupMenuItem(
                      value: 'resend',
                      child: Row(
                        children: [
                          Icon(Icons.send, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Resend Invite'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Remove',
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
        color: color.withOpacity(0.1),
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
      case 'resend':
        await _resendInvitation(member);
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<WorkspaceProvider>();
              await provider.removeMember(member.userId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${member.email} removed')),
                );
              }
            },
            child: const Text(
              'Remove',
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
                        Navigator.pop(context);
                        if (value != null) {
                          final provider = context.read<WorkspaceProvider>();
                          await provider.updateMemberRole(member.userId, value);
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _resendInvitation(WorkspaceMember member) async {
    if (!AppConfig.emailsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email notifications are disabled'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Implement resend invitation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invitation resent to ${member.email}')),
    );
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();
    WorkspaceRole selectedRole = WorkspaceRole.editor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Invite Team Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: emailController,
                label: 'Email Address',
                hint: 'colleague@company.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<WorkspaceRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: WorkspaceRole.values
                    .where((r) => r != WorkspaceRole.owner)
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                selectedRole.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppConfig.emailsEnabled
                    ? 'An invitation email will be sent to this address.'
                    : 'An invitation will be created. Share the invite link manually.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an email address'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final provider = context.read<WorkspaceProvider>();
                final result = await provider.inviteMember(
                  email: email,
                  role: selectedRole,
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invitation sent to $email'),
                        backgroundColor: AppColors.success,
                      ),
                    );
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
              child: const Text('Send Invite'),
            ),
          ],
        ),
      ),
    );
  }
}
