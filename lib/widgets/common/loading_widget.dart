// lib/widgets/common/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart'; // For colors

/// A customizable loading indicator widget that provides visual feedback
/// during asynchronous operations. It uses a CircularProgressIndicator
/// and can display an optional message.
class LoadingWidget extends StatelessWidget { // Renamed class to LoadingWidget
  final String? message;
  final Color? color;

  /// Constructor for LoadingWidget.
  const LoadingWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16.0),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? AppColors.textDark : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
