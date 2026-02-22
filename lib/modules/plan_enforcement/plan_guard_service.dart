import '../subscription/subscription_models.dart';
import '../workspace/workspace_models.dart';

/// PlanGuardService - Enforces plan limits before actions
class PlanGuardService {
  // ── Template ──────────────────────────────────────────────────────────────

  static bool canCreateTemplate({
    required PlanType currentPlan,
    required int currentTemplateCount,
  }) {
    final e = PlanEntitlements.forPlan(currentPlan);
    if (e.maxTemplates == -1) return true;
    return currentTemplateCount < e.maxTemplates;
  }

  // ── Approval level ─────────────────────────────────────────────────────────

  static bool canAddApprovalLevel({
    required PlanType currentPlan,
    required int currentLevelCount,
  }) {
    final e = PlanEntitlements.forPlan(currentPlan);
    return currentLevelCount < e.maxApprovalLevels;
  }

  // ── Workspace ─────────────────────────────────────────────────────────────

  static bool canCreateWorkspace({
    required PlanType currentPlan,
    required int currentWorkspaceCount,
  }) {
    final e = PlanEntitlements.forPlan(currentPlan);
    if (e.maxWorkspaces == -1) return true;
    return currentWorkspaceCount < e.maxWorkspaces;
  }

  static bool canCreateWorkspaceFromList({
    required PlanType currentPlan,
    required List<Workspace> workspaces,
    required String userId,
  }) {
    final ownedCount = workspaces.where((w) => w.ownerId == userId).length;
    return canCreateWorkspace(
      currentPlan: currentPlan,
      currentWorkspaceCount: ownedCount,
    );
  }

  /// Users can always join workspaces via invitation — no limit
  static bool canJoinWorkspace() => true;

  static int countOwnedWorkspaces(List<Workspace> workspaces, String userId) =>
      workspaces.where((w) => w.ownerId == userId).length;

  static int countJoinedWorkspaces(List<Workspace> workspaces, String userId) =>
      workspaces.where((w) => w.ownerId != userId).length;

  static List<Workspace> getOwnedWorkspaces(
          List<Workspace> workspaces, String userId) =>
      workspaces.where((w) => w.ownerId == userId).toList();

  static List<Workspace> getJoinedWorkspaces(
          List<Workspace> workspaces, String userId) =>
      workspaces.where((w) => w.ownerId != userId).toList();

  // ── Team member ────────────────────────────────────────────────────────────

  static bool canInviteTeamMember({
    required PlanType currentPlan,
    required int currentMemberCount,
  }) {
    final e = PlanEntitlements.forPlan(currentPlan);
    if (e.maxTeamMembers == -1) return true;
    return currentMemberCount < e.maxTeamMembers;
  }

  // ── Feature flags ──────────────────────────────────────────────────────────

  static bool showBrandHeader(PlanType p) =>
      PlanEntitlements.forPlan(p).showBrandHeader;

  static bool canUseCustomHeader(PlanType p) =>
      PlanEntitlements.forPlan(p).customHeader;

  static bool hasHash(PlanType p) => PlanEntitlements.forPlan(p).hasHash;

  static bool canUseEmailNotification(PlanType p) =>
      PlanEntitlements.forPlan(p).emailNotification;

  static bool canExportExcel(PlanType p) =>
      PlanEntitlements.forPlan(p).excelExport;

  static bool canUseAnalytics(PlanType p) =>
      PlanEntitlements.forPlan(p).analytics;

  // ── Validate or throw ──────────────────────────────────────────────────────

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
            'Template limit reached for ${currentPlan.displayName} plan. '
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
            'Approval level limit reached. Upgrade your plan.',
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
            'Workspace limit reached for ${currentPlan.displayName} plan. '
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
            'Team member limit reached. Upgrade your plan.',
          );
        }
        break;

      case PlanAction.useCustomHeader:
        canPerform = canUseCustomHeader(currentPlan);
        if (!canPerform) {
          throw PlanLimitExceededException(
            'Custom headers are only available on Pro plan.',
          );
        }
        break;

      case PlanAction.exportExcel:
        canPerform = canExportExcel(currentPlan);
        if (!canPerform) {
          throw PlanLimitExceededException(
            'Excel export is available on Starter and Pro plans.',
          );
        }
        break;
    }
  }

  // ── Quota helpers ──────────────────────────────────────────────────────────

  static int getRemainingQuota({
    required PlanType currentPlan,
    required PlanAction action,
    required int currentCount,
  }) {
    final e = PlanEntitlements.forPlan(currentPlan);

    switch (action) {
      case PlanAction.createTemplate:
        if (e.maxTemplates == -1) return 999999;
        return (e.maxTemplates - currentCount).clamp(0, e.maxTemplates);
      case PlanAction.addApprovalLevel:
        return (e.maxApprovalLevels - currentCount)
            .clamp(0, e.maxApprovalLevels);
      case PlanAction.createWorkspace:
        if (e.maxWorkspaces == -1) return 999999;
        return (e.maxWorkspaces - currentCount).clamp(0, e.maxWorkspaces);
      case PlanAction.inviteTeamMember:
        if (e.maxTeamMembers == -1) return 999999;
        return (e.maxTeamMembers - currentCount).clamp(0, e.maxTeamMembers);
      default:
        return 0;
    }
  }

  static double getUsagePercentage({
    required PlanType currentPlan,
    required PlanAction action,
    required int currentCount,
  }) {
    final e = PlanEntitlements.forPlan(currentPlan);
    int max;

    switch (action) {
      case PlanAction.createTemplate:
        max = e.maxTemplates;
        break;
      case PlanAction.addApprovalLevel:
        max = e.maxApprovalLevels;
        break;
      case PlanAction.createWorkspace:
        max = e.maxWorkspaces;
        break;
      case PlanAction.inviteTeamMember:
        max = e.maxTeamMembers;
        break;
      default:
        return 0.0;
    }

    if (max == -1) return 0.0; // unlimited — never at limit
    if (max == 0) return 1.0;
    return (currentCount / max).clamp(0.0, 1.0);
  }

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

  // ── Plan comparison data ───────────────────────────────────────────────────

  static List<PlanComparison> getPlanComparisons() {
    return [
      PlanComparison(
        plan: PlanType.free,
        price: 'Free',
        features: [
          '1 workspace',
          '1 template',
          'Basic approval flow',
          'PDF with Approv Now header',
          'Verification hash',
        ],
        limitations: [
          'No email notifications',
          'No custom header',
          'No Excel export',
        ],
      ),
      PlanComparison(
        plan: PlanType.starter,
        price: '\$5.99/month',
        features: [
          '3 workspaces',
          '5 templates',
          'PDF with workspace name header',
          'Email notifications',
          'Excel export',
          'Basic analytics',
          'Verification hash',
        ],
        limitations: [
          'No custom branding / logo',
        ],
      ),
      PlanComparison(
        plan: PlanType.pro,
        price: '\$15.99/month',
        features: [
          'Unlimited workspaces',
          'Unlimited templates',
          'Custom PDF header (name + description + logo)',
          'Workspace branding & logo',
          'Email notifications',
          'Excel export',
          'Full analytics',
          'Verification hash',
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
  exportExcel,
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

  String get planName => plan.displayName;
}
