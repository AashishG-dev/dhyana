// lib/core/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:dhyana/core/constants/app_colors.dart'; // For snackbar colors
import 'package:dhyana/widgets/dialogs/message_dialog.dart'; // Corrected import path for custom message dialog

/// Contains various general-purpose helper functions that can be reused
/// across different parts of the Dhyana application.
class Helpers {
  /// Displays a customizable Snackbar at the bottom of the screen.
  /// This is a common UI feedback mechanism for short, transient messages.
  static void showSnackbar(BuildContext context, String message,
      {Color? backgroundColor, Color? textColor, Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any existing snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? AppColors.backgroundLight),
        ),
        backgroundColor: backgroundColor ?? AppColors.primaryLightBlue,
        duration: duration,
        behavior: SnackBarBehavior.floating, // Makes it float above the bottom navigation bar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.all(16.0), // Adds margin around the snackbar
      ),
    );
  }

  /// Formats a DateTime object into a human-readable string.
  /// Uses the 'intl' package for flexible date formatting.
  /// Example: formatDate(DateTime.now(), 'yyyy-MM-dd HH:mm') -> "2023-10-27 15:30"
  static String formatDate(DateTime date, [String formatPattern = 'yyyy-MM-dd']) {
    return DateFormat(formatPattern).format(date);
  }

  /// Introduces a delay for a specified number of milliseconds.
  /// Useful for simulating network delays or for controlled animations.
  static Future<void> delay(int milliseconds) {
    return Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Shows a custom message dialog.
  /// This replaces the default `alert()` or `showDialog()` for consistent UI.
  static Future<void> showMessageDialog(
      BuildContext context, {
        required String title,
        required String message,
        String? buttonText,
        VoidCallback? onButtonPressed,
      }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return MessageDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onButtonPressed: () {
            Navigator.of(dialogContext).pop(); // Dismiss the dialog
            onButtonPressed?.call(); // Call the provided callback if any
          },
        );
      },
    );
  }

  /// Shows a custom confirmation dialog.
  /// This replaces the default `confirm()` for consistent UI.
  static Future<bool?> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Yes',
        String cancelText = 'No',
      }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color, // Use glass morphism background
          shape: Theme.of(context).cardTheme.shape,
          title: Text(title, style: Theme.of(context).textTheme.titleLarge),
          content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Return false on cancel
              },
              child: Text(cancelText, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Return true on confirm
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}
