import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../auth_models.dart';
import '../../workspace/workspace_provider.dart';
import '../../template/template_provider.dart';
import '../../request/request_provider.dart';
import '../../subscription/subscription_provider.dart';
import '../../notification/notification_provider.dart';
import '../../approval_engine/approval_engine_provider.dart';
import 'login_screen.dart';
import '../../../core/theme/app_colors.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Track the last *processed* state so we can detect transitions.
  AuthStatus? _lastStatus;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  void _initializeAuth() {
    final authProvider = context.read<AuthProvider>();
    authProvider.initialize();
  }

  /// Called whenever we transition INTO authenticated.
  void _onAuthenticated(String userId) {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    workspaceProvider.setCurrentUser(userId);
    notificationProvider.initialize(userId);
  }

  /// Called whenever we transition OUT OF authenticated (logout / account switch).
  void _onLogout() {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final templateProvider = context.read<TemplateProvider>();
    final requestProvider = context.read<RequestProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final approvalEngineProvider = context.read<ApprovalEngineProvider>();

    workspaceProvider.clearCurrentUser();
    templateProvider.setCurrentWorkspace(null);
    requestProvider.setCurrentWorkspace(null);
    notificationProvider.clear();
    subscriptionProvider.reset();
    approvalEngineProvider.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final status = authProvider.state.status;
        final userId = authProvider.user?.id;

        // ── Transition detection ───────────────────────────────────────────
        //
        // We detect transitions by comparing (status, userId) with the
        // previous build's values. All side-effects run in a post-frame
        // callback so they don't trigger setState during build.
        //
        // Cases:
        //  A. unauthenticated/error → authenticated  : fresh login
        //  B. authenticated (userA) → authenticated (userB) : account switch
        //  C. authenticated → unauthenticated/error  : logout
        //
        if (status == AuthStatus.authenticated && userId != null) {
          // Case A: transitioned INTO authenticated
          if (_lastStatus != AuthStatus.authenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _onAuthenticated(userId);
            });
          }
          // Case B: same authenticated session but different user
          else if (_lastUserId != null && _lastUserId != userId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _onLogout();
                _onAuthenticated(userId);
              }
            });
          }
        } else if ((status == AuthStatus.unauthenticated ||
                status == AuthStatus.error) &&
            _lastStatus == AuthStatus.authenticated) {
          // Case C: transitioned OUT of authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onLogout();
          });
        }

        _lastStatus = status;
        _lastUserId = userId;
        // ──────────────────────────────────────────────────────────────────

        switch (status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const _LoadingScreen();

          case AuthStatus.authenticated:
            return widget.child;

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.loading ?? 'Loading...',
              style:
                  const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        return child;
      },
    );
  }
}
