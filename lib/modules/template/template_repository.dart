import 'dart:async';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';
import '../template/template_models.dart';

/// TemplateRepository - Supabase implementation
class TemplateRepository {
  final SupabaseService _supabase;

  TemplateRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  /// Create a new template
  Future<Template> createTemplate(Template template) async {
    try {
      final response = await _supabase.createTemplate(
        workspaceId: template.workspaceId,
        name: template.name,
        description: template.description,
        fields: template.fields.map((f) => f.toJson()).toList(),
        approvalSteps: template.approvalSteps.map((s) => s.toJson()).toList(),
      );

      return _mapToTemplate(response);
    } catch (e) {
      AppLogger.error('Error creating template', e);
      rethrow;
    }
  }

  /// Get template by ID
  Future<Template?> getTemplate(String templateId) async {
    try {
      final response = await _supabase.getTemplate(templateId);
      if (response == null) return null;
      return _mapToTemplate(response);
    } catch (e) {
      AppLogger.error('Error getting template', e);
      rethrow;
    }
  }

  /// Get all templates for a workspace
  Future<List<Template>> getTemplatesByWorkspace(String workspaceId) async {
    try {
      final templates = await _supabase.getTemplates(workspaceId);
      return templates.map(_mapToTemplate).toList();
    } catch (e) {
      AppLogger.error('Error getting templates', e);
      rethrow;
    }
  }

  /// Get template count for workspace
  Future<int> getTemplateCount(String workspaceId) async {
    try {
      final templates = await getTemplatesByWorkspace(workspaceId);
      return templates.length;
    } catch (e) {
      AppLogger.error('Error getting template count', e);
      return 0;
    }
  }

  /// Update template
  Future<void> updateTemplate(Template template) async {
    try {
      await _supabase.updateTemplate(
        template.id,
        {
          'name': template.name,
          'description': template.description,
          'fields': template.fields.map((f) => f.toJson()).toList(),
          'approval_steps':
              template.approvalSteps.map((s) => s.toJson()).toList(),
          'is_active': template.isActive,
        },
      );
    } catch (e) {
      AppLogger.error('Error updating template', e);
      rethrow;
    }
  }

  /// Delete template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _supabase.deleteTemplate(templateId);
    } catch (e) {
      AppLogger.error('Error deleting template', e);
      rethrow;
    }
  }

  /// Stream templates for workspace
  Stream<List<Template>> streamTemplatesByWorkspace(String workspaceId) {
    final controller = StreamController<List<Template>>();

    // Initial fetch
    getTemplatesByWorkspace(workspaceId).then((templates) {
      controller.add(templates);
    }).catchError((error) {
      controller.addError(error);
    });

    // Refresh every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final templates = await getTemplatesByWorkspace(workspaceId);
        if (!controller.isClosed) {
          controller.add(templates);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });

    return controller.stream;
  }

  /// Map Supabase response to Template model
  Template _mapToTemplate(Map<String, dynamic> json) {
    final fieldsJson = json['fields'] as List<dynamic>? ?? [];
    final stepsJson = json['approval_steps'] as List<dynamic>? ?? [];

    return Template(
      id: json['id'].toString(),
      workspaceId: json['workspace_id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      fields: fieldsJson
          .map((f) => TemplateField.fromJson(f as Map<String, dynamic>))
          .toList(),
      approvalSteps: stepsJson
          .map((s) => ApprovalStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
