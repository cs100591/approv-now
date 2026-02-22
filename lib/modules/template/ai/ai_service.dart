import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/ai_generation_result.dart';
import '../template_models.dart';

/// DeepSeek AI Service
/// Handles AI-powered template generation using DeepSeek API
class AiService {
  final String? apiKey;
  final String model;
  final Duration timeout;

  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';

  AiService({
    this.apiKey,
    this.model = 'deepseek-chat',
    this.timeout = const Duration(seconds: 15),
  });

  /// Check if AI service is properly configured
  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  /// Generate template configuration based on template name
  Future<AiGenerationResult?> generateTemplate(String templateName) async {
    if (!isConfigured) {
      throw Exception(
          'DeepSeek API Key not configured. Please set DEEPSEEK_API_KEY environment variable.');
    }

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {
                  'role': 'system',
                  'content': _systemPrompt,
                },
                {
                  'role': 'user',
                  'content': 'Template Name: "$templateName"',
                },
              ],
              'temperature': 0.3,
              'max_tokens': 2000,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return _parseAiResponse(templateName, content);
      } else if (response.statusCode == 401) {
        throw Exception(
            'Invalid DeepSeek API Key. Please check your configuration.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            'DeepSeek API error: ${error['error']['message'] ?? response.body}');
      }
    } on TimeoutException {
      throw Exception(
          'DeepSeek API request timed out. Please check your internet connection.');
    } catch (e) {
      throw Exception('AI generation failed: $e');
    }
  }

  /// System prompt for AI template generation
  String get _systemPrompt {
    final fieldTypes = FieldType.values.map((e) => e.name).join(', ');

    return '''
You are a professional approval workflow design expert. Based on the user-provided template name, generate a complete approval template configuration.

Available field types: $fieldTypes

Approval workflow reference:
- Simple approval (1 level): Direct Manager
- Standard approval (2 levels): Manager → HR/Finance
- Complex approval (3 levels): Manager → Department Director → CEO

Please generate the following content (JSON format):
{
  "description": "Template description (concise and clear)",
  "fields": [
    {
      "name": "Field identifier (lowercase English + underscores)",
      "label": "Field display name (English)",
      "type": "Field type",
      "required": true/false,
      "placeholder": "Hint text (optional)",
      "options": ["Option 1", "Option 2"] // Only for dropdown type
    }
  ],
  "approvalSteps": [
    {
      "level": 1,
      "name": "Step name",
      "approvers": [],
      "requireAll": false,
      "condition": "Conditional expression (optional)"
    }
  ]
}

Requirements:
1. Generate 3-8 reasonable fields
2. Set 1-3 approval levels based on scenario complexity
3. Field types must match the available type list
4. Output must be valid JSON only, no explanatory text
''';
  }

  /// Parse AI response into structured result
  AiGenerationResult? _parseAiResponse(String templateName, String content) {
    try {
      // Extract JSON part
      final jsonMatch =
          RegExp(r'```json\n(.*?)\n```', dotAll: true).firstMatch(content);
      final jsonStr = jsonMatch?.group(1) ?? content;

      final data = jsonDecode(jsonStr);

      // Parse fields
      final fields = (data['fields'] as List).asMap().entries.map((entry) {
        final field = entry.value as Map<String, dynamic>;
        return TemplateField(
          id: 'ai_field_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          name: field['name'] as String,
          label: field['label'] as String,
          type: FieldType.values.firstWhere(
            (e) => e.name == field['type'],
            orElse: () => FieldType.text,
          ),
          required: field['required'] as bool? ?? false,
          order: entry.key,
          placeholder: field['placeholder'] as String?,
          options: field['options'] != null
              ? List<String>.from(field['options'])
              : null,
          validation: const {},
        );
      }).toList();

      // Parse approval steps
      final steps =
          (data['approvalSteps'] as List).asMap().entries.map((entry) {
        final step = entry.value as Map<String, dynamic>;
        return ApprovalStep(
          id: 'ai_step_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          level: step['level'] as int? ?? entry.key + 1,
          name: step['name'] as String,
          approvers: List<String>.from(step['approvers'] ?? []),
          requireAll: step['requireAll'] as bool? ?? false,
          condition: step['condition'] as String?,
        );
      }).toList();

      return AiGenerationResult(
        templateName: templateName,
        description: data['description'] as String,
        fields: fields,
        approvalSteps: steps,
        confidence: 0.95,
        source: 'ai',
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
}
