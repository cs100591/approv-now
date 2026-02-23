import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/auth_provider.dart';
import '../../subscription/subscription_provider.dart';
import '../notification_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;
  bool _requestUpdatesEnabled = true;
  bool _invitationUpdatesEnabled = true;
  bool _mentionUpdatesEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: Load from shared preferences or backend
    // For now using defaults
    setState(() {});
  }

  Future<void> _saveSettings() async {
    // TODO: Save to shared preferences or backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final isPro = subscriptionProvider.currentPlan.name.toLowerCase() == 'pro';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notificationSettings),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push Notifications Master Switch
            _buildSettingCard(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on your device',
              icon: Icons.notifications_active,
              trailing: Switch(
                value: _pushNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _pushNotificationsEnabled = value;
                    if (!value) {
                      // Disable all sub-options when master is off
                      _requestUpdatesEnabled = false;
                      _invitationUpdatesEnabled = false;
                      _mentionUpdatesEnabled = false;
                    }
                  });
                  _saveSettings();
                },
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Email Notifications (Pro only)
            _buildSettingCard(
              title: 'Email Notifications',
              subtitle: isPro
                  ? 'Receive email notifications'
                  : 'Upgrade to Pro to enable email notifications',
              icon: Icons.email,
              trailing: isPro
                  ? Switch(
                      value: _emailNotificationsEnabled,
                      onChanged: (value) {
                        setState(() => _emailNotificationsEnabled = value);
                        _saveSettings();
                      },
                      activeColor: AppColors.primary,
                    )
                  : Chip(
                      label: Text(AppLocalizations.of(context)!.pro),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              onTap: !isPro ? () => _showProFeatureDialog(context) : null,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notification Types (only if push is enabled)
            if (_pushNotificationsEnabled) ...[
              _buildSectionTitle('Notification Types'),
              const SizedBox(height: AppSpacing.md),
              _buildSettingCard(
                title: 'Request Updates',
                subtitle: 'New requests, approvals, and rejections',
                icon: Icons.description,
                trailing: Switch(
                  value: _requestUpdatesEnabled,
                  onChanged: (value) {
                    setState(() => _requestUpdatesEnabled = value);
                    _saveSettings();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSettingCard(
                title: 'Workspace Invitations',
                subtitle: 'When you are invited to a workspace',
                icon: Icons.group_add,
                trailing: Switch(
                  value: _invitationUpdatesEnabled,
                  onChanged: (value) {
                    setState(() => _invitationUpdatesEnabled = value);
                    _saveSettings();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSettingCard(
                title: 'Mentions',
                subtitle: 'When someone mentions you in comments',
                icon: Icons.alternate_email,
                trailing: Switch(
                  value: _mentionUpdatesEnabled,
                  onChanged: (value) {
                    setState(() => _mentionUpdatesEnabled = value);
                    _saveSettings();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),

            // Info Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'You can view all your notifications in the Notifications tab.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4,
    );
  }

  void _showProFeatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.proFeature),
        content: const Text(
          'Email notifications are available for Pro users only. Upgrade to Pro to enable this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to upgrade page
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(AppLocalizations.of(context)!.upgradeToPro),
          ),
        ],
      ),
    );
  }
}
