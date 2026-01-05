// lib/widgets/dialogs/login_prompt_dialog.dart
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shows a dialog prompting the guest user to log in to access a feature.
void showLoginPromptDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // User must explicitly choose an option
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
            'This feature is only available for registered users. Please log in or create an account to continue.'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: <Widget>[
          CustomButton(
            text: 'Go Home',
            onPressed: () {
              // Dismiss the dialog and navigate to the home screen
              Navigator.of(dialogContext).pop();
              context.go('/home');
            },
            type: ButtonType.secondary,
            isFullWidth: false,
          ),
          CustomButton(
            text: 'Login / Sign Up',
            onPressed: () {
              // Dismiss the dialog and navigate to the welcome/login screen
              Navigator.of(dialogContext).pop();
              context.go('/welcome');
            },
            type: ButtonType.primary,
            isFullWidth: false,
          ),
        ],
      );
    },
  );
}