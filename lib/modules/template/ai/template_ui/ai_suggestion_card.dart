import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/ai_generation_result.dart';

/// AI Suggestion Card
/// Shows list of suggested scenarios
class AiSuggestionCard extends StatelessWidget {
  final List<AiMatchResult> suggestions;
  final Function(AiMatchResult) onSelect;
  final VoidCallback onUseAi;

  const AiSuggestionCard({
    super.key,
    required this.suggestions,
    required this.onSelect,
    required this.onUseAi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggestions',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No exact match found. Here are similar scenarios:',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...suggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.divider.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: onUseAi,
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Let AI generate a new scenario',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(AiMatchResult suggestion) {
    final result = suggestion.result;
    if (result == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () => onSelect(suggestion),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.matchedScenario ?? 'Suggested Scenario',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.fields.length} fields · ${result.approvalSteps.length} approval levels',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(suggestion.matchScore)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(suggestion.matchScore * 100).toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _getScoreColor(suggestion.matchScore),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.warning;
    return AppColors.textSecondary;
  }
}
