import 'dart:async';
import 'package:flutter/foundation.dart';
import '../template/template_models.dart';
import 'request_models.dart';
import 'request_service.dart';
import 'request_repository.dart';
import '../../core/utils/app_logger.dart';

class RequestProvider extends ChangeNotifier {
  final RequestService _requestService;
  final RequestRepository _requestRepository;

  RequestState _state = const RequestState();
  StreamSubscription<List<ApprovalRequest>>? _requestsSubscription;
  StreamSubscription<List<ApprovalRequest>>? _pendingRequestsSubscription;
  String? _currentWorkspaceId;
  String? _currentApproverId;

  RequestProvider({
    required RequestService requestService,
    required RequestRepository requestRepository,
  })  : _requestService = requestService,
        _requestRepository = requestRepository {
    _initialize();
  }

  RequestState get state => _state;
  List<ApprovalRequest> get requests => _state.requests;
  ApprovalRequest? get selectedRequest => _state.selectedRequest;
  List<ApprovalRequest> get pendingRequests => _state.pendingRequests;
  int get pendingCount => _state.pendingCount;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  Future<void> _initialize() async {
    // Don't load requests on init - wait for workspace to be selected
  }

  /// Set current workspace and subscribe to its requests
  void setCurrentWorkspace(String? workspaceId, {String? approverId}) {
    if (_currentWorkspaceId == workspaceId &&
        _currentApproverId == approverId) {
      return;
    }

    _currentWorkspaceId = workspaceId;
    _currentApproverId = approverId;
    _cancelSubscriptions();

    if (workspaceId != null) {
      _subscribeToRequests(workspaceId);
      if (approverId != null) {
        _subscribeToPendingRequests(workspaceId, approverId);
      }
    } else {
      _state = const RequestState();
      notifyListeners();
    }
  }

  void _cancelSubscriptions() {
    _requestsSubscription?.cancel();
    _pendingRequestsSubscription?.cancel();
    _requestsSubscription = null;
    _pendingRequestsSubscription = null;
  }

  void _subscribeToRequests(String workspaceId) {
    _requestsSubscription =
        _requestRepository.streamRequestsByWorkspace(workspaceId).listen(
      (requests) {
        _state = _state.copyWith(requests: requests);
        notifyListeners();
        AppLogger.info(
            'Loaded ${requests.length} requests for workspace: $workspaceId');
      },
      onError: (error) {
        AppLogger.error('Error loading requests', error);
        _state = _state.copyWith(error: error.toString());
        notifyListeners();
      },
    );
  }

  void _subscribeToPendingRequests(String workspaceId, String approverId) {
    _pendingRequestsSubscription = _requestRepository
        .streamPendingRequestsForApprover(workspaceId, approverId)
        .listen(
      (pendingRequests) {
        _state = _state.copyWith(
          pendingRequests: pendingRequests,
          pendingCount: pendingRequests.length,
        );
        notifyListeners();
        AppLogger.info('Loaded ${pendingRequests.length} pending requests');
      },
      onError: (error) {
        AppLogger.error('Error loading pending requests', error);
      },
    );
  }

  /// Load requests for workspace (manual refresh)
  Future<void> loadRequests() async {
    if (_currentWorkspaceId == null) {
      AppLogger.warning('Cannot load requests: no workspace selected');
      return;
    }

    _setLoading(true);

    try {
      final requests =
          await _requestRepository.getRequestsByWorkspace(_currentWorkspaceId!);
      _state = _state.copyWith(requests: requests);
      AppLogger.info('Manually loaded ${requests.length} requests');
    } catch (e) {
      AppLogger.error('Error loading requests', e);
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadRequestsByWorkspace(String workspaceId) async {
    _currentWorkspaceId = workspaceId;
    _cancelSubscriptions();
    _setLoading(true);

    try {
      final requests =
          await _requestRepository.getRequestsByWorkspace(workspaceId);
      _state = _state.copyWith(requests: requests);
      _subscribeToRequests(workspaceId);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadPendingRequests(
      String workspaceId, String approverId) async {
    _currentApproverId = approverId;
    _setLoading(true);

    try {
      final pendingRequests =
          await _requestRepository.getPendingRequestsForApprover(
        workspaceId,
        approverId,
      );
      final pendingCount = pendingRequests.length;

      _state = _state.copyWith(
        pendingRequests: pendingRequests,
        pendingCount: pendingCount,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<ApprovalRequest?> createDraftRequest({
    required String workspaceId,
    required Template template,
    required String submittedBy,
    required String submittedByName,
  }) async {
    _setLoading(true);

    try {
      final request = await _requestService.createDraftRequest(
        workspaceId: workspaceId,
        template: template,
        submittedBy: submittedBy,
        submittedByName: submittedByName,
      );

      await _requestRepository.createRequest(request);

      // Real-time subscription will update the state automatically
      AppLogger.info('Created request: ${request.id}');
      return request;
    } catch (e) {
      AppLogger.error('Error creating request', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitRequest({
    required String requestId,
    required List<FieldValue> fieldValues,
  }) async {
    _setLoading(true);

    try {
      final request = await _requestService.submitRequest(
        requestId: requestId,
        fieldValues: fieldValues,
      );

      await _requestRepository.updateRequest(request);

      final requests =
          _state.requests.map((r) => r.id == requestId ? request : r).toList();

      _state = _state.copyWith(
        requests: requests,
        selectedRequest: request,
      );

      AppLogger.info('Submitted request: $requestId');
    } catch (e) {
      AppLogger.error('Error submitting request', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateFieldValues({
    required String requestId,
    required List<FieldValue> fieldValues,
  }) async {
    _setLoading(true);

    try {
      final request = await _requestService.updateFieldValues(
        requestId: requestId,
        fieldValues: fieldValues,
      );

      await _requestRepository.updateRequest(request);

      final requests =
          _state.requests.map((r) => r.id == requestId ? request : r).toList();

      _state = _state.copyWith(
        requests: requests,
        selectedRequest: request,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> approveRequest({
    required String requestId,
    required String approverId,
    required String approverName,
    required Template template,
    String? comment,
  }) async {
    _setLoading(true);

    try {
      final request = await _requestService.approveRequest(
        requestId: requestId,
        approverId: approverId,
        approverName: approverName,
        template: template,
        comment: comment,
      );

      await _requestRepository.updateRequest(request);

      final requests =
          _state.requests.map((r) => r.id == requestId ? request : r).toList();

      // Update pending requests
      final pendingRequests =
          _state.pendingRequests.where((r) => r.id != requestId).toList();

      _state = _state.copyWith(
        requests: requests,
        selectedRequest: request,
        pendingRequests: pendingRequests,
        pendingCount: pendingRequests.length,
      );

      AppLogger.info('Approved request: $requestId');
    } catch (e) {
      AppLogger.error('Error approving request', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rejectRequest({
    required String requestId,
    required String approverId,
    required String approverName,
    required Template template,
    String? comment,
  }) async {
    _setLoading(true);

    try {
      final request = await _requestService.rejectRequest(
        requestId: requestId,
        approverId: approverId,
        approverName: approverName,
        template: template,
        comment: comment,
      );

      await _requestRepository.updateRequest(request);

      final requests =
          _state.requests.map((r) => r.id == requestId ? request : r).toList();

      // Update pending requests
      final pendingRequests =
          _state.pendingRequests.where((r) => r.id != requestId).toList();

      _state = _state.copyWith(
        requests: requests,
        selectedRequest: request,
        pendingRequests: pendingRequests,
        pendingCount: pendingRequests.length,
      );

      AppLogger.info('Rejected request: $requestId');
    } catch (e) {
      AppLogger.error('Error rejecting request', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectRequest(String requestId) async {
    try {
      final request = await _requestRepository.getRequest(requestId);
      _state = _state.copyWith(selectedRequest: request);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  Future<void> deleteRequest(String requestId) async {
    _setLoading(true);

    try {
      await _requestService.deleteRequest(requestId);
      await _requestRepository.deleteRequest(requestId);

      final requests = _state.requests.where((r) => r.id != requestId).toList();
      _state = _state.copyWith(
        requests: requests,
        selectedRequest: _state.selectedRequest?.id == requestId
            ? null
            : _state.selectedRequest,
      );

      AppLogger.info('Deleted request: $requestId');
    } catch (e) {
      AppLogger.error('Error deleting request', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Get pending request count for plan enforcement
  Future<int> getPendingRequestCount(
      String workspaceId, String approverId) async {
    try {
      return await _requestRepository.getPendingRequestCount(
          workspaceId, approverId);
    } catch (e) {
      AppLogger.error('Error getting pending request count', e);
      return _state.pendingRequests.length;
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
