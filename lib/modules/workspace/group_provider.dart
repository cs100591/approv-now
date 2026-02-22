import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/utils/app_logger.dart';
import 'member_group.dart';
import 'group_repository.dart';
import 'workspace_repository.dart';

class GroupState {
  final List<MemberGroup> groups;
  final Map<String, List<String>> groupMemberIds;
  final MemberGroup? selectedGroup;
  final bool isLoading;
  final String? error;

  const GroupState({
    this.groups = const [],
    this.groupMemberIds = const {},
    this.selectedGroup,
    this.isLoading = false,
    this.error,
  });

  int getGroupMemberCount(String groupId) {
    return groupMemberIds[groupId]?.length ?? 0;
  }

  GroupState copyWith({
    List<MemberGroup>? groups,
    Map<String, List<String>>? groupMemberIds,
    MemberGroup? selectedGroup,
    bool? isLoading,
    String? error,
    bool clearSelectedGroup = false,
  }) {
    return GroupState(
      groups: groups ?? this.groups,
      groupMemberIds: groupMemberIds ?? this.groupMemberIds,
      selectedGroup:
          clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GroupProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final WorkspaceRepository _workspaceRepository;

  GroupState _state = const GroupState();
  StreamSubscription<List<MemberGroup>>? _groupsSubscription;
  String? _currentWorkspaceId;
  bool _isDisposed = false;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      _safeNotifyListeners();
    }
  }

  GroupProvider({
    GroupRepository? groupRepository,
    WorkspaceRepository? workspaceRepository,
  })  : _groupRepository = groupRepository ?? GroupRepository(),
        _workspaceRepository = workspaceRepository ?? WorkspaceRepository();

  GroupState get state => _state;
  List<MemberGroup> get groups => _state.groups;
  MemberGroup? get selectedGroup => _state.selectedGroup;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  /// Load groups for workspace
  Future<void> loadWorkspaceGroups(String workspaceId) async {
    if (_currentWorkspaceId == workspaceId && _state.groups.isNotEmpty) return;

    _currentWorkspaceId = workspaceId;
    _state = _state.copyWith(isLoading: true);
    _safeNotifyListeners();

    try {
      final groupsWithMembers =
          await _groupRepository.getGroupsWithMemberCounts(workspaceId);

      final groups = groupsWithMembers.map((g) => g.group).toList();
      final memberIds = <String, List<String>>{};
      for (final g in groupsWithMembers) {
        memberIds[g.group.id] = g.memberIds;
      }

      _state = _state.copyWith(
        groups: groups,
        groupMemberIds: memberIds,
        isLoading: false,
        error: null,
      );
      _safeNotifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load workspace groups', e);
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _safeNotifyListeners();
    }
  }

  /// Subscribe to groups for workspace
  void subscribeToWorkspaceGroups(String workspaceId) {
    if (_currentWorkspaceId == workspaceId) return;

    _currentWorkspaceId = workspaceId;
    _groupsSubscription?.cancel();
    _groupsSubscription =
        _groupRepository.streamWorkspaceGroups(workspaceId).listen(
      (groups) {
        _state = _state.copyWith(
          groups: groups,
          isLoading: false,
          error: null,
        );
        _safeNotifyListeners();

        _loadGroupMemberCounts();
      },
      onError: (error) {
        AppLogger.error('Error in groups stream', error);
        _state = _state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
        _safeNotifyListeners();
      },
    );
  }

  /// Load member counts for all groups
  Future<void> _loadGroupMemberCounts() async {
    // Guard against disposed provider
    if (_isDisposed) return;

    final memberIds = <String, List<String>>{};

    for (final group in _state.groups) {
      // Check if disposed before each async operation
      if (_isDisposed) return;

      final ids = await _groupRepository.getGroupMemberIds(group.id);
      memberIds[group.id] = ids;
    }

    // Final check before updating state
    if (_isDisposed) return;

    _state = _state.copyWith(groupMemberIds: memberIds);
    _safeNotifyListeners();
  }

  /// Create group
  Future<MemberGroup?> createGroup({
    required String workspaceId,
    required String name,
    String? description,
    String color = '#3B82F6',
    required String createdBy,
  }) async {
    try {
      final group = await _groupRepository.createGroup(
        workspaceId: workspaceId,
        name: name,
        description: description,
        color: color,
        createdBy: createdBy,
      );

      final groups = [..._state.groups, group];
      _state = _state.copyWith(groups: groups);
      _safeNotifyListeners();

      return group;
    } catch (e) {
      AppLogger.error('Failed to create group', e);
      _state = _state.copyWith(error: e.toString());
      _safeNotifyListeners();
      return null;
    }
  }

  /// Update group
  Future<bool> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? color,
  }) async {
    try {
      final updatedGroup = await _groupRepository.updateGroup(
        groupId,
        name: name,
        description: description,
        color: color,
      );

      final groups = _state.groups.map((g) {
        if (g.id == groupId) return updatedGroup;
        return g;
      }).toList();

      _state = _state.copyWith(groups: groups);
      _safeNotifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('Failed to update group', e);
      _state = _state.copyWith(error: e.toString());
      _safeNotifyListeners();
      return false;
    }
  }

  /// Delete group
  Future<bool> deleteGroup(String groupId) async {
    try {
      await _groupRepository.deleteGroup(groupId);

      final groups = _state.groups.where((g) => g.id != groupId).toList();
      final memberIds = Map<String, List<String>>.from(_state.groupMemberIds);
      memberIds.remove(groupId);

      _state = _state.copyWith(
        groups: groups,
        groupMemberIds: memberIds,
        clearSelectedGroup: _state.selectedGroup?.id == groupId,
      );
      _safeNotifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('Failed to delete group', e);
      _state = _state.copyWith(error: e.toString());
      _safeNotifyListeners();
      return false;
    }
  }

  /// Add member to group
  Future<bool> addMemberToGroup({
    required String groupId,
    required String workspaceMemberId,
    String? addedBy,
  }) async {
    try {
      await _groupRepository.addMemberToGroup(
        groupId: groupId,
        workspaceMemberId: workspaceMemberId,
        addedBy: addedBy,
      );

      final memberIds = Map<String, List<String>>.from(_state.groupMemberIds);
      final currentIds = memberIds[groupId] ?? [];
      if (!currentIds.contains(workspaceMemberId)) {
        memberIds[groupId] = [...currentIds, workspaceMemberId];
      }

      _state = _state.copyWith(groupMemberIds: memberIds);
      _safeNotifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('Failed to add member to group', e);
      _state = _state.copyWith(error: e.toString());
      _safeNotifyListeners();
      return false;
    }
  }

  /// Remove member from group
  Future<bool> removeMemberFromGroup({
    required String groupId,
    required String workspaceMemberId,
  }) async {
    try {
      await _groupRepository.removeMemberFromGroup(
        groupId: groupId,
        workspaceMemberId: workspaceMemberId,
      );

      final memberIds = Map<String, List<String>>.from(_state.groupMemberIds);
      final currentIds = memberIds[groupId] ?? [];
      memberIds[groupId] =
          currentIds.where((id) => id != workspaceMemberId).toList();

      _state = _state.copyWith(groupMemberIds: memberIds);
      _safeNotifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('Failed to remove member from group', e);
      _state = _state.copyWith(error: e.toString());
      _safeNotifyListeners();
      return false;
    }
  }

  /// Get member IDs in a group
  List<String> getGroupMemberIds(String groupId) {
    return _state.groupMemberIds[groupId] ?? [];
  }

  /// Get groups for a member
  List<MemberGroup> getGroupsForMember(String workspaceMemberId) {
    return _state.groups.where((group) {
      final memberIds = _state.groupMemberIds[group.id] ?? [];
      return memberIds.contains(workspaceMemberId);
    }).toList();
  }

  /// Select group
  void selectGroup(MemberGroup? group) {
    _state = _state.copyWith(selectedGroup: group);
    _safeNotifyListeners();
  }

  /// Clear error
  void clearError() {
    _state = _state.copyWith(error: null);
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _groupsSubscription?.cancel();
    super.dispose();
  }
}
