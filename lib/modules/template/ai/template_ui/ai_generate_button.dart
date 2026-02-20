import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AiGenerateButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final MatchStatus matchStatus;
  final VoidCallback? onPressed;

  const AiGenerateButton({
    super.key,
    required this.isEnabled,
    this.isLoading = false,
    this.matchStatus = MatchStatus.none,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getBorderColor(),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(),
                const SizedBox(width: 6),
                Text(
                  _getLabel(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getTextColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getIconColor()),
        ),
      );
    }

    IconData iconData;
    switch (matchStatus) {
      case MatchStatus.matched:
        iconData = Icons.check_circle;
        break;
      case MatchStatus.suggested:
        iconData = Icons.lightbulb;
        break;
      case MatchStatus.generating:
        iconData = Icons.auto_awesome;
        break;
      case MatchStatus.none:
      default:
        iconData = Icons.auto_awesome;
        break;
    }

    return Icon(
      iconData,
      size: 16,
      color: _getIconColor(),
    );
  }

  String _getLabel() {
    if (isLoading) return 'Generating...';

    switch (matchStatus) {
      case MatchStatus.matched:
        return 'Matched';
      case MatchStatus.suggested:
        return 'Suggested';
      case MatchStatus.generating:
        return 'AI Generate';
      case MatchStatus.none:
      default:
        return 'AI Generate';
    }
  }

  Color _getBackgroundColor() {
    if (!isEnabled) return AppColors.surface;

    switch (matchStatus) {
      case MatchStatus.matched:
        return AppColors.success.withOpacity(0.1);
      case MatchStatus.suggested:
        return AppColors.warning.withOpacity(0.1);
      case MatchStatus.generating:
      case MatchStatus.none:
      default:
        return AppColors.primary.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    if (!isEnabled) return AppColors.divider;

    switch (matchStatus) {
      case MatchStatus.matched:
        return AppColors.success;
      case MatchStatus.suggested:
        return AppColors.warning;
      case MatchStatus.generating:
      case MatchStatus.none:
      default:
        return AppColors.primary;
    }
  }

  Color _getTextColor() {
    if (!isEnabled) return AppColors.textHint;

    switch (matchStatus) {
      case MatchStatus.matched:
        return AppColors.success;
      case MatchStatus.suggested:
        return AppColors.warning;
      case MatchStatus.generating:
      case MatchStatus.none:
      default:
        return AppColors.primary;
    }
  }

  Color _getIconColor() {
    return _getTextColor();
  }
}

enum MatchStatus {
  none, // No match
  matched, // High match (green)
  suggested, // Medium match (yellow)
  generating, // Generating
}
