import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../../core/repositories/firestore_repository.dart';
import '../../core/utils/app_logger.dart';
import 'workspace_models.dart';

/// WorkspaceRepository - Handles workspace data with Firestore
///
/// Data Structure in Firestore:
/// Collection: workspaces
/// Document: {workspaceId}
///
/// Workspace ownership is determined by the `ownerId` field.
/// Members can access workspaces they are part of via the `members` array.
class WorkspaceRepository extends FirestoreRepository {
  static const String _collectionPath = 'workspaces';

  WorkspaceRepository({FirebaseFirestore? firestore})
      : super(firestore: firestore);

  /// Create a new workspace
  Future<Workspace> createWorkspace(Workspace workspace) async {
    try {
      final data = workspace.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = firestore.collection(_collectionPath).doc(workspace.id);
      await docRef.set(data);

      AppLogger.info('Created workspace: ${workspace.id}');
      return workspace;
    } catch (e) {
      AppLogger.error('Error creating workspace', e);
      rethrow;
    }
  }

  /// Get workspace by ID
  Future<Workspace?> getWorkspace(String workspaceId) async {
    try {
      final doc =
          await firestore.collection(_collectionPath).doc(workspaceId).get();

      if (doc.exists && doc.data() != null) {
        return Workspace.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting workspace: $workspaceId', e);
      return null;
    }
  }

  /// Get all workspaces for a user (owned or member)
  Future<List<Workspace>> getWorkspacesForUser(String userId) async {
    try {
      // Get workspaces where user is owner
      final ownerQuery = await firestore
          .collection(_collectionPath)
          .where('ownerId', isEqualTo: userId)
          .get();

      // Get workspaces where user is a member
      final memberQuery = await firestore
          .collection(_collectionPath)
          .where('memberIds', arrayContains: userId)
          .get();

      // Combine results
      final Map<String, Workspace> workspaceMap = {};

      for (final doc in ownerQuery.docs) {
        final workspace = Workspace.fromJson(doc.data());
        workspaceMap[workspace.id] = workspace;
      }

      for (final doc in memberQuery.docs) {
        final workspace = Workspace.fromJson(doc.data());
        workspaceMap[workspace.id] = workspace;
      }

      final workspaces = workspaceMap.values.toList();
      workspaces.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return workspaces;
    } catch (e) {
      AppLogger.error('Error getting workspaces for user: $userId', e);
      return [];
    }
  }

  /// Get all workspaces (for admin purposes)
  Future<List<Workspace>> getAllWorkspaces() async {
    try {
      final snapshot = await firestore.collection(_collectionPath).get();
      return snapshot.docs
          .map((doc) => Workspace.fromJson(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all workspaces', e);
      return [];
    }
  }

  /// Update workspace
  Future<void> updateWorkspace(Workspace workspace) async {
    try {
      final data = workspace.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await firestore
          .collection(_collectionPath)
          .doc(workspace.id)
          .update(data);

      AppLogger.info('Updated workspace: ${workspace.id}');
    } catch (e) {
      AppLogger.error('Error updating workspace: ${workspace.id}', e);
      rethrow;
    }
  }

  /// Update specific fields in workspace
  Future<void> updateWorkspaceFields(
    String workspaceId,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();

      await firestore
          .collection(_collectionPath)
          .doc(workspaceId)
          .update(fields);

      AppLogger.info('Updated workspace fields: $workspaceId');
    } catch (e) {
      AppLogger.error('Error updating workspace fields: $workspaceId', e);
      rethrow;
    }
  }

  /// Delete workspace
  Future<void> deleteWorkspace(String workspaceId) async {
    try {
      await firestore.collection(_collectionPath).doc(workspaceId).delete();
      AppLogger.info('Deleted workspace: $workspaceId');
    } catch (e) {
      AppLogger.error('Error deleting workspace: $workspaceId', e);
      rethrow;
    }
  }

  /// Add member to workspace
  Future<void> addMember(String workspaceId, String userId) async {
    try {
      await firestore.collection(_collectionPath).doc(workspaceId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('Added member $userId to workspace $workspaceId');
    } catch (e) {
      AppLogger.error('Error adding member to workspace', e);
      rethrow;
    }
  }

  /// Remove member from workspace
  Future<void> removeMember(String workspaceId, String userId) async {
    try {
      await firestore.collection(_collectionPath).doc(workspaceId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('Removed member $userId from workspace $workspaceId');
    } catch (e) {
      AppLogger.error('Error removing member from workspace', e);
      rethrow;
    }
  }

  /// Stream workspaces for user (real-time updates)
  Stream<List<Workspace>> streamWorkspacesForUser(String userId) {
    // Combine two streams: owner and member
    final ownerStream = firestore
        .collection(_collectionPath)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workspace.fromJson(doc.data()))
            .toList());

    final memberStream = firestore
        .collection(_collectionPath)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workspace.fromJson(doc.data()))
            .toList());

    // Combine streams
    return Rx.combineLatest2<List<Workspace>, List<Workspace>, List<Workspace>>(
      ownerStream,
      memberStream,
      (ownerWorkspaces, memberWorkspaces) {
        final Map<String, Workspace> workspaceMap = {};

        for (final workspace in ownerWorkspaces) {
          workspaceMap[workspace.id] = workspace;
        }

        for (final workspace in memberWorkspaces) {
          workspaceMap[workspace.id] = workspace;
        }

        final workspaces = workspaceMap.values.toList();
        workspaces.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return workspaces;
      },
    );
  }

  /// Stream single workspace (real-time updates)
  Stream<Workspace?> streamWorkspace(String workspaceId) {
    return firestore
        .collection(_collectionPath)
        .doc(workspaceId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return Workspace.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Check if workspace exists for user
  Future<bool> hasWorkspace(String userId) async {
    try {
      final query = await firestore
          .collection(_collectionPath)
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking workspace existence', e);
      return false;
    }
  }

  /// Get workspace count for user
  Future<int> getWorkspaceCount(String userId) async {
    try {
      final workspaces = await getWorkspacesForUser(userId);
      return workspaces.length;
    } catch (e) {
      AppLogger.error('Error getting workspace count', e);
      return 0;
    }
  }

  // Legacy methods for backward compatibility (using local storage)
  // These will be removed after migration is complete

  Future<void> saveCurrentWorkspaceLocal(Workspace workspace) async {
    // Keep for local caching if needed
  }

  Future<Workspace?> getCurrentWorkspaceLocal() async {
    // Keep for local caching if needed
    return null;
  }

  Future<void> clearCurrentWorkspaceLocal() async {
    // Keep for local caching if needed
  }
}
