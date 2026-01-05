import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/widgets/common/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF212121)]
                : [AppColors.backgroundLight, const Color(0xFFEEEEEE)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.self_improvement,
                size: 120,
                // ✅ FIX: Replaced the non-existent 'primaryGreenDark' with 'primaryLightGreen'
                color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryPurple,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(
                'Welcome to Dhyana',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'Your personal guide to mindfulness, meditation, and inner peace.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withAlpha(204),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLarge * 2),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  context.go('/login');
                },
                type: ButtonType.primary,
                icon: Icons.login,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              CustomButton(
                text: 'Sign Up',
                onPressed: () {
                  context.go('/signup');
                },
                type: ButtonType.secondary,
                icon: Icons.person_add_alt_1_outlined,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              CustomButton(
                text: 'Continue as Guest',
                onPressed: () => context.go('/home'),
                type: ButtonType.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}