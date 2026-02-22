import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../template_models.dart';
import '../models/ai_generation_result.dart';
import '../smart_template_generator.dart';

/// AI Preview Dialog
class AiPreviewDialog extends StatelessWidget {
  final AiGenerationResult result;
  final MatchType matchType;
  final double matchScore;
  final VoidCallback onApply;
  final VoidCallback onRegenerate;
  final VoidCallback onCancel;

  const AiPreviewDialog({
    super.key,
    required this.result,
    required this.matchType,
    required this.matchScore,
    required this.onApply,
    required this.onRegenerate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMatchInfo(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFieldsSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildApprovalSection(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _getHeaderColor().withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            _getHeaderIcon(),
            color: _getHeaderColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Preview',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.templateName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Scenario: ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                result.matchedScenario ?? 'Custom',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Match Type: ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getMatchTypeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getMatchTypeText(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getMatchTypeColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Match Score: ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(matchScore * 100).toInt()}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getScoreColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.format_list_bulleted,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Fields (${result.fields.length})',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...result.fields.asMap().entries.map((entry) {
          final field = entry.value;
          final index = entry.key;
          return _buildFieldItem(field, index);
        }),
      ],
    );
  }

  Widget _buildFieldItem(TemplateField field, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      field.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (field.required) ...[
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_getFieldTypeName(field.type)}${field.options != null ? ' · ${field.options!.length} options' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Approval Steps (${result.approvalSteps.length})',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...result.approvalSteps.map((step) => _buildStepItem(step)),
      ],
    );
  }

  Widget _buildStepItem(ApprovalStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${step.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${step.approvers.length} approvers${step.requireAll ? ' (all required)' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onRegenerate,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Regenerate'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Apply'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHeaderColor() {
    switch (matchType) {
      case MatchType.localExact:
        return AppColors.success;
      case MatchType.localSuggested:
        return AppColors.warning;
      case MatchType.cached:
        return AppColors.info;
      case MatchType.aiGenerated:
        return AppColors.primary;
      case MatchType.genericFallback:
        return AppColors.textSecondary;
    }
  }

  IconData _getHeaderIcon() {
    switch (matchType) {
      case MatchType.localExact:
        return Icons.check_circle;
      case MatchType.localSuggested:
        return Icons.lightbulb;
      case MatchType.cached:
        return Icons.storage;
      case MatchType.aiGenerated:
        return Icons.auto_awesome;
      case MatchType.genericFallback:
        return Icons.article;
    }
  }

  Color _getMatchTypeColor() {
    return _getHeaderColor();
  }

  String _getMatchTypeText() {
    switch (matchType) {
      case MatchType.localExact:
        return 'Exact Match';
      case MatchType.localSuggested:
        return 'Suggested';
      case MatchType.cached:
        return 'Cached';
      case MatchType.aiGenerated:
        return 'AI Generated';
      case MatchType.genericFallback:
        return 'Generic';
    }
  }

  Color _getScoreColor() {
    if (matchScore >= 0.8) return AppColors.success;
    if (matchScore >= 0.6) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _getFieldTypeName(FieldType type) {
    final names = {
      FieldType.text: 'Text',
      FieldType.number: 'Number',
      FieldType.date: 'Date',
      FieldType.dropdown: 'Dropdown',
      FieldType.checkbox: 'Checkbox',
      FieldType.multiline: 'Multiline',
      FieldType.file: 'File',
      FieldType.currency: 'Currency',
    };
    return names[type] ?? type.name;
  }
}
