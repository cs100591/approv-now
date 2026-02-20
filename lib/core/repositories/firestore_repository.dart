import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_logger.dart';

/// Base repository for Firestore operations
/// Provides common CRUD operations with user isolation
abstract class FirestoreRepository {
  final FirebaseFirestore _firestore;

  FirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Create document with auto-generated ID
  Future<String> create({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = await _firestore.collection(collectionPath).add(data);
      AppLogger.info('Created document: ${docRef.id} in $collectionPath');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating document in $collectionPath', e);
      rethrow;
    }
  }

  /// Create document with specific ID
  Future<void> createWithId({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).set(data);
      AppLogger.info('Created document: $documentId in $collectionPath');
    } catch (e) {
      AppLogger.error(
          'Error creating document $documentId in $collectionPath', e);
      rethrow;
    }
  }

  /// Get document by ID
  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      final doc =
          await _firestore.collection(collectionPath).doc(documentId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (e) {
      AppLogger.error(
          'Error getting document $documentId from $collectionPath', e);
      return null;
    }
  }

  /// Get all documents from collection
  Future<List<Map<String, dynamic>>> getAll({
    required String collectionPath,
  }) async {
    try {
      final snapshot = await _firestore.collection(collectionPath).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('Error getting all documents from $collectionPath', e);
      return [];
    }
  }

  /// Query documents with filters
  Future<List<Map<String, dynamic>>> query({
    required String collectionPath,
    required List<QueryFilter> filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      // Apply filters
      for (final filter in filters) {
        query = query.where(filter.field, isEqualTo: filter.value);
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('Error querying $collectionPath', e);
      return [];
    }
  }

  /// Update document
  Future<void> update({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update(data);
      AppLogger.info('Updated document: $documentId in $collectionPath');
    } catch (e) {
      AppLogger.error(
          'Error updating document $documentId in $collectionPath', e);
      rethrow;
    }
  }

  /// Delete document
  Future<void> delete({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
      AppLogger.info('Deleted document: $documentId from $collectionPath');
    } catch (e) {
      AppLogger.error(
          'Error deleting document $documentId from $collectionPath', e);
      rethrow;
    }
  }

  /// Delete all documents matching query
  Future<int> deleteWhere({
    required String collectionPath,
    required List<QueryFilter> filters,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      for (final filter in filters) {
        query = query.where(filter.field, isEqualTo: filter.value);
      }

      final snapshot = await query.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      AppLogger.info(
          'Deleted ${snapshot.docs.length} documents from $collectionPath');
      return snapshot.docs.length;
    } catch (e) {
      AppLogger.error('Error deleting documents from $collectionPath', e);
      return 0;
    }
  }

  /// Stream document changes
  Stream<Map<String, dynamic>?> streamDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return _firestore
        .collection(collectionPath)
        .doc(documentId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    });
  }

  /// Stream collection changes
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collectionPath,
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    if (filters != null) {
      for (final filter in filters) {
        query = query.where(filter.field, isEqualTo: filter.value);
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Batch write multiple documents
  Future<void> batchWrite({
    required List<BatchOperation> operations,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final op in operations) {
        final docRef =
            _firestore.collection(op.collectionPath).doc(op.documentId);

        switch (op.type) {
          case BatchOperationType.create:
            batch.set(docRef, op.data);
            break;
          case BatchOperationType.update:
            batch.update(docRef, op.data);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      AppLogger.info('Batch write completed: ${operations.length} operations');
    } catch (e) {
      AppLogger.error('Error in batch write', e);
      rethrow;
    }
  }

  /// Run transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    return await _firestore.runTransaction(transactionHandler);
  }
}

/// Query filter helper
class QueryFilter {
  final String field;
  final dynamic value;

  const QueryFilter({
    required this.field,
    required this.value,
  });
}

/// Batch operation helper
class BatchOperation {
  final BatchOperationType type;
  final String collectionPath;
  final String documentId;
  final Map<String, dynamic> data;

  const BatchOperation({
    required this.type,
    required this.collectionPath,
    required this.documentId,
    this.data = const {},
  });
}

enum BatchOperationType {
  create,
  update,
  delete,
}
