import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'template_models.dart';

class TemplateRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveTemplates(List<Template> templates) async {
    final prefs = await _preferences;
    final templatesJson = templates.map((t) => t.toJson()).toList();
    await prefs.setString('templates', jsonEncode(templatesJson));
  }

  Future<List<Template>> getTemplates() async {
    final prefs = await _preferences;
    final templatesJson = prefs.getString('templates');
    if (templatesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(templatesJson);
      return decoded.map((json) => Template.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Template>> getTemplatesByWorkspace(String workspaceId) async {
    final templates = await getTemplates();
    return templates.where((t) => t.workspaceId == workspaceId).toList();
  }

  Future<Template?> getTemplateById(String templateId) async {
    final templates = await getTemplates();
    try {
      return templates.firstWhere((t) => t.id == templateId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addTemplate(Template template) async {
    final templates = await getTemplates();
    templates.add(template);
    await saveTemplates(templates);
  }

  Future<void> updateTemplate(Template template) async {
    final templates = await getTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      templates[index] = template;
      await saveTemplates(templates);
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    final templates = await getTemplates();
    templates.removeWhere((t) => t.id == templateId);
    await saveTemplates(templates);
  }

  Future<int> getTemplateCount() async {
    final templates = await getTemplates();
    return templates.length;
  }

  Future<int> getTemplateCountByWorkspace(String workspaceId) async {
    final templates = await getTemplates();
    return templates.where((t) => t.workspaceId == workspaceId).length;
  }
}
