import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../workspace/workspace_provider.dart';
import '../template_provider.dart';
import '../template_models.dart';

class TemplatesListScreen extends StatefulWidget {
  const TemplatesListScreen({super.key});

  @override
  State<TemplatesListScreen> createState() => _TemplatesListScreenState();
}

class _TemplatesListScreenState extends State<TemplatesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTemplates();
    });
  }

  Future<void> _loadTemplates() async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final templateProvider = context.read<TemplateProvider>();

    final currentWorkspace = workspaceProvider.currentWorkspace;
    if (currentWorkspace != null) {
      await templateProvider.loadTemplatesByWorkspace(currentWorkspace.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = context.watch<WorkspaceProvider>();
    final currentWorkspace = workspaceProvider.currentWorkspace;
    final currentUser = context.watch<AuthProvider>().user;

    // Check if user can create template
    final canCreateTemplate = currentUser != null &&
        currentWorkspace != null &&
        (currentWorkspace.createdBy == currentUser.id ||
            currentWorkspace.ownerId == currentUser.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.templates),
        actions: canCreateTemplate
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.createTemplate);
                  },
                ),
              ]
            : null,
      ),
      body: Consumer<TemplateProvider>(
        builder: (context, templateProvider, child) {
          if (templateProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (templateProvider.error != null) {
            return ErrorState(
              message: templateProvider.error!,
              onRetry: _loadTemplates,
            );
          }

          final templates = templateProvider.templates;

          if (templates.isEmpty) {
            return EmptyState(
              icon: Icons.description_outlined,
              message: 'No Templates',
              subMessage: canCreateTemplate
                  ? 'Create your first template to get started'
                  : 'Contact workspace admin to create templates',
              action: canCreateTemplate
                  ? PrimaryButton(
                      text: AppLocalizations.of(context)!.createTemplate,
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.createTemplate);
                      },
                    )
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTemplates,
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _buildTemplateCard(template);
              },
            ),
          );
        },
      ),
      floatingActionButton: canCreateTemplate
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.createTemplate);
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.newTemplate),
            )
          : null,
    );
  }

  Widget _buildTemplateCard(Template template) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        title: Text(
          template.name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (template.description != null &&
                template.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  template.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _buildInfoChip(
                  Icons.format_list_bulleted,
                  '${template.fields.length} fields',
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildInfoChip(
                  Icons.check_circle_outline,
                  '${template.approvalSteps.length} steps',
                ),
                const SizedBox(width: AppSpacing.sm),
                if (template.isActive)
                  _buildInfoChip(
                    Icons.circle,
                    AppLocalizations.of(context)!.active,
                    color: AppColors.success,
                  )
                else
                  _buildInfoChip(
                    Icons.circle,
                    'Inactive',
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onMenuSelected(value, template),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'use',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.useTemplate),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _useTemplate(template),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textSecondary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _useTemplate(Template template) {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final authProvider = context.read<AuthProvider>();

    if (workspaceProvider.currentWorkspace == null ||
        authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workspace first')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      RouteNames.createRequest,
      arguments: {'templateId': template.id},
    );
  }

  void _onMenuSelected(String value, Template template) {
    switch (value) {
      case 'use':
        _useTemplate(template);
        break;
      case 'edit':
        _editTemplate(template);
        break;
      case 'delete':
        _deleteTemplate(template);
        break;
    }
  }

  void _editTemplate(Template template) {
    Navigator.pushNamed(
      context,
      '/edit-template',
      arguments: {'template': template},
    );
  }

  void _deleteTemplate(Template template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTemplate),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<TemplateProvider>()
                  .deleteTemplate(template.id);
            },
            child: Text(AppLocalizations.of(context)!.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
