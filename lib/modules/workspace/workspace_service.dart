import 'dart:math';
import 'workspace_models.dart';

/// WorkspaceService - Business logic for workspace management
class WorkspaceService {
  final List<Workspace> _workspaces = [];
  Workspace? _currentWorkspace;

  // Get all workspaces
  List<Workspace> getWorkspaces() {
    return List.unmodifiable(_workspaces);
  }

  // Get current workspace
  Workspace? get currentWorkspace => _currentWorkspace;

  // Create new workspace
  Future<Workspace> createWorkspace({
    required String name,
    String? description,
    String? companyName,
    String? address,
    required String createdBy,
  }) async {
    final workspace = Workspace(
      id: _generateId(),
      name: name,
      description: description,
      companyName: companyName,
      address: address,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      members: [createdBy],
    );

    _workspaces.add(workspace);
    return workspace;
  }

  // Update workspace header info
  Future<Workspace> updateWorkspaceHeader({
    required String workspaceId,
    String? name,
    String? description,
    String? logoUrl,
    String? companyName,
    String? address,
    String? footerText,
  }) async {
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) {
      throw Exception('Workspace not found');
    }

    final updated = _workspaces[index].copyWith(
      name: name,
      description: description,
      logoUrl: logoUrl,
      companyName: companyName,
      address: address,
      footerText: footerText,
      updatedAt: DateTime.now(),
    );

    _workspaces[index] = updated;

    if (_currentWorkspace?.id == workspaceId) {
      _currentWorkspace = updated;
    }

    return updated;
  }

  // Switch active workspace
  Future<void> switchWorkspace(String workspaceId) async {
    final workspace = _workspaces.firstWhere(
      (w) => w.id == workspaceId,
      orElse: () => throw Exception('Workspace not found'),
    );
    _currentWorkspace = workspace;
  }

  // Get pending approval count for current workspace
  Future<int> getPendingApprovalCount() async {
    // This would query the request module in real implementation
    // Returning mock data for now
    return 0;
  }

  // Delete workspace
  Future<void> deleteWorkspace(String workspaceId) async {
    _workspaces.removeWhere((w) => w.id == workspaceId);
    if (_currentWorkspace?.id == workspaceId) {
      _currentWorkspace = null;
    }
  }

  // Add member to workspace
  Future<void> addMember(String workspaceId, String userId) async {
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) return;

    final members = List<String>.from(_workspaces[index].members);
    if (!members.contains(userId)) {
      members.add(userId);
      _workspaces[index] = _workspaces[index].copyWith(members: members);
    }
  }

  // Remove member from workspace
  Future<void> removeMember(String workspaceId, String userId) async {
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) return;

    final members = List<String>.from(_workspaces[index].members);
    members.remove(userId);
    _workspaces[index] = _workspaces[index].copyWith(members: members);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
