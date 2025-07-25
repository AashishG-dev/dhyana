// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart'; // For showing snackbar/dialogs
import 'package:dhyana/providers/auth_provider.dart'; // For authService
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart'; // For loading indicator

/// A screen for user login, allowing users to authenticate with their email and password.
/// It integrates with `AuthService` via Riverpod to handle authentication logic
/// and provides navigation to signup and forgot password screens.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the login process when the login button is pressed.
  /// It validates the form, calls the authentication service, and
  /// handles success or error states.
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = ref.read(authServiceProvider);
        await authService.login(_emailController.text.trim(), _passwordController.text.trim());

        // On successful login, navigate to the home screen.
        // The authStateProvider redirect in App widget will also handle this.
        if (mounted) {
          context.go('/home');
          Helpers.showSnackbar(context, 'Logged in successfully!');
        }
      } catch (e) {
        debugPrint('Login Error: $e');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Login Failed',
            message: e.toString().contains('firebase_auth')
                ? 'Invalid email or password. Please try again.' // Generic message for common Firebase errors
                : 'An unexpected error occurred. Please try again later.',
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
          'Login',
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
                      'Welcome Back!',
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
                      validator: Validators.isValidPassword,
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
                    const SizedBox(height: AppConstants.paddingSmall),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        text: 'Forgot Password?',
                        onPressed: () {
                          context.go('/forgot-password');
                        },
                        type: ButtonType.text,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _isLoading
                        ? const LoadingWidget()
                        : CustomButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      type: ButtonType.primary,
                      icon: Icons.login,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                          ),
                        ),
                        CustomButton(
                          text: 'Sign Up',
                          onPressed: () {
                            context.go('/signup');
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
