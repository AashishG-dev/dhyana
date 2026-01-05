// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

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

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final authService = ref.read(authServiceProvider);
        await authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          context.go('/home');
          Helpers.showSnackbar(context, 'Logged in successfully!');
        }
      } catch (e) {
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Login Failed',
            message: e.toString().contains('firebase_auth')
                ? 'Invalid email or password. Please try again.'
                : 'An unexpected error occurred. Please try again later.',
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        context.go('/home');
        Helpers.showSnackbar(context, 'Signed in with Google successfully!');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(
          context,
          title: 'Google Sign-In Failed',
          message: 'An unexpected error occurred. Please try again later.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: AppTextStyles.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                    const SizedBox(height: AppConstants.paddingMedium),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      validator: Validators.isValidPassword,
                      prefixIcon: Icon(Icons.lock_outline,
                          color: (isDarkMode
                              ? AppColors.textDark
                              : AppColors.textLight)
                              .withOpacity(0.7)),
                      suffixIcon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: (isDarkMode
                            ? AppColors.textDark
                            : AppColors.textLight)
                            .withOpacity(0.7),
                      ),
                      onSuffixIconPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        text: 'Forgot Password?',
                        onPressed: () => context.go('/forgot-password'),
                        type: ButtonType.text,
                        isFullWidth: false,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _isLoading
                        ? const LoadingWidget()
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomButton(
                          text: 'Login',
                          onPressed: _handleLogin,
                          type: ButtonType.primary,
                          icon: Icons.login,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        // This is the new, isolated Google Sign-In button
                        OutlinedButton.icon(
                          icon: Image.asset(
                            'assets/icons/google_logo.png',
                            height: 20.0,
                            width: 20.0,
                          ),
                          onPressed: _handleGoogleSignIn,
                          label: Text(
                            'Sign in with Google',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingMedium,
                              horizontal: AppConstants.paddingLarge,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                            ),
                            side: BorderSide(
                              color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: AppTextStyles.bodyMedium,
                        ),
                        CustomButton(
                          text: 'Sign Up',
                          onPressed: () => context.go('/signup'),
                          type: ButtonType.text,
                          isFullWidth: false,
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