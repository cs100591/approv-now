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

  /// Check if user can invite team member
  static bool canInviteTeamMember({
    required PlanType currentPlan,
    required int currentMemberCount,
  }) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    return currentMemberCount < entitlements.maxTeamMembers;
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

      case PlanAction.inviteTeamMember:
        canPerform = canInviteTeamMember(
          currentPlan: currentPlan,
          currentMemberCount: currentCount,
        );
        if (!canPerform) {
          throw PlanLimitExceededException(
            'Team member limit reached for ${currentPlan.name} plan. '
            'Upgrade to invite more team members.',
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
      case PlanAction.inviteTeamMember:
        return entitlements.maxTeamMembers - currentCount;
      default:
        return 0;
    }
  }

  /// Get plan limits as map
  static Map<String, dynamic> getPlanLimits(PlanType plan) {
    final entitlements = PlanEntitlements.forPlan(plan);
    return {
      'maxTemplates': entitlements.maxTemplates,
      'maxApprovalLevels': entitlements.maxApprovalLevels,
      'maxWorkspaces': entitlements.maxWorkspaces,
      'maxTeamMembers': entitlements.maxTeamMembers,
    };
  }

  /// Get usage percentage for a resource
  static double getUsagePercentage({
    required PlanType currentPlan,
    required PlanAction action,
    required int currentCount,
  }) {
    final entitlements = PlanEntitlements.forPlan(currentPlan);
    int max;

    switch (action) {
      case PlanAction.createTemplate:
        max = entitlements.maxTemplates;
        break;
      case PlanAction.addApprovalLevel:
        max = entitlements.maxApprovalLevels;
        break;
      case PlanAction.createWorkspace:
        max = entitlements.maxWorkspaces;
        break;
      case PlanAction.inviteTeamMember:
        max = entitlements.maxTeamMembers;
        break;
      default:
        return 0.0;
    }

    if (max == 0) return 1.0;
    return (currentCount / max).clamp(0.0, 1.0);
  }

  /// Check if usage is approaching limit (80% threshold)
  static bool isApproachingLimit({
    required PlanType currentPlan,
    required PlanAction action,
    required int currentCount,
    double threshold = 0.8,
  }) {
    final percentage = getUsagePercentage(
      currentPlan: currentPlan,
      action: action,
      currentCount: currentCount,
    );
    return percentage >= threshold && percentage < 1.0;
  }

  /// Get plan comparison data for upgrade dialog
  static List<PlanComparison> getPlanComparisons() {
    return [
      PlanComparison(
        plan: PlanType.free,
        price: 'Free',
        features: [
          '3 templates',
          '2 approval levels',
          '1 workspace',
          '3 team members',
          'Basic analytics',
        ],
        limitations: [
          'PDF watermark',
          'No custom headers',
        ],
      ),
      PlanComparison(
        plan: PlanType.starter,
        price: '\$9/month',
        features: [
          '10 templates',
          '5 approval levels',
          '3 workspaces',
          '10 team members',
          'Full analytics',
          'No watermark',
        ],
        limitations: [
          'No custom headers',
        ],
      ),
      PlanComparison(
        plan: PlanType.pro,
        price: '\$29/month',
        features: [
          '100 templates',
          '10 approval levels',
          '10 workspaces',
          '50 team members',
          'Full analytics',
          'Custom PDF headers',
          'Priority support',
        ],
        limitations: [],
      ),
    ];
  }
}

/// Plan actions that can be guarded
enum PlanAction {
  createTemplate,
  addApprovalLevel,
  createWorkspace,
  inviteTeamMember,
  useCustomHeader,
}

/// Exception thrown when plan limit is exceeded
class PlanLimitExceededException implements Exception {
  final String message;

  PlanLimitExceededException(this.message);

  @override
  String toString() => message;
}

/// Plan comparison data for upgrade UI
class PlanComparison {
  final PlanType plan;
  final String price;
  final List<String> features;
  final List<String> limitations;

  const PlanComparison({
    required this.plan,
    required this.price,
    required this.features,
    required this.limitations,
  });

  String get planName {
    switch (plan) {
      case PlanType.free:
        return 'Free';
      case PlanType.starter:
        return 'Starter';
      case PlanType.pro:
        return 'Pro';
    }
  }
}
