import 'dart:async';
import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/stream_helper.dart';
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
      // Get approval steps from template if templateId is provided
      List<Map<String, dynamic>> approvalSteps = [];
      try {
        final templateResponse = await _supabase.client
            .from('templates')
            .select('approval_steps')
            .eq('id', request.templateId!)
            .single();

        if (templateResponse != null &&
            templateResponse['approval_steps'] != null) {
          final steps = templateResponse['approval_steps'] as List<dynamic>;
          approvalSteps = steps
              .map((step) => {
                    'step_id': step['id'] ?? step['step_id'],
                    'name': step['name'],
                    'approvers': step['approvers'],
                    'require_all': step['require_all'] ?? false,
                    'condition': step['condition'],
                  })
              .toList();
        }
      } catch (e) {
        AppLogger.warning('Could not fetch template approval steps: $e');
      }

      final response = await _supabase.createRequest(
        workspaceId: request.workspaceId,
        templateId: request.templateId,
        templateName: request.templateName,
        fieldValues: request.fieldValues.map((f) => f.toJson()).toList(),
        approvalSteps: approvalSteps,
        status: request.status.name,
        currentLevel: request.currentLevel,
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

  /// Stream requests for workspace with safe lifecycle management
  Stream<List<ApprovalRequest>> streamRequestsByWorkspace(String workspaceId) {
    return StreamHelper.createPollingStream(
      fetchData: () => getRequestsByWorkspace(workspaceId),
      interval: const Duration(seconds: 30),
    );
  }

  /// Stream pending requests for approver with safe lifecycle management
  Stream<List<ApprovalRequest>> streamPendingRequestsForApprover(
    String workspaceId,
    String approverId,
  ) {
    return StreamHelper.createPollingStream(
      fetchData: () => getPendingRequestsForApprover(workspaceId, approverId),
      interval: const Duration(seconds: 30),
    );
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
