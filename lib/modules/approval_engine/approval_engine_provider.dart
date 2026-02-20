import 'package:flutter/foundation.dart';
import '../request/request_models.dart';
import '../template/template_models.dart';
import 'approval_engine_service.dart';

class ApprovalEngineProvider extends ChangeNotifier {
  final ApprovalEngineService _approvalEngineService;

  ApprovalEngineState _state = const ApprovalEngineState();

  ApprovalEngineProvider({
    required ApprovalEngineService approvalEngineService,
  }) : _approvalEngineService = approvalEngineService;

  ApprovalEngineState get state => _state;
  bool get isProcessing => _state.isProcessing;
  ApprovalProgress? get progress => _state.progress;
  String? get error => _state.error;

  /// Execute approval action
  Future<ApprovalResult?> approve({
    required ApprovalRequest request,
    required Template template,
    required String approverId,
    required String approverName,
    String? comment,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      final result = await _approvalEngineService.executeApproval(
        request: request,
        template: template,
        approverId: approverId,
        approverName: approverName,
        comment: comment,
      );

      // Update progress
      final progress =
          _approvalEngineService.getProgress(result.request, template);
      _state = _state.copyWith(progress: progress);

      _setProcessing(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setProcessing(false);
      return null;
    }
  }

  /// Execute rejection action
  Future<ApprovalResult?> reject({
    required ApprovalRequest request,
    required Template template,
    required String approverId,
    required String approverName,
    String? comment,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      final result = await _approvalEngineService.executeRejection(
        request: request,
        template: template,
        approverId: approverId,
        approverName: approverName,
        comment: comment,
      );

      _setProcessing(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setProcessing(false);
      return null;
    }
  }

  /// Load approval progress for a request
  void loadProgress(ApprovalRequest request, Template template) {
    final progress = _approvalEngineService.getProgress(request, template);
    _state = _state.copyWith(progress: progress);
    notifyListeners();
  }

  /// Check if user can approve at current level
  bool canUserApprove(
      ApprovalRequest request, Template template, String userId) {
    try {
      final approvers =
          _approvalEngineService.getCurrentLevelApprovers(request, template);
      return approvers.contains(userId);
    } catch (e) {
      return false;
    }
  }

  /// Get current level approvers
  List<String> getCurrentApprovers(ApprovalRequest request, Template template) {
    try {
      return _approvalEngineService.getCurrentLevelApprovers(request, template);
    } catch (e) {
      return [];
    }
  }

  void _setProcessing(bool processing) {
    _state = _state.copyWith(isProcessing: processing);
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

  void clearProgress() {
    _state = _state.copyWith(progress: null);
    notifyListeners();
  }
}

/// State for approval engine provider
class ApprovalEngineState {
  final bool isProcessing;
  final ApprovalProgress? progress;
  final String? error;

  const ApprovalEngineState({
    this.isProcessing = false,
    this.progress,
    this.error,
  });

  ApprovalEngineState copyWith({
    bool? isProcessing,
    ApprovalProgress? progress,
    String? error,
  }) {
    return ApprovalEngineState(
      isProcessing: isProcessing ?? this.isProcessing,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}
