import 'dart:async';
import 'package:flutter/foundation.dart';
import 'workspace_models.dart';
import 'workspace_service.dart';
import 'workspace_repository.dart';
import 'workspace_member.dart';
import '../../core/utils/app_logger.dart';

class WorkspaceProvider extends ChangeNotifier {
  final WorkspaceService _workspaceService;
  final WorkspaceRepository _workspaceRepository;

  String? _currentUserId;
  StreamSubscription<List<Workspace>>? _workspacesSubscription;
  StreamSubscription<Workspace?>? _currentWorkspaceSubscription;

  WorkspaceState _state = const WorkspaceState();

  WorkspaceProvider({
    required WorkspaceService workspaceService,
    required WorkspaceRepository workspaceRepository,
    String? userId,
  })  : _workspaceService = workspaceService,
        _workspaceRepository = workspaceRepository,
        _currentUserId = userId {
    _initialize();
  }

  WorkspaceState get state => _state;
  List<Workspace> get workspaces => _state.workspaces;
  Workspace? get currentWorkspace => _state.currentWorkspace;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  /// Set current user and start listening to their workspaces
  void setCurrentUser(String? userId) {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    _cancelSubscriptions();

    if (userId != null) {
      _subscribeToWorkspaces(userId);
    } else {
      _state = const WorkspaceState();
      notifyListeners();
    }
  }

  Future<void> _initialize() async {
    if (_currentUserId != null) {
      await loadWorkspaces();
      _subscribeToWorkspaces(_currentUserId!);
    }
  }

  void _cancelSubscriptions() {
    _workspacesSubscription?.cancel();
    _currentWorkspaceSubscription?.cancel();
    _workspacesSubscription = null;
    _currentWorkspaceSubscription = null;
  }

  void _subscribeToWorkspaces(String userId) {
    _workspacesSubscription =
        _workspaceRepository.streamWorkspacesForUser(userId).listen(
      (workspaces) {
        Workspace? currentWs;

        // Try to keep the same workspace selected
        if (_state.currentWorkspace != null) {
          currentWs = workspaces.firstWhere(
            (w) => w.id == _state.currentWorkspace!.id,
            orElse: () => workspaces.isNotEmpty
                ? workspaces.first
                : throw StateError('No workspaces'),
          );
        } else if (workspaces.isNotEmpty) {
          currentWs = workspaces.first;
        }

        _state = _state.copyWith(
          workspaces: workspaces,
          currentWorkspace: currentWs,
        );
        notifyListeners();

        AppLogger.info(
            'Loaded ${workspaces.length} workspaces for user: $userId');
      },
      onError: (error) {
        AppLogger.error('Error loading workspaces', error);
        _state = _state.copyWith(error: error.toString());
        notifyListeners();
      },
    );
  }

  /// Load workspaces for current user (manual refresh)
  Future<void> loadWorkspaces() async {
    if (_currentUserId == null) {
      AppLogger.warning('Cannot load workspaces: no user logged in');
      return;
    }

    _setLoading(true);

    try {
      final workspaces =
          await _workspaceRepository.getWorkspacesForUser(_currentUserId!);

      Workspace? currentWs;
      if (_state.currentWorkspace != null) {
        // Try to keep the same workspace selected
        try {
          currentWs =
              workspaces.firstWhere((w) => w.id == _state.currentWorkspace!.id);
        } catch (_) {
          // Current workspace not found, select first one
          currentWs = workspaces.isNotEmpty ? workspaces.first : null;
        }
      } else if (workspaces.isNotEmpty) {
        currentWs = workspaces.first;
      }

      _state = WorkspaceState(
        workspaces: workspaces,
        currentWorkspace: currentWs,
      );

      AppLogger.info('Manually loaded ${workspaces.length} workspaces');
    } catch (e) {
      AppLogger.error('Error loading workspaces', e);
      _state = WorkspaceState(error: e.toString());
    }

    _setLoading(false);
  }

  /// Create a new workspace
  Future<Workspace?> createWorkspace({
    required String name,
    String? description,
    String? companyName,
    String? address,
    required String createdBy,
    required String creatorEmail,
  }) async {
    if (_currentUserId == null) {
      _state = _state.copyWith(error: 'No user logged in');
      notifyListeners();
      return null;
    }

    _setLoading(true);

    try {
      // Create workspace via service (local logic)
      final workspace = await _workspaceService.createWorkspace(
        name: name,
        description: description,
        companyName: companyName,
        address: address,
        createdBy: createdBy,
        creatorEmail: creatorEmail,
      );

      // Create a Firestore-ready version with ownerId and memberIds
      final firestoreWorkspace = workspace.copyWith(
        ownerId: createdBy,
        memberIds: [createdBy],
      );

      // Save to Firestore
      await _workspaceRepository.createWorkspace(firestoreWorkspace);

      // Real-time subscription will update the state automatically
      AppLogger.info('Created workspace: ${workspace.id}');

      return firestoreWorkspace;
    } catch (e) {
      AppLogger.error('Error creating workspace', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Switch active workspace
  Future<void> switchWorkspace(String workspaceId) async {
    _setLoading(true);

    try {
      // Update service state
      await _workspaceService.switchWorkspace(workspaceId);

      // Find workspace in local state
      final workspace = _state.workspaces.firstWhere(
        (w) => w.id == workspaceId,
        orElse: () => throw Exception('Workspace not found'),
      );

      _state = _state.copyWith(currentWorkspace: workspace);
      AppLogger.info('Switched to workspace: $workspaceId');
    } catch (e) {
      AppLogger.error('Error switching workspace', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Update workspace header info
  Future<void> updateWorkspaceHeader({
    required String workspaceId,
    String? name,
    String? description,
    String? logoUrl,
    String? companyName,
    String? address,
    String? footerText,
  }) async {
    _setLoading(true);

    try {
      // Update via service
      final workspace = await _workspaceService.updateWorkspaceHeader(
        workspaceId: workspaceId,
        name: name,
        description: description,
        logoUrl: logoUrl,
        companyName: companyName,
        address: address,
        footerText: footerText,
      );

      // Update in Firestore
      await _workspaceRepository.updateWorkspace(workspace);

      // Update local state
      final workspaces = _state.workspaces
          .map((w) => w.id == workspaceId ? workspace : w)
          .toList();

      _state = _state.copyWith(
        workspaces: workspaces,
        currentWorkspace: workspaceId == _state.currentWorkspace?.id
            ? workspace
            : _state.currentWorkspace,
      );

      AppLogger.info('Updated workspace: $workspaceId');
    } catch (e) {
      AppLogger.error('Error updating workspace', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user already has a workspace (for auto-creation logic)
  Future<bool> hasAnyWorkspace() async {
    if (_currentUserId == null) return false;

    try {
      return await _workspaceRepository.hasWorkspace(_currentUserId!);
    } catch (e) {
      AppLogger.error('Error checking workspace existence', e);
      return false;
    }
  }

  /// Invite a new member to the current workspace
  Future<WorkspaceMember?> inviteMember({
    required String email,
    required WorkspaceRole role,
  }) async {
    if (_state.currentWorkspace == null) {
      _state = _state.copyWith(error: 'No workspace selected');
      notifyListeners();
      return null;
    }

    if (_currentUserId == null) {
      _state = _state.copyWith(error: 'No user logged in');
      notifyListeners();
      return null;
    }

    _setLoading(true);

    try {
      final member = await _workspaceService.inviteMember(
        workspaceId: _state.currentWorkspace!.id,
        email: email,
        role: role,
        invitedBy: _currentUserId!,
      );

      // Update workspace in Firestore with new member
      final updatedWorkspace = _state.currentWorkspace!.copyWith(
        members: [..._state.currentWorkspace!.members, member],
      );

      await _workspaceRepository.updateWorkspace(updatedWorkspace);

      // Update local state
      final workspaces = _state.workspaces
          .map((w) => w.id == updatedWorkspace.id ? updatedWorkspace : w)
          .toList();

      _state = _state.copyWith(
        workspaces: workspaces,
        currentWorkspace: updatedWorkspace,
      );

      AppLogger.info('Invited member: $email');
      return member;
    } catch (e) {
      AppLogger.error('Error inviting member', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove a member from the current workspace
  Future<void> removeMember(String userId) async {
    if (_state.currentWorkspace == null) {
      _state = _state.copyWith(error: 'No workspace selected');
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      await _workspaceService.removeMember(
        _state.currentWorkspace!.id,
        userId,
      );

      // Update workspace in Firestore
      final updatedMembers = _state.currentWorkspace!.members
          .where((m) => m.userId != userId)
          .toList();

      final updatedWorkspace = _state.currentWorkspace!.copyWith(
        members: updatedMembers,
      );

      await _workspaceRepository.updateWorkspace(updatedWorkspace);

      // Update local state
      final workspaces = _state.workspaces
          .map((w) => w.id == updatedWorkspace.id ? updatedWorkspace : w)
          .toList();

      _state = _state.copyWith(
        workspaces: workspaces,
        currentWorkspace: updatedWorkspace,
      );

      AppLogger.info('Removed member: $userId');
    } catch (e) {
      AppLogger.error('Error removing member', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Update member role
  Future<void> updateMemberRole(String userId, WorkspaceRole newRole) async {
    if (_state.currentWorkspace == null) {
      _state = _state.copyWith(error: 'No workspace selected');
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      await _workspaceService.updateMemberRole(
        workspaceId: _state.currentWorkspace!.id,
        userId: userId,
        newRole: newRole,
      );

      // Update workspace in Firestore
      final updatedMembers = _state.currentWorkspace!.members.map((m) {
        if (m.userId == userId) {
          return m.copyWith(role: newRole);
        }
        return m;
      }).toList();

      final updatedWorkspace = _state.currentWorkspace!.copyWith(
        members: updatedMembers,
      );

      await _workspaceRepository.updateWorkspace(updatedWorkspace);

      // Update local state
      final workspaces = _state.workspaces
          .map((w) => w.id == updatedWorkspace.id ? updatedWorkspace : w)
          .toList();

      _state = _state.copyWith(
        workspaces: workspaces,
        currentWorkspace: updatedWorkspace,
      );

      AppLogger.info('Updated role for member: $userId');
    } catch (e) {
      AppLogger.error('Error updating member role', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Accept invitation
  Future<void> acceptInvitation({
    required String workspaceId,
    required String inviteToken,
    required String userId,
    String? displayName,
  }) async {
    _setLoading(true);

    try {
      await _workspaceService.acceptInvitation(
        workspaceId: workspaceId,
        inviteToken: inviteToken,
        userId: userId,
        displayName: displayName,
      );

      // Add user to workspace members in Firestore
      await _workspaceRepository.addMember(workspaceId, userId);

      // Reload workspaces
      await loadWorkspaces();

      AppLogger.info('Accepted invitation to workspace: $workspaceId');
    } catch (e) {
      AppLogger.error('Error accepting invitation', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
