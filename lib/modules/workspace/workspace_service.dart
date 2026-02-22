import 'dart:math';
import 'workspace_models.dart';
import 'workspace_member.dart';

/// WorkspaceService - Stateless business logic for workspace management
///
/// This service is now stateless. All data operations are performed on objects
/// passed as parameters. Data persistence is handled by WorkspaceRepository.
class WorkspaceService {
  // Create new workspace
  Workspace createWorkspace({
    required String name,
    String? description,
    String? companyName,
    String? address,
    required String createdBy,
    required String creatorEmail,
  }) {
    return Workspace(
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
  }

  // Update workspace header info
  Workspace updateWorkspaceHeader({
    required Workspace existingWorkspace,
    String? name,
    String? description,
    String? logoUrl,
    String? companyName,
    String? address,
    String? footerText,
  }) {
    return existingWorkspace.copyWith(
      name: name,
      description: description,
      logoUrl: logoUrl,
      companyName: companyName,
      address: address,
      footerText: footerText,
      updatedAt: DateTime.now(),
    );
  }

  // Switch active workspace - no longer maintains state, handled by provider
  void switchWorkspace(String workspaceId) {
    // State is managed by WorkspaceProvider, this method is a no-op
    // kept for API compatibility
  }

  // Invite member to workspace
  Workspace inviteMember({
    required Workspace existingWorkspace,
    required String email,
    required WorkspaceRole role,
    required String invitedBy,
  }) {
    // Check if member already exists
    final existingMember = existingWorkspace.getMemberByEmail(email);
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

    final updatedMembers = [...existingWorkspace.members, newMember];
    return existingWorkspace.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
  }

  // Accept invitation
  Workspace acceptInvitation({
    required Workspace existingWorkspace,
    required String inviteToken,
    required String userId,
    String? displayName,
    String? photoUrl,
  }) {
    final memberIndex = existingWorkspace.members.indexWhere(
      (m) => m.inviteToken == inviteToken && m.status == MemberStatus.pending,
    );

    if (memberIndex == -1) {
      throw Exception('Invalid or expired invitation');
    }

    final updatedMembers =
        List<WorkspaceMember>.from(existingWorkspace.members);
    updatedMembers[memberIndex] = updatedMembers[memberIndex].copyWith(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      status: MemberStatus.active,
      joinedAt: DateTime.now(),
    );

    return existingWorkspace.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
  }

  // Remove member from workspace
  Workspace removeMember({
    required Workspace existingWorkspace,
    required String userId,
  }) {
    final updatedMembers =
        existingWorkspace.members.where((m) => m.userId != userId).toList();

    return existingWorkspace.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
  }

  // Update member role
  Workspace updateMemberRole({
    required Workspace existingWorkspace,
    required String userId,
    required WorkspaceRole newRole,
  }) {
    final memberIndex = existingWorkspace.members.indexWhere(
      (m) => m.userId == userId,
    );

    if (memberIndex == -1) {
      throw Exception('Member not found');
    }

    final updatedMembers =
        List<WorkspaceMember>.from(existingWorkspace.members);
    updatedMembers[memberIndex] = updatedMembers[memberIndex].copyWith(
      role: newRole,
    );

    return existingWorkspace.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
  }

  // Cancel pending invitation
  Workspace cancelInvitation({
    required Workspace existingWorkspace,
    required String userId,
  }) {
    final updatedMembers = existingWorkspace.members
        .where((m) => !(m.userId == userId && m.status == MemberStatus.pending))
        .toList();

    return existingWorkspace.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  String _generateInviteToken() {
    return '${_generateId()}_${Random().nextInt(999999).toString().padLeft(6, '0')}';
  }
}
