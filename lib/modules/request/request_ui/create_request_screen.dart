import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../workspace/workspace_provider.dart';
import '../../template/template_provider.dart';
import '../../template/template_models.dart';
import '../request_provider.dart';
import '../request_models.dart';

class CreateRequestScreen extends StatefulWidget {
  final String? templateId;

  const CreateRequestScreen({super.key, this.templateId});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  Template? _selectedTemplate;
  final Map<String, dynamic> _fieldValues = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final templateProvider = context.read<TemplateProvider>();

    // First load all templates for the current workspace
    final workspaceProvider = context.read<WorkspaceProvider>();
    if (workspaceProvider.currentWorkspace != null) {
      await templateProvider
          .loadTemplatesByWorkspace(workspaceProvider.currentWorkspace!.id);
    }

    if (widget.templateId != null && mounted) {
      await templateProvider.selectTemplate(widget.templateId!);
      if (mounted) {
        // Only set template if it was found successfully (no error)
        if (templateProvider.error == null) {
          setState(() {
            _selectedTemplate = templateProvider.selectedTemplate;
          });
        } else {
          // Clear error so user can select from list
          templateProvider.clearError();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Request'),
        actions: [
          if (_selectedTemplate != null)
            TextButton(
              onPressed: _isLoading ? null : _submitRequest,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
        ],
      ),
      body: _selectedTemplate == null
          ? _buildTemplateSelector()
          : _buildRequestForm(),
    );
  }

  Widget _buildTemplateSelector() {
    return Consumer<TemplateProvider>(
      builder: (context, templateProvider, child) {
        if (templateProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error if template not found
        if (templateProvider.error != null) {
          return ErrorState(
            message:
                'Template not found. Please select a template from the list.',
            onRetry: () {
              templateProvider.clearError();
              _initialize();
            },
          );
        }

        final templates =
            templateProvider.templates.where((t) => t.isActive).toList();

        if (templates.isEmpty) {
          return EmptyState(
            icon: Icons.description_outlined,
            message: 'No Templates Available',
            subMessage: 'Create a template first to submit a request',
          );
        }

        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
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
                subtitle: template.description != null
                    ? Text(
                        template.description!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  setState(() {
                    _selectedTemplate = template;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestForm() {
    final template = _selectedTemplate!;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // Template Info
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.name,
                        style: AppTextStyles.h4,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedTemplate = null;
                          _fieldValues.clear();
                        });
                      },
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Change'),
                    ),
                  ],
                ),
                if (template.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    template.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Form Fields
        Text(
          'Request Details',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        ...template.fields.map((field) => _buildFieldInput(field)),
        const SizedBox(height: AppSpacing.xl),

        // Approval Flow Info
        if (template.approvalSteps.isNotEmpty) ...[
          Text(
            'Approval Flow',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.md),
          ...template.approvalSteps.asMap().entries.map(
                (entry) => _buildApprovalStep(
                    entry.value, entry.key + 1, template.approvalSteps.length),
              ),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Submit Button
        PrimaryButton(
          text: 'Submit Request',
          onPressed: _isLoading ? null : _submitRequest,
          isLoading: _isLoading,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildFieldInput(TemplateField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: _buildFieldWidget(field),
    );
  }

  Widget _buildFieldWidget(TemplateField field) {
    switch (field.type) {
      case FieldType.text:
        return AppTextField(
          label: field.label,
          hint: field.placeholder,
          onChanged: (value) {
            setState(() {
              _fieldValues[field.name] = value;
            });
          },
        );

      case FieldType.multiline:
        return AppTextField(
          label: field.label,
          hint: field.placeholder,
          maxLines: 4,
          onChanged: (value) {
            setState(() {
              _fieldValues[field.name] = value;
            });
          },
        );

      case FieldType.number:
        return AppTextField(
          label: field.label,
          hint: field.placeholder,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _fieldValues[field.name] = num.tryParse(value);
            });
          },
        );

      case FieldType.currency:
        return AppTextField(
          label: field.label,
          hint: field.placeholder ?? '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: const Icon(Icons.attach_money),
          onChanged: (value) {
            setState(() {
              _fieldValues[field.name] = num.tryParse(value);
            });
          },
        );

      case FieldType.date:
        return _buildDatePicker(field);

      case FieldType.dropdown:
        return _buildDropdown(field);

      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          value: _fieldValues[field.name] ?? false,
          onChanged: (value) {
            setState(() {
              _fieldValues[field.name] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        );

      case FieldType.file:
        return _buildFilePicker(field);
    }
  }

  Widget _buildDatePicker(TemplateField field) {
    final selectedDate = _fieldValues[field.name] as DateTime?;

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            _fieldValues[field.name] = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : field.placeholder ?? 'Select a date',
              style: AppTextStyles.bodyMedium.copyWith(
                color: selectedDate != null
                    ? AppColors.textPrimary
                    : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(TemplateField field) {
    final options = field.options ?? [];
    final selectedValue = _fieldValues[field.name] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(field.placeholder ?? 'Select an option'),
          value: selectedValue,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _fieldValues[field.name] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFilePicker(TemplateField field) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File upload coming soon')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                _fieldValues[field.name] ??
                    field.placeholder ??
                    'Attach a file',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _fieldValues[field.name] != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalStep(
      ApprovalStep step, int currentStep, int totalSteps) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$currentStep',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${step.approvers.length} approver(s)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (currentStep < totalSteps)
            Icon(Icons.arrow_downward, color: AppColors.textHint, size: 16),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    // Validate required fields
    for (final field in _selectedTemplate!.fields) {
      if (field.required) {
        final value = _fieldValues[field.name];
        if (value == null || (value is String && value.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill in ${field.label}')),
          );
          return;
        }
      }
    }

    final workspaceProvider = context.read<WorkspaceProvider>();
    final authProvider = context.read<AuthProvider>();
    final requestProvider = context.read<RequestProvider>();

    if (workspaceProvider.currentWorkspace == null ||
        authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workspace first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create field values
      final fieldValues = _selectedTemplate!.fields.map((field) {
        return FieldValue(
          fieldId: field.id,
          fieldName: field.name,
          fieldType: field.type,
          value: _fieldValues[field.name],
        );
      }).toList();

      // Create draft request first
      await requestProvider.createDraftRequest(
        workspaceId: workspaceProvider.currentWorkspace!.id,
        template: _selectedTemplate!,
        submittedBy: authProvider.user!.id,
        submittedByName:
            authProvider.user!.displayName ?? authProvider.user!.email,
      );

      // Get the created request and submit it
      final requests = requestProvider.requests;
      final newRequest = requests.lastWhere(
        (r) =>
            r.templateId == _selectedTemplate!.id &&
            r.status == RequestStatus.draft,
      );

      await requestProvider.submitRequest(
        requestId: newRequest.id,
        fieldValues: fieldValues,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
