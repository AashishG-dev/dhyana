import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/user_profile_provider.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

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

  Future<void> _handleProfileSetup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) {
        debugPrint('No authenticated user found for profile setup.');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Error',
            message: 'No active user session. Please log in again.',
          );
          context.go('/login');
        }
        setState(() { _isLoading = false; });
        return;
      }

      try {
        final userProfileNotifier = ref.read(userProfileNotifierProvider.notifier);

        final updatedUser = UserModel(
          id: currentUser.uid,
          email: currentUser.email ?? 'no_email@example.com',
          name: _nameController.text.trim(),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          meditationGoals: [],
        );

        await userProfileNotifier.updateUserProfile(updatedUser);

        if (mounted) {
          context.go('/home');
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
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                      style: AppTextStyles.displayLarge.copyWith(
                        color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Tell us a bit about yourself to personalize your Dhyana experience.',
                      style: AppTextStyles.bodyMedium,
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
                        color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                      ),
                    ),
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
