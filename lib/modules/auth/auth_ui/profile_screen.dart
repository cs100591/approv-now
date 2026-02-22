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
              const SnackBar(
                content: Text('Biometric login enabled'),
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
          const SnackBar(
            content: Text('Biometric login disabled'),
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
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
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
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                    title: 'Edit Profile',
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
                      Navigator.pushNamed(context, RouteNames.notifications);
                    },
                  ),
                  if (_biometricAvailable) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(_biometricIcon, color: AppColors.primary),
                      title: const Text('Biometric Login'),
                      subtitle: Text(
                        _biometricIcon == Icons.face
                            ? 'Face ID'
                            : 'Fingerprint',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Switch(
                        value: _biometricEnabled,
                        onChanged: _toggleBiometric,
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                  ],
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
            SecondaryButton(
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
        title: const Text('Edit Profile'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile updated successfully')),
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
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.logout,
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
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: L10n.all.length,
                  itemBuilder: (context, index) {
                    final locale = L10n.all[index];
                    final isSelected = localeProvider.locale?.languageCode ==
                            locale.languageCode &&
                        localeProvider.locale?.scriptCode == locale.scriptCode;

                    return ListTile(
                      title: Text(L10n.getLanguageName(locale)),
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
