// lib/widgets/dialogs/message_dialog.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/widgets/common/custom_button.dart';

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const MessageDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
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
        style: AppTextStyles.titleLarge.copyWith(
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      actions: [
        Center(
          child: CustomButton(
            text: buttonText ?? 'OK',
            type: ButtonType.primary,
            onPressed: () {
              // The helper function that shows this dialog is responsible
              // for popping it. We just call the callback here.
              onButtonPressed?.call();
            },
          ),
        ),
      ],
    );
  }
}