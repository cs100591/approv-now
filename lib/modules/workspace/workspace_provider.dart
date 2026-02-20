import 'package:flutter/foundation.dart';
import 'workspace_models.dart';
import 'workspace_service.dart';
import 'workspace_repository.dart';

class WorkspaceProvider extends ChangeNotifier {
  final WorkspaceService _workspaceService;
  final WorkspaceRepository _workspaceRepository;

  WorkspaceState _state = const WorkspaceState();

  WorkspaceProvider({
    required WorkspaceService workspaceService,
    required WorkspaceRepository workspaceRepository,
  })  : _workspaceService = workspaceService,
        _workspaceRepository = workspaceRepository {
    _initialize();
  }

  WorkspaceState get state => _state;
  List<Workspace> get workspaces => _state.workspaces;
  Workspace? get currentWorkspace => _state.currentWorkspace;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  Future<void> _initialize() async {
    await loadWorkspaces();
  }

  Future<void> loadWorkspaces() async {
    _setLoading(true);

    try {
      final workspaces = await _workspaceRepository.getWorkspaces();
      final currentWorkspace = await _workspaceRepository.getCurrentWorkspace();

      _state = WorkspaceState(
        workspaces: workspaces,
        currentWorkspace: currentWorkspace,
      );
    } catch (e) {
      _state = WorkspaceState(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> createWorkspace({
    required String name,
    String? description,
    String? companyName,
    String? address,
    required String createdBy,
  }) async {
    _setLoading(true);

    try {
      final workspace = await _workspaceService.createWorkspace(
        name: name,
        description: description,
        companyName: companyName,
        address: address,
        createdBy: createdBy,
      );

      await _workspaceRepository.addWorkspace(workspace);

      final workspaces = [..._state.workspaces, workspace];
      _state = _state.copyWith(workspaces: workspaces);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> switchWorkspace(String workspaceId) async {
    _setLoading(true);

    try {
      await _workspaceService.switchWorkspace(workspaceId);
      final workspace =
          _state.workspaces.firstWhere((w) => w.id == workspaceId);
      await _workspaceRepository.saveCurrentWorkspace(workspace);

      _state = _state.copyWith(currentWorkspace: workspace);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

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
      final workspace = await _workspaceService.updateWorkspaceHeader(
        workspaceId: workspaceId,
        name: name,
        description: description,
        logoUrl: logoUrl,
        companyName: companyName,
        address: address,
        footerText: footerText,
      );

      await _workspaceRepository.updateWorkspace(workspace);

      final workspaces = _state.workspaces
          .map((w) => w.id == workspaceId ? workspace : w)
          .toList();

      _state = _state.copyWith(
        workspaces: workspaces,
        currentWorkspace: workspaceId == _state.currentWorkspace?.id
            ? workspace
            : _state.currentWorkspace,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }
}
