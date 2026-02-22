import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/app_logger.dart';
import '../../auth/auth_provider.dart';
import '../request_provider.dart';
import '../request_models.dart';
import '../../../core/widgets/shimmer_loading.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Requests'),
        elevation: 0,
      ),
      body: Consumer2<RequestProvider, AuthProvider>(
        builder: (context, requestProvider, authProvider, child) {
          final currentUser = authProvider.user;

          Widget content;
          if (currentUser == null) {
            content = Center(
                key: ValueKey('login'), child: Text('Please login'));
          } else if (requestProvider.isLoading &&
              requestProvider.requests.isEmpty) {
            content = const ShimmerCardList(
                key: ValueKey('shimmer'), itemCount: 5, cardHeight: 120);
          } else {
            final myRequests = requestProvider.requests
                .where((r) => r.submittedBy == currentUser.id)
                .toList();

            if (myRequests.isEmpty && !requestProvider.isLoading) {
              content = _buildEmptyState(context);
            } else if (myRequests.isEmpty && requestProvider.isLoading) {
              content = const ShimmerCardList(
                  key: ValueKey('shimmer'), itemCount: 5, cardHeight: 120);
            } else {
              content = RefreshIndicator(
                key: const ValueKey('list'),
                onRefresh: () => requestProvider.loadRequests(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myRequests.length,
                  itemBuilder: (context, index) {
                    final request = myRequests[index];
                    return _buildRequestCard(context, request, currentUser.id);
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteNames.createRequest),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newRequest),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No requests yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.createRequest),
            icon: const Icon(Icons.add),
            label: const Text('Create Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    ApprovalRequest request,
    String currentUserId,
  ) {
    // Check if user can edit/delete this request
    final canEdit = request.canEdit && request.submittedBy == currentUserId;
    final canDelete = request.submittedBy == currentUserId;

    return Dismissible(
      key: Key(request.id),
      direction:
          canDelete ? DismissDirection.horizontal : DismissDirection.none,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left to delete
          return await _showDeleteConfirmation(context, request);
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right to edit
          if (canEdit) {
            _navigateToEdit(context, request);
          }
          return false; // Don't dismiss
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteRequest(context, request);
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: canEdit ? AppColors.primary : Colors.transparent,
        child: canEdit
            ? Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.edit,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : null,
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            request.templateName,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Status: ${request.status.name.toUpperCase()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getStatusColor(request.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${_formatDate(request.submittedAt)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor:
                _getStatusColor(request.status).withValues(alpha: 0.1),
            child: Icon(
              _getStatusIcon(request.status),
              color: _getStatusColor(request.status),
              size: 20,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(
            context,
            RouteNames.requestDetails,
            arguments: {'requestId': request.id},
          ),
        ),
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
        return AppColors.textSecondary;
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
        return Icons.circle_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    ApprovalRequest request,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Request'),
            content: Text(
              'Are you sure you want to delete "${request.templateName}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteRequest(BuildContext context, ApprovalRequest request) {
    final requestProvider = context.read<RequestProvider>();

    try {
      requestProvider.deleteRequest(request.id);
      AppLogger.info('Request deleted: ${request.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to delete request', e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToEdit(BuildContext context, ApprovalRequest request) {
    // Navigate to edit screen with request data
    Navigator.pushNamed(
      context,
      RouteNames.createRequest,
      arguments: {
        'editMode': true,
        'request': request,
      },
    );
  }
}
