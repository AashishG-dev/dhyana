// lib/screens/auth/signup_screen.dart
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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
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

  Future<void> _handleSignup() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final authService = ref.read(authServiceProvider);
        await authService.signup(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          context.go('/profile-setup');
          Helpers.showSnackbar(
              context, 'Account created successfully! Complete your profile.');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          final errorMessage = e.code == 'email-already-in-use'
              ? 'The email is already in use.'
              : e.code == 'weak-password'
              ? 'The password is too weak.'
              : 'Signup failed. Try again.';
          Helpers.showMessageDialog(
            context,
            title: 'Signup Failed',
            message: errorMessage,
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        context.go('/home');
        Helpers.showSnackbar(context, 'Signed up with Google successfully!');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(
          context,
          title: 'Google Sign-Up Failed',
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
          'Sign Up',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
          ),
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
          // Background Gradient
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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingLarge),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(
                              'Create Your Account',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: isDarkMode
                                    ? AppColors.primaryLightGreen
                                    : AppColors.primaryLightBlue,
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
                                      .withAlpha(179)),
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              obscureText: _obscurePassword,
                              validator: (value) =>
                                  Validators.isValidPassword(
                                    value,
                                    minLength: AppConstants.minPasswordLength,
                                  ),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: (isDarkMode
                                      ? AppColors.textDark
                                      : AppColors.textLight)
                                      .withAlpha(179)),
                              suffixIcon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: (isDarkMode
                                    ? AppColors.textDark
                                    : AppColors.textLight)
                                    .withAlpha(179),
                              ),
                              onSuffixIconPressed: () {
                                setState(
                                        () => _obscurePassword = !_obscurePassword);
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
                              prefixIcon: Icon(Icons.lock_reset_outlined,
                                  color: (isDarkMode
                                      ? AppColors.textDark
                                      : AppColors.textLight)
                                      .withAlpha(179)),
                              suffixIcon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: (isDarkMode
                                    ? AppColors.textDark
                                    : AppColors.textLight)
                                    .withAlpha(179),
                              ),
                              onSuffixIconPressed: () {
                                setState(() => _obscureConfirmPassword =
                                !_obscureConfirmPassword);
                              },
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),
                            _isLoading
                                ? const LoadingWidget()
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomButton(
                                  text: 'Sign Up',
                                  onPressed: _handleSignup,
                                  type: ButtonType.primary,
                                  icon: Icons.person_add_alt_1_outlined,
                                ),
                                const SizedBox(height: AppConstants.paddingMedium),
                                // This is the new, isolated Google Sign-In button
                                OutlinedButton.icon(
                                  icon: Image.asset(
                                    'assets/icons/google_logo.png',
                                    height: 20.0,
                                    width: 20.0,
                                  ),
                                  onPressed: _handleGoogleSignUp,
                                  label: Text(
                                    'Sign up with Google',
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
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDarkMode
                                        ? AppColors.textDark
                                        : AppColors.textLight,
                                  ),
                                ),
                                CustomButton(
                                  text: 'Login',
                                  onPressed: () => context.go('/login'),
                                  type: ButtonType.text,
                                  isFullWidth: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}