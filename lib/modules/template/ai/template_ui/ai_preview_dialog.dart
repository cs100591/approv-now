import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../template_models.dart';
import '../models/ai_generation_result.dart';
import '../smart_template_generator.dart';

/// AI 生成预览弹窗
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
            // 头部
            _buildHeader(),

            // 内容区域
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 场景识别信息
                    _buildMatchInfo(),
                    const SizedBox(height: AppSpacing.lg),

                    // 字段配置
                    _buildFieldsSection(),
                    const SizedBox(height: AppSpacing.lg),

                    // 审批流程
                    _buildApprovalSection(),
                  ],
                ),
              ),
            ),

            // 底部按钮
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
        color: _getHeaderColor().withOpacity(0.1),
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
                  'AI 生成预览',
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
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '场景识别：',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                result.matchedScenario ?? '自定义场景',
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
                '匹配类型：',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getMatchTypeColor().withOpacity(0.1),
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
                '匹配度：',
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
              '字段配置（${result.fields.length}个）',
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
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
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
                  '${_getFieldTypeName(field.type)}${field.options != null ? ' · ${field.options!.length}个选项' : ''}',
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
              '审批流程（${result.approvalSteps.length}级）',
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
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
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
                  '${step.approvers.length} 位审批人${step.requireAll ? '（需全部通过）' : ''}',
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
          top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onRegenerate,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重新生成'),
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
              label: const Text('应用配置'),
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
        return '本地精确匹配';
      case MatchType.localSuggested:
        return '本地推荐';
      case MatchType.cached:
        return '缓存结果';
      case MatchType.aiGenerated:
        return 'AI 生成';
      case MatchType.genericFallback:
        return '通用模板';
    }
  }

  Color _getScoreColor() {
    if (matchScore >= 0.8) return AppColors.success;
    if (matchScore >= 0.6) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _getFieldTypeName(FieldType type) {
    final names = {
      FieldType.text: '文本',
      FieldType.number: '数字',
      FieldType.date: '日期',
      FieldType.dropdown: '下拉选择',
      FieldType.checkbox: '复选框',
      FieldType.multiline: '多行文本',
      FieldType.file: '文件',
      FieldType.currency: '金额',
    };
    return names[type] ?? type.name;
  }
}
