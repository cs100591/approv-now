import 'package:flutter_test/flutter_test.dart';
import 'package:approve_now/modules/subscription/subscription_models.dart';
import 'package:approve_now/modules/plan_enforcement/plan_guard_service.dart';

void main() {
  group('Plan Enforcement Tests', () {
    group('Free Plan', () {
      const freePlan = PlanType.free;

      test('Free plan should allow 3 team members', () {
        expect(
          PlanGuardService.canInviteTeamMember(
            currentPlan: freePlan,
            currentMemberCount: 2,
          ),
          isTrue,
        );
      });

      test('Free plan should block 4th team member', () {
        expect(
          PlanGuardService.canInviteTeamMember(
            currentPlan: freePlan,
            currentMemberCount: 3,
          ),
          isFalse,
        );
      });

      test('Free plan should allow 1 workspace', () {
        expect(
          PlanGuardService.canCreateWorkspace(
            currentPlan: freePlan,
            currentWorkspaceCount: 0,
          ),
          isTrue,
        );
      });

      test('Free plan should block 2nd workspace', () {
        expect(
          PlanGuardService.canCreateWorkspace(
            currentPlan: freePlan,
            currentWorkspaceCount: 1,
          ),
          isFalse,
        );
      });

      test('Free plan should allow 3 templates', () {
        expect(
          PlanGuardService.canCreateTemplate(
            currentPlan: freePlan,
            currentTemplateCount: 2,
          ),
          isTrue,
        );
      });

      test('Free plan should block 4th template', () {
        expect(
          PlanGuardService.canCreateTemplate(
            currentPlan: freePlan,
            currentTemplateCount: 3,
          ),
          isFalse,
        );
      });

      test('Free plan should have watermark', () {
        expect(
          PlanGuardService.shouldApplyWatermark(freePlan),
          isTrue,
        );
      });

      test('Free plan should not have custom header', () {
        expect(
          PlanGuardService.canUseCustomHeader(freePlan),
          isFalse,
        );
      });
    });

    group('Starter Plan', () {
      const starterPlan = PlanType.starter;

      test('Starter plan should allow 10 team members', () {
        expect(
          PlanGuardService.canInviteTeamMember(
            currentPlan: starterPlan,
            currentMemberCount: 9,
          ),
          isTrue,
        );
      });

      test('Starter plan should block 11th team member', () {
        expect(
          PlanGuardService.canInviteTeamMember(
            currentPlan: starterPlan,
            currentMemberCount: 10,
          ),
          isFalse,
        );
      });

      test('Starter plan should allow 3 workspaces', () {
        expect(
          PlanGuardService.canCreateWorkspace(
            currentPlan: starterPlan,
            currentWorkspaceCount: 2,
          ),
          isTrue,
        );
      });

      test('Starter plan should block 4th workspace', () {
        expect(
          PlanGuardService.canCreateWorkspace(
            currentPlan: starterPlan,
            currentWorkspaceCount: 3,
          ),
          isFalse,
        );
      });

      test('Starter plan should not have watermark', () {
        expect(
          PlanGuardService.shouldApplyWatermark(starterPlan),
          isFalse,
        );
      });

      test('Starter plan should not have custom header', () {
        expect(
          PlanGuardService.canUseCustomHeader(starterPlan),
          isFalse,
        );
      });
    });

    group('Pro Plan', () {
      const proPlan = PlanType.pro;

      test('Pro plan should allow 50 team members', () {
        expect(
          PlanGuardService.canInviteTeamMember(
            currentPlan: proPlan,
            currentMemberCount: 49,
          ),
          isTrue,
        );
      });

      test('Pro plan should block 51st team member', () {
        expect(
          PlanGuardService.canInviteTeamMember(
            currentPlan: proPlan,
            currentMemberCount: 50,
          ),
          isFalse,
        );
      });

      test('Pro plan should allow 10 workspaces', () {
        expect(
          PlanGuardService.canCreateWorkspace(
            currentPlan: proPlan,
            currentWorkspaceCount: 9,
          ),
          isTrue,
        );
      });

      test('Pro plan should block 11th workspace', () {
        expect(
          PlanGuardService.canCreateWorkspace(
            currentPlan: proPlan,
            currentWorkspaceCount: 10,
          ),
          isFalse,
        );
      });

      test('Pro plan should have custom header', () {
        expect(
          PlanGuardService.canUseCustomHeader(proPlan),
          isTrue,
        );
      });

      test('Pro plan should not have watermark', () {
        expect(
          PlanGuardService.shouldApplyWatermark(proPlan),
          isFalse,
        );
      });
    });

    group('Usage Percentage', () {
      test('Should calculate 50% usage correctly', () {
        final percentage = PlanGuardService.getUsagePercentage(
          currentPlan: PlanType.free,
          action: PlanAction.inviteTeamMember,
          currentCount: 1, // 1 out of 3
        );
        expect(percentage, closeTo(0.33, 0.01));
      });

      test('Should detect approaching limit at 80%', () {
        expect(
          PlanGuardService.isApproachingLimit(
            currentPlan: PlanType.starter,
            action: PlanAction.inviteTeamMember,
            currentCount: 9, // 9 out of 10 = 90%, which is >= 80% and < 100%
            threshold: 0.8,
          ),
          isTrue,
        );
      });

      test('Should not detect approaching limit at 50%', () {
        expect(
          PlanGuardService.isApproachingLimit(
            currentPlan: PlanType.starter,
            action: PlanAction.inviteTeamMember,
            currentCount: 5, // 5 out of 10 = 50%
            threshold: 0.8,
          ),
          isFalse,
        );
      });
    });

    group('Remaining Quota', () {
      test('Should calculate remaining team members', () {
        final remaining = PlanGuardService.getRemainingQuota(
          currentPlan: PlanType.starter,
          action: PlanAction.inviteTeamMember,
          currentCount: 5,
        );
        expect(remaining, 5); // 10 - 5 = 5
      });

      test('Should calculate remaining workspaces', () {
        final remaining = PlanGuardService.getRemainingQuota(
          currentPlan: PlanType.pro,
          action: PlanAction.createWorkspace,
          currentCount: 3,
        );
        expect(remaining, 7); // 10 - 3 = 7
      });
    });

    group('Plan Comparisons', () {
      test('Should return all 3 plans for comparison', () {
        final comparisons = PlanGuardService.getPlanComparisons();
        expect(comparisons.length, 3);
        expect(comparisons[0].plan, PlanType.free);
        expect(comparisons[1].plan, PlanType.starter);
        expect(comparisons[2].plan, PlanType.pro);
      });

      test('Should have correct pricing', () {
        final comparisons = PlanGuardService.getPlanComparisons();
        expect(comparisons[0].price, 'Free');
        expect(comparisons[1].price, '\$9/month');
        expect(comparisons[2].price, '\$29/month');
      });
    });

    group('Plan Limits Map', () {
      test('Should return correct limits for free plan', () {
        final limits = PlanGuardService.getPlanLimits(PlanType.free);
        expect(limits['maxTemplates'], 3);
        expect(limits['maxApprovalLevels'], 2);
        expect(limits['maxWorkspaces'], 1);
        expect(limits['maxTeamMembers'], 3);
      });

      test('Should return correct limits for pro plan', () {
        final limits = PlanGuardService.getPlanLimits(PlanType.pro);
        expect(limits['maxTemplates'], 100);
        expect(limits['maxApprovalLevels'], 10);
        expect(limits['maxWorkspaces'], 10);
        expect(limits['maxTeamMembers'], 50);
      });
    });

    group('Exception Handling', () {
      test('Should throw exception when team member limit exceeded', () {
        expect(
          () => PlanGuardService.validateOrThrow(
            currentPlan: PlanType.free,
            action: PlanAction.inviteTeamMember,
            currentCount: 3,
          ),
          throwsA(isA<PlanLimitExceededException>()),
        );
      });

      test('Should throw exception when workspace limit exceeded', () {
        expect(
          () => PlanGuardService.validateOrThrow(
            currentPlan: PlanType.free,
            action: PlanAction.createWorkspace,
            currentCount: 1,
          ),
          throwsA(isA<PlanLimitExceededException>()),
        );
      });

      test('Should not throw exception when within limits', () {
        expect(
          () => PlanGuardService.validateOrThrow(
            currentPlan: PlanType.starter,
            action: PlanAction.inviteTeamMember,
            currentCount: 5,
          ),
          returnsNormally,
        );
      });
    });
  });
}
