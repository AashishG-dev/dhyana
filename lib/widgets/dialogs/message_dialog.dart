// lib/widgets/common/message_dialog.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/widgets/common/custom_button.dart'; // For the custom button

/// A custom dialog widget for displaying messages to the user.
/// It adheres to the Dhyana app's Glass Morphism design, providing a
/// consistent look for alerts and informational pop-ups.
class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  /// Constructor for MessageDialog.
  const MessageDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      // Use the theme's card color for the background to get the glass effect
      backgroundColor: isDarkMode ? AppColors.glassDarkSurface : AppColors.glassLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(
          color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          width: 1.0,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
        ),
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        Center(
          child: CustomButton(
            text: buttonText ?? 'OK',
            onPressed: () {
              // If a callback is provided, execute it. Otherwise, just pop the dialog.
              onButtonPressed?.call();
              Navigator.of(context).pop();
            },
            type: ButtonType.primary, // Corrected: Access ButtonType directly
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
    );
  }
}
