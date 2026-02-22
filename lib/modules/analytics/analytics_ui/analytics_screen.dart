import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../workspace/workspace_provider.dart';
import '../../request/request_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Trends'),
              Tab(text: 'Performance'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildTrendsTab(),
            _buildPerformanceTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<WorkspaceProvider, RequestProvider>(
      builder: (context, workspaceProvider, requestProvider, child) {
        final currentWorkspace = workspaceProvider.currentWorkspace;
        final requests = requestProvider.requests;

        final pendingCount =
            requests.where((r) => r.status.name == 'pending').length;
        final approvedCount =
            requests.where((r) => r.status.name == 'approved').length;
        final rejectedCount =
            requests.where((r) => r.status.name == 'rejected').length;
        final totalCount = requests.length;

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                children: [
                  _buildStatCard(
                    'Total Requests',
                    totalCount.toString(),
                    Icons.folder,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    AppLocalizations.of(context)!.pending,
                    pendingCount.toString(),
                    Icons.pending_actions,
                    AppColors.warning,
                  ),
                  _buildStatCard(
                    AppLocalizations.of(context)!.approved,
                    approvedCount.toString(),
                    Icons.check_circle,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    AppLocalizations.of(context)!.rejected,
                    rejectedCount.toString(),
                    Icons.cancel,
                    AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Approval Rate
              _buildSectionTitle('Approval Rate'),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: Center(
                          child: _buildApprovalRateChart(
                            approved: approvedCount,
                            rejected: rejectedCount,
                            pending: pendingCount,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(
                              AppLocalizations.of(context)!.approved,
                              AppColors.success),
                          const SizedBox(width: AppSpacing.lg),
                          _buildLegendItem(
                              AppLocalizations.of(context)!.rejected,
                              AppColors.error),
                          const SizedBox(width: AppSpacing.lg),
                          _buildLegendItem(
                              AppLocalizations.of(context)!.pending,
                              AppColors.warning),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Workspace Info
              if (currentWorkspace != null) ...[
                _buildSectionTitle('Workspace Info'),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    children: [
                      _buildInfoRow(AppLocalizations.of(context)!.workspace,
                          currentWorkspace.name),
                      const Divider(),
                      _buildInfoRow(
                          'Plan', currentWorkspace.plan.toUpperCase()),
                      const Divider(),
                      _buildInfoRow(
                          'Members', '${currentWorkspace.members.length}'),
                      const Divider(),
                      _buildInfoRow(
                        'Created',
                        '${currentWorkspace.createdAt.day}/${currentWorkspace.createdAt.month}/${currentWorkspace.createdAt.year}',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Weekly Activity'),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildMockBarChart(),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDayLabel('Mon'),
                      _buildDayLabel('Tue'),
                      _buildDayLabel('Wed'),
                      _buildDayLabel('Thu'),
                      _buildDayLabel('Fri'),
                      _buildDayLabel('Sat'),
                      _buildDayLabel('Sun'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Request Trends'),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildMockLineChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Top Performers'),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                _buildPerformerRow('John Doe', 45, 2),
                const Divider(),
                _buildPerformerRow('Jane Smith', 38, 1),
                const Divider(),
                _buildPerformerRow('Mike Johnson', 32, 3),
                const Divider(),
                _buildPerformerRow('Sarah Williams', 28, 0),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Average Approval Time'),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildMetricRow('Level 1', '2.5 hours'),
                  const Divider(),
                  _buildMetricRow('Level 2', '4.2 hours'),
                  const Divider(),
                  _buildMetricRow('Level 3', '6.8 hours'),
                  const Divider(),
                  _buildMetricRow('Overall', '4.5 hours'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4,
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRateChart({
    required int approved,
    required int rejected,
    required int pending,
  }) {
    final total = approved + rejected + pending;
    if (total == 0) {
      return Text(
        'No Data',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textHint,
        ),
      );
    }

    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPieSlice(AppColors.success, approved / total,
              AppLocalizations.of(context)!.approved),
          _buildPieSlice(AppColors.error, rejected / total,
              AppLocalizations.of(context)!.rejected),
          _buildPieSlice(AppColors.warning, pending / total,
              AppLocalizations.of(context)!.pending),
        ],
      );
    });
  }

  Widget _buildPieSlice(Color color, double percentage, String label) {
    return Container(
      width: 60 * percentage + 20,
      height: 60 * percentage + 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${(percentage * 100).toInt()}%',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockBarChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar(0.6),
        _buildBar(0.8),
        _buildBar(0.4),
        _buildBar(0.9),
        _buildBar(0.7),
        _buildBar(0.3),
        _buildBar(0.5),
      ],
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 24,
      height: 100 * height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildDayLabel(String day) {
    return Text(
      day,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildMockLineChart() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 150),
        painter: LineChartPainter(),
      ),
    );
  }

  Widget _buildPerformerRow(String name, int approved, int rejected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              name.split(' ').map((n) => n[0]).join(),
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$approved approved • $rejected rejected',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(approved / (approved + rejected) * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.3,
      size.width,
      size.height * 0.4,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
