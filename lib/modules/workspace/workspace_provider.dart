import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
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
  Timer? _loadingTimeoutTimer;

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

  /// Set current user and start listening to their workspaces.
  /// Always re-subscribes even for the same userId (covers re-login after logout).
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
    _cancelSubscriptions();

    if (userId != null) {
      _state = const WorkspaceState(); // Reset state for fresh user session
      notifyListeners();
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
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = null;
  }

  void _subscribeToWorkspaces(String userId) {
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = null;

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

        _loadingTimeoutTimer?.cancel();
        _loadingTimeoutTimer = null;

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
        _loadingTimeoutTimer?.cancel();
        _loadingTimeoutTimer = null;
        _state = _state.copyWith(
          error: 'Failed to load workspaces: ${error.toString()}',
          isLoading: false,
        );
        notifyListeners();
      },
    );

    _loadingTimeoutTimer = Timer(const Duration(seconds: 10), () {
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
      final workspace = _workspaceService.createWorkspace(
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
      // Find workspace in local state first
      final workspace = _state.workspaces.firstWhere(
        (w) => w.id == workspaceId,
        orElse: () => throw Exception('Workspace not found: $workspaceId'),
      );

      // Update service state (synchronous, no await needed)
      _workspaceService.switchWorkspace(workspaceId);

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
      // Find existing workspace from state
      final existingWorkspace = _state.workspaces.firstWhere(
        (w) => w.id == workspaceId,
        orElse: () => throw Exception('Workspace not found: $workspaceId'),
      );

      // Update via service (synchronous, no await needed)
      final workspace = _workspaceService.updateWorkspaceHeader(
        existingWorkspace: existingWorkspace,
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

  /// Upload a logo image for the workspace to Supabase Storage
  /// and update the workspace's logoUrl.
  Future<String?> uploadWorkspaceLogo({
    required String workspaceId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    _setLoading(true);
    try {
      // Upload to Supabase Storage bucket 'workspace-logos'
      final supabase = SupabaseService();
      final path = '$workspaceId/$fileName';
      await supabase.client.storage
          .from('workspace-logos')
          .uploadBinary(path, imageBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ));

      final logoUrl =
          supabase.client.storage.from('workspace-logos').getPublicUrl(path);

      // Update workspace record
      await updateWorkspaceHeader(workspaceId: workspaceId, logoUrl: logoUrl);

      AppLogger.info('Logo uploaded for workspace: $workspaceId → $logoUrl');
      return logoUrl;
    } catch (e) {
      AppLogger.error('Error uploading workspace logo', e);
      _state = _state.copyWith(error: 'Failed to upload logo: $e');
      notifyListeners();
      return null;
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

  // ============================================
  // INVITE CODE METHODS
  // ============================================

  /// Generate a new invite code for current workspace
  Future<Map<String, dynamic>?> generateInviteCode() async {
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
      final response = await SupabaseService().createInviteCode(
        workspaceId: _state.currentWorkspace!.id,
        createdBy: _currentUserId!,
      );

      _state = _state.copyWith(error: null);
      notifyListeners();

      AppLogger.info('Generated invite code: ${response['code']}');
      return response;
    } catch (e) {
      AppLogger.error('Error generating invite code', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get all invite codes for current workspace
  Future<List<Map<String, dynamic>>> getInviteCodes() async {
    if (_state.currentWorkspace == null) return [];

    try {
      return await SupabaseService().getWorkspaceInviteCodes(
        _state.currentWorkspace!.id,
      );
    } catch (e) {
      AppLogger.error('Error getting invite codes', e);
      return [];
    }
  }

  /// Delete an invite code
  Future<void> deleteInviteCode(String codeId) async {
    _setLoading(true);

    try {
      await SupabaseService().deleteInviteCode(codeId);
      AppLogger.info('Deleted invite code: $codeId');
    } catch (e) {
      AppLogger.error('Error deleting invite code', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Join workspace using invite code
  Future<bool> joinWorkspaceWithCode({
    required String code,
    required String userId,
    String? displayName,
  }) async {
    _setLoading(true);

    try {
      final response = await SupabaseService().useInviteCode(
        code: code,
        userId: userId,
        displayName: displayName,
      );

      // Refresh workspaces list
      await loadWorkspaces();

      AppLogger.info('Joined workspace: ${response['workspace_name']}');
      return true;
    } catch (e) {
      AppLogger.error('Error joining workspace', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Validate invite code before joining
  Future<Map<String, dynamic>?> validateInviteCode(String code) async {
    try {
      return await SupabaseService().validateInviteCode(code);
    } catch (e) {
      AppLogger.error('Error validating invite code', e);
      return null;
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

  /// Delete current workspace (only owner can delete)
  Future<void> deleteWorkspace() async {
    if (_state.currentWorkspace == null) {
      throw StateError('No workspace selected');
    }

    _setLoading(true);

    try {
      final workspaceId = _state.currentWorkspace!.id;
      await _workspaceRepository.deleteWorkspace(workspaceId);

      // Remove from local state
      final workspaces =
          _state.workspaces.where((w) => w.id != workspaceId).toList();

      _state = _state.copyWith(
        workspaces: workspaces,
        currentWorkspace: workspaces.isNotEmpty ? workspaces.first : null,
      );

      AppLogger.info('Deleted workspace: $workspaceId');
    } catch (e) {
      AppLogger.error('Error deleting workspace', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
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
