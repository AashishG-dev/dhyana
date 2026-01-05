// lib/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

enum ButtonType { primary, secondary, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (type) {
      case ButtonType.primary:
      // ✅ Use theme-aware colors
        bgColor = isDark ? AppColors.primaryBlue : AppColors.primaryTeal;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case ButtonType.secondary:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.textDark : AppColors.textLight;
        borderColor = isDark ? AppColors.textDark : AppColors.textLight;
        break;
      case ButtonType.text:
        bgColor = Colors.transparent;
        // ✅ Use theme-aware colors
        textColor = isDark ? AppColors.primaryBlue : AppColors.primaryTeal;
        borderColor = Colors.transparent;
        break;
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: type == ButtonType.text ? 0 : 2,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingMedium,
            horizontal: AppConstants.paddingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            side: BorderSide(color: borderColor, width: 1.2),
          ),
        ),
        icon: icon != null
            ? Icon(icon, color: textColor, size: 20)
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600, // button feel
          ),
        ),
      ),
    );
  }
}