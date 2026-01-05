import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;

  // ✅ Newly added props
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
      ),
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: suffixIcon!,
          onPressed: onSuffixIconPressed,
        )
            : null,
        filled: true,
        fillColor: isDarkMode
            ? AppColors.glassDarkSurface.withOpacity(0.3)
            : AppColors.glassLightSurface.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(
            color: isDarkMode
                ? AppColors.glassBorderDark
                : AppColors.glassBorderLight,
          ),
        ),
      ),
    );
  }
}
