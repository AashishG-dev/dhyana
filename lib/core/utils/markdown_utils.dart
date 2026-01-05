// lib/core/utils/markdown_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

/// Utility class to render Markdown content with app-specific styles.
class MarkdownUtils {
  static Widget buildMarkdownBody(String content, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return MarkdownBody(
      data: content,
      selectable: true,
      // ✅ UPDATED: Using a more detailed and consistent style sheet
      styleSheet: MarkdownStyleSheet(
        p: AppTextStyles.bodyLarge.copyWith(color: textColor, height: 1.5),
        h1: AppTextStyles.headlineLarge.copyWith(color: textColor),
        h2: AppTextStyles.headlineMedium.copyWith(color: textColor),
        h3: AppTextStyles.headlineSmall.copyWith(color: textColor),
        h4: AppTextStyles.titleLarge.copyWith(color: textColor),
        listBullet: AppTextStyles.bodyLarge.copyWith(color: textColor),
        blockquoteDecoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border(
            left: BorderSide(
              color: isDark ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
              width: 4.0,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.all(16.0),
        blockquote: AppTextStyles.bodyLarge.copyWith(
          fontStyle: FontStyle.italic,
          color: textColor.withOpacity(0.8),
        ),
        code: AppTextStyles.bodyMedium.copyWith(
          fontFamily: "monospace",
          backgroundColor: Colors.grey.withOpacity(0.15),
          color: textColor.withOpacity(0.9),
        ),
      ),
    );
  }
}