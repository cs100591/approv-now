import 'dart:async';
import 'package:flutter/foundation.dart';
import '../approval_engine/approval_engine_service.dart';
import '../template/template_models.dart';
import 'request_models.dart';
import 'request_repository.dart';
import '../../core/utils/app_logger.dart';

class RequestProvider extends ChangeNotifier {
  final RequestRepository _requestRepository;
  final ApprovalEngineService _approvalEngine;

  RequestState _state = const RequestState();
  StreamSubscription<List<ApprovalRequest>>? _requestsSubscription;
  StreamSubscription<List<ApprovalRequest>>? _pendingRequestsSubscription;
  String? _currentWorkspaceId;
  String? _currentApproverId;

  RequestProvider({
    required RequestRepository requestRepository,
    ApprovalEngineService? approvalEngine,
  })  : _requestRepository = requestRepository,
        _approvalEngine = approvalEngine ?? ApprovalEngineService() {
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

    if (workspaceId != null && workspaceId.isNotEmpty) {
      _subscribeToRequests(workspaceId);
      if (approverId != null && approverId.isNotEmpty) {
        _subscribeToPendingRequests(workspaceId, approverId);
      }
    } else {
      _state = const RequestState();
      notifyListeners();
    }
  }

  void _subscribeToRequests(String workspaceId) {
    _requestsSubscription =
        _requestRepository.streamRequestsByWorkspace(workspaceId).listen(
      (requests) {
        _state = _state.copyWith(requests: requests);
        notifyListeners();
      },
      onError: (error) {
        AppLogger.error('Error streaming requests', error);
        _state = _state.copyWith(error: error.toString());
        notifyListeners();
      },
    );
  }

  void _subscribeToPendingRequests(String workspaceId, String approverId) {
    _pendingRequestsSubscription = _requestRepository
        .streamPendingRequestsForApprover(workspaceId, approverId)
        .listen(
      (requests) {
        _state = _state.copyWith(
          pendingRequests: requests,
          pendingCount: requests.length,
        );
        notifyListeners();
      },
      onError: (error) {
        AppLogger.error('Error streaming pending requests', error);
      },
    );
  }

  void _cancelSubscriptions() {
    _requestsSubscription?.cancel();
    _requestsSubscription = null;
    _pendingRequestsSubscription?.cancel();
    _pendingRequestsSubscription = null;
  }

  /// Load requests for current workspace
  Future<void> loadRequests() async {
    if (_currentWorkspaceId == null) return;

    _setLoading(true);

    try {
      final requests =
          await _requestRepository.getRequestsByWorkspace(_currentWorkspaceId!);

      List<ApprovalRequest>? pendingRequests;
      if (_currentApproverId != null) {
        pendingRequests =
            await _requestRepository.getPendingRequestsForApprover(
          _currentWorkspaceId!,
          _currentApproverId!,
        );
      }

      _state = _state.copyWith(
        requests: requests,
        pendingRequests: pendingRequests ?? _state.pendingRequests,
        pendingCount: pendingRequests?.length ?? _state.pendingCount,
      );
    } catch (e) {
      AppLogger.error('Error loading requests', e);
      _state = _state.copyWith(error: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<ApprovalRequest?> createDraftRequest({
    required String workspaceId,
    required Template template,
    required String submittedBy,
    required String submittedByName,
  }) async {
    _setLoading(true);

    try {
      // Create request directly in database
      final request = ApprovalRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workspaceId: workspaceId,
        templateId: template.id,
        templateName: template.name,
        submittedBy: submittedBy,
        submittedByName: submittedByName,
        submittedAt: DateTime.now(),
        status: RequestStatus.draft,
      );

      final createdRequest = await _requestRepository.createRequest(request);

      // Add to local state immediately so submitRequest can find it
      final updatedRequests = [..._state.requests, createdRequest];
      _state = _state.copyWith(requests: updatedRequests);
      notifyListeners();

      AppLogger.info('Created request: ${createdRequest.id}');
      return createdRequest;
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
    ApprovalRequest?
        draftRequest, // Pass the draft directly to avoid state race
  }) async {
    _setLoading(true);

    try {
      // Use supplied draft request or fall back to state lookup
      ApprovalRequest request;
      if (draftRequest != null) {
        request = draftRequest;
      } else {
        final found = _state.requests.cast<ApprovalRequest?>().firstWhere(
              (r) => r!.id == requestId,
              orElse: () => null,
            );
        if (found == null) {
          // Try fetching from DB directly
          request = await _requestRepository.getRequest(requestId) ??
              (throw Exception('Request not found'));
        } else {
          request = found;
        }
      }

      if (!request.canEdit) {
        throw Exception('Cannot edit request in current status');
      }

      // Create revision for this submission
      final revision = RequestRevision(
        revisionNumber: request.revisionNumber,
        createdAt: DateTime.now(),
        fieldValues: fieldValues,
      );

      final updated = request.copyWith(
        status: RequestStatus.pending,
        fieldValues: fieldValues,
        currentLevel: 1,
        revisions: [...request.revisions, revision],
      );

      await _requestRepository.updateRequest(updated);

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
      final request = _state.requests.firstWhere(
        (r) => r.id == requestId,
        orElse: () => throw Exception('Request not found'),
      );

      final updated = request.copyWith(fieldValues: fieldValues);
      await _requestRepository.updateRequest(updated);

      AppLogger.info('Updated field values for request: $requestId');
    } catch (e) {
      AppLogger.error('Error updating field values', e);
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
      // Get request from database to ensure we have the latest data
      final request = await _requestRepository.getRequest(requestId);
      if (request == null) {
        throw Exception('Request not found in database');
      }

      if (request.status != RequestStatus.pending) {
        throw Exception('Request is not pending approval');
      }

      // Use ApprovalEngine to process the approval
      final result = await _approvalEngine.executeApproval(
        request: request,
        template: template,
        approverId: approverId,
        approverName: approverName,
        comment: comment,
      );

      // Update the revision with the action
      final updatedRevisions = [...request.revisions];
      if (updatedRevisions.isNotEmpty) {
        final lastRevision = updatedRevisions.last;
        updatedRevisions[updatedRevisions.length - 1] = lastRevision.copyWith(
          approvalActions: [...lastRevision.approvalActions, result.action],
        );
      }

      // Use the updated request from ApprovalEngine
      final updated = result.request.copyWith(
        revisions: updatedRevisions,
      );

      await _requestRepository.updateRequest(updated);

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
      // Get request from database
      final request = await _requestRepository.getRequest(requestId);
      if (request == null) {
        throw Exception('Request not found in database');
      }

      if (request.status != RequestStatus.pending) {
        throw Exception('Request is not pending approval');
      }

      // Use ApprovalEngine to process the rejection
      final result = await _approvalEngine.executeRejection(
        request: request,
        template: template,
        approverId: approverId,
        approverName: approverName,
        comment: comment,
      );

      // Update the revision with the action
      final updatedRevisions = [...request.revisions];
      if (updatedRevisions.isNotEmpty) {
        final lastRevision = updatedRevisions.last;
        updatedRevisions[updatedRevisions.length - 1] = lastRevision.copyWith(
          approvalActions: [...lastRevision.approvalActions, result.action],
        );
      }

      final updated = result.request.copyWith(
        revisions: updatedRevisions,
      );

      await _requestRepository.updateRequest(updated);

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
      AppLogger.error('Error selecting request', e);
    }
  }

  /// Fetch a single request directly from the database
  Future<ApprovalRequest?> fetchRequestById(String requestId) async {
    try {
      return await _requestRepository.getRequest(requestId);
    } catch (e) {
      AppLogger.error('Error fetching request by id', e);
      return null;
    }
  }

  Future<void> deleteRequest(String requestId) async {
    _setLoading(true);

    try {
      await _requestRepository.deleteRequest(requestId);

      final requests = _state.requests.where((r) => r.id != requestId).toList();
      final pendingRequests =
          _state.pendingRequests.where((r) => r.id != requestId).toList();

      _state = _state.copyWith(
        requests: requests,
        pendingRequests: pendingRequests,
        pendingCount: pendingRequests.length,
        selectedRequest: _state.selectedRequest?.id == requestId
            ? null
            : _state.selectedRequest,
      );

      notifyListeners();
      AppLogger.info('Deleted request: $requestId');
    } catch (e) {
      AppLogger.error('Error deleting request', e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<int> getPendingRequestCount(
      String workspaceId, String approverId) async {
    try {
      return await _requestRepository.getPendingRequestCount(
        workspaceId,
        approverId,
      );
    } catch (e) {
      AppLogger.error('Error getting pending request count', e);
      return 0;
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
