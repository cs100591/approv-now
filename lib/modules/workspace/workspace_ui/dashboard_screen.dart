import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/app_logger.dart';
import '../../auth/auth_provider.dart';
import '../../request/request_provider.dart';
import '../../request/request_models.dart';
import '../../subscription/subscription_provider.dart';
import '../../subscription/plan_upgrade_dialog.dart';
import '../../plan_enforcement/plan_guard_service.dart';
import '../../template/template_provider.dart';
import '../../notification/notification_ui/notification_badge.dart';
import '../../notification/notification_provider.dart';
import '../workspace_provider.dart';

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
    final notificationProvider = context.read<NotificationProvider>();

    final user = authProvider.user;
    if (user == null) return;

    workspaceProvider.setCurrentUser(user.id);
    notificationProvider.initialize(user.id);

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
                  ? Center(
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
                                  style:
                                      TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : workspaceProvider.workspaces.isEmpty
                      ? Center(
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
                        )
                      : const _DashboardContent(),
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

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final requestProvider = context.watch<RequestProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.user;

    final userRequests = currentUser != null
        ? requestProvider.requests
            .where((r) => r.submittedBy == currentUser.id)
            .toList()
        : <ApprovalRequest>[];

    final pendingCount =
        userRequests.where((r) => r.status == RequestStatus.pending).length;
    final approvedCount =
        userRequests.where((r) => r.status == RequestStatus.approved).length;
    final rejectedCount =
        userRequests.where((r) => r.status == RequestStatus.rejected).length;
    final totalCount = userRequests.length;

    final recentRequests = userRequests.toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    final displayRequests = recentRequests.take(5).toList();

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NotificationBanner(),
          Text(
            'Welcome back!',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Here's what's happening today",
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stats Grid
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        pendingCount.toString(),
                        Icons.hourglass_empty,
                        AppColors.warning,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 80,
                      color: AppColors.divider.withOpacity(0.5),
                    ),
                    Expanded(
                      child: _buildStatCard(
                        'Approved',
                        approvedCount.toString(),
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  color: AppColors.divider.withOpacity(0.5),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Rejected',
                        rejectedCount.toString(),
                        Icons.cancel,
                        AppColors.error,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 80,
                      color: AppColors.divider.withOpacity(0.5),
                    ),
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        totalCount.toString(),
                        Icons.folder,
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quick Actions
          Text(
            'Quick Actions',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'New Request',
                  Icons.add_circle,
                  AppColors.primary,
                  () => Navigator.pushNamed(context, RouteNames.createRequest),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildActionButton(
                  'Templates',
                  Icons.description,
                  AppColors.info,
                  () => Navigator.pushNamed(context, RouteNames.templates),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'My Approvals',
                  Icons.check_circle,
                  AppColors.success,
                  () {},
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildActionButton(
                  'Analytics',
                  Icons.analytics,
                  AppColors.accent,
                  () => Navigator.pushNamed(context, RouteNames.analytics),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (displayRequests.isEmpty)
            _buildEmptyState(
              'No recent activity',
              'Your recent requests and approvals will appear here',
            )
          else
            Column(
              children: displayRequests
                  .map((request) => _buildRequestCard(request))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ApprovalRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(request.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(request.status),
              color: _getStatusColor(request.status),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.templateName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${_getStatusText(request.status)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${request.submittedAt.day}/${request.submittedAt.month}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppColors.warning;
      case RequestStatus.approved:
        return AppColors.success;
      case RequestStatus.rejected:
        return AppColors.error;
      case RequestStatus.draft:
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.hourglass_empty;
      case RequestStatus.approved:
        return Icons.check_circle;
      case RequestStatus.rejected:
        return Icons.cancel;
      case RequestStatus.draft:
        return Icons.edit;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.draft:
        return 'Draft';
      default:
        return 'Unknown';
    }
  }
}
