import 'dart:math';
import 'workspace_models.dart';
import 'workspace_member.dart';

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
    required String creatorEmail,
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
      members: [
        WorkspaceMember(
          userId: createdBy,
          email: creatorEmail,
          role: WorkspaceRole.owner,
          status: MemberStatus.active,
          invitedAt: DateTime.now(),
          joinedAt: DateTime.now(),
          invitedBy: createdBy,
        ),
      ],
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

  // Invite member to workspace
  Future<WorkspaceMember> inviteMember({
    required String workspaceId,
    required String email,
    required WorkspaceRole role,
    required String invitedBy,
  }) async {
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) {
      throw Exception('Workspace not found');
    }

    // Check if member already exists
    final existingMember = _workspaces[index].getMemberByEmail(email);
    if (existingMember != null) {
      throw Exception('Member already exists in workspace');
    }

    final inviteToken = _generateInviteToken();
    final newMember = WorkspaceMember(
      userId: _generateId(), // Temporary ID until user accepts
      email: email,
      role: role,
      status: MemberStatus.pending,
      invitedAt: DateTime.now(),
      invitedBy: invitedBy,
      inviteToken: inviteToken,
    );

    final members = List<WorkspaceMember>.from(_workspaces[index].members);
    members.add(newMember);
    _workspaces[index] = _workspaces[index].copyWith(members: members);

    return newMember;
  }

  // Accept invitation
  Future<WorkspaceMember> acceptInvitation({
    required String workspaceId,
    required String inviteToken,
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) {
      throw Exception('Workspace not found');
    }

    final memberIndex = _workspaces[index].members.indexWhere(
          (m) =>
              m.inviteToken == inviteToken && m.status == MemberStatus.pending,
        );

    if (memberIndex == -1) {
      throw Exception('Invalid or expired invitation');
    }

    final updatedMember = _workspaces[index].members[memberIndex].copyWith(
          userId: userId,
          displayName: displayName,
          photoUrl: photoUrl,
          status: MemberStatus.active,
          joinedAt: DateTime.now(),
        );

    final members = List<WorkspaceMember>.from(_workspaces[index].members);
    members[memberIndex] = updatedMember;
    _workspaces[index] = _workspaces[index].copyWith(members: members);

    return updatedMember;
  }

  // Remove member from workspace
  Future<void> removeMember(String workspaceId, String userId) async {
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) return;

    final members = List<WorkspaceMember>.from(_workspaces[index].members);
    members.removeWhere((m) => m.userId == userId);
    _workspaces[index] = _workspaces[index].copyWith(members: members);
  }

  // Update member role
  Future<WorkspaceMember> updateMemberRole({
    required String workspaceId,
    required String userId,
    required WorkspaceRole newRole,
  }) async {
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) {
      throw Exception('Workspace not found');
    }

    final memberIndex = _workspaces[index].members.indexWhere(
          (m) => m.userId == userId,
        );

    if (memberIndex == -1) {
      throw Exception('Member not found');
    }

    final updatedMember = _workspaces[index].members[memberIndex].copyWith(
          role: newRole,
        );

    final members = List<WorkspaceMember>.from(_workspaces[index].members);
    members[memberIndex] = updatedMember;
    _workspaces[index] = _workspaces[index].copyWith(members: members);

    return updatedMember;
  }

  // Cancel pending invitation
  Future<void> cancelInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    final index = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (index == -1) return;

    final members = List<WorkspaceMember>.from(_workspaces[index].members);
    members.removeWhere(
        (m) => m.userId == userId && m.status == MemberStatus.pending);
    _workspaces[index] = _workspaces[index].copyWith(members: members);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  String _generateInviteToken() {
    return '${_generateId()}_${Random().nextInt(999999).toString().padLeft(6, '0')}';
  }
}
