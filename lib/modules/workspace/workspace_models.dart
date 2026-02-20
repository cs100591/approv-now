import 'package:equatable/equatable.dart';
import 'workspace_member.dart';

/// Workspace model representing an approval workspace
class Workspace extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? companyName;
  final String? address;
  final String? footerText;
  final String createdBy;
  final String ownerId; // Owner user ID for Firestore queries
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WorkspaceMember> members;
  final List<String>
      memberIds; // Array of member user IDs for Firestore queries
  final String plan; // free, starter, pro, business
  final Map<String, dynamic> settings;

  const Workspace({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.companyName,
    this.address,
    this.footerText,
    required this.createdBy,
    String? ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.members = const [],
    this.memberIds = const [],
    this.plan = 'free',
    this.settings = const {},
  }) : ownerId = ownerId ?? createdBy;

  /// Get owner of the workspace
  WorkspaceMember? get owner {
    try {
      return members.firstWhere((m) => m.role == WorkspaceRole.owner);
    } catch (e) {
      return null;
    }
  }

  /// Get active members only
  List<WorkspaceMember> get activeMembers =>
      members.where((m) => m.isActive).toList();

  /// Get pending invitations
  List<WorkspaceMember> get pendingMembers =>
      members.where((m) => m.isPending).toList();

  /// Check if user is member of workspace
  bool isMember(String userId) =>
      members.any((m) => m.userId == userId && m.isActive);

  /// Get member by user ID
  WorkspaceMember? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Get member by email
  WorkspaceMember? getMemberByEmail(String email) {
    try {
      return members.firstWhere((m) => m.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Get role of a specific user
  WorkspaceRole? getUserRole(String userId) {
    final member = getMember(userId);
    return member?.role;
  }

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? companyName,
    String? address,
    String? footerText,
    String? createdBy,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkspaceMember>? members,
    List<String>? memberIds,
    String? plan,
    Map<String, dynamic>? settings,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      footerText: footerText ?? this.footerText,
      createdBy: createdBy ?? this.createdBy,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
      memberIds: memberIds ?? this.memberIds,
      plan: plan ?? this.plan,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'companyName': companyName,
        'address': address,
        'footerText': footerText,
        'createdBy': createdBy,
        'ownerId': ownerId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'members': members.map((m) => m.toJson()).toList(),
        'memberIds': memberIds,
        'plan': plan,
        'settings': settings,
      };

  factory Workspace.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? [];
    final memberIdsJson = json['memberIds'] as List<dynamic>? ?? [];
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      companyName: json['companyName'] as String?,
      address: json['address'] as String?,
      footerText: json['footerText'] as String?,
      createdBy: json['createdBy'] as String,
      ownerId: json['ownerId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      members: membersJson
          .map((m) => WorkspaceMember.fromJson(m as Map<String, dynamic>))
          .toList(),
      memberIds: memberIdsJson.cast<String>().toList(),
      plan: json['plan'] as String? ?? 'free',
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        companyName,
        address,
        footerText,
        createdBy,
        ownerId,
        createdAt,
        updatedAt,
        members,
        memberIds,
        plan,
        settings
      ];
}

/// Request model for creating/updating workspace
class CreateWorkspaceRequest {
  final String name;
  final String? description;
  final String? companyName;
  final String? address;

  const CreateWorkspaceRequest({
    required this.name,
    this.description,
    this.companyName,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'companyName': companyName,
        'address': address,
      };
}

/// Request model for inviting a member
class InviteMemberRequest {
  final String email;
  final WorkspaceRole role;
  final String invitedBy;

  const InviteMemberRequest({
    required this.email,
    required this.role,
    required this.invitedBy,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role.name,
        'invitedBy': invitedBy,
      };
}

/// Workspace state for provider
class WorkspaceState extends Equatable {
  final List<Workspace> workspaces;
  final Workspace? currentWorkspace;
  final bool isLoading;
  final String? error;

  const WorkspaceState({
    this.workspaces = const [],
    this.currentWorkspace,
    this.isLoading = false,
    this.error,
  });

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    Workspace? currentWorkspace,
    bool? isLoading,
    String? error,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      currentWorkspace: currentWorkspace ?? this.currentWorkspace,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [workspaces, currentWorkspace, isLoading, error];
}
