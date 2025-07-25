// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/auth_provider.dart'; // For authService
import 'package:dhyana/providers/theme_provider.dart'; // For themeProvider
import 'package:dhyana/providers/notification_provider.dart'; // For notificationSettingsProvider
import 'package:dhyana/core/utils/helpers.dart'; // For showing snackbar/dialogs
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

/// A screen for managing application settings, including:
/// - Theme selection (light/dark/system).
/// - Notification settings (meditation reminders, mindful moments).
/// - Account management (logout).
/// It integrates with `ThemeProvider`, `NotificationSettingsNotifier`,
/// and `AuthService` via Riverpod.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay? _selectedReminderTime;

  @override
  void initState() {
    super.initState();
    _loadInitialReminderTime();
  }

  /// Loads the initial meditation reminder time from storage or default.
  Future<void> _loadInitialReminderTime() async {
    // In a real app, you'd fetch this from StorageService.
    // For now, let's assume a default or load from a placeholder.
    // Example: final storedTime = ref.read(storageServiceProvider).getString(AppConstants.meditationReminderTimeKey);
    // if (storedTime != null) {
    //   final parts = storedTime.split(':');
    //   _selectedReminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    // } else {
    //   _selectedReminderTime = const TimeOfDay(hour: 20, minute: 0); // Default 8 PM
    // }
    _selectedReminderTime = const TimeOfDay(hour: 20, minute: 0); // Default 8 PM
  }

  /// Handles user logout.
  Future<void> _handleLogout() async {
    final bool? confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      confirmText: 'Yes, Logout',
      cancelText: 'Cancel',
    );

    if (confirm == true) {
      try {
        await ref.read(authServiceProvider).logout();
        if (mounted) {
          context.go('/'); // Redirect to welcome/login screen
          Helpers.showSnackbar(context, 'Logged out successfully!');
        }
      } catch (e) {
        debugPrint('Logout Error: $e');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Logout Failed',
            message: 'An error occurred during logout. Please try again.',
          );
        }
      }
    }
  }

  /// Shows a time picker for setting meditation reminder time.
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme, // Use app's color scheme
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _selectedReminderTime = newTime;
      });
      // If reminder is already enabled, update its schedule
      final notificationNotifier = ref.read(notificationSettingsProvider.notifier);
      final isReminderEnabled = ref.read(notificationSettingsProvider);
      if (isReminderEnabled) {
        await notificationNotifier.toggleMeditationReminder(true, time: newTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Watch theme mode and notification reminder status
    final themeMode = ref.watch(themeProvider);
    final isMeditationReminderEnabled = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
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
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            // --- Theme Settings ---
            Card(
              margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Theme',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ListTile(
                      title: Text(
                        'Light Mode',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      trailing: Radio<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            ref.read(themeProvider.notifier).setLightMode();
                          }
                        },
                        activeColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Dark Mode',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      trailing: Radio<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            ref.read(themeProvider.notifier).setDarkMode();
                          }
                        },
                        activeColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'System Default',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      trailing: Radio<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            ref.read(themeProvider.notifier).setSystemMode();
                          }
                        },
                        activeColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Notification Settings ---
            Card(
              margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    SwitchListTile(
                      title: Text(
                        'Meditation Reminders',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      value: isMeditationReminderEnabled,
                      onChanged: (bool value) async {
                        final notificationNotifier = ref.read(notificationSettingsProvider.notifier);
                        if (value) {
                          // If enabling, ensure a time is selected
                          if (_selectedReminderTime == null) {
                            await _pickTime(context); // Force user to pick time
                          }
                          if (_selectedReminderTime != null) {
                            await notificationNotifier.toggleMeditationReminder(true, time: _selectedReminderTime);
                            if (context.mounted) Helpers.showSnackbar(context, 'Meditation reminders enabled.');
                          } else {
                            if (context.mounted) Helpers.showSnackbar(context, 'Please select a reminder time.', backgroundColor: AppColors.warningColor);
                          }
                        } else {
                          await notificationNotifier.toggleMeditationReminder(false);
                          if (context.mounted) Helpers.showSnackbar(context, 'Meditation reminders disabled.');
                        }
                      },
                      activeColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                    ),
                    if (isMeditationReminderEnabled)
                      ListTile(
                        title: Text(
                          'Reminder Time',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                          ),
                        ),
                        subtitle: Text(
                          _selectedReminderTime?.format(context) ?? 'Not set',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.access_time, color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue),
                          onPressed: () => _pickTime(context),
                        ),
                      ),
                    // You can add more notification settings here, e.g., for mindful moments
                    ListTile(
                      title: Text(
                        'Request Permissions',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      trailing: CustomButton(
                        text: 'Grant',
                        onPressed: () async {
                          final notificationNotifier = ref.read(notificationSettingsProvider.notifier);
                          final granted = await notificationNotifier.requestNotificationPermissions();
                          if (context.mounted) {
                            if (granted) {
                              Helpers.showSnackbar(context, 'Notification permissions granted!');
                            } else {
                              Helpers.showMessageDialog(
                                context,
                                title: 'Permissions Denied',
                                message: 'Notification permissions were denied. Please enable them in your device settings.',
                              );
                            }
                          }
                        },
                        type: ButtonType.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Account Settings ---
            Card(
              margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Center(
                      child: CustomButton(
                        text: 'Logout',
                        onPressed: _handleLogout,
                        type: ButtonType.secondary,
                        icon: Icons.logout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
