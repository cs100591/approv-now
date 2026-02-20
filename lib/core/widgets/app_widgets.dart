import 'package:flutter/material.dart';
import 'app_buttons.dart';
import 'app_inputs.dart';
import 'app_cards.dart';
import 'app_states.dart';

/// Exports all app widgets for easy importing
export 'app_buttons.dart';
export 'app_inputs.dart';
export 'app_cards.dart';
export 'app_states.dart';

/// AppWidgets class for organized access to all widgets
class AppWidgets {
  static const buttons = _AppButtons();
  static const inputs = _AppInputs();
  static const cards = _AppCards();
  static const states = _AppStates();
}

class _AppButtons {
  const _AppButtons();

  PrimaryButton primary({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) =>
      PrimaryButton(
        text: text,
        onPressed: onPressed,
        isLoading: isLoading,
        width: width,
        height: height,
      );

  SecondaryButton secondary({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) =>
      SecondaryButton(
        text: text,
        onPressed: onPressed,
        isLoading: isLoading,
        width: width,
        height: height,
      );

  AppTextButton text({
    required String text,
    VoidCallback? onPressed,
  }) =>
      AppTextButton(
        text: text,
        onPressed: onPressed,
      );
}

class _AppInputs {
  const _AppInputs();

  AppTextField textField({
    required String label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    int? maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Function(String)? onChanged,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
  }) =>
      AppTextField(
        label: label,
        hint: hint,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        textInputAction: textInputAction,
        focusNode: focusNode,
      );

  AppPasswordField password({
    required String label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
  }) =>
      AppPasswordField(
        label: label,
        hint: hint,
        controller: controller,
        validator: validator,
        textInputAction: textInputAction,
        focusNode: focusNode,
      );
}

class _AppCards {
  const _AppCards();

  AppCard card({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? borderRadius,
    VoidCallback? onTap,
    bool hasShadow = true,
  }) =>
      AppCard(
        child: child,
        padding: padding,
        margin: margin,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        onTap: onTap,
        hasShadow: hasShadow,
      );

  StatsCard stats({
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) =>
      StatsCard(
        title: title,
        value: value,
        icon: icon,
        iconColor: iconColor,
        onTap: onTap,
      );
}

class _AppStates {
  const _AppStates();

  EmptyState empty({
    required String message,
    String? subMessage,
    IconData icon = Icons.inbox,
    Widget? action,
  }) =>
      EmptyState(
        message: message,
        subMessage: subMessage,
        icon: icon,
        action: action,
      );

  LoadingState loading({String? message}) => LoadingState(message: message);

  ErrorState error({
    required String message,
    VoidCallback? onRetry,
  }) =>
      ErrorState(
        message: message,
        onRetry: onRetry,
      );
}
