import 'workspace_member.dart';

/// Centralized permission checking service
/// All permission checks should go through this class
class PermissionGuard {
  // ==================== Member Management ====================

  /// Check if user can invite new members
  static bool canInviteMembers(WorkspaceRole? role) {
    if (role == null) return false;
    return role == WorkspaceRole.owner || role == WorkspaceRole.admin;
  }

  /// Check if user can remove members
  static bool canRemoveMembers(
      WorkspaceRole? role, String targetUserId, String currentUserId) {
    if (role == null) return false;
    // Cannot remove yourself through this method
    if (targetUserId == currentUserId) return false;
    // Owner can remove anyone
    if (role == WorkspaceRole.owner) return true;
    // Admin can remove editors and viewers
    if (role == WorkspaceRole.admin) return true;
    return false;
  }

  /// Check if user can change member roles
  static bool canManageRoles(WorkspaceRole? role) {
    if (role == null) return false;
    // Only owner can manage roles
    return role == WorkspaceRole.owner;
  }

  /// Check if user can change specific member's role
  static bool canChangeMemberRole(
    WorkspaceRole? currentRole,
    WorkspaceRole? targetMemberRole,
    WorkspaceRole newRole,
  ) {
    if (currentRole == null) return false;

    // Only owner can change roles
    if (currentRole != WorkspaceRole.owner) return false;

    // Cannot change owner's role
    if (targetMemberRole == WorkspaceRole.owner) return false;

    // Valid role transitions
    return true;
  }

  // ==================== Template Management ====================

  /// Check if user can create templates
  static bool canCreateTemplate(WorkspaceRole? role) {
    if (role == null) return false;
    return role != WorkspaceRole.viewer;
  }

  /// Check if user can edit templates
  static bool canEditTemplate(WorkspaceRole? role) {
    if (role == null) return false;
    return role == WorkspaceRole.owner || role == WorkspaceRole.admin;
  }

  /// Check if user can delete templates
  static bool canDeleteTemplate(
    WorkspaceRole? role,
    String templateOwnerId,
    String currentUserId,
  ) {
    if (role == null) return false;
    // Owner and admin can delete any template
    if (role == WorkspaceRole.owner || role == WorkspaceRole.admin) return true;
    // Template creator can delete their own
    if (templateOwnerId == currentUserId) return true;
    return false;
  }

  /// Check if user can view templates
  static bool canViewTemplate(WorkspaceRole? role) {
    // All roles can view templates
    return role != null;
  }

  // ==================== Request Management ====================

  /// Check if user can create requests
  static bool canCreateRequest(WorkspaceRole? role) {
    if (role == null) return false;
    return role != WorkspaceRole.viewer;
  }

  /// Check if user can approve/reject requests
  static bool canApproveRequest(WorkspaceRole? role) {
    if (role == null) return false;
    return role != WorkspaceRole.viewer;
  }

  /// Check if user can view all requests in workspace
  static bool canViewAllRequests(WorkspaceRole? role) {
    // All members can view requests
    return role != null;
  }

  // ==================== Workspace Management ====================

  /// Check if user can manage workspace settings
  static bool canManageWorkspace(WorkspaceRole? role) {
    if (role == null) return false;
    return role == WorkspaceRole.owner;
  }

  /// Check if user can delete workspace
  static bool canDeleteWorkspace(WorkspaceRole? role) {
    if (role == null) return false;
    // Only owner can delete workspace
    return role == WorkspaceRole.owner;
  }

  /// Check if user can update workspace settings
  static bool canUpdateWorkspaceSettings(WorkspaceRole? role) {
    if (role == null) return false;
    return role == WorkspaceRole.owner || role == WorkspaceRole.admin;
  }

  // ==================== Analytics & Reports ====================

  /// Check if user can view analytics
  static bool canViewAnalytics(WorkspaceRole? role) {
    if (role == null) return false;
    return role == WorkspaceRole.owner || role == WorkspaceRole.admin;
  }

  /// Check if user can export reports
  static bool canExportReports(WorkspaceRole? role) {
    if (role == null) return false;
    return role == WorkspaceRole.owner || role == WorkspaceRole.admin;
  }

  // ==================== Permission Exceptions ====================

  /// Get error message for permission denial
  static String getPermissionErrorMessage(String action) {
    return 'You don\'t have permission to $action. Please contact your workspace administrator.';
  }

  /// Assert permission or throw exception
  static void assertPermission(bool hasPermission, String action) {
    if (!hasPermission) {
      throw PermissionDeniedException(getPermissionErrorMessage(action));
    }
  }
}

/// Custom exception for permission denied
class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => message;
}
