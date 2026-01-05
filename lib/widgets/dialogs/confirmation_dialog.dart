// lib/widgets/dialogs/confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/widgets/common/custom_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor:
      isDark ? AppColors.glassDarkSurface : AppColors.glassLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(
          color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          width: 1.0,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CustomButton(
                text: cancelText,
                type: ButtonType.secondary,
                onPressed: () {
                  onCancel();
                  Navigator.of(context).pop(false);
                },
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: CustomButton(
                text: confirmText,
                type: ButtonType.primary,
                onPressed: () {
                  onConfirm();
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
