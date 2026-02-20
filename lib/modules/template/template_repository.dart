import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/repositories/firestore_repository.dart';
import '../../core/utils/app_logger.dart';
import 'template_models.dart';

/// TemplateRepository - Handles template data with Firestore
///
/// Data Structure in Firestore:
/// Collection: templates
/// Document: {templateId}
///
/// Templates are associated with workspaces via the `workspaceId` field.
/// Access is controlled by workspace membership.
class TemplateRepository extends FirestoreRepository {
  static const String _collectionPath = 'templates';

  TemplateRepository({FirebaseFirestore? firestore})
      : super(firestore: firestore);

  /// Create a new template
  Future<Template> createTemplate(Template template) async {
    try {
      final data = template.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await firestore.collection(_collectionPath).doc(template.id).set(data);

      AppLogger.info('Created template: ${template.id}');
      return template;
    } catch (e) {
      AppLogger.error('Error creating template', e);
      rethrow;
    }
  }

  /// Get template by ID
  Future<Template?> getTemplate(String templateId) async {
    try {
      final doc =
          await firestore.collection(_collectionPath).doc(templateId).get();

      if (doc.exists && doc.data() != null) {
        return Template.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting template: $templateId', e);
      return null;
    }
  }

  /// Get all templates for a workspace
  Future<List<Template>> getTemplatesByWorkspace(String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Template.fromJson(doc.data())).toList();
    } catch (e) {
      AppLogger.error('Error getting templates for workspace: $workspaceId', e);
      return [];
    }
  }

  /// Get templates by creator
  Future<List<Template>> getTemplatesByCreator(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Template.fromJson(doc.data())).toList();
    } catch (e) {
      AppLogger.error('Error getting templates for creator: $userId', e);
      return [];
    }
  }

  /// Get active templates for a workspace
  Future<List<Template>> getActiveTemplates(String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Template.fromJson(doc.data())).toList();
    } catch (e) {
      AppLogger.error(
          'Error getting active templates for workspace: $workspaceId', e);
      return [];
    }
  }

  /// Update template
  Future<void> updateTemplate(Template template) async {
    try {
      final data = template.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await firestore.collection(_collectionPath).doc(template.id).update(data);

      AppLogger.info('Updated template: ${template.id}');
    } catch (e) {
      AppLogger.error('Error updating template: ${template.id}', e);
      rethrow;
    }
  }

  /// Update template status
  Future<void> updateTemplateStatus(String templateId, bool isActive) async {
    try {
      await firestore.collection(_collectionPath).doc(templateId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Updated template status: $templateId -> $isActive');
    } catch (e) {
      AppLogger.error('Error updating template status: $templateId', e);
      rethrow;
    }
  }

  /// Delete template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await firestore.collection(_collectionPath).doc(templateId).delete();
      AppLogger.info('Deleted template: $templateId');
    } catch (e) {
      AppLogger.error('Error deleting template: $templateId', e);
      rethrow;
    }
  }

  /// Delete all templates for a workspace
  Future<void> deleteTemplatesForWorkspace(String workspaceId) async {
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
          'Deleted ${snapshot.docs.length} templates for workspace: $workspaceId');
    } catch (e) {
      AppLogger.error(
          'Error deleting templates for workspace: $workspaceId', e);
      rethrow;
    }
  }

  /// Get template count for workspace
  Future<int> getTemplateCount(String workspaceId) async {
    try {
      final snapshot = await firestore
          .collection(_collectionPath)
          .where('workspaceId', isEqualTo: workspaceId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting template count', e);
      return 0;
    }
  }

  /// Stream templates for workspace (real-time updates)
  Stream<List<Template>> streamTemplatesByWorkspace(String workspaceId) {
    return firestore
        .collection(_collectionPath)
        .where('workspaceId', isEqualTo: workspaceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Template.fromJson(doc.data())).toList());
  }

  /// Stream single template (real-time updates)
  Stream<Template?> streamTemplate(String templateId) {
    return firestore
        .collection(_collectionPath)
        .doc(templateId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return Template.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Stream active templates for workspace (real-time updates)
  Stream<List<Template>> streamActiveTemplates(String workspaceId) {
    return firestore
        .collection(_collectionPath)
        .where('workspaceId', isEqualTo: workspaceId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Template.fromJson(doc.data())).toList());
  }
}
