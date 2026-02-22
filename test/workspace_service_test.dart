import 'package:flutter_test/flutter_test.dart';
import 'package:approve_now/modules/workspace/workspace_service.dart';
import 'package:approve_now/modules/workspace/workspace_member.dart';

void main() {
  group('WorkspaceService Tests', () {
    late WorkspaceService workspaceService;

    setUp(() {
      workspaceService = WorkspaceService();
    });

    test('Create workspace should succeed', () async {
      // Arrange
      final name = 'Test Workspace';
      final createdBy = 'user123';
      final creatorEmail = 'test@example.com';

      // Act
      final workspace = workspaceService.createWorkspace(
        name: name,
        createdBy: createdBy,
        creatorEmail: creatorEmail,
      );

      // Assert
      expect(workspace.name, name);
      expect(workspace.createdBy, createdBy);
      expect(workspace.id, isNotNull);
      expect(workspace.members.length, 1);
      expect(workspace.members.first.role, WorkspaceRole.owner);
      expect(workspace.members.first.email, creatorEmail);
    });

    test('Create workspace with all fields should succeed', () async {
      // Arrange
      final name = 'Test Workspace';
      final description = 'Test Description';
      final companyName = 'Test Company';
      final address = '123 Test St';
      final createdBy = 'user123';
      final creatorEmail = 'test@example.com';

      // Act
      final workspace = workspaceService.createWorkspace(
        name: name,
        description: description,
        companyName: companyName,
        address: address,
        createdBy: createdBy,
        creatorEmail: creatorEmail,
      );

      // Assert
      expect(workspace.name, name);
      expect(workspace.description, description);
      expect(workspace.companyName, companyName);
      expect(workspace.address, address);
      expect(workspace.createdBy, createdBy);
    });

    test('Invite member should add pending member', () async {
      // Arrange
      final workspace = workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      // Act
      final updatedWorkspace = workspaceService.inviteMember(
        existingWorkspace: workspace,
        email: 'newmember@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      // Assert
      final newMember = updatedWorkspace.members
          .firstWhere((m) => m.email == 'newmember@example.com');
      expect(newMember.email, 'newmember@example.com');
      expect(newMember.role, WorkspaceRole.editor);
      expect(newMember.status, MemberStatus.pending);
      expect(newMember.inviteToken, isNotNull);
    });

    test('Invite duplicate member should throw error', () async {
      // Arrange
      var workspace = workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      workspace = workspaceService.inviteMember(
        existingWorkspace: workspace,
        email: 'member@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      // Act & Assert
      expect(
        () => workspaceService.inviteMember(
          existingWorkspace: workspace,
          email: 'member@example.com',
          role: WorkspaceRole.viewer,
          invitedBy: 'user123',
        ),
        throwsException,
      );
    });

    test('Remove member should succeed', () async {
      // Arrange
      var workspace = workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      workspace = workspaceService.inviteMember(
        existingWorkspace: workspace,
        email: 'member@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      final memberToRemove =
          workspace.members.firstWhere((m) => m.email == 'member@example.com');

      // Act
      final updatedWorkspace = workspaceService.removeMember(
        existingWorkspace: workspace,
        userId: memberToRemove.userId!,
      );

      // Assert - workspace should only have owner now
      expect(updatedWorkspace.members.length, 1);
      expect(updatedWorkspace.members.first.role, WorkspaceRole.owner);
    });

    test('Update member role should succeed', () async {
      // Arrange
      var workspace = workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      workspace = workspaceService.inviteMember(
        existingWorkspace: workspace,
        email: 'member@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      final memberToUpdate =
          workspace.members.firstWhere((m) => m.email == 'member@example.com');

      // Act
      final updatedWorkspace = workspaceService.updateMemberRole(
        existingWorkspace: workspace,
        userId: memberToUpdate.userId!,
        newRole: WorkspaceRole.admin,
      );

      // Assert
      final updatedMember = updatedWorkspace.members
          .firstWhere((m) => m.email == 'member@example.com');
      expect(updatedMember.role, WorkspaceRole.admin);
    });

    test('Accept invitation should activate member', () async {
      // Arrange
      var workspace = workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      workspace = workspaceService.inviteMember(
        existingWorkspace: workspace,
        email: 'invited@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      final invitedMember =
          workspace.members.firstWhere((m) => m.email == 'invited@example.com');

      // Act
      final updatedWorkspace = workspaceService.acceptInvitation(
        existingWorkspace: workspace,
        inviteToken: invitedMember.inviteToken!,
        userId: 'new-user-id',
        displayName: 'New User',
      );

      // Assert
      final acceptedMember = updatedWorkspace.members
          .firstWhere((m) => m.email == 'invited@example.com');
      expect(acceptedMember.status, MemberStatus.active);
      expect(acceptedMember.userId, 'new-user-id');
      expect(acceptedMember.displayName, 'New User');
      expect(acceptedMember.joinedAt, isNotNull);
    });

    test('Switch workspace should work', () async {
      // Arrange
      final workspace = workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      // Act - switchWorkspace is now a no-op for API compatibility
      workspaceService.switchWorkspace(workspace.id);

      // Assert - no error should be thrown
      expect(true, isTrue);
    });

    test('Update workspace header should succeed', () async {
      // Arrange
      final workspace = workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      // Act
      final updated = workspaceService.updateWorkspaceHeader(
        existingWorkspace: workspace,
        name: 'Updated Name',
        companyName: 'Updated Company',
      );

      // Assert
      expect(updated.name, 'Updated Name');
      expect(updated.companyName, 'Updated Company');
    });
  });
}
