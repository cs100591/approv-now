import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/repositories/firestore_repository.dart';
import '../../core/utils/app_logger.dart';
import 'request_models.dart' hide FieldValue;

/// RequestRepository - Handles approval request data with Firestore
///
/// Data Structure in Firestore:
/// Collection: requests
/// Document: {requestId}
///
/// Requests are associated with workspaces via the `workspaceId` field.
/// Access is controlled by workspace membership.
class RequestRepository extends FirestoreRepository {
  static const String _collectionPath = 'requests';

  RequestRepository({FirebaseFirestore? firestore})
      : super(firestore: firestore);

  /// Create a new request
  Future<ApprovalRequest> createRequest(ApprovalRequest request) async {
    try {
      final data = request.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await firestore.collection(_collectionPath).doc(request.id).set(data);

      AppLogger.info('Created request: ${request.id}');
      return request;
    } catch (e) {
      AppLogger.error('Error creating request', e);
      rethrow;
    }
  }

  /// Get request by ID
  Future<ApprovalRequest?> getRequest(String requestId) async {
    try {
      final doc =
          await firestore.collection(_collectionPath).doc(requestId).get();

      if (doc.exists && doc.data() != null) {
        return ApprovalRequest.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting request: $requestId', e);
      return null;
    }
  }

  /// Get all requests for a workspace
  Future<List<ApprovalRequest>> getRequestsByWorkspace(
      String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApprovalRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting requests for workspace: $workspaceId', e);
      return [];
    }
  }

  /// Get requests submitted by a user
  Future<List<ApprovalRequest>> getRequestsBySubmitter(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('submittedBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApprovalRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting requests for submitter: $userId', e);
      return [];
    }
  }

  /// Get pending requests for an approver
  Future<List<ApprovalRequest>> getPendingRequestsForApprover(
    String workspaceId,
    String approverId,
  ) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .where('status', isEqualTo: 'pending')
          .where('currentApproverIds', arrayContains: approverId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApprovalRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error getting pending requests for approver: $approverId', e);
      return [];
    }
  }

  /// Get requests by status
  Future<List<ApprovalRequest>> getRequestsByStatus(
    String workspaceId,
    RequestStatus status,
  ) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApprovalRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting requests by status', e);
      return [];
    }
  }

  /// Get requests by template
  Future<List<ApprovalRequest>> getRequestsByTemplate(String templateId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('templateId', isEqualTo: templateId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApprovalRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting requests for template: $templateId', e);
      return [];
    }
  }

  /// Update request
  Future<void> updateRequest(ApprovalRequest request) async {
    try {
      final data = request.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await firestore.collection(_collectionPath).doc(request.id).update(data);

      AppLogger.info('Updated request: ${request.id}');
    } catch (e) {
      AppLogger.error('Error updating request: ${request.id}', e);
      rethrow;
    }
  }

  /// Update request status
  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status, {
    int? currentLevel,
    String? approvedBy,
    String? rejectionReason,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (currentLevel != null) {
        updates['currentLevel'] = currentLevel;
      }

      if (approvedBy != null) {
        updates['approvedBy'] = FieldValue.arrayUnion([approvedBy]);
      }

      if (rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
      }

      await firestore
          .collection(_collectionPath)
          .doc(requestId)
          .update(updates);

      AppLogger.info('Updated request status: $requestId -> ${status.name}');
    } catch (e) {
      AppLogger.error('Error updating request status: $requestId', e);
      rethrow;
    }
  }

  /// Delete request
  Future<void> deleteRequest(String requestId) async {
    try {
      await firestore.collection(_collectionPath).doc(requestId).delete();
      AppLogger.info('Deleted request: $requestId');
    } catch (e) {
      AppLogger.error('Error deleting request: $requestId', e);
      rethrow;
    }
  }

  /// Delete all requests for a workspace
  Future<void> deleteRequestsForWorkspace(String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .get();

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      AppLogger.info(
          'Deleted ${snapshot.docs.length} requests for workspace: $workspaceId');
    } catch (e) {
      AppLogger.error('Error deleting requests for workspace: $workspaceId', e);
      rethrow;
    }
  }

  /// Get request count for workspace
  Future<int> getRequestCount(String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting request count', e);
      return 0;
    }
  }

  /// Get pending request count for approver
  Future<int> getPendingRequestCount(
      String workspaceId, String approverId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .where('status', isEqualTo: 'pending')
          .where('currentApproverIds', arrayContains: approverId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting pending request count', e);
      return 0;
    }
  }

  /// Stream requests for workspace (real-time updates)
  Stream<List<ApprovalRequest>> streamRequestsByWorkspace(String workspaceId) {
    return firestore
        .collection(_collectionPath)
        .where('workspaceId', isEqualTo: workspaceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApprovalRequest.fromJson(doc.data()))
            .toList());
  }

  /// Stream single request (real-time updates)
  Stream<ApprovalRequest?> streamRequest(String requestId) {
    return firestore
        .collection(_collectionPath)
        .doc(requestId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return ApprovalRequest.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Stream pending requests for approver (real-time updates)
  Stream<List<ApprovalRequest>> streamPendingRequestsForApprover(
    String workspaceId,
    String approverId,
  ) {
    return firestore
        .collection(_collectionPath)
        .where('workspaceId', isEqualTo: workspaceId)
        .where('status', isEqualTo: 'pending')
        .where('currentApproverIds', arrayContains: approverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApprovalRequest.fromJson(doc.data()))
            .toList());
  }
}
