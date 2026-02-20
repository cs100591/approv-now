import 'package:flutter/foundation.dart';
import '../request/request_models.dart';
import 'hash_service.dart';

class VerificationProvider extends ChangeNotifier {
  final HashService _hashService;

  VerificationState _state = const VerificationState();

  VerificationProvider({
    required HashService hashService,
  }) : _hashService = hashService;

  VerificationState get state => _state;
  VerificationResult? get result => _state.result;
  bool get isVerifying => _state.isVerifying;
  String? get error => _state.error;

  /// Generate hash for request
  String generateHash(ApprovalRequest request) {
    return _hashService.generateHash(
      workspaceId: request.workspaceId,
      requestId: request.id,
      revisionNumber: request.revisionNumber,
      submittedBy: request.submittedBy,
      approvalActions: request.currentApprovalActions,
      fieldValues: request.fieldValues,
    );
  }

  /// Generate short hash for display
  String generateShortHash(ApprovalRequest request) {
    return _hashService.generateShortHash(
      workspaceId: request.workspaceId,
      requestId: request.id,
      revisionNumber: request.revisionNumber,
      submittedBy: request.submittedBy,
      approvalActions: request.currentApprovalActions,
      fieldValues: request.fieldValues,
    );
  }

  /// Verify hash against request
  Future<void> verifyHash({
    required String hash,
    required ApprovalRequest request,
  }) async {
    _setVerifying(true);
    _clearError();

    try {
      final result = _hashService.verifyHash(
        hash: hash,
        workspaceId: request.workspaceId,
        requestId: request.id,
        revisionNumber: request.revisionNumber,
        submittedBy: request.submittedBy,
        approvalActions: request.currentApprovalActions,
        fieldValues: request.fieldValues,
      );

      _state = _state.copyWith(result: result);
    } catch (e) {
      _setError(e.toString());
    }

    _setVerifying(false);
  }

  /// Verify hash against specific revision
  Future<void> verifyRevisionHash({
    required String hash,
    required RequestRevision revision,
    required String workspaceId,
    required String requestId,
    required String submittedBy,
  }) async {
    _setVerifying(true);
    _clearError();

    try {
      final result = _hashService.verifyRevisionHash(
        hash: hash,
        revision: revision,
        workspaceId: workspaceId,
        requestId: requestId,
        submittedBy: submittedBy,
      );

      _state = _state.copyWith(result: result);
    } catch (e) {
      _setError(e.toString());
    }

    _setVerifying(false);
  }

  /// Check all revisions for a matching hash
  Future<void> verifyAgainstAllRevisions({
    required String hash,
    required ApprovalRequest request,
  }) async {
    _setVerifying(true);
    _clearError();

    try {
      // Check current state first
      VerificationResult result = _hashService.verifyHash(
        hash: hash,
        workspaceId: request.workspaceId,
        requestId: request.id,
        revisionNumber: request.revisionNumber,
        submittedBy: request.submittedBy,
        approvalActions: request.currentApprovalActions,
        fieldValues: request.fieldValues,
      );

      // If not valid, check historical revisions
      if (!result.isValid) {
        for (final revision in request.revisions) {
          final revisionResult = _hashService.verifyRevisionHash(
            hash: hash,
            revision: revision,
            workspaceId: request.workspaceId,
            requestId: request.id,
            submittedBy: request.submittedBy,
          );

          if (revisionResult.isValid) {
            result = VerificationResult.superseded();
            break;
          }
        }
      }

      _state = _state.copyWith(result: result);
    } catch (e) {
      _setError(e.toString());
    }

    _setVerifying(false);
  }

  void _setVerifying(bool verifying) {
    _state = _state.copyWith(isVerifying: verifying);
    notifyListeners();
  }

  void _setError(String error) {
    _state = _state.copyWith(error: error);
    notifyListeners();
  }

  void _clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  void clearResult() {
    _state = _state.copyWith(result: null);
    notifyListeners();
  }
}

/// State for verification provider
class VerificationState {
  final VerificationResult? result;
  final bool isVerifying;
  final String? error;

  const VerificationState({
    this.result,
    this.isVerifying = false,
    this.error,
  });

  VerificationState copyWith({
    VerificationResult? result,
    bool? isVerifying,
    String? error,
  }) {
    return VerificationState(
      result: result ?? this.result,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error ?? this.error,
    );
  }
}
