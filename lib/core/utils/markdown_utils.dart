// lib/core/utils/markdown_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // For rendering Markdown content
import 'package:dhyana/core/constants/app_colors.dart'; // For styling Markdown elements
import 'package:dhyana/core/constants/app_text_styles.dart'; // For styling Markdown elements
import 'package:dhyana/core/constants/app_constants.dart'; // For border radius and other constants

/// Utilities for rendering Markdown content, specifically for educational articles
/// and stress relief exercise instructions within the Dhyana application.
class MarkdownUtils {
  /// Returns a MarkdownBody widget configured with Dhyana's styling.
  /// This function centralizes the styling for all Markdown content,
  /// ensuring consistency and adherence to the app's theme, including Glass Morphism.
  static Widget buildMarkdownBody(String data, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine text color based on theme
    final textColor = isDarkMode ? AppColors.textDark : AppColors.textLight;
    final linkColor = isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue;

    return MarkdownBody(
      data: data,
      selectable: true, // Allow users to select and copy text
      styleSheet: MarkdownStyleSheet(
        // Headings
        h1: AppTextStyles.headlineLarge.copyWith(color: textColor),
        h2: AppTextStyles.headlineMedium.copyWith(color: textColor),
        h3: AppTextStyles.headlineSmall.copyWith(color: textColor),
        h4: AppTextStyles.titleLarge.copyWith(color: textColor),
        h5: AppTextStyles.titleMedium.copyWith(color: textColor),
        h6: AppTextStyles.titleSmall.copyWith(color: textColor),

        // Paragraph text
        p: AppTextStyles.bodyMedium.copyWith(color: textColor, height: 1.5),

        // Strong (bold) text
        strong: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: textColor),

        // Emphasis (italic) text
        em: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic, color: textColor),

        // Links
        a: AppTextStyles.bodyMedium.copyWith(color: linkColor, decoration: TextDecoration.underline),

        // Blockquote
        blockquote: AppTextStyles.bodyMedium.copyWith(
          fontStyle: FontStyle.italic,
          color: textColor.withOpacity(0.7),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: linkColor, width: 4)),
          color: (isDarkMode ? AppColors.glassDarkSurface : AppColors.glassLightSurface).withOpacity(0.5), // Subtle glass effect
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        blockquotePadding: const EdgeInsets.all(AppConstants.paddingSmall),

        // Code blocks
        code: AppTextStyles.bodySmall.copyWith(
          fontFamily: 'monospace',
          backgroundColor: (isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.7),
          color: textColor,
        ),
        codeblockDecoration: BoxDecoration(
          color: (isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          border: Border.all(color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight),
        ),
        codeblockPadding: const EdgeInsets.all(AppConstants.paddingSmall),

        // Lists
        listBullet: AppTextStyles.bodyMedium.copyWith(color: textColor),
        // listItem: AppTextStyles.bodyMedium.copyWith(color: textColor), // Removed as it's not a valid parameter

        // Table
        tableBody: AppTextStyles.bodySmall.copyWith(color: textColor),
        tableHead: AppTextStyles.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.bold),
        tableBorder: TableBorder.all(color: textColor.withOpacity(0.5)),
      ),
      // Handle taps on links if needed
      onTapLink: (text, href, title) {
        // You can use url_launcher package here to open external links
        // For example: launchUrl(Uri.parse(href!));
        debugPrint('Tapped on link: $href');
      },
    );
  }
}
