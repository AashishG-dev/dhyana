// lib/core/constants/app_constants.dart

/// Stores various app-wide constants and configuration values not
/// directly related to colors or text styles. This includes API endpoints,
/// notification channel IDs, animation durations, and general UI dimensions.
class AppConstants {
  // --- API Endpoints ---
  // Placeholder for Gemini API base URL. Replace with your actual endpoint.
  // Remember to keep API keys secure and not hardcode them in production apps.
  static const String geminiApiBaseUrl = 'https://generativelanguage.googleapis.com/'; // Updated for Gemini API
  static const String geminiApiKey = 'AIzaSyDR0xIJQtWliusKf9kA_FeF-dYRfmZ6_ZE'; // Your actual Gemini key

  // Cloudinary configuration details
  // WARNING: Hardcoding these credentials is a major security risk!
  static const String cloudinaryCloudName = 'dvsghzc2q';
  static const String cloudinaryApiKey = '423438424223433';
  static const String cloudinaryApiSecret = '_3X4E5EK4E28agSjO8NNwrNzwyY';
  static const String cloudinaryUploadPreset = 'dhyana_unsigned_upload';
  // --- Notification Channel IDs ---
  // Unique IDs for different notification channels on Android.
  // These are important for users to manage notification preferences.
  static const String meditationReminderChannelId = 'meditation_reminders';
  static const String meditationReminderChannelName = 'Meditation Reminders';
  static const String meditationReminderChannelDescription = 'Notifications for scheduled meditation sessions.';

  static const String mindfulMomentChannelId = 'mindful_moments';
  static const String mindfulMomentChannelName = 'Mindful Moments';
  static const String mindfulMomentChannelDescription = 'Short, spontaneous reminders to practice mindfulness.';

  // --- Animation Durations ---
  // Standard durations for animations to ensure consistent feel.
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 400);
  static const Duration animationDurationSlow = Duration(milliseconds: 600);

  // --- UI Dimensions ---
  // Consistent padding, margin, and border radius values.
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0; // Common for cards and buttons
  static const double borderRadiusLarge = 24.0;

  // --- Other App-wide Constants ---
  static const int defaultMeditationDurationMinutes = 10; // Default duration for new meditation sessions
  static const int maxJournalEntryLength = 1000; // Max characters for journal entries
  static const int minPasswordLength = 6; // Minimum password length for authentication

  // Default image placeholder URL (if needed for UI, though Cloudinary will handle most assets)
  static const String defaultPlaceholderImageUrl = 'https://placehold.co/600x400/CCCCCC/000000?text=Image+Placeholder';

  // --- Shared Preferences Keys ---
  // Keys for storing data in shared preferences
  static const String themeModeKey = 'theme_mode';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userIdKey = 'user_id';
  static const String userProfileKey = 'user_profile'; // For caching user profile data
  static const String meditationReminderEnabledKey = 'meditation_reminder_enabled';
  static const String meditationReminderTimeKey = 'meditation_reminder_time';
  static const String mindfulMomentsEnabledKey = 'mindful_moments_enabled';
}
