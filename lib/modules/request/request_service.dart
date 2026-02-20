import 'dart:math';
import '../approval_engine/approval_engine_service.dart';
import '../template/template_models.dart';
import 'request_models.dart';

/// RequestService - Business logic for request management
class RequestService {
  final List<ApprovalRequest> _requests = [];
  final ApprovalEngineService _approvalEngine = ApprovalEngineService();

  // Get all requests
  List<ApprovalRequest> getRequests() {
    return List.unmodifiable(_requests);
  }

  // Get requests by workspace
  List<ApprovalRequest> getRequestsByWorkspace(String workspaceId) {
    return _requests.where((r) => r.workspaceId == workspaceId).toList();
  }

  // Get request by ID
  ApprovalRequest? getRequestById(String requestId) {
    try {
      return _requests.firstWhere((r) => r.id == requestId);
    } catch (e) {
      return null;
    }
  }

  // Create draft request
  Future<ApprovalRequest> createDraftRequest({
    required String workspaceId,
    required Template template,
    required String submittedBy,
    required String submittedByName,
  }) async {
    final request = ApprovalRequest(
      id: _generateId(),
      workspaceId: workspaceId,
      templateId: template.id,
      templateName: template.name,
      submittedBy: submittedBy,
      submittedByName: submittedByName,
      submittedAt: DateTime.now(),
      status: RequestStatus.draft,
    );

    _requests.add(request);
    return request;
  }

  // Submit request
  Future<ApprovalRequest> submitRequest({
    required String requestId,
    required List<FieldValue> fieldValues,
  }) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Request not found');
    }

    final request = _requests[index];
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

    _requests[index] = updated;
    return updated;
  }

  // Update field values for draft
  Future<ApprovalRequest> updateFieldValues({
    required String requestId,
    required List<FieldValue> fieldValues,
  }) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Request not found');
    }

    final request = _requests[index];
    if (!request.canEdit) {
      throw Exception('Cannot edit request in current status');
    }

    final updated = request.copyWith(
      fieldValues: fieldValues,
    );

    _requests[index] = updated;
    return updated;
  }

  // Approve request at current level using ApprovalEngine
  Future<ApprovalRequest> approveRequest({
    required String requestId,
    required String approverId,
    required String approverName,
    required Template template,
    String? comment,
  }) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Request not found');
    }

    final request = _requests[index];
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

    _requests[index] = updated;
    return updated;
  }

  // Reject request using ApprovalEngine
  Future<ApprovalRequest> rejectRequest({
    required String requestId,
    required String approverId,
    required String approverName,
    required Template template,
    String? comment,
  }) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Request not found');
    }

    final request = _requests[index];
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

    _requests[index] = result.request;
    return result.request;
  }

  // Get pending approval count for user
  Future<int> getPendingApprovalCount(String workspaceId, String userId) async {
    return _requests
        .where((r) =>
            r.workspaceId == workspaceId && r.status == RequestStatus.pending)
        .length;
  }

  // Get requests submitted by user
  List<ApprovalRequest> getRequestsBySubmitter(String submittedBy) {
    return _requests.where((r) => r.submittedBy == submittedBy).toList();
  }

  // Get pending requests for approver at specific level
  List<ApprovalRequest> getPendingForApprover(String approverId, int level) {
    return _requests
        .where(
            (r) => r.status == RequestStatus.pending && r.currentLevel == level)
        .toList();
  }

  // Delete request
  Future<void> deleteRequest(String requestId) async {
    _requests.removeWhere((r) => r.id == requestId);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
