import '../request/request_models.dart';
import '../template/template_models.dart';
import '../../core/utils/id_generator.dart';

/// ApprovalEngineService - Handles sequential approval logic
class ApprovalEngineService {
  /// Execute approval action and determine next state
  Future<ApprovalResult> executeApproval({
    required ApprovalRequest request,
    required Template template,
    required String approverId,
    required String approverName,
    String? comment,
  }) async {
    // Validate approver can approve at current level
    final currentStep = template.approvalSteps.firstWhere(
        (s) => s.level == request.currentLevel,
        orElse: () => throw Exception('No approval step found'));

    if (!currentStep.approvers.contains(approverId)) {
      throw Exception('Approver not authorized for this level');
    }

    // Check if all required approvers have approved at this level
    final levelApprovals = request.currentApprovalActions
        .where((a) => a.level == request.currentLevel && a.approved)
        .toList();

    final hasApproved = levelApprovals.any((a) => a.approverId == approverId);
    if (hasApproved) {
      throw Exception('Already approved at this level');
    }

    // Create approval action
    final action = ApprovalAction(
      id: _generateId(),
      level: request.currentLevel,
      approverId: approverId,
      approverName: approverName,
      approved: true,
      comment: comment,
      timestamp: DateTime.now(),
    );

    // Determine if we can advance to next level
    final canAdvance = _canAdvanceToNextLevel(
      currentStep: currentStep,
      levelApprovals: [...levelApprovals, action],
    );

    // Determine next state
    ApprovalRequest updatedRequest;
    bool isFinalized = false;

    if (canAdvance) {
      final nextLevel = request.currentLevel + 1;
      final maxLevel = template.maxApprovalLevel;

      if (nextLevel > maxLevel) {
        // Final approval
        updatedRequest = request.copyWith(
          status: RequestStatus.approved,
          approvalActions: [...request.approvalActions, action],
        );
        isFinalized = true;
      } else {
        // Advance to next level
        updatedRequest = request.copyWith(
          currentLevel: nextLevel,
          approvalActions: [...request.approvalActions, action],
        );
      }
    } else {
      // Still waiting for more approvals at this level
      updatedRequest = request.copyWith(
        approvalActions: [...request.approvalActions, action],
      );
    }

    return ApprovalResult(
      request: updatedRequest,
      action: action,
      advanced: canAdvance && !isFinalized,
      finalized: isFinalized,
    );
  }

  /// Execute rejection
  Future<ApprovalResult> executeRejection({
    required ApprovalRequest request,
    required Template template,
    required String approverId,
    required String approverName,
    String? comment,
  }) async {
    // Validate approver can reject at current level
    final currentStep = template.approvalSteps.firstWhere(
        (s) => s.level == request.currentLevel,
        orElse: () => throw Exception('No approval step found'));

    if (!currentStep.approvers.contains(approverId)) {
      throw Exception('Approver not authorized for this level');
    }

    final action = ApprovalAction(
      id: _generateId(),
      level: request.currentLevel,
      approverId: approverId,
      approverName: approverName,
      approved: false,
      comment: comment,
      timestamp: DateTime.now(),
    );

    final updatedRequest = request.copyWith(
      status: RequestStatus.rejected,
      approvalActions: [...request.approvalActions, action],
    );

    return ApprovalResult(
      request: updatedRequest,
      action: action,
      advanced: false,
      finalized: true,
    );
  }

  /// Check if request can advance to next level
  bool _canAdvanceToNextLevel({
    required ApprovalStep currentStep,
    required List<ApprovalAction> levelApprovals,
  }) {
    if (currentStep.requireAll) {
      // All approvers must approve
      return levelApprovals.length >= currentStep.approvers.length;
    } else {
      // Any single approver can approve
      return levelApprovals.isNotEmpty;
    }
  }

  /// Get current approval progress
  ApprovalProgress getProgress(ApprovalRequest request, Template template) {
    final currentStep = template.approvalSteps.firstWhere(
        (s) => s.level == request.currentLevel,
        orElse: () => template.approvalSteps.first);

    final levelApprovals = request.currentApprovalActions
        .where((a) => a.level == request.currentLevel && a.approved)
        .length;

    final requiredApprovals =
        currentStep.requireAll ? currentStep.approvers.length : 1;

    return ApprovalProgress(
      currentLevel: request.currentLevel,
      maxLevel: template.maxApprovalLevel,
      currentApprovals: levelApprovals,
      requiredApprovals: requiredApprovals,
      percentage: template.maxApprovalLevel > 0
          ? (request.currentLevel - 1) / template.maxApprovalLevel
          : 0.0,
    );
  }

  /// Get approvers for current level
  List<String> getCurrentLevelApprovers(
      ApprovalRequest request, Template template) {
    final currentStep = template.approvalSteps.firstWhere(
        (s) => s.level == request.currentLevel,
        orElse: () => throw Exception('No approval step'));
    return currentStep.approvers;
  }

  String _generateId() {
    return IdGenerator.generateId();
  }
}

/// Result of an approval action
class ApprovalResult {
  final ApprovalRequest request;
  final ApprovalAction action;
  final bool advanced;
  final bool finalized;

  const ApprovalResult({
    required this.request,
    required this.action,
    required this.advanced,
    required this.finalized,
  });
}

/// Approval progress tracking
class ApprovalProgress {
  final int currentLevel;
  final int maxLevel;
  final int currentApprovals;
  final int requiredApprovals;
  final double percentage;

  const ApprovalProgress({
    required this.currentLevel,
    required this.maxLevel,
    required this.currentApprovals,
    required this.requiredApprovals,
    required this.percentage,
  });

  bool get isComplete => currentLevel > maxLevel;
  bool get canAdvance => currentApprovals >= requiredApprovals;
}
