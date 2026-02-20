/// Workspace member role definitions
enum WorkspaceRole {
  owner, // Full permissions + can delete workspace
  admin, // Can manage members + create templates + approve
  editor, // Can create requests + approve
  viewer, // Read-only access
}

/// Member invitation status
enum MemberStatus {
  pending, // Invited but not yet accepted
  active, // Accepted and active
  inactive, // Disabled/blocked
}

/// Extension methods for WorkspaceRole
extension WorkspaceRoleExtension on WorkspaceRole {
  String get displayName {
    switch (this) {
      case WorkspaceRole.owner:
        return 'Owner';
      case WorkspaceRole.admin:
        return 'Admin';
      case WorkspaceRole.editor:
        return 'Editor';
      case WorkspaceRole.viewer:
        return 'Viewer';
    }
  }

  String get description {
    switch (this) {
      case WorkspaceRole.owner:
        return 'Full control including deletion';
      case WorkspaceRole.admin:
        return 'Can manage members and templates';
      case WorkspaceRole.editor:
        return 'Can create and approve requests';
      case WorkspaceRole.viewer:
        return 'View only access';
    }
  }

  int get permissionLevel {
    switch (this) {
      case WorkspaceRole.owner:
        return 4;
      case WorkspaceRole.admin:
        return 3;
      case WorkspaceRole.editor:
        return 2;
      case WorkspaceRole.viewer:
        return 1;
    }
  }
}

/// Extension methods for MemberStatus
extension MemberStatusExtension on MemberStatus {
  String get displayName {
    switch (this) {
      case MemberStatus.pending:
        return 'Pending';
      case MemberStatus.active:
        return 'Active';
      case MemberStatus.inactive:
        return 'Inactive';
    }
  }
}

/// Represents a member of a workspace
class WorkspaceMember {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final WorkspaceRole role;
  final MemberStatus status;
  final DateTime invitedAt;
  final DateTime? joinedAt;
  final String invitedBy; // User ID of inviter
  final String? inviteToken; // For accepting invitation

  const WorkspaceMember({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.status,
    required this.invitedAt,
    this.joinedAt,
    required this.invitedBy,
    this.inviteToken,
  });

  /// Check if member is active
  bool get isActive => status == MemberStatus.active;

  /// Check if member has pending invitation
  bool get isPending => status == MemberStatus.pending;

  /// Check if member can manage other members
  bool get canManageMembers =>
      role == WorkspaceRole.owner || role == WorkspaceRole.admin;

  /// Check if member can create templates
  bool get canCreateTemplate =>
      role == WorkspaceRole.owner ||
      role == WorkspaceRole.admin ||
      role == WorkspaceRole.editor;

  /// Check if member can delete templates
  bool get canDeleteTemplate =>
      role == WorkspaceRole.owner || role == WorkspaceRole.admin;

  /// Check if member can edit templates
  bool get canEditTemplate =>
      role == WorkspaceRole.owner || role == WorkspaceRole.admin;

  /// Check if member can create requests
  bool get canCreateRequest => role != WorkspaceRole.viewer;

  /// Check if member can approve requests
  bool get canApprove => role != WorkspaceRole.viewer;

  /// Check if member can invite others
  bool get canInvite =>
      role == WorkspaceRole.owner || role == WorkspaceRole.admin;

  /// Check if member can manage workspace settings
  bool get canManageWorkspace => role == WorkspaceRole.owner;

  /// Create a copy with modified fields
  WorkspaceMember copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    WorkspaceRole? role,
    MemberStatus? status,
    DateTime? invitedAt,
    DateTime? joinedAt,
    String? invitedBy,
    String? inviteToken,
  }) {
    return WorkspaceMember(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedAt: invitedAt ?? this.invitedAt,
      joinedAt: joinedAt ?? this.joinedAt,
      invitedBy: invitedBy ?? this.invitedBy,
      inviteToken: inviteToken ?? this.inviteToken,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'status': status.name,
      'invitedAt': invitedAt.toIso8601String(),
      'joinedAt': joinedAt?.toIso8601String(),
      'invitedBy': invitedBy,
      'inviteToken': inviteToken,
    };
  }

  /// Create from JSON
  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: WorkspaceRole.values.byName(json['role'] as String),
      status: MemberStatus.values.byName(json['status'] as String),
      invitedAt: DateTime.parse(json['invitedAt'] as String),
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : null,
      invitedBy: json['invitedBy'] as String,
      inviteToken: json['inviteToken'] as String?,
    );
  }

  @override
  String toString() {
    return 'WorkspaceMember(userId: $userId, email: $email, role: $role, status: $status)';
  }
}
