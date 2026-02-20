import 'dart:math';
import 'template_models.dart';

/// TemplateService - Business logic for template management
class TemplateService {
  final List<Template> _templates = [];

  // Get all templates
  List<Template> getTemplates() {
    return List.unmodifiable(_templates);
  }

  // Get templates by workspace
  List<Template> getTemplatesByWorkspace(String workspaceId) {
    return _templates.where((t) => t.workspaceId == workspaceId).toList();
  }

  // Get template by ID
  Template? getTemplateById(String templateId) {
    try {
      return _templates.firstWhere((t) => t.id == templateId);
    } catch (e) {
      return null;
    }
  }

  // Create new template
  Future<Template> createTemplate({
    required String workspaceId,
    required String name,
    String? description,
    required String createdBy,
  }) async {
    final template = Template(
      id: _generateId(),
      workspaceId: workspaceId,
      name: name,
      description: description,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _templates.add(template);
    return template;
  }

  // Update template
  Future<Template> updateTemplate({
    required String templateId,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index == -1) {
      throw Exception('Template not found');
    }

    final updated = _templates[index].copyWith(
      name: name,
      description: description,
      isActive: isActive,
      updatedAt: DateTime.now(),
    );

    _templates[index] = updated;
    return updated;
  }

  // Add field to template
  Future<Template> addField({
    required String templateId,
    required String name,
    required String label,
    required FieldType type,
    bool required = false,
    String? placeholder,
    List<String>? options,
    Map<String, dynamic> validation = const {},
  }) async {
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index == -1) {
      throw Exception('Template not found');
    }

    final template = _templates[index];
    final newField = TemplateField(
      id: _generateId(),
      name: name,
      label: label,
      type: type,
      required: required,
      order: template.fields.length,
      placeholder: placeholder,
      options: options,
      validation: validation,
    );

    final updatedFields = [...template.fields, newField];
    final updated = template.copyWith(
      fields: updatedFields,
      updatedAt: DateTime.now(),
    );

    _templates[index] = updated;
    return updated;
  }

  // Remove field from template
  Future<Template> removeField({
    required String templateId,
    required String fieldId,
  }) async {
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index == -1) {
      throw Exception('Template not found');
    }

    final template = _templates[index];
    final updatedFields =
        template.fields.where((f) => f.id != fieldId).toList();

    // Reorder remaining fields
    for (int i = 0; i < updatedFields.length; i++) {
      updatedFields[i] = updatedFields[i].copyWith(order: i);
    }

    final updated = template.copyWith(
      fields: updatedFields,
      updatedAt: DateTime.now(),
    );

    _templates[index] = updated;
    return updated;
  }

  // Reorder fields
  Future<Template> reorderFields({
    required String templateId,
    required List<String> fieldIds,
  }) async {
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index == -1) {
      throw Exception('Template not found');
    }

    final template = _templates[index];
    final fieldMap = {for (var f in template.fields) f.id: f};

    final reorderedFields = fieldIds.asMap().entries.map((entry) {
      final field = fieldMap[entry.value];
      if (field == null) throw Exception('Field not found: ${entry.value}');
      return field.copyWith(order: entry.key);
    }).toList();

    final updated = template.copyWith(
      fields: reorderedFields,
      updatedAt: DateTime.now(),
    );

    _templates[index] = updated;
    return updated;
  }

  // Add approval step
  Future<Template> addApprovalStep({
    required String templateId,
    required String name,
    required List<String> approvers,
    bool requireAll = false,
    String? condition,
  }) async {
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index == -1) {
      throw Exception('Template not found');
    }

    final template = _templates[index];
    final level = template.maxApprovalLevel + 1;

    final newStep = ApprovalStep(
      id: _generateId(),
      level: level,
      name: name,
      approvers: approvers,
      requireAll: requireAll,
      condition: condition,
    );

    final updatedSteps = [...template.approvalSteps, newStep];
    final updated = template.copyWith(
      approvalSteps: updatedSteps,
      updatedAt: DateTime.now(),
    );

    _templates[index] = updated;
    return updated;
  }

  // Remove approval step
  Future<Template> removeApprovalStep({
    required String templateId,
    required String stepId,
  }) async {
    final index = _templates.indexWhere((t) => t.id == templateId);
    if (index == -1) {
      throw Exception('Template not found');
    }

    final template = _templates[index];
    final updatedSteps =
        template.approvalSteps.where((s) => s.id != stepId).toList();

    // Reorder levels
    for (int i = 0; i < updatedSteps.length; i++) {
      updatedSteps[i] = updatedSteps[i].copyWith(level: i + 1);
    }

    final updated = template.copyWith(
      approvalSteps: updatedSteps,
      updatedAt: DateTime.now(),
    );

    _templates[index] = updated;
    return updated;
  }

  // Validate template rules
  TemplateValidationResult validateTemplate(Template template) {
    final List<String> errors = [];

    if (template.fields.isEmpty) {
      errors.add('Template must have at least one field');
    }

    if (template.approvalSteps.isEmpty) {
      errors.add('Template must have at least one approval step');
    }

    // Check for duplicate field names
    final fieldNames = template.fields.map((f) => f.name).toList();
    if (fieldNames.toSet().length != fieldNames.length) {
      errors.add('Field names must be unique');
    }

    // Check for empty approvers in steps
    for (final step in template.approvalSteps) {
      if (step.approvers.isEmpty) {
        errors.add(
            'Approval step "${step.name}" must have at least one approver');
      }
    }

    return TemplateValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // Delete template
  Future<void> deleteTemplate(String templateId) async {
    _templates.removeWhere((t) => t.id == templateId);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
