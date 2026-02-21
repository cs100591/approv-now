import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/app_logger.dart';
import '../../auth/auth_provider.dart';
import '../../request/request_provider.dart';
import '../../subscription/subscription_provider.dart';
import '../../subscription/plan_upgrade_dialog.dart';
import '../../plan_enforcement/plan_guard_service.dart';
import '../../template/template_provider.dart';
import '../../notification/notification_ui/notification_badge.dart';
import '../workspace_provider.dart';
import 'widgets/workspace_header.dart';
import 'widgets/pending_approval_banner.dart';
import 'widgets/stats_grid.dart';
import 'widgets/activity_list.dart';
import 'widgets/quick_actions_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isCreatingDefaultWorkspace = false;
  String? _loadingError;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final authProvider = context.read<AuthProvider>();

    final user = authProvider.user;
    if (user == null) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (workspaceProvider.isLoading) {
      await Future.delayed(const Duration(seconds: 3));
    }

    if (!mounted) return;

    if (workspaceProvider.error != null) {
      setState(() {
        _loadingError = workspaceProvider.error;
      });
      return;
    }

    _checkAndCreateDefaultWorkspace();
  }

  Future<void> _checkAndCreateDefaultWorkspace() async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final authProvider = context.read<AuthProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final requestProvider = context.read<RequestProvider>();
    final templateProvider = context.read<TemplateProvider>();

    final user = authProvider.user;
    if (user == null) return;

    try {
      final hasWorkspace = await workspaceProvider
          .hasAnyWorkspace()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        AppLogger.warning('Timeout checking workspace existence');
        return false;
      });

      if (!mounted) return;

      if (!hasWorkspace) {
        final currentPlan = subscriptionProvider.currentPlan;
        final canCreate = PlanGuardService.canCreateWorkspace(
          currentPlan: currentPlan,
          currentWorkspaceCount: 0,
        );

        if (!canCreate) {
          if (mounted) {
            await PlanUpgradeDialog.show(
              context: context,
              title: 'Workspace Limit Reached',
              message: 'You need to upgrade your plan to create a workspace.',
              currentPlan: currentPlan,
            );
          }
          return;
        }

        setState(() => _isCreatingDefaultWorkspace = true);

        try {
          final userName = user.displayName ?? user.email ?? 'User';

          final workspace = await workspaceProvider.createWorkspace(
            name: "$userName's Workspace",
            description: 'Default workspace created automatically',
            createdBy: user.id,
            creatorEmail: user.email,
          );

          if (workspace != null && mounted) {
            await workspaceProvider.switchWorkspace(workspace.id);

            templateProvider.setCurrentWorkspace(workspace.id);
            requestProvider.setCurrentWorkspace(workspace.id,
                approverId: user.id);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Welcome! Default workspace created successfully.'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } else if (mounted) {
            setState(() {
              _loadingError =
                  'Failed to create workspace. Please check your internet connection and try again.';
            });
          }
        } catch (e) {
          AppLogger.error('Error creating workspace', e);
          if (mounted) {
            setState(() {
              _loadingError = 'Failed to create workspace: ${e.toString()}';
            });
          }
        } finally {
          if (mounted) {
            setState(() => _isCreatingDefaultWorkspace = false);
          }
        }
      } else {
        if (workspaceProvider.currentWorkspace != null) {
          templateProvider
              .setCurrentWorkspace(workspaceProvider.currentWorkspace!.id);
          requestProvider.setCurrentWorkspace(
            workspaceProvider.currentWorkspace!.id,
            approverId: user.id,
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error in _checkAndCreateDefaultWorkspace', e);
      if (mounted) {
        setState(() {
          _loadingError = 'Failed to load workspace: $e';
        });
      }
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _loadingError = null;
      _retryCount++;
    });
    await _initializeDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = context.watch<WorkspaceProvider>();
    final isLoading =
        workspaceProvider.isLoading || _isCreatingDefaultWorkspace;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          const NotificationBadge(),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.profile);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'workspace',
                child: Row(
                  children: [
                    Icon(Icons.business),
                    SizedBox(width: 8),
                    Text('Switch Workspace'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Analytics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'join',
                child: Row(
                  children: [
                    Icon(Icons.group_add),
                    SizedBox(width: 8),
                    Text('Join Workspace'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isCreatingDefaultWorkspace
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Setting up your workspace...'),
                ],
              ),
            )
          : isLoading && workspaceProvider.workspaces.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading your workspace...'),
                    ],
                  ),
                )
              : _loadingError != null
                  ? _buildErrorState()
                  : workspaceProvider.workspaces.isEmpty
                      ? _buildEmptyState()
                      : _buildDashboardContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _loadingError!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryInitialization,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            if (_retryCount > 0) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.login,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Logout and try again',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business_center,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No Workspace Found',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to create a workspace. Please check your connection.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _loadingError = null);
                _checkAndCreateDefaultWorkspace();
              },
              icon: const Icon(Icons.add_business),
              label: const Text('Create Workspace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: () async {
        final workspaceProvider = context.read<WorkspaceProvider>();
        await workspaceProvider.loadWorkspaces();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Workspace Header
            const WorkspaceHeader(),
            const SizedBox(height: 16),
            // Pending Approvals Banner
            const PendingApprovalBanner(),
            const SizedBox(height: 16),
            // Stats Grid
            const StatsGrid(),
            const SizedBox(height: 24),
            // Activity List
            const ActivityList(),
            const SizedBox(height: 24),
            // Quick Actions
            const QuickActionsBar(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'workspace':
        Navigator.pushNamed(context, RouteNames.workspaceSwitch);
        break;
      case 'analytics':
        Navigator.pushNamed(context, RouteNames.analytics);
        break;
      case 'join':
        Navigator.pushNamed(context, RouteNames.joinWorkspace);
        break;
      case 'logout':
        _showLogoutConfirm(context);
        break;
    }
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
            child:
                const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
