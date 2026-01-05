// lib/providers/router_provider.dart
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/models/feedback_model.dart';
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/models/meme_model.dart';
import 'package:dhyana/models/music_track_model.dart';
import 'package:dhyana/models/standup_video_model.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/models/yoga_video_model.dart';
import 'package:dhyana/providers/onboarding_provider.dart';
import 'package:dhyana/screens/admin/add_edit_yoga_video_screen.dart';
import 'package:dhyana/screens/admin/feedback_detail_screen.dart';
import 'package:dhyana/screens/admin/feedback_management_screen.dart';
import 'package:dhyana/screens/admin/laughing_therapy_management_screen.dart';
import 'package:dhyana/screens/admin/manage_article_screen.dart';
import 'package:dhyana/screens/admin/manage_meme_screen.dart';
import 'package:dhyana/screens/admin/manage_standup_screen.dart';
import 'package:dhyana/screens/admin/manage_yoga_therapy_screen.dart';
import 'package:dhyana/screens/home/preferences_screen.dart';
import 'package:dhyana/screens/laughing/laughing_therapy_screen.dart';
import 'package:dhyana/screens/laughing/meme_feed_screen.dart';
import 'package:dhyana/screens/meditation/offline_meditations_screen.dart';
import 'package:dhyana/screens/meditation/session_complete_screen.dart';
import 'package:dhyana/screens/onboarding/login_prompt_screen.dart';
import 'package:dhyana/screens/onboarding/onboarding_screen.dart';
import 'package:dhyana/screens/profile/offline_screen.dart';
import 'package:dhyana/screens/settings/notification_settings_screen.dart';
import 'package:dhyana/screens/yoga/yoga_therapy_screen.dart';
import 'package:dhyana/screens/yoga/yoga_video_player_screen.dart';
import 'package:dhyana/screens/yoga/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/providers/auth_provider.dart';

// Screen Imports
import 'package:dhyana/screens/onboarding/splash_screen.dart';
import 'package:dhyana/screens/auth/login_screen.dart';
import 'package:dhyana/screens/auth/signup_screen.dart';
import 'package:dhyana/screens/auth/forgot_password_screen.dart';
import 'package:dhyana/screens/onboarding/welcome_screen.dart';
import 'package:dhyana/screens/onboarding/profile_setup_screen.dart';
import 'package:dhyana/screens/home/home_screen.dart';
import 'package:dhyana/screens/meditation/meditation_player_screen.dart';
import 'package:dhyana/screens/meditation/meditation_list_screen.dart';
import 'package:dhyana/screens/meditation/meditation_detail_screen.dart';
import 'package:dhyana/screens/meditation/breathing_technique_detail_screen.dart';
import 'package:dhyana/screens/meditation/breathing_techniques_list_screen.dart';
import 'package:dhyana/screens/meditation/meditation_hub_screen.dart';
import 'package:dhyana/screens/articles/article_list_screen.dart';
import 'package:dhyana/screens/articles/article_detail_screen.dart';
import 'package:dhyana/screens/articles/saved_articles_screen.dart';
import 'package:dhyana/screens/journal/journal_list_screen.dart';
import 'package:dhyana/screens/journal/journal_entry_screen.dart';
import 'package:dhyana/screens/chatbot/chatbot_screen.dart';
import 'package:dhyana/screens/progress/progress_screen.dart';
import 'package:dhyana/screens/stress_relief/stress_relief_suggestions_screen.dart';
import 'package:dhyana/screens/stress_relief/exercise_demo_screen.dart';
import 'package:dhyana/screens/settings/settings_screen.dart';
import 'package:dhyana/screens/reading_therapy/reading_therapy_screen.dart';
import 'package:dhyana/screens/music/music_therapy_screen.dart';
import 'package:dhyana/screens/music/music_player_screen.dart';
import 'package:dhyana/screens/music/music_category_screen.dart';
import 'package:dhyana/screens/profile/profile_screen.dart';
import 'package:dhyana/screens/profile/downloads_screen.dart';
import 'package:dhyana/screens/profile/edit_profile_screen.dart';
import 'package:dhyana/screens/admin/admin_portal_screen.dart';
import 'package:dhyana/screens/admin/article_management_screen.dart';
import 'package:dhyana/screens/admin/user_management_screen.dart';
import 'package:dhyana/screens/admin/edit_user_screen.dart';
import 'package:dhyana/screens/levels/levels_screen.dart';
import 'package:dhyana/screens/levels/level_detail_screen.dart';
import 'package:dhyana/core/utils/gamification_utils.dart';

import '../screens/settings/feedback_screen.dart';

final routeObserverProvider = Provider<RouteObserver<ModalRoute>>((ref) {
  return RouteObserver<ModalRoute>();
});

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final routerNotifierProvider =
AutoDisposeAsyncNotifierProvider<RouterNotifier, void>(() {
  return RouterNotifier();
});

class RouterNotifier extends AutoDisposeAsyncNotifier<void>
    implements Listenable {
  VoidCallback? _routerListener;

  @override
  Future<void> build() async {
    ref.listen(authStateProvider, (_, __) => _routerListener?.call());
    ref.listen(currentUserProfileProvider, (_, __) => _routerListener?.call());
    ref.listen(onboardingStatusProvider, (_, __) => _routerListener?.call());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final onboardingState = ref.watch(onboardingStatusProvider);
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(currentUserProfileProvider);
    final location = state.uri.path;
    final justLoggedOut = ref.watch(justLoggedOutProvider);

    if (authState.isLoading ||
        (authState.hasValue && !profileState.hasValue && !profileState.hasError)) {
      return '/splash';
    }

    if (justLoggedOut) {
      ref.read(onboardingNotifierProvider.notifier).clearLogoutFlag();
      return '/welcome';
    }

    final hasSeenOnboarding = onboardingState.value ?? false;
    final isLoggedIn = authState.valueOrNull != null;
    final userProfile = profileState.valueOrNull;

    const splash = '/splash';
    const onboarding = '/onboarding';
    const welcome = '/welcome';
    const home = '/home';
    const setup = '/profile-setup';
    const loginPrompt = '/login-prompt';

    const publicRoutes = [
      welcome,
      '/',
      '/login',
      '/signup',
      '/forgot-password',
      onboarding,
      loginPrompt
    ];
    const protectedRoutes = [
      '/profile',
      '/edit-profile',
      '/journal',
      '/progress',
      '/offline-content',
      '/saved-articles'
    ];

    if (!isLoggedIn && !hasSeenOnboarding && location != onboarding) {
      return onboarding;
    }

    if (!isLoggedIn && hasSeenOnboarding && location == splash) {
      return welcome;
    }

    if (isLoggedIn) {
      if (location == onboarding) {
        return home;
      }
      if (userProfile != null) {
        if (userProfile.name.isEmpty && location != setup) return setup;
        if (userProfile.name.isNotEmpty &&
            (publicRoutes.contains(location) || location == splash))
          return home;
      }
    } else {
      final isGoingToProtectedRoute =
      protectedRoutes.any((route) => location.startsWith(route));
      if (isGoingToProtectedRoute) {
        return loginPrompt;
      }
    }

    return null;
  }

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    _routerListener = null;
  }
}

// Helper function for clean fade transitions
CustomTransitionPage<T> _buildPageWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}


final routerProvider = Provider<GoRouter>((ref) {
  final navigatorKey = ref.watch(rootNavigatorKeyProvider);
  final routerNotifier = ref.watch(routerNotifierProvider.notifier);
  final routeObserver = ref.watch(routeObserverProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: routerNotifier,
    redirect: routerNotifier.redirect,
    observers: [routeObserver],
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login-prompt',
        name: 'login_prompt',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LoginPromptScreen(),
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile_setup',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ProfileSetupScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/preferences',
        name: 'preferences',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const PreferencesScreen(),
        ),
      ),
      GoRoute(
        path: '/levels',
        name: 'levels',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LevelsScreen(),
        ),
      ),
      GoRoute(
        path: '/level-detail',
        name: 'level_detail',
        pageBuilder: (context, state) {
          final level = state.extra as Level;
          return _buildPageWithFadeTransition(
            context: context,
            state: state,
            child: LevelDetailScreen(level: level),
          );
        },
      ),
      GoRoute(
        path: '/meditate',
        name: 'meditate',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const MeditationHubScreen(),
        ),
      ),
      GoRoute(
        path: '/meditations',
        name: 'meditations',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const MeditationListScreen(),
        ),
      ),
      GoRoute(
        path: '/meditation-detail/:id',
        name: 'meditation_detail',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child:
          MeditationDetailScreen(meditationId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/meditation-player/:id',
        name: 'meditation_player',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: MeditationPlayerScreen(
              meditationId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/meditation-complete',
        name: 'meditation_complete',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: SessionCompleteScreen(
              meditation: state.extra as MeditationModel),
        ),
      ),
      GoRoute(
        path: '/meditate/breathing',
        name: 'breathing_techniques_list',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const BreathingTechniquesListScreen(),
        ),
      ),
      GoRoute(
        path: '/meditate/breathing/:techniqueId',
        name: 'breathing_technique_detail',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: BreathingTechniqueDetailScreen(
              techniqueId: state.pathParameters['techniqueId']!),
        ),
      ),
      GoRoute(
        path: '/reading-therapy',
        name: 'reading_therapy',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ReadingTherapyScreen(),
        ),
      ),
      GoRoute(
        path: '/articles',
        name: 'articles',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ArticleListScreen(),
        ),
      ),
      GoRoute(
        path: '/article-detail/:id',
        name: 'article_detail',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: ArticleDetailScreen(articleId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/saved-articles',
        name: 'saved_articles',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SavedArticlesScreen(),
        ),
      ),
      GoRoute(
        path: '/music-therapy',
        name: 'music_therapy',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const MusicTherapyScreen(),
        ),
      ),
      GoRoute(
        path: '/music-category',
        name: 'music_category',
        pageBuilder: (context, state) {
          final category = state.extra as Map<String, String>;
          return _buildPageWithFadeTransition(
            context: context,
            state: state,
            child: MusicCategoryScreen(
                categoryTitle: category['title']!,
                categoryQuery: category['query']!),
          );
        },
      ),
      GoRoute(
        path: '/music-player',
        name: 'music_player',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return _buildPageWithFadeTransition(
            context: context,
            state: state,
            child: MusicPlayerScreen(
                track: data['track'], playlist: data['playlist']),
          );
        },
      ),
      GoRoute(
        path: '/offline-content',
        name: 'offline_content',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const OfflineScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit_profile',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const FeedbackScreen(),
        ),
      ),
      GoRoute(
        path: '/notification-settings',
        name: 'notification_settings',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const NotificationSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/admin-portal',
        name: 'admin_portal',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const AdminPortalScreen(),
        ),
      ),
      GoRoute(
        path: '/manage-article',
        name: 'manage_article',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: ManageArticleScreen(article: state.extra as ArticleModel?),
        ),
      ),
      GoRoute(
        path: '/admin/articles',
        name: 'admin_articles',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ArticleManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const UserManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/edit-user',
        name: 'admin_edit_user',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: EditUserScreen(user: state.extra as UserModel),
        ),
      ),
      GoRoute(
        path: '/admin/laughing-therapy',
        name: 'admin_laughing_therapy',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LaughingTherapyManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/manage-meme',
        name: 'admin_manage_meme',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: ManageMemeScreen(meme: state.extra as MemeModel?),
        ),
      ),
      GoRoute(
        path: '/admin/manage-standup',
        name: 'admin_manage_standup',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: ManageStandupScreen(video: state.extra as StandupVideoModel?),
        ),
      ),
      GoRoute(
        path: '/admin/manage-yoga-therapy',
        name: 'admin_manage_yoga_therapy',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ManageYogaTherapyScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/feedback',
        name: 'admin_feedback',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const FeedbackManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/feedback-detail',
        name: 'admin_feedback_detail',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: FeedbackDetailScreen(feedback: state.extra as FeedbackModel),
        ),
      ),
      GoRoute(
        path: '/admin/add-edit-yoga-video',
        name: 'admin_add_edit_yoga_video',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: AddEditYogaVideoScreen(video: state.extra as YogaVideoModel?),
        ),
      ),
      GoRoute(
        path: '/journal',
        name: 'journal',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const JournalListScreen(),
        ),
      ),
      GoRoute(
        path: '/journal-entry',
        name: 'journal_entry',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child:
          JournalEntryScreen(extra: state.extra as Map<String, dynamic>?),
        ),
      ),
      GoRoute(
        path: '/chatbot',
        name: 'chatbot',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ChatbotScreen(),
        ),
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const ProgressScreen(),
        ),
      ),
      GoRoute(
        path: '/stress-relief',
        name: 'stress_relief',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const StressReliefSuggestionsScreen(),
        ),
      ),
      GoRoute(
        path: '/exercise-demo/:id',
        name: 'exercise_demo',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child:
          ExerciseDemoScreen(exerciseId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/yoga',
        name: 'yoga',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const YogaTherapyScreen(),
        ),
      ),
      GoRoute(
        path: '/yoga/webview',
        name: 'yoga_webview',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return _buildPageWithFadeTransition(
            context: context,
            state: state,
            child: WebViewScreen(url: extra['url']!, title: extra['title']!),
          );
        },
      ),
      GoRoute(
        path: '/yoga/video',
        name: 'yoga_video',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final videoId = extra['videoId'] as String;
          final title = extra['title'] as String;
          final taskType = extra['taskType'] as String?;

          return _buildPageWithFadeTransition(
            context: context,
            state: state,
            child: YogaVideoPlayerScreen(
              videoId: videoId,
              title: title,
              taskType: taskType,
            ),
          );
        },
      ),
      GoRoute(
        path: '/laughing',
        name: 'laughing',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LaughingTherapyScreen(),
        ),
      ),
      GoRoute(
        path: '/laughing/memes',
        name: 'meme_feed',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const MemeFeedScreen(),
        ),
      ),
    ],
  );
});

