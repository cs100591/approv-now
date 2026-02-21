import 'dart:async';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';
import 'member_group.dart';

/// GroupRepository - Database operations for member groups
class GroupRepository {
  final SupabaseService _supabase;

  GroupRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  /// Create a new group
  Future<MemberGroup> createGroup({
    required String workspaceId,
    required String name,
    String? description,
    String color = '#3B82F6',
    required String createdBy,
  }) async {
    try {
      final response = await _supabase.client
          .from('member_groups')
          .insert({
            'workspace_id': workspaceId,
            'name': name,
            'description': description,
            'color': color,
            'created_by': createdBy,
          })
          .select()
          .single();

      return MemberGroup.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to create group', e);
      rethrow;
    }
  }

  /// Get groups for workspace
  Future<List<MemberGroup>> getWorkspaceGroups(String workspaceId) async {
    try {
      final response = await _supabase.client
          .from('member_groups')
          .select()
          .eq('workspace_id', workspaceId)
          .order('created_at', ascending: false);

      return response
          .map<MemberGroup>((json) => MemberGroup.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get workspace groups', e);
      return [];
    }
  }

  /// Get group by ID
  Future<MemberGroup?> getGroup(String groupId) async {
    try {
      final response = await _supabase.client
          .from('member_groups')
          .select()
          .eq('id', groupId)
          .maybeSingle();

      return response != null ? MemberGroup.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('Failed to get group', e);
      return null;
    }
  }

  /// Update group
  Future<MemberGroup> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? color,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (color != null) updates['color'] = color;

      final response = await _supabase.client
          .from('member_groups')
          .update(updates)
          .eq('id', groupId)
          .select()
          .single();

      return MemberGroup.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to update group', e);
      rethrow;
    }
  }

  /// Delete group
  Future<void> deleteGroup(String groupId) async {
    try {
      await _supabase.client.from('member_groups').delete().eq('id', groupId);
    } catch (e) {
      AppLogger.error('Failed to delete group', e);
      rethrow;
    }
  }

  /// Add member to group
  Future<GroupMember> addMemberToGroup({
    required String groupId,
    required String workspaceMemberId,
    String? addedBy,
  }) async {
    try {
      final response = await _supabase.client
          .from('group_members')
          .insert({
            'group_id': groupId,
            'workspace_member_id': workspaceMemberId,
            'added_by': addedBy,
          })
          .select()
          .single();

      return GroupMember.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to add member to group', e);
      rethrow;
    }
  }

  /// Remove member from group
  Future<void> removeMemberFromGroup({
    required String groupId,
    required String workspaceMemberId,
  }) async {
    try {
      await _supabase.client
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('workspace_member_id', workspaceMemberId);
    } catch (e) {
      AppLogger.error('Failed to remove member from group', e);
      rethrow;
    }
  }

  /// Get members in a group
  Future<List<String>> getGroupMemberIds(String groupId) async {
    try {
      final response = await _supabase.client
          .from('group_members')
          .select('workspace_member_id')
          .eq('group_id', groupId);

      return response
          .map<String>((json) => json['workspace_member_id'].toString())
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get group members', e);
      return [];
    }
  }

  /// Get groups for a workspace member
  Future<List<MemberGroup>> getMemberGroups(String workspaceMemberId) async {
    try {
      final response = await _supabase.client.from('group_members').select('''
            member_groups!inner(*)
          ''').eq('workspace_member_id', workspaceMemberId);

      return response
          .map<MemberGroup>((json) => MemberGroup.fromJson(
              json['member_groups'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get member groups', e);
      return [];
    }
  }

  /// Stream groups for workspace
  Stream<List<MemberGroup>> streamWorkspaceGroups(String workspaceId) {
    final controller = StreamController<List<MemberGroup>>();

    getWorkspaceGroups(workspaceId).then((groups) {
      if (!controller.isClosed) {
        controller.add(groups);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final groups = await getWorkspaceGroups(workspaceId);
        if (!controller.isClosed) {
          controller.add(groups);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });

    return controller.stream;
  }

  /// Get groups with member counts for workspace
  Future<List<MemberGroupWithMembers>> getGroupsWithMemberCounts(
      String workspaceId) async {
    try {
      final groups = await getWorkspaceGroups(workspaceId);
      final result = <MemberGroupWithMembers>[];

      for (final group in groups) {
        final memberIds = await getGroupMemberIds(group.id);
        result.add(MemberGroupWithMembers(
          group: group,
          memberIds: memberIds,
        ));
      }

      return result;
    } catch (e) {
      AppLogger.error('Failed to get groups with member counts', e);
      return [];
    }
  }
}
