// lib/screens/onboarding/login_prompt_screen.dart
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPromptScreen extends StatelessWidget {
  const LoginPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // Semi-transparent background
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Login Required',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'This feature is only available for registered users. Please log in or create an account to continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    text: 'Go Home',
                    onPressed: () => context.go('/home'),
                    type: ButtonType.secondary,
                    isFullWidth: false,
                  ),
                  CustomButton(
                    text: 'Login / Sign Up',
                    onPressed: () => context.go('/welcome'),
                    type: ButtonType.primary,
                    isFullWidth: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}