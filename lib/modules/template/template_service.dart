import '../../core/utils/id_generator.dart';
import 'template_models.dart';

/// TemplateService - Stateless business logic for template management
///
/// This service is now stateless. All data operations are performed on objects
/// passed as parameters. Data persistence is handled by TemplateRepository.
class TemplateService {
  // Create new template
  Template createTemplate({
    required String workspaceId,
    required String name,
    String? description,
    required String createdBy,
  }) {
    return Template(
      id: IdGenerator.generateId(),
      workspaceId: workspaceId,
      name: name,
      description: description,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Update template
  Template updateTemplate({
    required Template existingTemplate,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return existingTemplate.copyWith(
      name: name,
      description: description,
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
  }

  // Add field to template
  Template addField({
    required Template existingTemplate,
    required String name,
    required String label,
    required FieldType type,
    bool required = false,
    String? placeholder,
    List<String>? options,
    Map<String, dynamic> validation = const {},
  }) {
    final newField = TemplateField(
      id: IdGenerator.generateId(),
      name: name,
      label: label,
      type: type,
      required: required,
      order: existingTemplate.fields.length,
      placeholder: placeholder,
      options: options,
      validation: validation,
    );

    final updatedFields = [...existingTemplate.fields, newField];
    return existingTemplate.copyWith(
      fields: updatedFields,
      updatedAt: DateTime.now(),
    );
  }

  // Remove field from template
  Template removeField({
    required Template existingTemplate,
    required String fieldId,
  }) {
    final updatedFields =
        existingTemplate.fields.where((f) => f.id != fieldId).toList();

    // Reorder remaining fields
    for (int i = 0; i < updatedFields.length; i++) {
      updatedFields[i] = updatedFields[i].copyWith(order: i);
    }

    return existingTemplate.copyWith(
      fields: updatedFields,
      updatedAt: DateTime.now(),
    );
  }

  // Reorder fields
  Template reorderFields({
    required Template existingTemplate,
    required List<String> fieldIds,
  }) {
    final fieldMap = {for (var f in existingTemplate.fields) f.id: f};

    final reorderedFields = fieldIds.asMap().entries.map((entry) {
      final field = fieldMap[entry.value];
      if (field == null) throw Exception('Field not found: ${entry.value}');
      return field.copyWith(order: entry.key);
    }).toList();

    return existingTemplate.copyWith(
      fields: reorderedFields,
      updatedAt: DateTime.now(),
    );
  }

  // Add approval step
  Template addApprovalStep({
    required Template existingTemplate,
    required String name,
    required List<String> approvers,
    bool requireAll = false,
    String? condition,
  }) {
    final level = existingTemplate.maxApprovalLevel + 1;

    final newStep = ApprovalStep(
      id: IdGenerator.generateId(),
      level: level,
      name: name,
      approvers: approvers,
      requireAll: requireAll,
      condition: condition,
    );

    final updatedSteps = [...existingTemplate.approvalSteps, newStep];
    return existingTemplate.copyWith(
      approvalSteps: updatedSteps,
      updatedAt: DateTime.now(),
    );
  }

  // Remove approval step
  Template removeApprovalStep({
    required Template existingTemplate,
    required String stepId,
  }) {
    final updatedSteps =
        existingTemplate.approvalSteps.where((s) => s.id != stepId).toList();

    // Reorder levels
    for (int i = 0; i < updatedSteps.length; i++) {
      updatedSteps[i] = updatedSteps[i].copyWith(level: i + 1);
    }

    return existingTemplate.copyWith(
      approvalSteps: updatedSteps,
      updatedAt: DateTime.now(),
    );
  }

  // Update approval step
  Template updateApprovalStep({
    required Template existingTemplate,
    required String stepId,
    String? name,
    List<String>? approvers,
    bool? requireAll,
    String? condition,
  }) {
    final stepIndex =
        existingTemplate.approvalSteps.indexWhere((s) => s.id == stepId);
    if (stepIndex == -1) {
      throw Exception('Approval step not found: $stepId');
    }

    final updatedSteps =
        List<ApprovalStep>.from(existingTemplate.approvalSteps);
    updatedSteps[stepIndex] = updatedSteps[stepIndex].copyWith(
      name: name,
      approvers: approvers,
      requireAll: requireAll,
      condition: condition,
    );

    return existingTemplate.copyWith(
      approvalSteps: updatedSteps,
      updatedAt: DateTime.now(),
    );
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

  // Check if field name is unique in template
  bool isFieldNameUnique(Template template, String fieldName,
      {String? excludeFieldId}) {
    return !template.fields
        .any((f) => f.name == fieldName && f.id != excludeFieldId);
  }

  // Get next field order
  int getNextFieldOrder(Template template) {
    return template.fields.length;
  }

  // Get next approval level
  int getNextApprovalLevel(Template template) {
    return template.maxApprovalLevel + 1;
  }
}
