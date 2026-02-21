import 'dart:async';
import 'package:flutter/foundation.dart';
import 'workspace_models.dart';
import 'workspace_service.dart';
import 'workspace_repository.dart';
import 'workspace_member.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/supabase_service.dart';

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

  /// Clear current user (on logout)
  void clearCurrentUser() {
    setCurrentUser(null);
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
    _setLoading(true);

    _workspacesSubscription =
        _workspaceRepository.streamWorkspacesForUser(userId).listen(
      (workspaces) {
        Workspace? currentWs;

        if (_state.currentWorkspace != null) {
          try {
            currentWs = workspaces.firstWhere(
              (w) => w.id == _state.currentWorkspace!.id,
            );
          } catch (_) {
            currentWs = workspaces.isNotEmpty ? workspaces.first : null;
          }
        } else if (workspaces.isNotEmpty) {
          currentWs = workspaces.first;
        }

        _state = _state.copyWith(
          workspaces: workspaces,
          currentWorkspace: currentWs,
          isLoading: false,
          error: null,
        );
        notifyListeners();

        AppLogger.info(
            'Loaded ${workspaces.length} workspaces for user: $userId');
      },
      onError: (error) {
        AppLogger.error('Error loading workspaces stream', error);
        _state = _state.copyWith(
          error: 'Failed to load workspaces: ${error.toString()}',
          isLoading: false,
        );
        notifyListeners();
      },
    );

    // Timeout for initial load
    Future.delayed(const Duration(seconds: 10), () {
      if (_state.isLoading && _state.workspaces.isEmpty) {
        AppLogger.warning('Workspace loading timeout - showing empty state');
        _state = _state.copyWith(
          isLoading: false,
          error: 'Connection timeout. Please check your internet connection.',
        );
        notifyListeners();
      }
    });
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

    final currentWorkspace = _state.currentWorkspace!;
    final normalizedEmail = email.trim().toLowerCase();

    // Check for duplicate invitation
    final existingMember = currentWorkspace.members
        .where((m) => m.email.toLowerCase() == normalizedEmail)
        .firstOrNull;
    if (existingMember != null) {
      String errorMsg;
      if (existingMember.status == MemberStatus.pending) {
        errorMsg = 'This email already has a pending invitation';
      } else {
        errorMsg = 'This email is already a member of this workspace';
      }
      _state = _state.copyWith(error: errorMsg);
      notifyListeners();
      return null;
    }

    _setLoading(true);

    try {
      final inviteToken = _generateInviteToken();

      await SupabaseService().createInvitationByEmail(
        workspaceId: currentWorkspace.id,
        email: normalizedEmail,
        role: role.name,
        invitedBy: _currentUserId!,
        inviteToken: inviteToken,
      );

      final member = WorkspaceMember(
        userId: '00000000-0000-0000-0000-000000000000',
        email: normalizedEmail,
        role: role,
        status: MemberStatus.pending,
        invitedAt: DateTime.now(),
        invitedBy: _currentUserId!,
        inviteToken: inviteToken,
      );

      final updatedWorkspace = currentWorkspace.copyWith(
        members: [...currentWorkspace.members, member],
      );

      final workspaces = _state.workspaces
          .map((w) => w.id == updatedWorkspace.id ? updatedWorkspace : w)
          .toList();

      _state = _state.copyWith(
        workspaces: workspaces,
        currentWorkspace: updatedWorkspace,
        error: null,
      );

      _createInvitationNotification(
        email: normalizedEmail,
        workspaceId: currentWorkspace.id,
        workspaceName: currentWorkspace.name,
        inviteToken: inviteToken,
      );

      AppLogger.info('Invited member: $normalizedEmail');
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

  String _generateInviteToken() {
    final random = DateTime.now().microsecondsSinceEpoch;
    final hash = _currentUserId?.hashCode ?? 0;
    return '${random}_$hash';
  }

  void _createInvitationNotification({
    required String email,
    required String workspaceId,
    required String workspaceName,
    required String inviteToken,
  }) async {
    try {
      final response = await SupabaseService()
          .client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (response != null) {
        final invitedUserId = response['id'].toString();
        final inviterName = _state.currentWorkspace?.members
                .firstWhere(
                  (m) => m.userId == _currentUserId,
                  orElse: () => WorkspaceMember(
                    userId: _currentUserId!,
                    email: '',
                    role: WorkspaceRole.owner,
                    status: MemberStatus.active,
                    invitedAt: DateTime.now(),
                    invitedBy: '',
                  ),
                )
                .displayName ??
            'Someone';

        await SupabaseService().client.from('notifications').insert({
          'user_id': invitedUserId,
          'workspace_id': workspaceId,
          'type': 'workspace_invitation',
          'title': 'Workspace Invitation',
          'message': '$inviterName invited you to join "$workspaceName"',
          'data': {
            'workspace_name': workspaceName,
            'inviter_name': inviterName,
          },
          'action_type': 'accept_invitation',
          'action_data': {
            'invitation_token': inviteToken,
            'workspace_id': workspaceId,
          },
        });

        AppLogger.info('Created invitation notification for: $email');
      }
    } catch (e) {
      AppLogger.error('Error creating invitation notification', e);
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
      // Remove from database (workspace_members table)
      await _workspaceRepository.removeMember(
        _state.currentWorkspace!.id,
        userId,
      );

      // Also remove from workspace member_ids array
      await SupabaseService().removeWorkspaceMember(
        workspaceId: _state.currentWorkspace!.id,
        userId: userId,
      );

      // Update local state
      final updatedMembers = _state.currentWorkspace!.members
          .where((m) => m.userId != userId)
          .toList();

      final updatedWorkspace = _state.currentWorkspace!.copyWith(
        members: updatedMembers,
      );

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
      // Update in database (workspace_members table)
      await _workspaceRepository.updateMemberRole(
        _state.currentWorkspace!.id,
        userId,
        newRole,
      );

      // Update local state
      final updatedMembers = _state.currentWorkspace!.members.map((m) {
        if (m.userId == userId) {
          return m.copyWith(role: newRole);
        }
        return m;
      }).toList();

      final updatedWorkspace = _state.currentWorkspace!.copyWith(
        members: updatedMembers,
      );

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
    String? workspaceId,
    required String inviteToken,
    required String userId,
    String? displayName,
  }) async {
    _setLoading(true);

    try {
      await SupabaseService().acceptInvitation(
        inviteToken: inviteToken,
        userId: userId,
        displayName: displayName,
      );

      await loadWorkspaces();

      AppLogger.info('Accepted invitation');
    } catch (e) {
      AppLogger.error('Error accepting invitation', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Decline invitation
  Future<void> declineInvitation(String inviteToken) async {
    try {
      await SupabaseService().declineInvitation(inviteToken);
      AppLogger.info('Declined invitation');
    } catch (e) {
      AppLogger.error('Error declining invitation', e);
      rethrow;
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
