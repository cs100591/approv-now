import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/routing/route_names.dart';
import '../../../l10n/app_localizations.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic responsive width check
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.approval, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Approv Now',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, RouteNames.login),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              AppLocalizations.of(context)?.signIn ?? 'Log In',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteNames.register),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                AppLocalizations.of(context)?.createAccount ?? 'Sign Up',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Section ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding.left,
                vertical: isDesktop ? 80 : 40,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    Text(
                      'Streamline Your Approvals',
                      style:
                          (isDesktop ? AppTextStyles.display : AppTextStyles.h1)
                              .copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Create, track, and manage approval requests across your entire organization with ease.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: isDesktop ? 20 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PrimaryButton(
                          text: 'Get Started for Free',
                          onPressed: () =>
                              Navigator.pushNamed(context, RouteNames.register),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Features Section ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding.left,
                vertical: 60,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    Text(
                      'Why Approv Now?',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Wrap(
                      spacing: 32,
                      runSpacing: 32,
                      alignment: WrapAlignment.center,
                      children: [
                        _FeatureCard(
                          icon: Icons.electric_bolt,
                          title: 'Fast Approvals',
                          description:
                              'Build custom forms and routing logic in minutes.',
                        ),
                        _FeatureCard(
                          icon: Icons.history,
                          title: 'Audit Trails',
                          description:
                              'Immutable cryptographic records of every decision made.',
                        ),
                        _FeatureCard(
                          icon: Icons.picture_as_pdf,
                          title: 'Export Anywhere',
                          description:
                              'Generate rich PDFs and Excel summaries for reporting.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Pricing Section ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding.left,
                vertical: 60,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    Text(
                      'Simple, Transparent Pricing',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        _PricingCard(
                          title: 'Free',
                          price: '\$0',
                          features: [
                            '1 Workspace',
                            '1 Template',
                            'Up to 5 Team Members',
                          ],
                        ),
                        _PricingCard(
                          title: 'Starter',
                          price: '\$5.99/mo',
                          features: [
                            '3 Workspaces',
                            '5 Templates',
                            'Up to 15 Team Members',
                            'Excel Export',
                          ],
                          isPopular: true,
                        ),
                        _PricingCard(
                          title: 'Pro',
                          price: '\$15.99/mo',
                          features: [
                            'Unlimited Everything',
                            'Custom Branding',
                            'Email Notifications',
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            const SizedBox(height: 80),
            Text(
              '© ${DateTime.now().year} Approv Now. All rights reserved.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool isPopular;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.features,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppColors.primary : AppColors.divider,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Most Popular',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            price,
            style: AppTextStyles.display.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: isPopular
                ? PrimaryButton(
                    text: 'Get Started',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.register),
                  )
                : SecondaryButton(
                    text: 'Get Started',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.register),
                  ),
          ),
        ],
      ),
    );
  }
}
