// lib/screens/onboarding/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart'; // For showing snackbar/dialogs
import 'package:dhyana/providers/auth_provider.dart'; // For authStateProvider and firestoreServiceProvider
import 'package:dhyana/providers/user_profile_provider.dart'; // For userProfileNotifierProvider
import 'package:dhyana/models/user_model.dart'; // For UserModel
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart'; // For loading indicator

/// A screen for new users to set up their profile after registration.
/// It allows users to enter their name, and optionally set meditation goals.
/// This screen ensures that a basic user profile is created in Firestore.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Handles the profile setup process.
  /// It validates the form, retrieves the current user, creates/updates
  /// their profile in Firestore, and navigates to the home screen.
  Future<void> _handleProfileSetup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final currentUser = ref.read(authStateProvider).value; // Get the current Firebase User
      if (currentUser == null) {
        debugPrint('No authenticated user found for profile setup.');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Error',
            message: 'No active user session. Please log in again.',
          );
          context.go('/login'); // Redirect to login
        }
        setState(() { _isLoading = false; });
        return;
      }

      try {
        final userProfileNotifier = ref.read(userProfileNotifierProvider.notifier);

        // Create a new UserModel instance with updated name and current user's ID/email
        final updatedUser = UserModel(
          id: currentUser.uid,
          email: currentUser.email ?? 'no_email@example.com', // Use existing email or fallback
          name: _nameController.text.trim(),
          createdAt: DateTime.now(), // Assuming this is initial setup
          lastLoginAt: DateTime.now(),
          meditationGoals: [], // Can be expanded later for user selection
        );

        await userProfileNotifier.updateUserProfile(updatedUser);

        if (mounted) {
          context.go('/home'); // Navigate to home after profile setup
          Helpers.showSnackbar(context, 'Profile setup complete!');
        }
      } catch (e) {
        debugPrint('Profile Setup Error: $e');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Profile Setup Failed',
            message: 'An error occurred during profile setup. Please try again later.',
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
          'Complete Your Profile',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button for profile setup
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
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
                      'Just a few more details!',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Tell us a bit about yourself to personalize your Dhyana experience.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Your Name',
                      keyboardType: TextInputType.name,
                      validator: (value) => Validators.isValidName(value, minLength: 2),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: isDarkMode ? AppColors.textDark.withOpacity(0.7) : AppColors.textLight.withOpacity(0.7),
                      ),
                    ),
                    // You can add more fields here for meditation goals, etc.
                    const SizedBox(height: AppConstants.paddingLarge),
                    _isLoading
                        ? const LoadingWidget()
                        : CustomButton(
                      text: 'Complete Setup',
                      onPressed: _handleProfileSetup,
                      type: ButtonType.primary,
                      icon: Icons.check_circle_outline,
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
