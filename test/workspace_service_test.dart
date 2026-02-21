import 'package:flutter_test/flutter_test.dart';
import 'package:approve_now/modules/workspace/workspace_service.dart';
import 'package:approve_now/modules/workspace/workspace_models.dart';
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
      final workspace = await workspaceService.createWorkspace(
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
      final workspace = await workspaceService.createWorkspace(
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
      final workspace = await workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      // Act
      final member = await workspaceService.inviteMember(
        workspaceId: workspace.id,
        email: 'newmember@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      // Assert
      expect(member.email, 'newmember@example.com');
      expect(member.role, WorkspaceRole.editor);
      expect(member.status, MemberStatus.pending);
      expect(member.inviteToken, isNotNull);
    });

    test('Invite duplicate member should throw error', () async {
      // Arrange
      final workspace = await workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      await workspaceService.inviteMember(
        workspaceId: workspace.id,
        email: 'member@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      // Act & Assert
      expect(
        () => workspaceService.inviteMember(
          workspaceId: workspace.id,
          email: 'member@example.com',
          role: WorkspaceRole.viewer,
          invitedBy: 'user123',
        ),
        throwsException,
      );
    });

    test('Remove member should succeed', () async {
      // Arrange
      final workspace = await workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      final member = await workspaceService.inviteMember(
        workspaceId: workspace.id,
        email: 'member@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      // Act
      await workspaceService.removeMember(workspace.id, member.userId!);

      // Assert - workspace should only have owner now
      final updatedWorkspaces = workspaceService.getWorkspaces();
      expect(updatedWorkspaces.first.members.length, 1);
    });

    test('Update member role should succeed', () async {
      // Arrange
      final workspace = await workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      final member = await workspaceService.inviteMember(
        workspaceId: workspace.id,
        email: 'member@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      // Act
      final updatedMember = await workspaceService.updateMemberRole(
        workspaceId: workspace.id,
        userId: member.userId!,
        newRole: WorkspaceRole.admin,
      );

      // Assert
      expect(updatedMember.role, WorkspaceRole.admin);
    });

    test('Accept invitation should activate member', () async {
      // Arrange
      final workspace = await workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      final member = await workspaceService.inviteMember(
        workspaceId: workspace.id,
        email: 'invited@example.com',
        role: WorkspaceRole.editor,
        invitedBy: 'user123',
      );

      // Act
      final acceptedMember = await workspaceService.acceptInvitation(
        workspaceId: workspace.id,
        inviteToken: member.inviteToken!,
        userId: 'new-user-id',
        displayName: 'New User',
      );

      // Assert
      expect(acceptedMember.status, MemberStatus.active);
      expect(acceptedMember.userId, 'new-user-id');
      expect(acceptedMember.displayName, 'New User');
      expect(acceptedMember.joinedAt, isNotNull);
    });

    test('Switch workspace should set current workspace', () async {
      // Arrange
      final workspace = await workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      // Act
      await workspaceService.switchWorkspace(workspace.id);

      // Assert
      expect(workspaceService.currentWorkspace?.id, workspace.id);
    });

    test('Update workspace header should succeed', () async {
      // Arrange
      final workspace = await workspaceService.createWorkspace(
        name: 'Test Workspace',
        createdBy: 'user123',
        creatorEmail: 'owner@example.com',
      );

      // Act
      final updated = await workspaceService.updateWorkspaceHeader(
        workspaceId: workspace.id,
        name: 'Updated Name',
        companyName: 'Updated Company',
      );

      // Assert
      expect(updated.name, 'Updated Name');
      expect(updated.companyName, 'Updated Company');
    });
  });
}
