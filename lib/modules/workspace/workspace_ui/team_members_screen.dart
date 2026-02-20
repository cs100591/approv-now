import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../workspace/workspace_provider.dart';

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
            onPressed: () => _showInviteDialog(),
          ),
        ],
      ),
      body: Consumer<WorkspaceProvider>(
        builder: (context, workspaceProvider, child) {
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

          if (members.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              message: 'No Members',
              subMessage: 'Invite team members to your workspace',
              action: PrimaryButton(
                text: 'Invite Member',
                onPressed: () => _showInviteDialog(),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadWorkspaces,
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: members.length + 1,
              itemBuilder: (context, index) {
                if (index == members.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: SecondaryButton(
                      text: 'Invite New Member',
                      onPressed: () => _showInviteDialog(),
                    ),
                  );
                }

                return _buildMemberCard(members[index], index == 0);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberCard(String memberEmail, bool isOwner) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            memberEmail[0].toUpperCase(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                memberEmail,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isOwner)
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
                  'Owner',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          'Member',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: isOwner
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) => _onMemberAction(value, memberEmail),
                itemBuilder: (context) => [
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

  void _onMemberAction(String action, String memberEmail) {
    if (action == 'remove') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Member'),
          content: Text('Are you sure you want to remove $memberEmail?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$memberEmail removed')),
                );
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
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            Text(
              'An invitation email will be sent to this address.',
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
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invitation sent to ${emailController.text}'),
                  ),
                );
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}
