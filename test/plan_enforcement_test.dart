import 'package:flutter_test/flutter_test.dart';
import 'package:approve_now/modules/subscription/subscription_models.dart';
import 'package:approve_now/modules/plan_enforcement/plan_guard_service.dart';

void main() {
  group('Plan Enforcement Tests', () {
    // ── Free Plan ────────────────────────────────────────────────────────────
    group('Free Plan', () {
      const plan = PlanType.free;

      test('should allow first team member', () {
        expect(
          PlanGuardService.canInviteTeamMember(
              currentPlan: plan, currentMemberCount: 4),
          isTrue,
        );
      });

      test('should block 6th team member (max=5)', () {
        expect(
          PlanGuardService.canInviteTeamMember(
              currentPlan: plan, currentMemberCount: 5),
          isFalse,
        );
      });

      test('should allow 1st workspace', () {
        expect(
          PlanGuardService.canCreateWorkspace(
              currentPlan: plan, currentWorkspaceCount: 0),
          isTrue,
        );
      });

      test('should block 2nd workspace (max=1)', () {
        expect(
          PlanGuardService.canCreateWorkspace(
              currentPlan: plan, currentWorkspaceCount: 1),
          isFalse,
        );
      });

      test('should allow 1st template', () {
        expect(
          PlanGuardService.canCreateTemplate(
              currentPlan: plan, currentTemplateCount: 0),
          isTrue,
        );
      });

      test('should block 2nd template (max=1)', () {
        expect(
          PlanGuardService.canCreateTemplate(
              currentPlan: plan, currentTemplateCount: 1),
          isFalse,
        );
      });

      test('should show brand header (not custom)', () {
        expect(PlanGuardService.showBrandHeader(plan), isTrue);
      });

      test('should not have custom header', () {
        expect(PlanGuardService.canUseCustomHeader(plan), isFalse);
      });

      test('should have hash', () {
        expect(PlanGuardService.hasHash(plan), isTrue);
      });

      test('should not allow email notifications', () {
        expect(PlanGuardService.canUseEmailNotification(plan), isFalse);
      });

      test('should not allow excel export', () {
        expect(PlanGuardService.canExportExcel(plan), isFalse);
      });
    });

    // ── Starter Plan ─────────────────────────────────────────────────────────
    group('Starter Plan', () {
      const plan = PlanType.starter;

      test('should allow up to 15 team members', () {
        expect(
          PlanGuardService.canInviteTeamMember(
              currentPlan: plan, currentMemberCount: 14),
          isTrue,
        );
      });

      test('should block 16th team member (max=15)', () {
        expect(
          PlanGuardService.canInviteTeamMember(
              currentPlan: plan, currentMemberCount: 15),
          isFalse,
        );
      });

      test('should allow 3 workspaces', () {
        expect(
          PlanGuardService.canCreateWorkspace(
              currentPlan: plan, currentWorkspaceCount: 2),
          isTrue,
        );
      });

      test('should block 4th workspace (max=3)', () {
        expect(
          PlanGuardService.canCreateWorkspace(
              currentPlan: plan, currentWorkspaceCount: 3),
          isFalse,
        );
      });

      test('should not show brand header', () {
        expect(PlanGuardService.showBrandHeader(plan), isFalse);
      });

      test('should not have custom header (Pro only)', () {
        expect(PlanGuardService.canUseCustomHeader(plan), isFalse);
      });

      test('should allow email notifications', () {
        expect(PlanGuardService.canUseEmailNotification(plan), isTrue);
      });

      test('should allow excel export', () {
        expect(PlanGuardService.canExportExcel(plan), isTrue);
      });

      test('should have analytics', () {
        expect(PlanGuardService.canUseAnalytics(plan), isTrue);
      });
    });

    // ── Pro Plan ──────────────────────────────────────────────────────────────
    group('Pro Plan', () {
      const plan = PlanType.pro;

      test('should allow infinite team members', () {
        expect(
          PlanGuardService.canInviteTeamMember(
              currentPlan: plan, currentMemberCount: 9999),
          isTrue,
        );
      });

      test('should allow infinite workspaces', () {
        expect(
          PlanGuardService.canCreateWorkspace(
              currentPlan: plan, currentWorkspaceCount: 9999),
          isTrue,
        );
      });

      test('should allow infinite templates', () {
        expect(
          PlanGuardService.canCreateTemplate(
              currentPlan: plan, currentTemplateCount: 9999),
          isTrue,
        );
      });

      test('should have custom header', () {
        expect(PlanGuardService.canUseCustomHeader(plan), isTrue);
      });

      test('should not show brand header', () {
        expect(PlanGuardService.showBrandHeader(plan), isFalse);
      });

      test('should have email notifications', () {
        expect(PlanGuardService.canUseEmailNotification(plan), isTrue);
      });

      test('should have excel export', () {
        expect(PlanGuardService.canExportExcel(plan), isTrue);
      });

      test('should have analytics', () {
        expect(PlanGuardService.canUseAnalytics(plan), isTrue);
      });
    });

    // ── Usage Percentage ──────────────────────────────────────────────────────
    group('Usage Percentage', () {
      test('should calculate usage for free team members (5 max)', () {
        final pct = PlanGuardService.getUsagePercentage(
          currentPlan: PlanType.free,
          action: PlanAction.inviteTeamMember,
          currentCount: 5,
        );
        expect(pct, closeTo(1.0, 0.01));
      });

      test('should detect approaching limit at 80%', () {
        expect(
          PlanGuardService.isApproachingLimit(
            currentPlan: PlanType.starter,
            action: PlanAction.inviteTeamMember,
            currentCount: 13, // 13/15 = 86.7%
            threshold: 0.8,
          ),
          isTrue,
        );
      });

      test('should return 0.0 for unlimited pro plan', () {
        final pct = PlanGuardService.getUsagePercentage(
          currentPlan: PlanType.pro,
          action: PlanAction.createWorkspace,
          currentCount: 100,
        );
        expect(pct, 0.0); // unlimited
      });
    });

    // ── Remaining Quota ───────────────────────────────────────────────────────
    group('Remaining Quota', () {
      test('should calculate remaining team members for starter', () {
        final remaining = PlanGuardService.getRemainingQuota(
          currentPlan: PlanType.starter,
          action: PlanAction.inviteTeamMember,
          currentCount: 10,
        );
        expect(remaining, 5); // 15 - 10 = 5
      });

      test('should return large number for unlimited pro plan', () {
        final remaining = PlanGuardService.getRemainingQuota(
          currentPlan: PlanType.pro,
          action: PlanAction.createWorkspace,
          currentCount: 100,
        );
        expect(remaining, greaterThan(1000));
      });
    });

    // ── Plan Comparisons ──────────────────────────────────────────────────────
    group('Plan Comparisons', () {
      test('should return all 3 plans', () {
        final c = PlanGuardService.getPlanComparisons();
        expect(c.length, 3);
        expect(c[0].plan, PlanType.free);
        expect(c[1].plan, PlanType.starter);
        expect(c[2].plan, PlanType.pro);
      });

      test('should have correct pricing', () {
        final c = PlanGuardService.getPlanComparisons();
        expect(c[0].price, 'Free');
        expect(c[1].price, '\$5.99/month');
        expect(c[2].price, '\$15.99/month');
      });
    });

    // ── Exception Handling ────────────────────────────────────────────────────
    group('Exception Handling', () {
      test('should throw when template limit exceeded on free plan', () {
        expect(
          () => PlanGuardService.validateOrThrow(
            currentPlan: PlanType.free,
            action: PlanAction.createTemplate,
            currentCount: 1, // free max = 1
          ),
          throwsA(isA<PlanLimitExceededException>()),
        );
      });

      test('should throw when workspace limit exceeded on free plan', () {
        expect(
          () => PlanGuardService.validateOrThrow(
            currentPlan: PlanType.free,
            action: PlanAction.createWorkspace,
            currentCount: 1,
          ),
          throwsA(isA<PlanLimitExceededException>()),
        );
      });

      test('should not throw when within limits', () {
        expect(
          () => PlanGuardService.validateOrThrow(
            currentPlan: PlanType.starter,
            action: PlanAction.inviteTeamMember,
            currentCount: 5,
          ),
          returnsNormally,
        );
      });

      test('should not throw for pro unlimited workspace', () {
        expect(
          () => PlanGuardService.validateOrThrow(
            currentPlan: PlanType.pro,
            action: PlanAction.createWorkspace,
            currentCount: 9999,
          ),
          returnsNormally,
        );
      });
    });
  });
}
