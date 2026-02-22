import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../request/request_models.dart';

/// HashService - Handles SHA-256 hash generation and verification
class HashService {
  /// Generate SHA-256 hash for request verification
  ///
  /// Hash formula includes:
  /// - workspaceId
  /// - requestId
  /// - revisionNumber
  /// - submittedBy
  /// - approvalActions
  /// - field values
  String generateHash({
    required String workspaceId,
    required String requestId,
    required int revisionNumber,
    required String submittedBy,
    required List<ApprovalAction> approvalActions,
    required List<FieldValue> fieldValues,
  }) {
    // Build data string
    final buffer = StringBuffer();
    buffer.write(workspaceId);
    buffer.write('|');
    buffer.write(requestId);
    buffer.write('|');
    buffer.write(revisionNumber);
    buffer.write('|');
    buffer.write(submittedBy);
    buffer.write('|');

    // Add approval actions (only non-obsolete)
    final validActions = approvalActions.where((a) => !a.isObsolete).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final action in validActions) {
      buffer.write(action.approverId);
      buffer.write(':');
      buffer.write(action.level);
      buffer.write(':');
      buffer.write(action.approved ? '1' : '0');
      buffer.write('|');
    }

    // Add field values
    final sortedFields = fieldValues.toList()
      ..sort((a, b) => a.fieldId.compareTo(b.fieldId));

    for (final field in sortedFields) {
      buffer.write(field.fieldId);
      buffer.write(':');
      buffer.write(field.value?.toString() ?? '');
      buffer.write('|');
    }

    // Generate SHA-256 hash
    final bytes = utf8.encode(buffer.toString());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify hash against current request data
  VerificationResult verifyHash({
    required String hash,
    required String workspaceId,
    required String requestId,
    required int revisionNumber,
    required String submittedBy,
    required List<ApprovalAction> approvalActions,
    required List<FieldValue> fieldValues,
  }) {
    final currentHash = generateHash(
      workspaceId: workspaceId,
      requestId: requestId,
      revisionNumber: revisionNumber,
      submittedBy: submittedBy,
      approvalActions: approvalActions,
      fieldValues: fieldValues,
    );

    if (currentHash == hash) {
      return VerificationResult.valid();
    }

    // Check if this is a superseded revision
    // (hash doesn't match but request data is valid for an older revision)
    return VerificationResult.superseded();
  }

  /// Verify hash for a specific revision
  VerificationResult verifyRevisionHash({
    required String hash,
    required RequestRevision revision,
    required String workspaceId,
    required String requestId,
    required String submittedBy,
  }) {
    final revisionHash = generateHash(
      workspaceId: workspaceId,
      requestId: requestId,
      revisionNumber: revision.revisionNumber,
      submittedBy: submittedBy,
      approvalActions: revision.approvalActions,
      fieldValues: revision.fieldValues,
    );

    if (revisionHash == hash) {
      return VerificationResult.valid();
    }

    return VerificationResult.invalid();
  }

  /// Generate short hash (first 16 chars) for display
  String generateShortHash({
    required String workspaceId,
    required String requestId,
    required int revisionNumber,
    required String submittedBy,
    required List<ApprovalAction> approvalActions,
    required List<FieldValue> fieldValues,
  }) {
    final fullHash = generateHash(
      workspaceId: workspaceId,
      requestId: requestId,
      revisionNumber: revisionNumber,
      submittedBy: submittedBy,
      approvalActions: approvalActions,
      fieldValues: fieldValues,
    );
    return fullHash.substring(0, 16);
  }
}

/// Verification result
class VerificationResult {
  final VerificationStatus status;
  final String? message;

  const VerificationResult._(this.status, [this.message]);

  factory VerificationResult.valid() =>
      const VerificationResult._(VerificationStatus.valid);

  factory VerificationResult.invalid([String? message]) =>
      VerificationResult._(VerificationStatus.invalid, message);

  factory VerificationResult.superseded([String? message]) =>
      VerificationResult._(VerificationStatus.superseded, message);

  bool get isValid => status == VerificationStatus.valid;
  bool get isInvalid => status == VerificationStatus.invalid;
  bool get isSuperseded => status == VerificationStatus.superseded;
}

/// Verification status
enum VerificationStatus {
  valid,
  invalid,
  superseded,
}
