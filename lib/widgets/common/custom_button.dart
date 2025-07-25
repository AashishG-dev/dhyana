// lib/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';

/// Defines the type of button to render.
/// This enum must be declared outside the class.
enum ButtonType {
  primary,
  secondary,
  text,
  outline,
}

/// A customizable button widget that adheres to the Dhyana app's design system,
/// including the Glass Morphism theme. It supports different types (primary, secondary, text)
/// and can display a loading indicator.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon; // Optional icon for the button


  /// Constructor for CustomButton.
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary, // Default to primary button
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    Widget buttonChild = isLoading
        ? SizedBox(
      width: AppConstants.paddingMedium, // Size of the loading indicator
      height: AppConstants.paddingMedium,
      child: CircularProgressIndicator(
        color: type == ButtonType.text
            ? (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue)
            : (isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight),
        strokeWidth: 2.0,
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: type == ButtonType.text
                ? (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue)
                : (isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight),
            size: 18,
          ),
          const SizedBox(width: AppConstants.paddingSmall / 2),
        ],
        Text(
          text,
          style: AppTextStyles.buttonText.copyWith(
            color: type == ButtonType.text
                ? (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue)
                : (isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight),
          ),
        ),
      ],
    );

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
            foregroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
            textStyle: AppTextStyles.buttonText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium),
            elevation: 3,
          ),
          child: buttonChild,
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? AppColors.secondaryBrown : AppColors.secondaryOrange,
            foregroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
            textStyle: AppTextStyles.buttonText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium),
            elevation: 3,
          ),
          child: buttonChild,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
            textStyle: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.w400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
          ),
          child: buttonChild,
        );
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
            textStyle: AppTextStyles.buttonText,
            side: BorderSide(
                color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium),
          ),
          child: buttonChild,
        );
    }
  }
}
