import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../export/export_provider.dart';
import '../../workspace/workspace_provider.dart';
import '../../template/template_provider.dart';
import '../../template/template_models.dart';
import '../../auth/auth_provider.dart';
import '../request_provider.dart';
import '../request_models.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  ApprovalRequest? _request;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRequest());
  }

  Future<void> _loadRequest() async {
    final requestProvider = context.read<RequestProvider>();
    try {
      // First try to find in local state
      final local =
          requestProvider.requests.cast<ApprovalRequest?>().firstWhere(
                (r) => r!.id == widget.requestId,
                orElse: () => null,
              );
      if (local != null) {
        if (mounted)
          setState(() {
            _request = local;
            _isLoading = false;
          });
        return;
      }
      // Fall back to DB
      await requestProvider.selectRequest(widget.requestId);
      if (mounted) {
        setState(() {
          _request = requestProvider.selectedRequest;
          _isLoading = false;
          _error = _request == null ? 'Request not found' : null;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  Future<void> _approveRequest() async {
    if (_request == null) return;
    final authProvider = context.read<AuthProvider>();
    final requestProvider = context.read<RequestProvider>();
    final templateProvider = context.read<TemplateProvider>();
    if (authProvider.user == null) return;

    final template = templateProvider.getTemplateById(_request!.templateId);
    if (template == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template not found')),
      );
      return;
    }

    final comment = await _showCommentDialog(AppLocalizations.of(context)!.approveRequest);
    if (comment == null) return;

    try {
      await requestProvider.approveRequest(
        requestId: _request!.id,
        approverId: authProvider.user!.id,
        approverName:
            authProvider.user!.displayName ?? authProvider.user!.email,
        template: template,
        comment: comment.isEmpty ? null : comment,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Request approved ✓')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectRequest() async {
    if (_request == null) return;
    final authProvider = context.read<AuthProvider>();
    final requestProvider = context.read<RequestProvider>();
    final templateProvider = context.read<TemplateProvider>();
    if (authProvider.user == null) return;

    final template = templateProvider.getTemplateById(_request!.templateId);
    if (template == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template not found')),
      );
      return;
    }

    final comment =
        await _showCommentDialog(AppLocalizations.of(context)!.rejectRequest, requireComment: true);
    if (comment == null || comment.isEmpty) return;

    try {
      await requestProvider.rejectRequest(
        requestId: _request!.id,
        approverId: authProvider.user!.id,
        approverName:
            authProvider.user!.displayName ?? authProvider.user!.email,
        template: template,
        comment: comment,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Request rejected')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _exportPdf(BuildContext iconContext) async {
    if (_request == null) return;
    final exportProvider = context.read<ExportProvider>();
    final workspaceProvider = context.read<WorkspaceProvider>();
    final workspace = workspaceProvider.currentWorkspace;
    if (workspace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No workspace selected')),
      );
      return;
    }

    final box = iconContext.findRenderObject() as RenderBox?;
    final sharePositionOrigin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    try {
      await exportProvider.generatePdf(
        request: _request!,
        workspace: workspace,
      );
      if (!mounted) return;
      if (exportProvider.pdfBytes != null) {
        await exportProvider.sharePdf(
          '${_request!.templateName.replaceAll(' ', '_')}_${_request!.id.substring(0, 8)}.pdf',
          sharePositionOrigin: sharePositionOrigin,
        );
      }
      if (!mounted) return;
      if (exportProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF error: ${exportProvider.error}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PDF failed: $e')));
    }
  }

  Future<String?> _showCommentDialog(String title,
      {bool requireComment = false}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText:
                requireComment ? 'Reason (required)' : 'Comment (optional)',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (requireComment && controller.text.trim().isEmpty) return;
              Navigator.pop(ctx, controller.text.trim());
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_request?.templateName ?? AppLocalizations.of(context)!.requestDetails),
        actions: [
          if (_request != null)
            Builder(
              builder: (iconContext) => IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Export PDF',
                onPressed: () => _exportPdf(iconContext),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(
                  message: _error!,
                  onRetry: _loadRequest,
                )
              : _buildContent(),
      bottomNavigationBar:
          _request?.status == RequestStatus.pending ? _buildActionBar() : null,
    );
  }

  Widget _buildContent() {
    final request = _request!;
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.templateName, style: AppTextStyles.h4),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Submitted by ${request.submittedByName}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _formatDate(request.submittedAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Request fields
          Text(AppLocalizations.of(context)!.requestDetails, style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          if (request.fieldValues.isEmpty)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'No field data available',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: request.fieldValues.asMap().entries.map((entry) {
                    final i = entry.key;
                    final field = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i > 0) const Divider(height: AppSpacing.lg),
                        Text(
                          field.fieldName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildFieldValue(field),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          // Approval history
          if (request.currentApprovalActions.isNotEmpty) ...[
            Text('Approval History', style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.md),
            ...request.currentApprovalActions.map(_buildActionItem),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: AppLocalizations.of(context)!.reject,
              onPressed: _rejectRequest,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: PrimaryButton(
              text: AppLocalizations.of(context)!.approve,
              onPressed: _approveRequest,
            ),
          ),
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
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  Widget _buildActionItem(ApprovalAction action) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (action.approved ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
          child: Icon(
            action.approved ? Icons.check : Icons.close,
            color: action.approved ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(
          action.approverName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (action.comment != null)
              Text(
                action.comment!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            Text(
              _formatDate(action.timestamp),
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    }
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildFieldValue(FieldValue field) {
    if (field.fieldType == FieldType.file) {
      final value = field.value?.toString() ?? '';
      return Row(
        children: [
          const Icon(Icons.attach_file, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value.isNotEmpty && value != 'null'
                  ? value
                  : 'Attachment provided',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      );
    }

    return Text(
      _formatValueData(field.value, field.fieldType),
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatValueData(dynamic value, FieldType type) {
    if (value == null || value.toString().isEmpty || value.toString() == 'null')
      return '-';

    if (type == FieldType.checkbox || value is bool) {
      if (value.toString() == 'true') return AppLocalizations.of(context)!.yes;
      if (value.toString() == 'false') return AppLocalizations.of(context)!.no;
      return value == true ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no;
    }

    if (type == FieldType.date) {
      if (value is DateTime) return _formatFullDate(value);
      if (value is String) {
        try {
          return _formatFullDate(DateTime.parse(value));
        } catch (_) {}
      }
    }
    return value.toString();
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
