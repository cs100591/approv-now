import 'package:equatable/equatable.dart';
import '../../core/utils/data_parser.dart';

/// Field types available in templates
enum FieldType {
  text,
  number,
  date,
  dropdown,
  checkbox,
  multiline,
  file,
  currency,
}

/// Template field definition
class TemplateField extends Equatable {
  final String id;
  final String name;
  final String label;
  final FieldType type;
  final bool required;
  final int order;
  final String? placeholder;
  final List<String>? options; // For dropdown
  final Map<String, dynamic> validation;

  const TemplateField({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    required this.order,
    this.placeholder,
    this.options,
    this.validation = const {},
  });

  TemplateField copyWith({
    String? id,
    String? name,
    String? label,
    FieldType? type,
    bool? required,
    int? order,
    String? placeholder,
    List<String>? options,
    Map<String, dynamic>? validation,
  }) {
    return TemplateField(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      order: order ?? this.order,
      placeholder: placeholder ?? this.placeholder,
      options: options ?? this.options,
      validation: validation ?? this.validation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'label': label,
        'type': type.name,
        'required': required,
        'order': order,
        'placeholder': placeholder,
        'options': options,
        'validation': validation,
      };

  factory TemplateField.fromJson(Map<String, dynamic> json) => TemplateField(
        id: DataParser.parseString(json['id']),
        name: DataParser.parseString(json['name']),
        label: DataParser.parseString(json['label']),
        type: DataParser.parseEnumWithDefault(
          json['type'],
          FieldType.values,
          FieldType.text,
        ),
        required: DataParser.parseBool(json['required'], false),
        order: DataParser.parseInt(json['order'], 0),
        placeholder: json['placeholder'] as String?,
        options: json['options'] != null
            ? DataParser.parseStringList(json['options'])
            : null,
        validation: json['validation'] as Map<String, dynamic>? ?? {},
      );

  @override
  List<Object?> get props => [
        id,
        name,
        label,
        type,
        required,
        order,
        placeholder,
        options,
        validation,
      ];
}

/// Approval step definition
class ApprovalStep extends Equatable {
  final String id;
  final int level;
  final String name;
  final List<String> approvers;
  final bool requireAll;
  final String? condition;

  const ApprovalStep({
    required this.id,
    required this.level,
    required this.name,
    required this.approvers,
    this.requireAll = false,
    this.condition,
  });

  ApprovalStep copyWith({
    String? id,
    int? level,
    String? name,
    List<String>? approvers,
    bool? requireAll,
    String? condition,
  }) {
    return ApprovalStep(
      id: id ?? this.id,
      level: level ?? this.level,
      name: name ?? this.name,
      approvers: approvers ?? this.approvers,
      requireAll: requireAll ?? this.requireAll,
      condition: condition ?? this.condition,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'name': name,
        'approvers': approvers,
        'requireAll': requireAll,
        'condition': condition,
      };

  factory ApprovalStep.fromJson(Map<String, dynamic> json) => ApprovalStep(
        id: DataParser.parseString(json['id']),
        level: DataParser.parseInt(json['level'], 1),
        name: DataParser.parseString(json['name']),
        approvers: DataParser.parseStringList(json['approvers']),
        requireAll: DataParser.parseBool(json['requireAll'], false),
        condition: json['condition'] as String?,
      );

  @override
  List<Object?> get props =>
      [id, level, name, approvers, requireAll, condition];
}

/// Template model representing an approval template
class Template extends Equatable {
  final String id;
  final String workspaceId;
  final String name;
  final String? description;
  final List<TemplateField> fields;
  final List<ApprovalStep> approvalSteps;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Template({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description,
    this.fields = const [],
    this.approvalSteps = const [],
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Template copyWith({
    String? id,
    String? workspaceId,
    String? name,
    String? description,
    List<TemplateField>? fields,
    List<ApprovalStep>? approvalSteps,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      approvalSteps: approvalSteps ?? this.approvalSteps,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'description': description,
        'fields': fields.map((f) => f.toJson()).toList(),
        'approvalSteps': approvalSteps.map((s) => s.toJson()).toList(),
        'isActive': isActive,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Template.fromJson(Map<String, dynamic> json) => Template(
        id: DataParser.parseString(json['id']),
        workspaceId: DataParser.parseString(json['workspaceId']),
        name: DataParser.parseString(json['name']),
        description: json['description'] as String?,
        fields: (json['fields'] as List?)
                ?.map((f) => TemplateField.fromJson(f as Map<String, dynamic>))
                .toList() ??
            [],
        approvalSteps: (json['approvalSteps'] as List?)
                ?.map((s) => ApprovalStep.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        isActive: DataParser.parseBool(json['isActive'], true),
        createdBy: DataParser.parseString(json['createdBy']),
        createdAt: DataParser.parseDateTime(json['createdAt']),
        updatedAt: DataParser.parseDateTime(json['updatedAt']),
      );

  int get maxApprovalLevel => approvalSteps.isEmpty
      ? 0
      : approvalSteps.map((s) => s.level).reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        name,
        description,
        fields,
        approvalSteps,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

/// Template state for provider
class TemplateState extends Equatable {
  final List<Template> templates;
  final Template? selectedTemplate;
  final bool isLoading;
  final String? error;

  const TemplateState({
    this.templates = const [],
    this.selectedTemplate,
    this.isLoading = false,
    this.error,
  });

  TemplateState copyWith({
    List<Template>? templates,
    Template? selectedTemplate,
    bool? isLoading,
    String? error,
  }) {
    return TemplateState(
      templates: templates ?? this.templates,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [templates, selectedTemplate, isLoading, error];
}

/// Validation result for template rules
class TemplateValidationResult {
  final bool isValid;
  final List<String> errors;

  const TemplateValidationResult({
    this.isValid = true,
    this.errors = const [],
  });
}
