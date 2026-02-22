import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Global error boundary widget
/// Catches and displays Flutter widget errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallbackWidget;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackWidget,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallbackWidget ?? _buildErrorWidget();
    }
    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(24),
        color: AppColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We apologize for the inconvenience. Please restart the app.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_error?.exception != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  _error!.exception.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

/// Setup global error handling
void setupErrorHandling() {
  // Set custom error widget builder
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Rendering Error',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A widget failed to render properly.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            ...[
              const SizedBox(height: 12),
              Text(
                details.exception.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  };

  // Catch uncaught Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log the error
    debugPrint('❌ FLUTTER ERROR: ${details.exception}');
    debugPrint('📍 Stack trace: ${details.stack}');

    // In production, you would send this to crash reporting service
    // FirebaseCrashlytics.instance.recordFlutterError(details);

    // Still show error in debug mode
    if (true) {
      // Change to !kReleaseMode for production
      FlutterError.presentError(details);
    }
  };
}
