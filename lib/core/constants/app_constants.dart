// lib/core/constants/app_constants.dart
class AppConstants {
  // --- API Endpoints ---
  static const String geminiApiBaseUrl =
      'https://generativelanguage.googleapis.com/';

  // WARNING: Do NOT hardcode real keys in production apps.
  static const String geminiApiKey =
      'AIzaSyDD-qi_sV6kXsfm_SArx1vozx36WtbmOFA';

  static const String pexelsApiBaseUrl = 'https://api.pexels.com/v1/';
  static const String pexelsApiKey = 'SaR5zTQtF9eFFtqX1wCk8zYiMIDJDMmbcqv2uYmW2v8Rm8N5XQ0cMVOo';
  static const String pixabayApiKey =
      '51743832-b6f01dc88fec4bc638cac0fd7';
  static const String pixabayApiBaseUrl = 'https://pixabay.com/api/';

  // Jamendo
  static const String jamendoApiBaseUrl = 'https://api.jamendo.com/v3.0/';
  static const String jamendoClientId = '157714b0';

  // Cloudinary (WARNING: never ship secrets in apps!)
  static const String cloudinaryCloudName = 'djahvdbbq';
  static const String cloudinaryApiKey = '423438424223433';
  static const String cloudinaryApiSecret = '_3X4E5EK4E28agSjO8NNwrNzwyY';
  static const String cloudinaryUploadPreset = 'ml_default';

  // --- Notification Channel IDs ---
  static const String meditationReminderChannelId = 'meditation_reminders';
  static const String meditationReminderChannelName = 'Meditation Reminders';
  static const String meditationReminderChannelDescription =
      'Notifications for scheduled meditation sessions.';

  static const String mindfulMomentChannelId = 'mindful_moments';
  static const String mindfulMomentChannelName = 'Mindful Moments';
  static const String mindfulMomentChannelDescription =
      'Short, spontaneous reminders to practice mindfulness.';

  // ✅ ADDED: New channel for Journaling Reminders
  static const String journalReminderChannelId = 'journal_reminders';
  static const String journalReminderChannelName = 'Journal Reminders';
  static const String journalReminderChannelDescription =
      'Notifications for scheduled journaling sessions.';

  // --- Animation Durations ---
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 400);
  static const Duration animationDurationSlow = Duration(milliseconds: 600);

  // --- UI Dimensions ---
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
  static const int defaultMeditationDurationMinutes = 10;
  static const int maxJournalEntryLength = 1000;
  static const int minPasswordLength = 6;

  // Default image placeholder URL
  static const String defaultPlaceholderImageUrl =
      'https://placehold.co/600x400/CCCCCC/000000?text=Image+Placeholder';

  // --- Shared Preferences Keys ---
  static const String themeModeKey = 'theme_mode';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userIdKey = 'user_id';
  static const String userProfileKey = 'user_profile';
  static const String meditationReminderEnabledKey =
      'meditation_reminder_enabled';
  static const String meditationReminderTimeKey = 'meditation_reminder_time';
  static const String mindfulMomentsEnabledKey = 'mindful_moments_enabled';
}