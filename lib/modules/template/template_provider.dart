import 'dart:async';
import 'package:flutter/foundation.dart';
import 'template_models.dart';
import 'template_service.dart';
import 'template_repository.dart';
import '../../core/utils/app_logger.dart';

class TemplateProvider extends ChangeNotifier {
  final TemplateService _templateService;
  final TemplateRepository _templateRepository;

  TemplateState _state = const TemplateState();
  StreamSubscription<List<Template>>? _templatesSubscription;
  String? _currentWorkspaceId;

  TemplateProvider({
    required TemplateService templateService,
    required TemplateRepository templateRepository,
  })  : _templateService = templateService,
        _templateRepository = templateRepository {
    _initialize();
  }

  TemplateState get state => _state;
  List<Template> get templates => _state.templates;
  Template? get selectedTemplate => _state.selectedTemplate;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  Future<void> _initialize() async {
    // Don't load templates on init - wait for workspace to be selected
  }

  /// Set current workspace and subscribe to its templates
  void setCurrentWorkspace(String? workspaceId) {
    if (_currentWorkspaceId == workspaceId) return;

    _currentWorkspaceId = workspaceId;
    _cancelSubscription();

    if (workspaceId != null) {
      _subscribeToTemplates(workspaceId);
    } else {
      _state = const TemplateState();
      notifyListeners();
    }
  }

  void _cancelSubscription() {
    _templatesSubscription?.cancel();
    _templatesSubscription = null;
  }

  void _subscribeToTemplates(String workspaceId) {
    _templatesSubscription =
        _templateRepository.streamTemplatesByWorkspace(workspaceId).listen(
      (templates) {
        _state = _state.copyWith(templates: templates);
        notifyListeners();
        AppLogger.info(
            'Loaded ${templates.length} templates for workspace: $workspaceId');
      },
      onError: (error) {
        AppLogger.error('Error loading templates', error);
        _state = _state.copyWith(error: error.toString());
        notifyListeners();
      },
    );
  }

  /// Load templates for workspace (manual refresh)
  Future<void> loadTemplates() async {
    if (_currentWorkspaceId == null) {
      AppLogger.warning('Cannot load templates: no workspace selected');
      return;
    }

    _setLoading(true);

    try {
      final templates = await _templateRepository
          .getTemplatesByWorkspace(_currentWorkspaceId!);
      _state = _state.copyWith(templates: templates);
      AppLogger.info('Manually loaded ${templates.length} templates');
    } catch (e) {
      AppLogger.error('Error loading templates', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }

    _setLoading(false);
  }

  Future<void> loadTemplatesByWorkspace(String workspaceId) async {
    _currentWorkspaceId = workspaceId;
    _cancelSubscription();
    _setLoading(true);

    try {
      final templates =
          await _templateRepository.getTemplatesByWorkspace(workspaceId);
      _state = _state.copyWith(templates: templates);
      _subscribeToTemplates(workspaceId);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }

    _setLoading(false);
  }

  Future<Template?> createTemplate({
    required String workspaceId,
    required String name,
    String? description,
    required String createdBy,
  }) async {
    _setLoading(true);

    try {
      final template = _templateService.createTemplate(
        workspaceId: workspaceId,
        name: name,
        description: description,
        createdBy: createdBy,
      );

      await _templateRepository.createTemplate(template);

      // Immediately refresh templates list to show new template
      await loadTemplatesByWorkspace(workspaceId);

      AppLogger.info('Created template: ${template.id}');
      return template;
    } catch (e) {
      AppLogger.error('Error creating template', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Create template with all fields and approval steps in one operation
  Future<Template?> createTemplateWithFields({
    required String workspaceId,
    required String name,
    String? description,
    required String createdBy,
    required List<TemplateField> fields,
    required List<ApprovalStep> approvalSteps,
  }) async {
    _setLoading(true);

    try {
      // Create template with all data at once
      final template = Template(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workspaceId: workspaceId,
        name: name,
        description: description,
        fields: fields,
        approvalSteps: approvalSteps,
        isActive: true,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _templateRepository.createTemplate(template);

      // Immediately refresh templates list to show new template
      await loadTemplatesByWorkspace(workspaceId);

      AppLogger.info(
          'Created template with ${fields.length} fields and ${approvalSteps.length} steps: ${template.id}');
      return template;
    } catch (e) {
      AppLogger.error('Error creating template with fields', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTemplate({
    required String templateId,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    _setLoading(true);

    try {
      // Find existing template from state
      final existingTemplate = _state.templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found: $templateId'),
      );

      final template = _templateService.updateTemplate(
        existingTemplate: existingTemplate,
        name: name,
        description: description,
        isActive: isActive,
      );

      await _templateRepository.updateTemplate(template);

      final templates = _state.templates
          .map((t) => t.id == templateId ? template : t)
          .toList();

      _state = _state.copyWith(
        templates: templates,
        selectedTemplate: _state.selectedTemplate?.id == templateId
            ? template
            : _state.selectedTemplate,
      );

      AppLogger.info('Updated template: $templateId');
    } catch (e) {
      AppLogger.error('Error updating template', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addField({
    required String templateId,
    required String name,
    required String label,
    required FieldType type,
    bool required = false,
    String? placeholder,
    List<String>? options,
    Map<String, dynamic> validation = const {},
  }) async {
    _setLoading(true);

    try {
      // Find existing template from state
      final existingTemplate = _state.templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found: $templateId'),
      );

      final template = _templateService.addField(
        existingTemplate: existingTemplate,
        name: name,
        label: label,
        type: type,
        required: required,
        placeholder: placeholder,
        options: options,
        validation: validation,
      );

      await _templateRepository.updateTemplate(template);

      final templates = _state.templates
          .map((t) => t.id == templateId ? template : t)
          .toList();

      _state = _state.copyWith(
        templates: templates,
        selectedTemplate: template,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeField({
    required String templateId,
    required String fieldId,
  }) async {
    _setLoading(true);

    try {
      // Find existing template from state
      final existingTemplate = _state.templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found: $templateId'),
      );

      final template = _templateService.removeField(
        existingTemplate: existingTemplate,
        fieldId: fieldId,
      );

      await _templateRepository.updateTemplate(template);

      final templates = _state.templates
          .map((t) => t.id == templateId ? template : t)
          .toList();

      _state = _state.copyWith(
        templates: templates,
        selectedTemplate: template,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reorderFields({
    required String templateId,
    required List<String> fieldIds,
  }) async {
    _setLoading(true);

    try {
      // Find existing template from state
      final existingTemplate = _state.templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found: $templateId'),
      );

      final template = _templateService.reorderFields(
        existingTemplate: existingTemplate,
        fieldIds: fieldIds,
      );

      await _templateRepository.updateTemplate(template);

      final templates = _state.templates
          .map((t) => t.id == templateId ? template : t)
          .toList();

      _state = _state.copyWith(
        templates: templates,
        selectedTemplate: template,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addApprovalStep({
    required String templateId,
    required String name,
    required List<String> approvers,
    bool requireAll = false,
    String? condition,
  }) async {
    _setLoading(true);

    try {
      // Find existing template from state
      final existingTemplate = _state.templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found: $templateId'),
      );

      final template = _templateService.addApprovalStep(
        existingTemplate: existingTemplate,
        name: name,
        approvers: approvers,
        requireAll: requireAll,
        condition: condition,
      );

      await _templateRepository.updateTemplate(template);

      final templates = _state.templates
          .map((t) => t.id == templateId ? template : t)
          .toList();

      _state = _state.copyWith(
        templates: templates,
        selectedTemplate: template,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeApprovalStep({
    required String templateId,
    required String stepId,
  }) async {
    _setLoading(true);

    try {
      // Find existing template from state
      final existingTemplate = _state.templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found: $templateId'),
      );

      final template = _templateService.removeApprovalStep(
        existingTemplate: existingTemplate,
        stepId: stepId,
      );

      await _templateRepository.updateTemplate(template);

      final templates = _state.templates
          .map((t) => t.id == templateId ? template : t)
          .toList();

      _state = _state.copyWith(
        templates: templates,
        selectedTemplate: template,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Get template by ID from loaded templates (sync)
  Template? getTemplateById(String templateId) {
    try {
      return _state.templates.firstWhere((t) => t.id == templateId);
    } catch (e) {
      return null;
    }
  }

  Future<void> selectTemplate(String templateId) async {
    try {
      final template = await _templateRepository.getTemplate(templateId);
      _state = _state.copyWith(selectedTemplate: template);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    _setLoading(true);

    try {
      // Delete directly via repository (service method removed)
      await _templateRepository.deleteTemplate(templateId);

      final templates =
          _state.templates.where((t) => t.id != templateId).toList();
      _state = _state.copyWith(
        templates: templates,
        selectedTemplate: _state.selectedTemplate?.id == templateId
            ? null
            : _state.selectedTemplate,
      );

      AppLogger.info('Deleted template: $templateId');
    } catch (e) {
      AppLogger.error('Error deleting template', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Get template count for plan enforcement
  Future<int> getTemplateCount(String workspaceId) async {
    try {
      return await _templateRepository.getTemplateCount(workspaceId);
    } catch (e) {
      AppLogger.error('Error getting template count', e);
      return _state.templates.length;
    }
  }

  TemplateValidationResult validateTemplate(Template template) {
    return _templateService.validateTemplate(template);
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}
