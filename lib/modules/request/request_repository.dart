import 'dart:async';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';
import '../template/template_models.dart';
import 'request_models.dart';

/// RequestRepository - Supabase implementation
class RequestRepository {
  final SupabaseService _supabase;

  RequestRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  /// Create a new request
  Future<ApprovalRequest> createRequest(ApprovalRequest request) async {
    try {
      final response = await _supabase.createRequest(
        workspaceId: request.workspaceId,
        templateId: request.templateId,
        templateName: request.templateName,
        fieldValues: request.fieldValues.map((f) => f.toJson()).toList(),
        approvalSteps: [], // TODO: Get from template
      );

      return _mapToRequest(response);
    } catch (e) {
      AppLogger.error('Error creating request', e);
      rethrow;
    }
  }

  /// Get request by ID
  Future<ApprovalRequest?> getRequest(String requestId) async {
    try {
      final response = await _supabase.getRequest(requestId);
      if (response == null) return null;
      return _mapToRequest(response);
    } catch (e) {
      AppLogger.error('Error getting request', e);
      rethrow;
    }
  }

  /// Get all requests for a workspace
  Future<List<ApprovalRequest>> getRequestsByWorkspace(
      String workspaceId) async {
    try {
      final requests = await _supabase.getRequests(workspaceId);
      return requests.map(_mapToRequest).toList();
    } catch (e) {
      AppLogger.error('Error getting requests', e);
      rethrow;
    }
  }

  /// Get pending requests for approver
  Future<List<ApprovalRequest>> getPendingRequestsForApprover(
    String workspaceId,
    String approverId,
  ) async {
    try {
      final requests = await _supabase.getPendingRequests(workspaceId);
      return requests.map(_mapToRequest).toList();
    } catch (e) {
      AppLogger.error('Error getting pending requests', e);
      rethrow;
    }
  }

  /// Get pending request count for approver
  Future<int> getPendingRequestCount(
      String workspaceId, String approverId) async {
    try {
      final requests =
          await getPendingRequestsForApprover(workspaceId, approverId);
      return requests.length;
    } catch (e) {
      AppLogger.error('Error getting pending request count', e);
      return 0;
    }
  }

  /// Update request
  Future<void> updateRequest(ApprovalRequest request) async {
    try {
      await _supabase.updateRequest(
        request.id,
        {
          'status': request.status.name,
          'current_level': request.currentLevel,
          'field_values': request.fieldValues.map((f) => f.toJson()).toList(),
          'approval_actions':
              request.approvalActions.map((a) => a.toJson()).toList(),
          'revision_number': request.revisionNumber,
        },
      );
    } catch (e) {
      AppLogger.error('Error updating request', e);
      rethrow;
    }
  }

  /// Delete request
  Future<void> deleteRequest(String requestId) async {
    try {
      await _supabase.deleteRequest(requestId);
    } catch (e) {
      AppLogger.error('Error deleting request', e);
      rethrow;
    }
  }

  /// Stream requests for workspace
  Stream<List<ApprovalRequest>> streamRequestsByWorkspace(String workspaceId) {
    final controller = StreamController<List<ApprovalRequest>>();

    getRequestsByWorkspace(workspaceId).then((requests) {
      controller.add(requests);
    }).catchError((error) {
      controller.addError(error);
    });

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final requests = await getRequestsByWorkspace(workspaceId);
        if (!controller.isClosed) {
          controller.add(requests);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });

    return controller.stream;
  }

  /// Stream pending requests for approver
  Stream<List<ApprovalRequest>> streamPendingRequestsForApprover(
    String workspaceId,
    String approverId,
  ) {
    final controller = StreamController<List<ApprovalRequest>>();

    getPendingRequestsForApprover(workspaceId, approverId).then((requests) {
      controller.add(requests);
    }).catchError((error) {
      controller.addError(error);
    });

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final requests =
            await getPendingRequestsForApprover(workspaceId, approverId);
        if (!controller.isClosed) {
          controller.add(requests);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });

    return controller.stream;
  }

  /// Map Supabase response to ApprovalRequest model
  ApprovalRequest _mapToRequest(Map<String, dynamic> json) {
    final fieldValuesJson = json['field_values'] as List<dynamic>? ?? [];
    final approvalActionsJson =
        json['approval_actions'] as List<dynamic>? ?? [];

    return ApprovalRequest(
      id: json['id'].toString(),
      workspaceId: json['workspace_id']?.toString() ?? '',
      templateId: json['template_id']?.toString() ?? '',
      templateName: json['template_name']?.toString() ?? '',
      submittedBy: json['submitted_by']?.toString() ?? '',
      submittedByName: json['submitted_by_name']?.toString() ?? '',
      submittedAt: _parseDateTime(json['created_at']),
      status: _parseStatus(json['status']),
      currentLevel: json['current_level'] as int? ?? 1,
      revisionNumber: json['revision_number'] as int? ?? 0,
      fieldValues: fieldValuesJson
          .map((f) => FieldValue.fromJson(f as Map<String, dynamic>))
          .toList(),
      approvalActions: approvalActionsJson
          .map((a) => ApprovalAction.fromJson(a as Map<String, dynamic>))
          .toList(),
      revisions: [],
    );
  }

  RequestStatus _parseStatus(dynamic value) {
    if (value == null) return RequestStatus.draft;
    if (value is String) {
      try {
        return RequestStatus.values.byName(value);
      } catch (_) {
        return RequestStatus.draft;
      }
    }
    return RequestStatus.draft;
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
