import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../auth/auth_provider.dart';
import '../../workspace/workspace_provider.dart';
import '../../subscription/subscription_provider.dart';
import '../../subscription/subscription_models.dart';
import '../biometric_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _biometricService = BiometricService();
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  IconData _biometricIcon = Icons.fingerprint;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final canCheck = await _biometricService.canCheckBiometrics;
    final enabled = await _biometricService.isBiometricEnabled;
    final primaryType = await _biometricService.primaryBiometricType;

    if (mounted) {
      setState(() {
        _biometricAvailable = canCheck;
        _biometricEnabled = enabled;
        _biometricIcon = primaryType == 'face' ? Icons.face : Icons.fingerprint;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final result = await _biometricService.authenticate();
      if (result.success) {
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.user;
        if (user != null) {
          // In a real app, you'd get the stored password or ask user to re-enter
          // For now, just show success
          await _biometricService.enableBiometric(
            email: user.email,
            password: 'stored_password', // In production, use secure storage
          );
          setState(() => _biometricEnabled = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.biometricLoginEnabled),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      } else if (result.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      await _biometricService.disableBiometric();
      setState(() => _biometricEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.biometricLoginDisabled),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.notLoggedIn)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
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
            _buildSectionTitle(AppLocalizations.of(context)!.account),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  Builder(builder: (context) {
                    final currentLocale =
                        context.watch<LocaleProvider>().locale;
                    return _buildListTile(
                      icon: Icons.language,
                      title: AppLocalizations.of(context)!.language,
                      trailing: Text(
                          currentLocale != null
                              ? L10n.getLanguageName(currentLocale)
                              : 'English',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      onTap: () => _showLanguagePickerSheet(context),
                    );
                  }),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: AppLocalizations.of(context)!.editProfile,
                    onTap: () => _showEditProfileDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: AppLocalizations.of(context)!.changePassword,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.notifications_outlined,
                    title: AppLocalizations.of(context)!.notifications,
                    onTap: () {
                      Navigator.pushNamed(
                          context, RouteNames.notificationSettings);
                    },
                  ),
                  if (_biometricAvailable) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(_biometricIcon, color: AppColors.primary),
                      title: Text(AppLocalizations.of(context)!.biometricLogin),
                      subtitle: Text(
                        _biometricIcon == Icons.face
                            ? AppLocalizations.of(context)!.faceId
                            : AppLocalizations.of(context)!.fingerprint,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Switch(
                        value: _biometricEnabled,
                        onChanged: _toggleBiometric,
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primary;
                          }
                          return null;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Subscription'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  Consumer<SubscriptionProvider>(
                    builder: (context, subscriptionProvider, child) {
                      final currentPlan = subscriptionProvider.currentPlan;
                      final isFree = currentPlan == PlanType.free;

                      return _buildListTile(
                        icon: Icons.workspace_premium,
                        title: 'Current Plan',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isFree
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            currentPlan.displayName,
                            style: TextStyle(
                              color: isFree
                                  ? AppColors.primary
                                  : AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, RouteNames.subscription);
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.upgrade,
                    title: 'Upgrade Plan',
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.subscription);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle(AppLocalizations.of(context)!.workspaces),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.business,
                    title: AppLocalizations.of(context)!.switchWorkspace,
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.workspaceSwitch);
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.people_outline,
                    title: AppLocalizations.of(context)!.teamMembers,
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.teamMembers);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
            SecondaryButtonFullWidth(
              text: AppLocalizations.of(context)!.logout,
              onPressed: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: AppSpacing.lg),
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
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
        title: Text(AppLocalizations.of(context)!.editProfile),
        content: AppTextField(
          controller: nameController,
          label: AppLocalizations.of(context)!.displayName,
          hint: 'Your name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              Navigator.pop(context);
              try {
                await authProvider.updateProfile(displayName: newName);
                if (context.mounted) {
                  await context.read<WorkspaceProvider>().loadWorkspaces();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.profileUpdated)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $e')),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // AuthWrapper will automatically show LoginScreen when auth state changes
              await context.read<AuthProvider>().logout();
            },
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxHeight: 400),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final localeProvider = context.watch<LocaleProvider>();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: AppTextStyles.h3,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: L10n.options.length,
                  itemBuilder: (context, index) {
                    final option = L10n.options[index];
                    final locale = option.locale;
                    final isSelected = localeProvider.locale?.languageCode ==
                            locale.languageCode &&
                        localeProvider.locale?.scriptCode == locale.scriptCode;

                    return ListTile(
                      title: Text(option.displayName),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        context.read<LocaleProvider>().setLocale(locale);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
