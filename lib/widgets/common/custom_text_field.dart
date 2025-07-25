// lib/widgets/common/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';

/// A customizable text input field that adheres to the Dhyana app's design system,
/// incorporating the Glass Morphism theme. It supports various input types,
/// validation, and can display prefix/suffix icons.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;

  /// Constructor for CustomTextField.
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.maxLines = 1, // Default to single line
    this.minLines,
    this.maxLength,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      focusNode: focusNode,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
      ),
      cursorColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.5),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
        ),
        filled: true,
        fillColor: isDarkMode ? AppColors.glassDarkSurface : AppColors.glassLightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(
            color: AppColors.errorColor,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(
            color: AppColors.errorColor,
            width: 2.0,
          ),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: suffixIcon!,
          onPressed: onSuffixIconPressed,
          color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
        )
            : null,
      ),
    );
  }
}
