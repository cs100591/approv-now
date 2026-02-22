import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/app_logger.dart';
import '../auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<AuthProvider>();

      try {
        final success = await provider
            .registerWithCredentials(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        )
            .timeout(const Duration(seconds: 30), onTimeout: () {
          // Handle timeout
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Registration timed out. Please check your connection and try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        });

        if (success && mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to login page after successful registration
          Navigator.pushReplacementNamed(context, RouteNames.login);
        }
      } catch (e) {
        // Error is already handled by AuthProvider, but ensure UI updates
        AppLogger.error('Registration error in UI', e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.createAccount,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign up to get started with Approv Now',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Register Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: AppLocalizations.of(context)!.fullName,
                      hint: 'Enter your full name',
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AppLocalizations.of(context)!.email,
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPasswordField(
                      label: AppLocalizations.of(context)!.password,
                      hint: 'Create a password',
                      controller: _passwordController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Password is required';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPasswordField(
                      label: AppLocalizations.of(context)!.confirmPassword,
                      hint: 'Confirm your password',
                      controller: _confirmPasswordController,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Error Message
                    Consumer<AuthProvider>(
                      builder: (context, provider, child) {
                        if (provider.error != null) {
                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    provider.error!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // Register Button
                    Consumer<AuthProvider>(
                      builder: (context, provider, child) {
                        return PrimaryButton(
                          text: AppLocalizations.of(context)!.createAccount,
                          isLoading: provider.isLoading,
                          onPressed: _register,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Login Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppTextButton(
                      text: AppLocalizations.of(context)!.signIn,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
