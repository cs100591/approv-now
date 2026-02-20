import 'package:flutter/foundation.dart';
import 'template_models.dart';
import 'template_service.dart';
import 'template_repository.dart';

class TemplateProvider extends ChangeNotifier {
  final TemplateService _templateService;
  final TemplateRepository _templateRepository;

  TemplateState _state = const TemplateState();

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
    await loadTemplates();
  }

  Future<void> loadTemplates() async {
    _setLoading(true);

    try {
      final templates = await _templateRepository.getTemplates();
      _state = _state.copyWith(templates: templates);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadTemplatesByWorkspace(String workspaceId) async {
    _setLoading(true);

    try {
      final templates =
          await _templateRepository.getTemplatesByWorkspace(workspaceId);
      _state = _state.copyWith(templates: templates);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> createTemplate({
    required String workspaceId,
    required String name,
    String? description,
    required String createdBy,
  }) async {
    _setLoading(true);

    try {
      final template = await _templateService.createTemplate(
        workspaceId: workspaceId,
        name: name,
        description: description,
        createdBy: createdBy,
      );

      await _templateRepository.addTemplate(template);

      final templates = [..._state.templates, template];
      _state = _state.copyWith(templates: templates);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> updateTemplate({
    required String templateId,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    _setLoading(true);

    try {
      final template = await _templateService.updateTemplate(
        templateId: templateId,
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
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
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
      final template = await _templateService.addField(
        templateId: templateId,
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
    }

    _setLoading(false);
  }

  Future<void> removeField({
    required String templateId,
    required String fieldId,
  }) async {
    _setLoading(true);

    try {
      final template = await _templateService.removeField(
        templateId: templateId,
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
    }

    _setLoading(false);
  }

  Future<void> reorderFields({
    required String templateId,
    required List<String> fieldIds,
  }) async {
    _setLoading(true);

    try {
      final template = await _templateService.reorderFields(
        templateId: templateId,
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
    }

    _setLoading(false);
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
      final template = await _templateService.addApprovalStep(
        templateId: templateId,
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
    }

    _setLoading(false);
  }

  Future<void> removeApprovalStep({
    required String templateId,
    required String stepId,
  }) async {
    _setLoading(true);

    try {
      final template = await _templateService.removeApprovalStep(
        templateId: templateId,
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
    }

    _setLoading(false);
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
      final template = await _templateRepository.getTemplateById(templateId);
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
      await _templateService.deleteTemplate(templateId);
      await _templateRepository.deleteTemplate(templateId);

      final templates =
          _state.templates.where((t) => t.id != templateId).toList();
      _state = _state.copyWith(
        templates: templates,
        selectedTemplate: _state.selectedTemplate?.id == templateId
            ? null
            : _state.selectedTemplate,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
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
}
