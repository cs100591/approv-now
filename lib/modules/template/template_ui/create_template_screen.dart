import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/auth_provider.dart';
import '../../workspace/workspace_provider.dart';
import '../template_provider.dart';
import '../template_models.dart';
import '../ai/smart_template_generator.dart';
import '../ai/models/ai_generation_result.dart';
import '../ai/template_ui/ai_generate_button.dart';
import '../ai/template_ui/ai_preview_dialog.dart';
import '../ai/template_ui/ai_suggestion_card.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<TemplateField> _fields = [];
  final List<ApprovalStep> _approvalSteps = [];

  bool _isLoading = false;
  bool _isGenerating = false;
  MatchStatus _matchStatus = MatchStatus.none;

  // AI Generator
  late final SmartTemplateGenerator _aiGenerator;
  GenerationResponse? _lastGenerationResponse;
  List<AiMatchResult> _suggestions = [];

  @override
  void initState() {
    super.initState();
    // 初始化 AI Generator（注意：需要配置 OpenAI API Key）
    _aiGenerator = SmartTemplateGenerator(
      // openAiApiKey: 'your-api-key-here', // 如果有 API Key 可以取消注释
      enableAi: false, // 默认禁用 AI，需要配置 API Key 后启用
    );

    // 监听输入变化
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 当模板名称变化时，检查匹配状态
  void _onNameChanged() {
    final name = _nameController.text.trim();
    if (name.length >= 2) {
      _checkLocalMatch(name);
    } else {
      setState(() {
        _matchStatus = MatchStatus.none;
        _suggestions = [];
      });
    }
  }

  /// 检查本地匹配
  void _checkLocalMatch(String templateName) {
    // 使用本地匹配器检查
    final matcher = _aiGenerator.getSuggestions(templateName);
    matcher.then((suggestions) {
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          if (suggestions.isNotEmpty && suggestions.first.matchScore >= 0.8) {
            _matchStatus = MatchStatus.matched;
          } else if (suggestions.isNotEmpty &&
              suggestions.first.matchScore >= 0.5) {
            _matchStatus = MatchStatus.suggested;
          } else {
            _matchStatus = MatchStatus.none;
          }
        });
      }
    });
  }

  /// 点击 AI 生成按钮
  Future<void> _onAiGeneratePressed() async {
    final templateName = _nameController.text.trim();
    if (templateName.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _matchStatus = MatchStatus.generating;
    });

    try {
      final response = await _aiGenerator.generate(templateName);

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _lastGenerationResponse = response;
        });

        if (response.success) {
          _showPreviewDialog(response);
        } else {
          _showErrorDialog(response.error ?? '生成失败');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _matchStatus = MatchStatus.none;
        });
        _showErrorDialog(e.toString());
      }
    }
  }

  /// 显示预览弹窗
  void _showPreviewDialog(GenerationResponse response) {
    if (response.result == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AiPreviewDialog(
        result: response.result!,
        matchType: response.matchType!,
        matchScore: response.matchScore!,
        onApply: () {
          Navigator.pop(context);
          _applyAiResult(response.result!);
        },
        onRegenerate: () {
          Navigator.pop(context);
          _onAiGeneratePressed();
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  /// 显示错误弹窗
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生成失败'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 应用 AI 生成的结果
  void _applyAiResult(AiGenerationResult result) {
    setState(() {
      // 更新描述
      _descriptionController.text = result.description;

      // 更新字段
      _fields.clear();
      _fields.addAll(result.fields);

      // 更新审批步骤
      _approvalSteps.clear();
      _approvalSteps.addAll(result.approvalSteps);

      // 更新匹配状态
      _matchStatus = MatchStatus.matched;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已应用 AI 生成的配置：${result.matchedScenario ?? "自定义场景"}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// 使用 AI 强制生成
  Future<void> _onUseAiGenerate() async {
    setState(() {
      _isGenerating = true;
      _matchStatus = MatchStatus.generating;
    });

    try {
      final response =
          await _aiGenerator.generateWithAi(_nameController.text.trim());

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });

        if (response.success && response.result != null) {
          _showPreviewDialog(response);
        } else {
          _showErrorDialog(response.error ?? 'AI 生成失败');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _matchStatus = MatchStatus.none;
        });
        _showErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Template'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTemplate,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Basic Info Section
            _buildSectionHeader(
              'Template Information',
              'Basic details about this template',
            ),
            const SizedBox(height: AppSpacing.md),

            // Template Name with AI Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _nameController,
                    label: 'Template Name',
                    hint: 'e.g., Budget Approval',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a template name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 24), // 对齐输入框
                  child: AiGenerateButton(
                    isEnabled: _nameController.text.trim().length >= 2,
                    isLoading: _isGenerating,
                    matchStatus: _matchStatus,
                    onPressed: _onAiGeneratePressed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 显示推荐场景（如果有）
            if (_suggestions.isNotEmpty &&
                _suggestions.first.matchScore >= 0.5 &&
                _suggestions.first.matchScore < 0.8 &&
                _fields.isEmpty) ...[
              AiSuggestionCard(
                suggestions: _suggestions.take(3).toList(),
                onSelect: (suggestion) {
                  if (suggestion.result != null) {
                    _applyAiResult(suggestion.result!);
                  }
                },
                onUseAi: _onUseAiGenerate,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            AppTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Brief description of this template',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Fields Section
            _buildSectionHeaderWithAction(
              'Form Fields',
              'Define the fields users will fill out',
              Icons.add_circle_outline,
              _addField,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_fields.isEmpty)
              _buildEmptyState(
                icon: Icons.format_list_bulleted,
                message: 'No fields yet',
                subMessage:
                    'Tap + to add your first field or use AI to generate',
              )
            else
              Column(
                children: _fields.asMap().entries.map((entry) {
                  return _buildFieldCard(entry.value, entry.key);
                }).toList(),
              ),
            const SizedBox(height: AppSpacing.xl),

            // Approval Steps Section
            _buildSectionHeaderWithAction(
              'Approval Steps',
              'Who needs to approve this request?',
              Icons.add_circle_outline,
              _addApprovalStep,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_approvalSteps.isEmpty)
              _buildEmptyState(
                icon: Icons.people_outline,
                message: 'No approval steps',
                subMessage: 'Add at least one approver',
              )
            else
              Column(
                children: _approvalSteps.asMap().entries.map((entry) {
                  return _buildStepCard(entry.value, entry.key);
                }).toList(),
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderWithAction(
    String title,
    String subtitle,
    IconData actionIcon,
    VoidCallback onAction,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onAction,
          icon: Icon(actionIcon, color: AppColors.primary),
          tooltip: 'Add',
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subMessage,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(TemplateField field, int index) {
    IconData iconData;
    String typeLabel;
    String? extraInfo;

    switch (field.type) {
      case FieldType.text:
        iconData = Icons.text_fields;
        typeLabel = 'Text';
        break;
      case FieldType.number:
        iconData = Icons.numbers;
        typeLabel = 'Number';
        break;
      case FieldType.date:
        iconData = Icons.calendar_today;
        typeLabel = 'Date';
        break;
      case FieldType.dropdown:
        iconData = Icons.arrow_drop_down_circle;
        typeLabel = 'Dropdown';
        extraInfo = '${field.options?.length ?? 0} options';
        break;
      case FieldType.checkbox:
        iconData = Icons.check_box;
        typeLabel = 'Checkbox';
        break;
      case FieldType.multiline:
        iconData = Icons.notes;
        typeLabel = 'Multiline';
        break;
      case FieldType.file:
        iconData = Icons.attach_file;
        typeLabel = 'File';
        break;
      case FieldType.currency:
        iconData = Icons.attach_money;
        typeLabel = 'Currency';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconData, color: AppColors.primary, size: 20),
        ),
        title: Text(
          field.label,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          extraInfo != null
              ? '$typeLabel • $extraInfo${field.required ? ' • Required' : ''}'
              : '$typeLabel${field.required ? ' • Required' : ''}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index > 0)
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18),
                onPressed: () => _moveField(index, index - 1),
                tooltip: 'Move up',
              ),
            if (index < _fields.length - 1)
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18),
                onPressed: () => _moveField(index, index + 1),
                tooltip: 'Move down',
              ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
              onPressed: () => _editField(field, index),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
              onPressed: () => _removeField(index),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(ApprovalStep step, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '${step.level}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          step.name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${step.approvers.length} approver(s)${step.requireAll ? ' (All required)' : ''}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
          onPressed: () => _removeStep(index),
          tooltip: 'Delete',
        ),
      ),
    );
  }

  void _addField() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFieldSheet(
        onAdd: (field) {
          setState(() {
            _fields.add(field);
          });
        },
      ),
    );
  }

  void _editField(TemplateField field, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFieldSheet(
        field: field,
        onAdd: (updatedField) {
          setState(() {
            _fields[index] = updatedField;
          });
        },
      ),
    );
  }

  void _addApprovalStep() {
    final nextLevel = _approvalSteps.isEmpty
        ? 1
        : _approvalSteps.map((s) => s.level).reduce((a, b) => a > b ? a : b) +
            1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddApprovalStepSheet(
        level: nextLevel,
        onAdd: (step) {
          setState(() {
            _approvalSteps.add(step);
            _approvalSteps.sort((a, b) => a.level.compareTo(b.level));
          });
        },
      ),
    );
  }

  void _moveField(int fromIndex, int toIndex) {
    setState(() {
      final field = _fields.removeAt(fromIndex);
      _fields.insert(toIndex, field);
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _removeStep(int index) {
    setState(() {
      _approvalSteps.removeAt(index);
    });
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    final workspaceProvider = context.read<WorkspaceProvider>();
    final authProvider = context.read<AuthProvider>();
    final templateProvider = context.read<TemplateProvider>();

    if (workspaceProvider.currentWorkspace == null ||
        authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workspace first')),
      );
      return;
    }

    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one field')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await templateProvider.createTemplate(
        workspaceId: workspaceProvider.currentWorkspace!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: authProvider.user!.id,
      );

      // Get the newly created template
      final templates = templateProvider.templates;
      final newTemplate = templates.lastWhere(
        (t) => t.name == _nameController.text.trim(),
      );

      // Add fields with their options
      for (final field in _fields) {
        await templateProvider.addField(
          templateId: newTemplate.id,
          name: field.name,
          label: field.label,
          type: field.type,
          required: field.required,
          placeholder: field.placeholder,
          options: field.options,
          validation: field.validation,
        );
      }

      // Add approval steps
      for (final step in _approvalSteps) {
        await templateProvider.addApprovalStep(
          templateId: newTemplate.id,
          name: step.name,
          approvers: step.approvers,
          requireAll: step.requireAll,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template created successfully')),
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

// Add/Edit Field Sheet with Dropdown and Checkbox Support
class AddFieldSheet extends StatefulWidget {
  final TemplateField? field;
  final Function(TemplateField) onAdd;

  const AddFieldSheet({
    super.key,
    this.field,
    required this.onAdd,
  });

  @override
  State<AddFieldSheet> createState() => _AddFieldSheetState();
}

class _AddFieldSheetState extends State<AddFieldSheet> {
  late final _labelController =
      TextEditingController(text: widget.field?.label ?? '');
  late final _placeholderController =
      TextEditingController(text: widget.field?.placeholder ?? '');
  late FieldType _selectedType = widget.field?.type ?? FieldType.text;
  late bool _isRequired = widget.field?.required ?? false;

  // For dropdown options
  final _optionController = TextEditingController();
  late List<String> _options = widget.field?.options?.toList() ?? [];

  // For checkbox default
  late bool _checkboxDefault =
      widget.field?.validation['default'] as bool? ?? false;

  @override
  void dispose() {
    _labelController.dispose();
    _placeholderController.dispose();
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
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
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Text(
                      widget.field != null ? 'Edit Field' : 'Add Field',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Field Label
                    AppTextField(
                      controller: _labelController,
                      label: 'Field Label',
                      hint: 'e.g., Department, Amount',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field Type
                    Text(
                      'Field Type',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTypeChip(
                            FieldType.text, 'Text', Icons.text_fields),
                        _buildTypeChip(
                            FieldType.multiline, 'Multiline', Icons.notes),
                        _buildTypeChip(
                            FieldType.number, 'Number', Icons.numbers),
                        _buildTypeChip(
                            FieldType.currency, 'Currency', Icons.attach_money),
                        _buildTypeChip(
                            FieldType.date, 'Date', Icons.calendar_today),
                        _buildTypeChip(FieldType.dropdown, 'Dropdown',
                            Icons.arrow_drop_down_circle),
                        _buildTypeChip(
                            FieldType.checkbox, 'Checkbox', Icons.check_box),
                        _buildTypeChip(
                            FieldType.file, 'File', Icons.attach_file),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Placeholder
                    if (_selectedType != FieldType.checkbox &&
                        _selectedType != FieldType.file)
                      AppTextField(
                        controller: _placeholderController,
                        label: 'Placeholder (Optional)',
                        hint: 'Hint text for this field',
                      ),
                    if (_selectedType != FieldType.checkbox &&
                        _selectedType != FieldType.file)
                      const SizedBox(height: AppSpacing.md),

                    // Dropdown Options
                    if (_selectedType == FieldType.dropdown) ...[
                      Text(
                        'Dropdown Options',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _optionController,
                              label: 'Add Option',
                              hint: 'e.g., Marketing',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            onPressed: _optionController.text.isEmpty
                                ? null
                                : () {
                                    setState(() {
                                      _options
                                          .add(_optionController.text.trim());
                                      _optionController.clear();
                                    });
                                  },
                            icon: const Icon(Icons.add_circle,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                      if (_options.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _options.map((option) {
                            return Chip(
                              label: Text(option),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _options.remove(option);
                                });
                              },
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Checkbox Default Value
                    if (_selectedType == FieldType.checkbox)
                      CheckboxListTile(
                        title: const Text('Checked by default'),
                        value: _checkboxDefault,
                        onChanged: (value) {
                          setState(() {
                            _checkboxDefault = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    if (_selectedType == FieldType.checkbox)
                      const SizedBox(height: AppSpacing.md),

                    // Required
                    CheckboxListTile(
                      title: const Text('Required Field'),
                      subtitle: const Text('Users must fill this field'),
                      value: _isRequired,
                      onChanged: (value) {
                        setState(() {
                          _isRequired = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Save Button
                    PrimaryButton(
                      text: widget.field != null ? 'Save Changes' : 'Add Field',
                      onPressed: () {
                        if (_labelController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter a field label')),
                          );
                          return;
                        }

                        if (_selectedType == FieldType.dropdown &&
                            _options.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please add at least one dropdown option')),
                          );
                          return;
                        }

                        final field = TemplateField(
                          id: widget.field?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _labelController.text
                              .toLowerCase()
                              .replaceAll(' ', '_'),
                          label: _labelController.text,
                          type: _selectedType,
                          required: _isRequired,
                          order: widget.field?.order ?? 0,
                          placeholder: _placeholderController.text.isEmpty
                              ? null
                              : _placeholderController.text,
                          options: _selectedType == FieldType.dropdown
                              ? _options
                              : null,
                          validation: _selectedType == FieldType.checkbox
                              ? {'default': _checkboxDefault}
                              : {},
                        );

                        widget.onAdd(field);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeChip(FieldType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedType = type);
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.divider,
      ),
    );
  }
}

// Add Approval Step Sheet
class AddApprovalStepSheet extends StatefulWidget {
  final int level;
  final Function(ApprovalStep) onAdd;

  const AddApprovalStepSheet({
    super.key,
    required this.level,
    required this.onAdd,
  });

  @override
  State<AddApprovalStepSheet> createState() => _AddApprovalStepSheetState();
}

class _AddApprovalStepSheetState extends State<AddApprovalStepSheet> {
  final _nameController = TextEditingController();
  final _approverController = TextEditingController();
  final List<String> _approvers = [];
  bool _requireAll = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
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
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Text(
                      'Approval Step ${widget.level}',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Add approvers for this step',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Step Name
                    AppTextField(
                      controller: _nameController,
                      label: 'Step Name',
                      hint: 'e.g., Manager Review',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Add Approver
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _approverController,
                            label: 'Approver Email',
                            hint: 'manager@company.com',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          onPressed: _approverController.text.isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    _approvers
                                        .add(_approverController.text.trim());
                                    _approverController.clear();
                                  });
                                },
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primary),
                        ),
                      ],
                    ),

                    // Approvers List
                    if (_approvers.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _approvers.map((approver) {
                          return Chip(
                            label: Text(approver),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _approvers.remove(approver);
                              });
                            },
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),
                    CheckboxListTile(
                      title: const Text('Require all approvers'),
                      subtitle: const Text('Everyone must approve to proceed'),
                      value: _requireAll,
                      onChanged: (value) {
                        setState(() => _requireAll = value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    PrimaryButton(
                      text: 'Add Step',
                      onPressed: () {
                        if (_nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter a step name')),
                          );
                          return;
                        }
                        if (_approvers.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please add at least one approver')),
                          );
                          return;
                        }

                        final step = ApprovalStep(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          level: widget.level,
                          name: _nameController.text,
                          approvers: List.from(_approvers),
                          requireAll: _requireAll,
                        );

                        widget.onAdd(step);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
