// lib/screens/settings/settings_screen.dart
import 'package:dhyana/providers/onboarding_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/theme_provider.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/providers/user_profile_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    final bool? confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      confirmText: 'Yes, Logout',
      cancelText: 'Cancel',
    );

    if (confirm == true && context.mounted) {
      try {
        // ✅ ADDED: This tells the router that a logout has occurred
        // so it can redirect to the welcome screen properly.
        await ref.read(onboardingNotifierProvider.notifier).handleLogoutRedirect();
        await ref.read(authServiceProvider).logout();

      } catch (e) {
        debugPrint('Logout Error: $e');
        if (context.mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Logout Failed',
            message: 'An error occurred during logout. Please try again.',
          );
        }
      }
    }
  }

  Future<void> _handleDeleteData(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProfileProvider).value;
    if (user?.id == null) return;

    final bool? confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete All My Data',
      message:
      'This action is irreversible and will permanently delete all your journal entries, progress, and preferences. Are you sure you want to continue?',
      confirmText: 'Yes, Delete Everything',
      cancelText: 'Cancel',
    );

    if (confirm == true && context.mounted) {
      try {
        await ref
            .read(userProfileNotifierProvider.notifier)
            .deleteUserData(user!.id!);
        if (context.mounted) {
          Helpers.showSnackbar(
              context, 'Your data has been successfully deleted.');
          context.go('/welcome');
        }
      } catch (e) {
        debugPrint('Delete Data Error: $e');
        if (context.mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Deletion Failed',
            message:
            'An error occurred while deleting your data. Please try again.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeModeAsync = ref.watch(themeProvider);
    final user = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: Stack(
        fit: StackFit.expand,
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
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              children: [
                _buildSettingsCard(
                  context,
                  title: 'App Theme',
                  child: themeModeAsync.when(
                    data: (themeMode) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildThemeChoice(
                          context: context,
                          icon: Icons.wb_sunny_outlined,
                          label: 'Light',
                          isSelected: themeMode == ThemeMode.light,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(ThemeMode.light),
                        ),
                        _buildThemeChoice(
                          context: context,
                          icon: Icons.nightlight_outlined,
                          label: 'Dark',
                          isSelected: themeMode == ThemeMode.dark,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(ThemeMode.dark),
                        ),
                        _buildThemeChoice(
                          context: context,
                          icon: Icons.settings_system_daydream_outlined,
                          label: 'System',
                          isSelected: themeMode == ThemeMode.system,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(ThemeMode.system),
                        ),
                      ],
                    ),
                    loading: () => const LoadingWidget(),
                    error: (err, stack) =>
                    const Text('Error loading theme settings.'),
                  ),
                ),
                _buildSettingsCard(
                  context,
                  title: 'Notifications',
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Reminder Settings'),
                    subtitle: const Text('Set daily reminders for meditation'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/notification-settings'),
                  ),
                ),
                if (user?.id != null)
                  _buildSettingsCard(
                    context,
                    title: 'Manage Data',
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Update Preferences',
                          onPressed: () => context.push('/preferences'),
                          type: ButtonType.secondary,
                          icon: Icons.tune,
                        ),
                        const SizedBox(height: 16.0),
                        CustomButton(
                          text: 'Delete My Data',
                          onPressed: () => _handleDeleteData(context, ref),
                          type: ButtonType.secondary,
                          icon: Icons.delete_forever,
                        ),
                      ],
                    ),
                  ),
                _buildSettingsCard(
                  context,
                  title: 'Account',
                  child: Center(
                    child: CustomButton(
                      text: 'Logout',
                      onPressed: () => _handleLogout(context, ref),
                      type: ButtonType.secondary,
                      icon: Icons.logout,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: IgnorePointer(
                child: Text(
                  'Developed by Aashish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppConstants.paddingMedium),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChoice({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color =
    isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryPurple;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(38) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withAlpha(77),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? color : null,
                )),
          ],
        ),
      ),
    );
  }
}