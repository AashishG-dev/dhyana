// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For FirebaseAuthException

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart'; // For showing snackbar/dialogs
import 'package:dhyana/providers/auth_provider.dart'; // For authService
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart'; // For loading indicator

/// A screen for users to reset their password. It allows users to enter their
/// email address to receive a password reset link. It integrates with `AuthService`
/// via Riverpod to handle the password reset logic.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handles the password reset process when the button is pressed.
  /// It validates the email, calls the authentication service to send
  /// a reset email, and provides feedback to the user.
  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = ref.read(authServiceProvider);
        await authService.resetPassword(_emailController.text.trim());

        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Password Reset Email Sent',
            message: 'A password reset link has been sent to your email address. Please check your inbox.',
            buttonText: 'OK',
            onButtonPressed: () {
              context.go('/login'); // Navigate back to login after sending email
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('Firebase Auth Reset Password Error: ${e.code} - ${e.message}');
        if (mounted) {
          String errorMessage;
          if (e.code == 'user-not-found') {
            errorMessage = 'No user found for that email. Please check the email address.';
          } else {
            errorMessage = 'An error occurred while sending the reset email. Please try again.';
          }
          Helpers.showMessageDialog(
            context,
            title: 'Password Reset Failed',
            message: errorMessage,
          );
        }
      } catch (e) {
        debugPrint('General Reset Password Error: $e');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Password Reset Failed',
            message: 'An unexpected error occurred. Please try again later.',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        backgroundColor: Colors.transparent, // Ensure AppBar is transparent for background
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
          ),
          onPressed: () {
            context.pop(); // Go back to the previous screen (login)
          },
        ),
      ),
      extendBodyBehindAppBar: true, // Extends body behind the app bar
      body: Stack(
        children: [
          // Background gradient or image (for Glass Morphism effect)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [AppColors.backgroundDark, const Color(0xFF212121)]
                    : [AppColors.backgroundLight, const Color(0xFFEEEEEE)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reset Your Password',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Enter your email address below and we\'ll send you a link to reset your password.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.isValidEmail,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: isDarkMode ? AppColors.textDark.withOpacity(0.7) : AppColors.textLight.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _isLoading
                        ? const LoadingWidget()
                        : CustomButton(
                      text: 'Send Reset Link',
                      onPressed: _handlePasswordReset,
                      type: ButtonType.primary,
                      icon: Icons.send_outlined,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    CustomButton(
                      text: 'Back to Login',
                      onPressed: () {
                        context.go('/login');
                      },
                      type: ButtonType.text,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
