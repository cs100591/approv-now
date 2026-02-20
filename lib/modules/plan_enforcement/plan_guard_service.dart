import 'dart:math';
import '../subscription/subscription_models.dart';

/// PlanGuardService - Enforces plan limits before actions
class PlanGuardService {
  /// Check if user can create a template
  static bool canCreateTemplate({
    required PlanType currentPlan,
    required int currentTemplateCount,
  }) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    return currentTemplateCount < entitlements.maxTemplates;
  }

  /// Check if user can add approval level
  static bool canAddApprovalLevel({
    required PlanType currentPlan,
    required int currentLevelCount,
  }) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    return currentLevelCount < entitlements.maxApprovalLevels;
  }

  /// Check if user can create workspace
  static bool canCreateWorkspace({
    required PlanType currentPlan,
    required int currentWorkspaceCount,
  }) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    return currentWorkspaceCount < entitlements.maxWorkspaces;
  }

  /// Check if custom header is available
  static bool canUseCustomHeader(PlanType currentPlan) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    return entitlements.customHeader;
  }

  /// Check if watermark should be applied
  static bool shouldApplyWatermark(PlanType currentPlan) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    return entitlements.watermark;
  }

  /// Check if analytics is available
  static bool canUseAnalytics(PlanType currentPlan) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    return entitlements.analytics;
  }

  /// Validate action or throw exception
  static void validateOrThrow({
    required PlanType currentPlan,
    required PlanAction action,
    required int currentCount,
  }) {
    bool canPerform;

    switch (action) {
      case PlanAction.createTemplate:
        canPerform = canCreateTemplate(
          currentPlan: currentPlan,
          currentTemplateCount: currentCount,
        );
        if (!canPerform) {
          throw PlanLimitExceededException(
            'Template limit reached for ${currentPlan.name} plan. '
            'Upgrade to create more templates.',
          );
        }
        break;

      case PlanAction.addApprovalLevel:
        canPerform = canAddApprovalLevel(
          currentPlan: currentPlan,
          currentLevelCount: currentCount,
        );
        if (!canPerform) {
          throw PlanLimitExceededException(
            'Approval level limit reached for ${currentPlan.name} plan. '
            'Upgrade to add more levels.',
          );
        }
        break;

      case PlanAction.createWorkspace:
        canPerform = canCreateWorkspace(
          currentPlan: currentPlan,
          currentWorkspaceCount: currentCount,
        );
        if (!canPerform) {
          throw PlanLimitExceededException(
            'Workspace limit reached for ${currentPlan.name} plan. '
            'Upgrade to create more workspaces.',
          );
        }
        break;

      case PlanAction.useCustomHeader:
        canPerform = canUseCustomHeader(currentPlan);
        if (!canPerform) {
          throw PlanLimitExceededException(
            'Custom headers are only available on Pro plan. '
            'Upgrade to access this feature.',
          );
        }
        break;
    }
  }

  /// Get remaining quota
  static int getRemainingQuota({
    required PlanType currentPlan,
    required PlanAction action,
    required int currentCount,
  }) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);

    switch (action) {
      case PlanAction.createTemplate:
        return entitlements.maxTemplates - currentCount;
      case PlanAction.addApprovalLevel:
        return entitlements.maxApprovalLevels - currentCount;
      case PlanAction.createWorkspace:
        return entitlements.maxWorkspaces - currentCount;
      default:
        return 0;
    }
  }

  /// Get plan limits as map
  static Map<String, int> getPlanLimits(PlanType plan) {
    final entitlements = PlanEntitlements.forPlan(plan);
    return {
      'maxTemplates': entitlements.maxTemplates,
      'maxApprovalLevels': entitlements.maxApprovalLevels,
      'maxWorkspaces': entitlements.maxWorkspaces,
    };
  }
}

/// Plan actions that can be guarded
enum PlanAction {
  createTemplate,
  addApprovalLevel,
  createWorkspace,
  useCustomHeader,
}

/// Exception thrown when plan limit is exceeded
class PlanLimitExceededException implements Exception {
  final String message;

  PlanLimitExceededException(this.message);

  @override
  String toString() => message;
}
