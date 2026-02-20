import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import 'workspace_models.dart';

class WorkspaceRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveWorkspaces(List<Workspace> workspaces) async {
    final prefs = await _preferences;
    final workspacesJson = workspaces.map((w) => w.toJson()).toList();
    await prefs.setString('workspaces', jsonEncode(workspacesJson));
  }

  Future<List<Workspace>> getWorkspaces() async {
    final prefs = await _preferences;
    final workspacesJson = prefs.getString('workspaces');
    if (workspacesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(workspacesJson);
      return decoded.map((json) => Workspace.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCurrentWorkspace(Workspace workspace) async {
    final prefs = await _preferences;
    await prefs.setString(
        AppConstants.currentWorkspaceKey, jsonEncode(workspace.toJson()));
  }

  Future<Workspace?> getCurrentWorkspace() async {
    final prefs = await _preferences;
    final workspaceJson = prefs.getString(AppConstants.currentWorkspaceKey);
    if (workspaceJson == null) return null;

    try {
      return Workspace.fromJson(jsonDecode(workspaceJson));
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCurrentWorkspace() async {
    final prefs = await _preferences;
    await prefs.remove(AppConstants.currentWorkspaceKey);
  }

  Future<void> addWorkspace(Workspace workspace) async {
    final workspaces = await getWorkspaces();
    workspaces.add(workspace);
    await saveWorkspaces(workspaces);
  }

  Future<void> updateWorkspace(Workspace workspace) async {
    final workspaces = await getWorkspaces();
    final index = workspaces.indexWhere((w) => w.id == workspace.id);
    if (index != -1) {
      workspaces[index] = workspace;
      await saveWorkspaces(workspaces);
    }
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    final workspaces = await getWorkspaces();
    workspaces.removeWhere((w) => w.id == workspaceId);
    await saveWorkspaces(workspaces);
  }
}
