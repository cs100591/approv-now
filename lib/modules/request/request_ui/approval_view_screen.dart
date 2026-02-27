import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../template/template_provider.dart';
import '../../workspace/workspace_member.dart';
import '../../workspace/workspace_provider.dart';
import '../request_provider.dart';
import '../request_models.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'request_detail_screen.dart';

class ApprovalViewScreen extends StatefulWidget {
  const ApprovalViewScreen({super.key});

  @override
  State<ApprovalViewScreen> createState() => _ApprovalViewScreenState();
}

class _ApprovalViewScreenState extends State<ApprovalViewScreen> {
  String? _selectedRequestId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final requestProvider = context.read<RequestProvider>();
    final authProvider = context.read<AuthProvider>();

    if (workspaceProvider.currentWorkspace != null &&
        authProvider.user != null) {
      // Determine if current user is admin/owner
      final workspace = workspaceProvider.currentWorkspace!;
      final userId = authProvider.user!.id;
      final role = workspace.getUserRole(userId);
      final isAdminOrOwner =
          role == WorkspaceRole.admin || role == WorkspaceRole.owner;

      requestProvider.setCurrentWorkspace(
        workspace.id,
        approverId: userId,
        isAdminOrOwner: isAdminOrOwner,
      );

      await requestProvider.loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = TabBarView(
      children: [
        // "All" tab: my own requests + pending approvals for me
        _buildMyRequestsList(),
        // "Pending" tab: only approval requests directed at ME
        _buildPendingApprovalsList(),
        // Completed tabs filtered from my own requests
        _buildRequestList([RequestStatus.approved]),
        _buildRequestList([RequestStatus.rejected]),
      ],
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.requests),
          bottom: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.all),
              Tab(text: AppLocalizations.of(context)!.pending),
              Tab(text: AppLocalizations.of(context)!.approved),
              Tab(text: AppLocalizations.of(context)!.rejected),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: ResponsiveLayout(
          mobile: bodyContent,
          desktop: Row(
            children: [
              SizedBox(
                width: 400,
                child: bodyContent,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _selectedRequestId == null
                    ? Center(
                        child: Text(
                          'Select a request to view details',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    : RequestDetailScreen(
                        key: ValueKey(_selectedRequestId),
                        requestId: _selectedRequestId!,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "All" tab: shows current user's own requests
  /// (admin/owner also sees all workspace requests)
  Widget _buildMyRequestsList() {
    return Consumer2<RequestProvider, AuthProvider>(
      builder: (context, requestProvider, authProvider, child) {
        Widget content;

        if (requestProvider.isLoading && requestProvider.requests.isEmpty) {
          content = const ShimmerCardList(
              key: ValueKey('shimmer'), itemCount: 5, cardHeight: 180);
        } else if (requestProvider.error != null) {
          content = ErrorState(
            key: const ValueKey('error'),
            message: requestProvider.error!,
            onRetry: _loadRequests,
          );
        } else {
          // Admin/owner sees all workspace requests; others see only their own
          final List<ApprovalRequest> requests = requestProvider.isAdminOrOwner
              ? requestProvider.allRequests
              : requestProvider.requests;

          if (requests.isEmpty && !requestProvider.isLoading) {
            content = _buildEmptyState([]);
          } else if (requests.isEmpty && requestProvider.isLoading) {
            content = const ShimmerCardList(
                key: ValueKey('shimmer'), itemCount: 5, cardHeight: 180);
          } else {
            content = RefreshIndicator(
              key: const ValueKey('list'),
              onRefresh: _loadRequests,
              child: ListView.builder(
                padding: AppSpacing.screenPadding,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  // No approve/reject actions in log view
                  return _buildRequestCard(request, showActions: false);
                },
              ),
            );
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: content,
        );
      },
    );
  }

  /// "Pending" tab: only requests where the current user is a designated approver
  Widget _buildPendingApprovalsList() {
    return Consumer<RequestProvider>(
      builder: (context, requestProvider, child) {
        Widget content;

        if (requestProvider.isLoading &&
            requestProvider.pendingRequests.isEmpty) {
          content = const ShimmerCardList(
              key: ValueKey('shimmer'), itemCount: 5, cardHeight: 180);
        } else if (requestProvider.error != null) {
          content = ErrorState(
            key: const ValueKey('error'),
            message: requestProvider.error!,
            onRetry: _loadRequests,
          );
        } else {
          final requests = requestProvider.pendingRequests;

          if (requests.isEmpty && !requestProvider.isLoading) {
            content = _buildEmptyState([RequestStatus.pending]);
          } else if (requests.isEmpty && requestProvider.isLoading) {
            content = const ShimmerCardList(
                key: ValueKey('shimmer'), itemCount: 5, cardHeight: 180);
          } else {
            content = RefreshIndicator(
              key: const ValueKey('list'),
              onRefresh: _loadRequests,
              child: ListView.builder(
                padding: AppSpacing.screenPadding,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  // Show approve/reject actions here — user IS an approver for these
                  return _buildRequestCard(request, showActions: true);
                },
              ),
            );
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: content,
        );
      },
    );
  }

  Widget _buildRequestList(List<RequestStatus> statuses) {
    return Consumer<RequestProvider>(
      builder: (context, requestProvider, child) {
        Widget content;

        if (requestProvider.isLoading && requestProvider.requests.isEmpty) {
          content = const ShimmerCardList(
              key: ValueKey('shimmer'), itemCount: 5, cardHeight: 180);
        } else if (requestProvider.error != null) {
          content = ErrorState(
            key: const ValueKey('error'),
            message: requestProvider.error!,
            onRetry: _loadRequests,
          );
        } else {
          // Only the current user's own requests, filtered by status
          List<ApprovalRequest> requests = requestProvider.requests
              .where((r) => statuses.contains(r.status))
              .toList();

          if (requests.isEmpty && !requestProvider.isLoading) {
            content = _buildEmptyState(statuses);
          } else if (requests.isEmpty && requestProvider.isLoading) {
            content = const ShimmerCardList(
                key: ValueKey('shimmer'), itemCount: 5, cardHeight: 180);
          } else {
            content = RefreshIndicator(
              key: const ValueKey('list'),
              onRefresh: _loadRequests,
              child: ListView.builder(
                padding: AppSpacing.screenPadding,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildRequestCard(request, showActions: false);
                },
              ),
            );
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: content,
        );
      },
    );
  }

  Widget _buildEmptyState(List<RequestStatus> statuses) {
    String message;
    IconData icon;

    if (statuses.contains(RequestStatus.pending)) {
      message = 'No pending requests';
      icon = Icons.pending_actions;
    } else if (statuses.contains(RequestStatus.approved)) {
      message = 'No approved requests';
      icon = Icons.check_circle;
    } else if (statuses.contains(RequestStatus.rejected)) {
      message = 'No rejected requests';
      icon = Icons.cancel;
    } else {
      message = 'No requests yet';
      icon = Icons.inbox;
    }

    return EmptyState(
      icon: icon,
      message: message,
      subMessage: 'Pull down to refresh',
    );
  }

  Widget _buildRequestCard(ApprovalRequest request,
      {bool showActions = false}) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _viewRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.templateName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Submitted by ${request.submittedByName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatDate(request.submittedAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              if (request.status == RequestStatus.pending) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Builder(builder: (context) {
                      final template = context
                          .read<TemplateProvider>()
                          .getTemplateById(request.templateId);
                      final workspace =
                          context.read<WorkspaceProvider>().currentWorkspace;

                      int maxLevel = 1;
                      String waitingText = 'Pending Approval';

                      if (template != null) {
                        maxLevel = template.maxApprovalLevel;
                        final currentStep = template.approvalSteps.firstWhere(
                            (s) => s.level == request.currentLevel,
                            orElse: () => template.approvalSteps.first);

                        if (workspace != null) {
                          final approverNames =
                              currentStep.approvers.map((uid) {
                            final member = workspace.getMember(uid);
                            return member?.displayName ??
                                member?.email ??
                                'Approver';
                          }).toList();

                          if (approverNames.isNotEmpty) {
                            if (approverNames.length == 1) {
                              waitingText = 'Waiting for ${approverNames[0]}';
                            } else {
                              waitingText =
                                  'Waiting for ${approverNames[0]} and ${approverNames.length - 1} others';
                            }
                          }
                        }
                      }

                      return Expanded(
                        child: Text(
                          'Level ${request.currentLevel} of $maxLevel • $waitingText',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                ),
              ],
              Builder(builder: (context) {
                final authProvider = context.read<AuthProvider>();
                final templateProvider = context.read<TemplateProvider>();

                bool isApprover = false;
                if (showActions && request.canShowActions) {
                  final template =
                      templateProvider.getTemplateById(request.templateId);
                  final userId = authProvider.user?.id;

                  if (template != null && userId != null) {
                    final currentStep = template.approvalSteps.firstWhere(
                        (s) => s.level == request.currentLevel,
                        orElse: () => template.approvalSteps.first);

                    final hasApproved = request.currentApprovalActions.any(
                        (a) =>
                            a.level == request.currentLevel &&
                            a.approverId == userId &&
                            a.approved);

                    if (currentStep.approvers.contains(userId) &&
                        !hasApproved) {
                      isApprover = true;
                    }
                  }
                }

                if (isApprover) {
                  return Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: SecondaryButton(
                              text: AppLocalizations.of(context)!.reject,
                              onPressed: () => _rejectRequest(request),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: PrimaryButton(
                              text: AppLocalizations.of(context)!.approve,
                              onPressed: () => _approveRequest(request),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color color;
    String label;

    switch (status) {
      case RequestStatus.draft:
        color = AppColors.textHint;
        label = AppLocalizations.of(context)!.draft;
        break;
      case RequestStatus.pending:
        color = AppColors.warning;
        label = AppLocalizations.of(context)!.pending;
        break;
      case RequestStatus.approved:
        color = AppColors.success;
        label = AppLocalizations.of(context)!.approved;
        break;
      case RequestStatus.rejected:
        color = AppColors.error;
        label = AppLocalizations.of(context)!.rejected;
        break;
      case RequestStatus.revised:
        color = AppColors.info;
        label = AppLocalizations.of(context)!.revised;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _viewRequestDetails(ApprovalRequest request) {
    if (ResponsiveLayout.isMobile(context)) {
      Navigator.pushNamed(
        context,
        RouteNames.requestDetails,
        arguments: {'requestId': request.id},
      );
    } else {
      setState(() {
        _selectedRequestId = request.id;
      });
    }
  }

  Future<void> _approveRequest(ApprovalRequest request) async {
    final authProvider = context.read<AuthProvider>();
    final requestProvider = context.read<RequestProvider>();
    final templateProvider = context.read<TemplateProvider>();

    if (authProvider.user == null) return;

    // Get template for this request
    final template = templateProvider.getTemplateById(request.templateId);
    if (template == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Template not found')),
        );
      }
      return;
    }

    // Show comment dialog
    final comment =
        await _showCommentDialog(AppLocalizations.of(context)!.approveRequest);
    if (comment == null) return;

    try {
      await requestProvider.approveRequest(
        requestId: request.id,
        approverId: authProvider.user!.id,
        approverName:
            authProvider.user!.displayName ?? authProvider.user!.email,
        template: template,
        comment: comment.isEmpty ? null : comment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request approved \u2713')),
        );
        // Refresh the list so the card disappears / updates
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _rejectRequest(ApprovalRequest request) async {
    final authProvider = context.read<AuthProvider>();
    final requestProvider = context.read<RequestProvider>();
    final templateProvider = context.read<TemplateProvider>();

    if (authProvider.user == null) return;

    // Get template for this request
    final template = templateProvider.getTemplateById(request.templateId);
    if (template == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Template not found')),
        );
      }
      return;
    }

    // Show comment dialog
    final comment = await _showCommentDialog(
        AppLocalizations.of(context)!.rejectRequest,
        requireComment: true);
    if (comment == null || comment.isEmpty) return;

    try {
      await requestProvider.rejectRequest(
        requestId: request.id,
        approverId: authProvider.user!.id,
        approverName:
            authProvider.user!.displayName ?? authProvider.user!.email,
        template: template,
        comment: comment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request rejected')),
        );
        // Refresh the list so the card disappears / updates
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String?> _showCommentDialog(String title,
      {bool requireComment = false}) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: requireComment
                ? 'Reason (required)'
                : 'Add a comment (optional)',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (requireComment && controller.text.trim().isEmpty) {
                // Show error feedback when rejection reason is required but empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context, controller.text.trim());
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }
}

extension on ApprovalRequest {
  /// Only true when the request is pending — actual approver check is enforced
  /// by the ApprovalEngine on the server side and by which list (pendingRequests)
  /// the card appears in. Cards in the pending-approvals list always pass showActions:true.
  bool get canShowActions => status == RequestStatus.pending;
}
