// lib/widgets/dialogs/confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/widgets/common/custom_button.dart'; // For the custom button

/// A custom confirmation dialog widget that provides a consistent look and feel
/// for user confirmations (e.g., "Are you sure you want to delete?").
/// It adheres to the Dhyana app's Glass Morphism design.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  /// Constructor for ConfirmationDialog.
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomButton(
              text: cancelText,
              onPressed: () {
                onCancel();
                Navigator.of(context).pop(false); // Pop with false for cancellation
              },
              type: ButtonType.outline,
            ),
            CustomButton(
              text: confirmText,
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop(true); // Pop with true for confirmation
              },
              type: ButtonType.primary,
            ),
          ],
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
