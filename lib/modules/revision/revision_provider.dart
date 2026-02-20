import 'package:flutter/foundation.dart';
import '../request/request_models.dart';
import 'revision_service.dart';

class RevisionProvider extends ChangeNotifier {
  final RevisionService _revisionService;

  RevisionState _state = const RevisionState();

  RevisionProvider({
    required RevisionService revisionService,
  }) : _revisionService = revisionService;

  RevisionState get state => _state;
  List<RequestRevision> get revisions => _state.revisions;
  RevisionComparison? get comparison => _state.comparison;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  /// Create new revision
  Future<RevisionResult?> createRevision({
    required ApprovalRequest request,
    required List<FieldValue> newFieldValues,
    required String editedBy,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _revisionService.createRevision(
        request: request,
        newFieldValues: newFieldValues,
        editedBy: editedBy,
      );

      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Load revision history
  void loadRevisionHistory(ApprovalRequest request) {
    final revisions = _revisionService.getRevisionHistory(request);
    _state = _state.copyWith(revisions: revisions);
    notifyListeners();
  }

  /// Load specific revision
  void loadRevision(ApprovalRequest request, int revisionNumber) {
    final revision = _revisionService.getRevision(request, revisionNumber);
    _state = _state.copyWith(selectedRevision: revision);
    notifyListeners();
  }

  /// Compare two revisions
  void compareRevisions(int revisionNumber1, int revisionNumber2) {
    final revision1 = _state.revisions.firstWhere(
      (r) => r.revisionNumber == revisionNumber1,
      orElse: () => throw Exception('Revision $revisionNumber1 not found'),
    );
    final revision2 = _state.revisions.firstWhere(
      (r) => r.revisionNumber == revisionNumber2,
      orElse: () => throw Exception('Revision $revisionNumber2 not found'),
    );

    final comparison = _revisionService.compareRevisions(revision1, revision2);
    _state = _state.copyWith(comparison: comparison);
    notifyListeners();
  }

  /// Check if restart notification should be triggered
  bool shouldTriggerRestartNotification(ApprovalRequest request) {
    return _revisionService.shouldTriggerRestartNotification(request);
  }

  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
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

  void clearComparison() {
    _state = _state.copyWith(comparison: null);
    notifyListeners();
  }
}

/// State for revision provider
class RevisionState {
  final List<RequestRevision> revisions;
  final RequestRevision? selectedRevision;
  final RevisionComparison? comparison;
  final bool isLoading;
  final String? error;

  const RevisionState({
    this.revisions = const [],
    this.selectedRevision,
    this.comparison,
    this.isLoading = false,
    this.error,
  });

  RevisionState copyWith({
    List<RequestRevision>? revisions,
    RequestRevision? selectedRevision,
    RevisionComparison? comparison,
    bool? isLoading,
    String? error,
  }) {
    return RevisionState(
      revisions: revisions ?? this.revisions,
      selectedRevision: selectedRevision ?? this.selectedRevision,
      comparison: comparison ?? this.comparison,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
