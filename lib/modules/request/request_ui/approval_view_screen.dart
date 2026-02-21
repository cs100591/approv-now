import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../template/template_provider.dart';
import '../../workspace/workspace_provider.dart';
import '../request_provider.dart';
import '../request_models.dart';

class ApprovalViewScreen extends StatefulWidget {
  const ApprovalViewScreen({super.key});

  @override
  State<ApprovalViewScreen> createState() => _ApprovalViewScreenState();
}

class _ApprovalViewScreenState extends State<ApprovalViewScreen> {
  int _selectedTab = 0;

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

    if (workspaceProvider.currentWorkspace != null) {
      // Set current workspace which automatically subscribes to requests
      requestProvider.setCurrentWorkspace(
        workspaceProvider.currentWorkspace!.id,
        approverId: authProvider.user?.id,
      );

      // Manually refresh requests
      await requestProvider.loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Requests'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestList(RequestStatus.values),
            _buildRequestList([RequestStatus.pending]),
            _buildRequestList([RequestStatus.approved]),
            _buildRequestList([RequestStatus.rejected]),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(List<RequestStatus> statuses) {
    return Consumer<RequestProvider>(
      builder: (context, requestProvider, child) {
        if (requestProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (requestProvider.error != null) {
          return ErrorState(
            message: requestProvider.error!,
            onRetry: _loadRequests,
          );
        }

        List<ApprovalRequest> requests = requestProvider.requests;

        if (statuses.length < RequestStatus.values.length) {
          requests =
              requests.where((r) => statuses.contains(r.status)).toList();
        }

        if (requests.isEmpty) {
          return _buildEmptyState(statuses);
        }

        return RefreshIndicator(
          onRefresh: _loadRequests,
          child: ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(request);
            },
          ),
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

  Widget _buildRequestCard(ApprovalRequest request) {
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
                    Text(
                      'Level ${request.currentLevel + 1} of ${request.currentLevel + 1}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (request.canShowActions) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Reject',
                        onPressed: () => _rejectRequest(request),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Approve',
                        onPressed: () => _approveRequest(request),
                      ),
                    ),
                  ],
                ),
              ],
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
        label = 'Draft';
        break;
      case RequestStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        break;
      case RequestStatus.approved:
        color = AppColors.success;
        label = 'Approved';
        break;
      case RequestStatus.rejected:
        color = AppColors.error;
        label = 'Rejected';
        break;
      case RequestStatus.revised:
        color = AppColors.info;
        label = 'Revised';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return _RequestDetailsSheet(
            request: request,
            scrollController: scrollController,
            onApprove: _approveRequest,
            onReject: _rejectRequest,
          );
        },
      ),
    );
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
    final comment = await _showCommentDialog('Approve Request');
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
          const SnackBar(content: Text('Request approved')),
        );
        Navigator.pop(context);
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
    final comment =
        await _showCommentDialog('Reject Request', requireComment: true);
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
        Navigator.pop(context);
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (requireComment && controller.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(context, controller.text.trim());
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _RequestDetailsSheet extends StatelessWidget {
  final ApprovalRequest request;
  final ScrollController scrollController;
  final Function(ApprovalRequest) onApprove;
  final Function(ApprovalRequest) onReject;

  const _RequestDetailsSheet({
    required this.request,
    required this.scrollController,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: AppSpacing.screenPadding,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.templateName,
                        style: AppTextStyles.h3,
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
                Text(
                  'Submitted on ${_formatFullDate(request.submittedAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Field Values
                Text(
                  'Request Details',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: AppSpacing.md),
                ...request.fieldValues
                    .map((fieldValue) => _buildFieldValue(fieldValue)),
                const SizedBox(height: AppSpacing.lg),

                // Approval Actions
                if (request.currentApprovalActions.isNotEmpty) ...[
                  Text(
                    'Approval History',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...request.currentApprovalActions
                      .map((action) => _buildActionItem(action)),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ),
          ),

          // Action Buttons
          if (request.canShowActions) ...[
            Container(
              padding: AppSpacing.screenPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Reject',
                      onPressed: () => onReject(request),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Approve',
                      onPressed: () => onApprove(request),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color color;
    String label;

    switch (status) {
      case RequestStatus.draft:
        color = AppColors.textHint;
        label = 'Draft';
        break;
      case RequestStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        break;
      case RequestStatus.approved:
        color = AppColors.success;
        label = 'Approved';
        break;
      case RequestStatus.rejected:
        color = AppColors.error;
        label = 'Rejected';
        break;
      case RequestStatus.revised:
        color = AppColors.info;
        label = 'Revised';
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

  Widget _buildFieldValue(FieldValue fieldValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldValue.fieldName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            fieldValue.value?.toString() ?? '-',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(ApprovalAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: action.approved
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              action.approved ? Icons.check : Icons.close,
              color: action.approved ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.approverName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (action.comment != null) ...[
                  Text(
                    action.comment!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                Text(
                  _formatFullDate(action.timestamp),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

extension on ApprovalRequest {
  bool get canShowActions => status == RequestStatus.pending;
}
