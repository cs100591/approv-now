import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/routing/route_names.dart';
import '../auth_provider.dart';
import '../biometric_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _biometricService = BiometricService();

  bool _biometricAvailable = false;
  bool _hasStoredCredentials = false;
  IconData _biometricIcon = Icons.fingerprint;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _biometricService.canCheckBiometrics;
      final hasCredentials = await _biometricService.hasStoredCredentials;
      final primaryType = await _biometricService.primaryBiometricType;

      if (mounted) {
        setState(() {
          _biometricAvailable = canCheck && hasCredentials;
          _hasStoredCredentials = hasCredentials;
          _biometricIcon =
              primaryType.name == 'face' ? Icons.face : Icons.fingerprint;
        });
      }
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<AuthProvider>();
      final success = await provider.loginWithCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        final shouldEnable = await _showBiometricPrompt();
        if (shouldEnable == true) {
          await _biometricService.enableBiometric(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
        }
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
        }
      }
    }
  }

  Future<void> _loginWithBiometric() async {
    final result = await _biometricService.authenticate();

    if (!mounted) return;

    if (result.success && result.email != null && result.password != null) {
      final provider = context.read<AuthProvider>();
      final success = await provider.loginWithCredentials(
        email: result.email!,
        password: result.password!,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
      }
    } else if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool?> _showBiometricPrompt() async {
    if (_hasStoredCredentials) return false;

    final canCheck = await _biometricService.canCheckBiometrics;
    if (!canCheck) return false;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Login?'),
        content: const Text(
          'Would you like to enable fingerprint or face ID for quick login?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.approval,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  'Approv Now',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  'Sign in to your account',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Email',
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
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
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
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppTextButton(
                        text: 'Forgot Password?',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Consumer<AuthProvider>(
                      builder: (context, provider, child) {
                        if (provider.error != null) {
                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
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
                    Consumer<AuthProvider>(
                      builder: (context, provider, child) {
                        return PrimaryButton(
                          text: 'Sign In',
                          isLoading: provider.isLoading,
                          onPressed: _login,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_biometricAvailable) ...[
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: _BiometricLoginButton(
                    icon: _biometricIcon,
                    onPressed: _loginWithBiometric,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.border,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      _biometricAvailable ? '' : 'OR',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.border,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppTextButton(
                      text: 'Create Account',
                      onPressed: () {
                        Navigator.of(context).pushNamed(RouteNames.register);
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

class _BiometricLoginButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _BiometricLoginButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Use Biometric',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
