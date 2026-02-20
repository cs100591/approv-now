import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'request_models.dart';

class RequestRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveRequests(List<ApprovalRequest> requests) async {
    final prefs = await _preferences;
    final requestsJson = requests.map((r) => r.toJson()).toList();
    await prefs.setString('requests', jsonEncode(requestsJson));
  }

  Future<List<ApprovalRequest>> getRequests() async {
    final prefs = await _preferences;
    final requestsJson = prefs.getString('requests');
    if (requestsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(requestsJson);
      return decoded.map((json) => ApprovalRequest.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ApprovalRequest>> getRequestsByWorkspace(
      String workspaceId) async {
    final requests = await getRequests();
    return requests.where((r) => r.workspaceId == workspaceId).toList();
  }

  Future<List<ApprovalRequest>> getRequestsByTemplate(String templateId) async {
    final requests = await getRequests();
    return requests.where((r) => r.templateId == templateId).toList();
  }

  Future<List<ApprovalRequest>> getRequestsByStatus(
      RequestStatus status) async {
    final requests = await getRequests();
    return requests.where((r) => r.status == status).toList();
  }

  Future<List<ApprovalRequest>> getPendingRequestsForApprover(
    String workspaceId,
    String approverId,
    int level,
  ) async {
    final requests = await getRequests();
    return requests
        .where((r) =>
            r.workspaceId == workspaceId &&
            r.status == RequestStatus.pending &&
            r.currentLevel == level)
        .toList();
  }

  Future<ApprovalRequest?> getRequestById(String requestId) async {
    final requests = await getRequests();
    try {
      return requests.firstWhere((r) => r.id == requestId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addRequest(ApprovalRequest request) async {
    final requests = await getRequests();
    requests.add(request);
    await saveRequests(requests);
  }

  Future<void> updateRequest(ApprovalRequest request) async {
    final requests = await getRequests();
    final index = requests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      requests[index] = request;
      await saveRequests(requests);
    }
  }

  Future<void> deleteRequest(String requestId) async {
    final requests = await getRequests();
    requests.removeWhere((r) => r.id == requestId);
    await saveRequests(requests);
  }

  Future<int> getRequestCount() async {
    final requests = await getRequests();
    return requests.length;
  }

  Future<int> getRequestCountByWorkspace(String workspaceId) async {
    final requests = await getRequests();
    return requests.where((r) => r.workspaceId == workspaceId).length;
  }

  Future<int> getPendingRequestCount(
      String workspaceId, String approverId) async {
    final requests = await getRequests();
    return requests
        .where((r) =>
            r.workspaceId == workspaceId && r.status == RequestStatus.pending)
        .length;
  }
}
