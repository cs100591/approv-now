import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/app_logger.dart';
import '../../auth/auth_provider.dart';
import '../workspace_provider.dart';

class JoinWorkspaceScreen extends StatefulWidget {
  const JoinWorkspaceScreen({super.key});

  @override
  State<JoinWorkspaceScreen> createState() => _JoinWorkspaceScreenState();
}

class _JoinWorkspaceScreenState extends State<JoinWorkspaceScreen> {
  final _codeController = TextEditingController();
  bool _isValidating = false;
  bool _isJoining = false;
  Map<String, dynamic>? _validatedWorkspace;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.length != 6) {
      setState(() {
        _error = 'Please enter a 6-character code';
        _validatedWorkspace = null;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _error = null;
      _validatedWorkspace = null;
    });

    try {
      final workspaceProvider = context.read<WorkspaceProvider>();
      final result = await workspaceProvider.validateInviteCode(code);

      if (mounted) {
        setState(() {
          _isValidating = false;
          if (result != null) {
            _validatedWorkspace = result;
            _error = null;
          } else {
            _error = 'Invalid or expired invite code';
          }
        });
      }
    } catch (e) {
      AppLogger.error('Error validating invite code', e);
      if (mounted) {
        setState(() {
          _isValidating = false;
          _error = 'Failed to validate code. Please try again.';
        });
      }
    }
  }

  Future<void> _joinWorkspace() async {
    if (_validatedWorkspace == null) return;

    final code = _codeController.text.trim().toUpperCase();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      setState(() {
        _error = 'You must be logged in to join a workspace';
      });
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final workspaceProvider = context.read<WorkspaceProvider>();
      final success = await workspaceProvider.joinWorkspaceWithCode(
        code: code,
        userId: user.id,
        displayName: user.displayName,
      );

      if (mounted) {
        if (success) {
          final workspaceName =
              (_validatedWorkspace?['workspace'] as Map<String, dynamic>?)
                      ?.cast<String, dynamic>()['name'] as String? ??
                  'Workspace';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined $workspaceName successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushReplacementNamed(context, RouteNames.dashboard);
        } else {
          setState(() {
            _isJoining = false;
            _error = workspaceProvider.error ?? 'Failed to join workspace';
          });
        }
      }
    } catch (e) {
      AppLogger.error('Error joining workspace', e);
      if (mounted) {
        setState(() {
          _isJoining = false;
          _error = 'Failed to join workspace. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Join Workspace'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.group_add,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join a Workspace',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Enter the 6-character invite code provided by your workspace owner',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Code Input
            Text(
              'Invite Code',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                hintText: 'A3B7K9',
                hintStyle: TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: AppColors.textHint,
                ),
                counterText: '',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorText: _error,
                suffixIcon: _codeController.text.length == 6
                    ? IconButton(
                        icon: _isValidating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle,
                                color: AppColors.success),
                        onPressed: _isValidating ? null : _validateCode,
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _error = null;
                  if (value.length == 6) {
                    _validateCode();
                  } else {
                    _validatedWorkspace = null;
                  }
                });
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Workspace Preview
            if (_validatedWorkspace != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Workspace Found!',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                (_validatedWorkspace?['workspace']
                                                as Map<String, dynamic>?)
                                            ?.cast<String, dynamic>()['name']
                                        as String? ??
                                    'Unknown Workspace',
                                style: AppTextStyles.h4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isJoining ? null : _joinWorkspace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isJoining
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Join Workspace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Instructions
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildInstructionItem(
                    '1',
                    'Ask your workspace owner for an invite code',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildInstructionItem(
                    '2',
                    'Enter the 6-character code above',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildInstructionItem(
                    '3',
                    'Click "Join Workspace" to become a member',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
