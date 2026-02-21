import 'dart:async';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';
import 'workspace_models.dart';
import 'workspace_member.dart';

/// WorkspaceRepository - Supabase implementation
class WorkspaceRepository {
  final SupabaseService _supabase;

  WorkspaceRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  /// Create a new workspace
  Future<Workspace> createWorkspace(Workspace workspace) async {
    try {
      final response = await _supabase.createWorkspace(
        name: workspace.name,
        description: workspace.description,
        companyName: workspace.companyName,
      );

      return _mapToWorkspace(response);
    } catch (e) {
      AppLogger.error('Error creating workspace', e);
      rethrow;
    }
  }

  /// Get workspace by ID
  Future<Workspace?> getWorkspace(String workspaceId) async {
    try {
      final response = await _supabase.client
          .from('workspaces')
          .select()
          .eq('id', workspaceId)
          .maybeSingle();

      if (response == null) return null;
      return _mapToWorkspace(response);
    } catch (e) {
      AppLogger.error('Error getting workspace', e);
      rethrow;
    }
  }

  /// Get all workspaces for a user
  Future<List<Workspace>> getWorkspacesForUser(String userId) async {
    try {
      final workspaces = await _supabase.getWorkspaces();
      final result = <Workspace>[];

      for (final ws in workspaces) {
        final workspace = _mapToWorkspace(ws);
        // Load members from workspace_members table
        final members = await getMembers(workspace.id);
        result.add(workspace.copyWith(members: members));
      }

      return result;
    } catch (e) {
      AppLogger.error('Error getting workspaces for user', e);
      rethrow;
    }
  }

  /// Check if user has any workspace
  Future<bool> hasWorkspace(String userId) async {
    try {
      final workspaces = await getWorkspacesForUser(userId);
      return workspaces.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking workspace existence', e);
      return false;
    }
  }

  /// Update workspace
  Future<void> updateWorkspace(Workspace workspace) async {
    try {
      await _supabase.updateWorkspace(
        workspace.id,
        {
          'name': workspace.name,
          'description': workspace.description,
          'logo_url': workspace.logoUrl,
          'company_name': workspace.companyName,
          'address': workspace.address,
          'footer_text': workspace.footerText,
          'plan': workspace.plan,
          'settings': workspace.settings,
        },
      );
    } catch (e) {
      AppLogger.error('Error updating workspace', e);
      rethrow;
    }
  }

  /// Delete workspace
  Future<void> deleteWorkspace(String workspaceId) async {
    try {
      await _supabase.deleteWorkspace(workspaceId);
    } catch (e) {
      AppLogger.error('Error deleting workspace', e);
      rethrow;
    }
  }

  /// Stream workspaces for user
  Stream<List<Workspace>> streamWorkspacesForUser(String userId) {
    final controller = StreamController<List<Workspace>>();
    Timer? timer;

    // Initial fetch
    getWorkspacesForUser(userId).then((workspaces) {
      if (!controller.isClosed) {
        controller.add(workspaces);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });

    // Refresh every 30 seconds
    timer = Timer.periodic(const Duration(seconds: 30), (t) async {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      try {
        final workspaces = await getWorkspacesForUser(userId);
        if (!controller.isClosed) {
          controller.add(workspaces);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });

    // Clean up when stream is cancelled
    controller.onCancel = () {
      timer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  /// Add member to workspace
  Future<void> addMember(String workspaceId, dynamic memberOrUserId) async {
    try {
      WorkspaceMember member;
      if (memberOrUserId is String) {
        // If just userId is passed, create a basic member
        member = WorkspaceMember(
          userId: memberOrUserId,
          email: '',
          role: WorkspaceRole.viewer,
          status: MemberStatus.active,
          invitedAt: DateTime.now(),
          invitedBy: '',
        );
      } else if (memberOrUserId is WorkspaceMember) {
        member = memberOrUserId;
      } else {
        throw ArgumentError('memberOrUserId must be String or WorkspaceMember');
      }

      await _supabase.client.from('workspace_members').insert({
        'workspace_id': workspaceId,
        'user_id': member.userId,
        'email': member.email,
        'display_name': member.displayName,
        'photo_url': member.photoUrl,
        'role': member.role.name,
        'status': member.status.name,
        'invited_by': member.invitedBy,
        'invite_token': member.inviteToken,
      });
    } catch (e) {
      AppLogger.error('Error adding member', e);
      rethrow;
    }
  }

  /// Remove member from workspace
  Future<void> removeMember(String workspaceId, String userId) async {
    try {
      await _supabase.client
          .from('workspace_members')
          .delete()
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId);
    } catch (e) {
      AppLogger.error('Error removing member', e);
      rethrow;
    }
  }

  /// Get members of workspace
  Future<List<WorkspaceMember>> getMembers(String workspaceId) async {
    try {
      final response = await _supabase.client
          .from('workspace_members')
          .select()
          .eq('workspace_id', workspaceId);

      return response.map<WorkspaceMember>(_mapToMember).toList();
    } catch (e) {
      AppLogger.error('Error getting members', e);
      rethrow;
    }
  }

  /// Update member role
  Future<void> updateMemberRole(
      String workspaceId, String userId, WorkspaceRole role) async {
    try {
      await _supabase.client
          .from('workspace_members')
          .update({'role': role.name})
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId);
    } catch (e) {
      AppLogger.error('Error updating member role', e);
      rethrow;
    }
  }

  /// Map Supabase response to Workspace model
  Workspace _mapToWorkspace(Map<String, dynamic> json) {
    final memberIds = (json['member_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Workspace(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      companyName: json['company_name']?.toString(),
      address: json['address']?.toString(),
      footerText: json['footer_text']?.toString(),
      createdBy: json['created_by']?.toString() ?? '',
      ownerId: json['owner_id']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      members: [], // Members are in separate table
      memberIds: memberIds,
      plan: json['plan']?.toString() ?? 'free',
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  /// Map Supabase response to WorkspaceMember model
  WorkspaceMember _mapToMember(Map<String, dynamic> json) {
    return WorkspaceMember(
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      role: _parseRole(json['role']),
      status: _parseStatus(json['status']),
      invitedAt: _parseDateTime(json['invited_at']),
      joinedAt:
          json['joined_at'] != null ? _parseDateTime(json['joined_at']) : null,
      invitedBy: json['invited_by']?.toString() ?? '',
      inviteToken: json['invite_token']?.toString(),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  WorkspaceRole _parseRole(dynamic value) {
    if (value == null) return WorkspaceRole.viewer;
    if (value is String) {
      try {
        return WorkspaceRole.values.byName(value);
      } catch (_) {
        return WorkspaceRole.viewer;
      }
    }
    return WorkspaceRole.viewer;
  }

  MemberStatus _parseStatus(dynamic value) {
    if (value == null) return MemberStatus.pending;
    if (value is String) {
      try {
        return MemberStatus.values.byName(value);
      } catch (_) {
        return MemberStatus.pending;
      }
    }
    return MemberStatus.pending;
  }
}
