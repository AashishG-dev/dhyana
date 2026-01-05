import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

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

  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final authService = ref.read(authServiceProvider);
        await authService.resetPassword(_emailController.text.trim());

        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Password Reset Email Sent',
            message: 'We’ve sent a reset link to your email. Please check your inbox.',
            buttonText: 'OK',
            onButtonPressed: () => context.go('/login'),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          final errorMessage = e.code == 'user-not-found'
              ? 'No user found for that email.'
              : 'Could not send reset email. Please try again.';
          Helpers.showMessageDialog(
            context,
            title: 'Password Reset Failed',
            message: errorMessage,
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: AppTextStyles.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDarkMode ? AppColors.textDark : AppColors.textLight),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [AppColors.backgroundDark, const Color(0xFF212121)]
                    : [AppColors.backgroundLight, const Color(0xFFEEEEEE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Reset Your Password',
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Enter your email to receive a reset link.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.isValidEmail,
                      prefixIcon: Icon(Icons.email_outlined,
                          color: (isDarkMode
                              ? AppColors.textDark
                              : AppColors.textLight)
                              .withOpacity(0.7)),
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
                      onPressed: () => context.go('/login'),
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