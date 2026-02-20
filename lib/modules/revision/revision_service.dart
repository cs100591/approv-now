import 'dart:math';
import '../request/request_models.dart';
import '../template/template_models.dart';

/// RevisionService - Handles request revision logic
class RevisionService {
  /// Create new revision when request is edited
  Future<RevisionResult> createRevision({
    required ApprovalRequest request,
    required List<FieldValue> newFieldValues,
    required String editedBy,
  }) async {
    // Increment revision number
    final newRevisionNumber = request.revisionNumber + 1;

    // Create new revision entry
    final newRevision = RequestRevision(
      revisionNumber: newRevisionNumber,
      createdAt: DateTime.now(),
      fieldValues: newFieldValues,
    );

    // Mark old approval actions as obsolete
    final updatedActions = request.approvalActions.map((action) {
      return action.copyWith(isObsolete: true);
    }).toList();

    // Create updated request
    final updatedRequest = request.copyWith(
      revisionNumber: newRevisionNumber,
      currentLevel: 1, // Reset to first level
      status: RequestStatus.pending,
      fieldValues: newFieldValues,
      approvalActions: updatedActions,
      revisions: [...request.revisions, newRevision],
    );

    return RevisionResult(
      request: updatedRequest,
      newRevision: newRevision,
      oldActionsObsolete: true,
      restarted: true,
    );
  }

  /// Get revision history for a request
  List<RequestRevision> getRevisionHistory(ApprovalRequest request) {
    return request.revisions;
  }

  /// Get specific revision
  RequestRevision? getRevision(ApprovalRequest request, int revisionNumber) {
    try {
      return request.revisions
          .firstWhere((r) => r.revisionNumber == revisionNumber);
    } catch (e) {
      return null;
    }
  }

  /// Compare two revisions
  RevisionComparison compareRevisions(
    RequestRevision revision1,
    RequestRevision revision2,
  ) {
    final changes = <FieldChange>[];

    // Get all field IDs from both revisions
    final allFieldIds = {
      ...revision1.fieldValues.map((f) => f.fieldId),
      ...revision2.fieldValues.map((f) => f.fieldId),
    };

    for (final fieldId in allFieldIds) {
      final value1 = revision1.fieldValues.firstWhere(
        (f) => f.fieldId == fieldId,
        orElse: () => const FieldValue(
          fieldId: '',
          fieldName: '',
          fieldType: FieldType.text,
          value: null,
        ),
      );
      final value2 = revision2.fieldValues.firstWhere(
        (f) => f.fieldId == fieldId,
        orElse: () => const FieldValue(
          fieldId: '',
          fieldName: '',
          fieldType: FieldType.text,
          value: null,
        ),
      );

      if (value1.value != value2.value) {
        changes.add(FieldChange(
          fieldId: fieldId,
          fieldName:
              value2.fieldName.isNotEmpty ? value2.fieldName : value1.fieldName,
          oldValue: value1.value,
          newValue: value2.value,
        ));
      }
    }

    return RevisionComparison(
      revisionNumber1: revision1.revisionNumber,
      revisionNumber2: revision2.revisionNumber,
      changes: changes,
    );
  }

  /// Check if request needs restart notification
  bool shouldTriggerRestartNotification(ApprovalRequest request) {
    return request.revisionNumber > 1 && request.currentLevel == 1;
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}

/// Result of a revision operation
class RevisionResult {
  final ApprovalRequest request;
  final RequestRevision newRevision;
  final bool oldActionsObsolete;
  final bool restarted;

  const RevisionResult({
    required this.request,
    required this.newRevision,
    required this.oldActionsObsolete,
    required this.restarted,
  });
}

/// Comparison between two revisions
class RevisionComparison {
  final int revisionNumber1;
  final int revisionNumber2;
  final List<FieldChange> changes;

  const RevisionComparison({
    required this.revisionNumber1,
    required this.revisionNumber2,
    required this.changes,
  });

  bool get hasChanges => changes.isNotEmpty;
}

/// Individual field change
class FieldChange {
  final String fieldId;
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;

  const FieldChange({
    required this.fieldId,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
  });
}
