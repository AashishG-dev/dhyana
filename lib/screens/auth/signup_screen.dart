// lib/screens/auth/signup_screen.dart
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

/// A screen for user registration, allowing new users to create an account
/// with their email and password. It integrates with `AuthService` via Riverpod
/// to handle registration logic and provides navigation to the login screen.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles the signup process when the signup button is pressed.
  /// It validates the form, calls the authentication service, and
  /// handles success or error states.
  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = ref.read(authServiceProvider);
        await authService.signup(_emailController.text.trim(), _passwordController.text.trim());

        // On successful signup, navigate to the profile setup screen.
        if (mounted) {
          context.go('/profile-setup'); // Redirect to profile setup after signup
          Helpers.showSnackbar(context, 'Account created successfully! Please complete your profile.');
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('Signup Error: ${e.code} - ${e.message}');
        if (mounted) {
          String errorMessage;
          if (e.code == 'email-already-in-use') {
            errorMessage = 'The email address is already in use by another account.';
          } else if (e.code == 'weak-password') {
            errorMessage = 'The password provided is too weak.';
          } else {
            errorMessage = 'An error occurred during signup. Please try again.';
          }
          Helpers.showMessageDialog(
            context,
            title: 'Signup Failed',
            message: errorMessage,
          );
        }
      } catch (e) {
        debugPrint('General Signup Error: $e');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Signup Failed',
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
          'Sign Up',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        backgroundColor: Colors.transparent, // Ensure AppBar is transparent for background
        elevation: 0,
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
                      'Create Your Account',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                        fontWeight: FontWeight.bold,
                      ),
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
                    const SizedBox(height: AppConstants.paddingMedium),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      validator: (value) => Validators.isValidPassword(
                        value,
                        minLength: AppConstants.minPasswordLength,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: isDarkMode ? AppColors.textDark.withOpacity(0.7) : AppColors.textLight.withOpacity(0.7),
                      ),
                      suffixIcon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: isDarkMode ? AppColors.textDark.withOpacity(0.7) : AppColors.textLight.withOpacity(0.7),
                      ),
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      validator: (value) => Validators.isMatching(
                        _passwordController.text,
                        value,
                        field1Name: 'Password',
                        field2Name: 'Confirm Password',
                      ),
                      prefixIcon: Icon(
                        Icons.lock_reset_outlined,
                        color: isDarkMode ? AppColors.textDark.withOpacity(0.7) : AppColors.textLight.withOpacity(0.7),
                      ),
                      suffixIcon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: isDarkMode ? AppColors.textDark.withOpacity(0.7) : AppColors.textLight.withOpacity(0.7),
                      ),
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _isLoading
                        ? const LoadingWidget()
                        : CustomButton(
                      text: 'Sign Up',
                      onPressed: _handleSignup,
                      type: ButtonType.primary,
                      icon: Icons.person_add_alt_1_outlined,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                          ),
                        ),
                        CustomButton(
                          text: 'Login',
                          onPressed: () {
                            context.go('/login');
                          },
                          type: ButtonType.text,
                        ),
                      ],
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
