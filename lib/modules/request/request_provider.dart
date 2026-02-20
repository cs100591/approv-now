import 'package:flutter/foundation.dart';
import '../template/template_models.dart';
import 'request_models.dart';
import 'request_service.dart';
import 'request_repository.dart';

class RequestProvider extends ChangeNotifier {
  final RequestService _requestService;
  final RequestRepository _requestRepository;

  RequestState _state = const RequestState();

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
    await loadRequests();
  }

  Future<void> loadRequests() async {
    _setLoading(true);

    try {
      final requests = await _requestRepository.getRequests();
      _state = _state.copyWith(requests: requests);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadRequestsByWorkspace(String workspaceId) async {
    _setLoading(true);

    try {
      final requests =
          await _requestRepository.getRequestsByWorkspace(workspaceId);
      _state = _state.copyWith(requests: requests);
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadPendingRequests(
      String workspaceId, String approverId) async {
    _setLoading(true);

    try {
      final pendingRequests =
          await _requestRepository.getPendingRequestsForApprover(
        workspaceId,
        approverId,
        1, // Current level would be determined by business logic
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

  Future<void> createDraftRequest({
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

      await _requestRepository.addRequest(request);

      final requests = [..._state.requests, request];
      _state = _state.copyWith(
        requests: requests,
        selectedRequest: request,
      );
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
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
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
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
    }

    _setLoading(false);
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
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
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
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
    }

    _setLoading(false);
  }

  Future<void> selectRequest(String requestId) async {
    try {
      final request = await _requestRepository.getRequestById(requestId);
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
