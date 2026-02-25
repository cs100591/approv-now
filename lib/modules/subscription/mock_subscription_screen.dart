import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';

/// Mock Subscription Screen for App Store screenshots
/// This version doesn't require RevenueCat configuration
class MockSubscriptionScreen extends StatelessWidget {
  const MockSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Upgrade to unlock more features',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Starter Monthly
              _buildPlanCard(
                title: 'Starter Monthly',
                price: '\$4.99',
                period: '/month',
                features: [
                  'Up to 3 Workspaces',
                  'Up to 10 Team Members',
                  'Up to 10 Templates',
                  'No Watermark on PDFs',
                  'Email Notifications',
                ],
                isPopular: false,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),

              // Starter Yearly
              _buildPlanCard(
                title: 'Starter Yearly',
                price: '\$49.99',
                period: '/year',
                features: [
                  'Up to 3 Workspaces',
                  'Up to 10 Team Members',
                  'Up to 10 Templates',
                  'No Watermark on PDFs',
                  'Email Notifications',
                  'Save 20% vs Monthly',
                ],
                isPopular: false,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),

              // Pro Monthly
              _buildPlanCard(
                title: 'Pro Monthly',
                price: '\$17.99',
                period: '/month',
                features: [
                  'Up to 10 Workspaces',
                  'Up to 50 Team Members',
                  'Up to 100 Templates',
                  'Custom PDF Header',
                  'Advanced Analytics',
                  'Priority Support',
                ],
                isPopular: true,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),

              // Pro Yearly
              _buildPlanCard(
                title: 'Pro Yearly',
                price: '\$159',
                period: '/year',
                features: [
                  'Up to 10 Workspaces',
                  'Up to 50 Team Members',
                  'Up to 100 Templates',
                  'Custom PDF Header',
                  'Advanced Analytics',
                  'Priority Support',
                  'Save 20% vs Monthly',
                ],
                isPopular: false,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.xl),

              // Restore purchases link
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Restore Purchases'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Terms
              Center(
                child: Text(
                  'Subscriptions will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withAlpha(153),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isPopular ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        side: isPopular
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              price,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              period,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Text(
                        'POPULAR',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular ? AppColors.primary : null,
                    foregroundColor: isPopular ? Colors.white : null,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: const Text('Subscribe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
