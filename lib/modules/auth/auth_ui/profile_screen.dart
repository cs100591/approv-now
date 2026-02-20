import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            // Profile Header
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              _getInitials(user.displayName ?? user.email),
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user.displayName ?? 'No Name',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Account Settings
            _buildSectionTitle('Account'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () => _showEditProfileDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.notifications);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Workspaces
            _buildSectionTitle('Workspaces'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.business,
                    title: 'Switch Workspace',
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.workspaceSwitch);
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.people_outline,
                    title: 'Team Members',
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.teamMembers);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Analytics & Reports
            _buildSectionTitle('Analytics'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.analytics_outlined,
                    title: 'View Analytics',
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.analytics);
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.download_outlined,
                    title: 'Export Reports',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout Button
            SecondaryButton(
              text: 'Log Out',
              onPressed: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: AppSpacing.lg),

            // App Info
            Text(
              'Approv Now v1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '© 2026 Approv Now. All rights reserved.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.h4,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  String _getInitials(String text) {
    if (text.isEmpty) return '?';
    final parts = text.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return text[0].toUpperCase();
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.displayName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: AppTextField(
          controller: nameController,
          label: 'Display Name',
          hint: 'Your name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Note: This would need a method in AuthProvider to update profile
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.login,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
