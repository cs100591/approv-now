import 'package:equatable/equatable.dart';
import '../../template_models.dart';

/// AI 生成结果模型
class AiGenerationResult extends Equatable {
  final String templateName;
  final String description;
  final List<TemplateField> fields;
  final List<ApprovalStep> approvalSteps;
  final double confidence; // 0.0 - 1.0
  final String source; // 'local', 'ai', 'cache'
  final String? matchedScenario;
  final DateTime generatedAt;

  const AiGenerationResult({
    required this.templateName,
    required this.description,
    required this.fields,
    required this.approvalSteps,
    required this.confidence,
    required this.source,
    this.matchedScenario,
    required this.generatedAt,
  });

  AiGenerationResult copyWith({
    String? templateName,
    String? description,
    List<TemplateField>? fields,
    List<ApprovalStep>? approvalSteps,
    double? confidence,
    String? source,
    String? matchedScenario,
    DateTime? generatedAt,
  }) {
    return AiGenerationResult(
      templateName: templateName ?? this.templateName,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      approvalSteps: approvalSteps ?? this.approvalSteps,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      matchedScenario: matchedScenario ?? this.matchedScenario,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'templateName': templateName,
        'description': description,
        'fields': fields.map((f) => f.toJson()).toList(),
        'approvalSteps': approvalSteps.map((s) => s.toJson()).toList(),
        'confidence': confidence,
        'source': source,
        'matchedScenario': matchedScenario,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory AiGenerationResult.fromJson(Map<String, dynamic> json) =>
      AiGenerationResult(
        templateName: json['templateName'] as String,
        description: json['description'] as String,
        fields: (json['fields'] as List)
            .map((f) => TemplateField.fromJson(f))
            .toList(),
        approvalSteps: (json['approvalSteps'] as List)
            .map((s) => ApprovalStep.fromJson(s))
            .toList(),
        confidence: json['confidence'] as double,
        source: json['source'] as String,
        matchedScenario: json['matchedScenario'] as String?,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );

  @override
  List<Object?> get props => [
        templateName,
        description,
        fields,
        approvalSteps,
        confidence,
        source,
        matchedScenario,
        generatedAt,
      ];
}

/// AI 匹配结果
class AiMatchResult {
  final AiGenerationResult? result;
  final double matchScore; // 0.0 - 1.0
  final String matchType; // 'exact', 'contains', 'fuzzy', 'none'
  final String? matchedPresetName;

  const AiMatchResult({
    this.result,
    required this.matchScore,
    required this.matchType,
    this.matchedPresetName,
  });

  bool get isHighMatch => matchScore >= 0.8;
  bool get isMediumMatch => matchScore >= 0.5 && matchScore < 0.8;
  bool get isLowMatch => matchScore < 0.5;
}
