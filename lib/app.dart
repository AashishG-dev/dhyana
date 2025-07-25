// lib/app.dart
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/screens/meditation/breathing_exercise_screen.dart';
import 'package:dhyana/screens/meditation/breathing_technique_detail_screen.dart';
import 'package:dhyana/screens/meditation/breathing_techniques_list_screen.dart';
import 'package:dhyana/screens/meditation/meditation_hub_screen.dart';
import 'package:dhyana/screens/reading_therapy/reading_therapy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/theme_provider.dart';
import 'package:dhyana/core/theme/app_theme.dart';

import 'package:dhyana/screens/auth/login_screen.dart';
import 'package:dhyana/screens/auth/signup_screen.dart';
import 'package:dhyana/screens/auth/forgot_password_screen.dart';
import 'package:dhyana/screens/onboarding/welcome_screen.dart';
import 'package:dhyana/screens/onboarding/profile_setup_screen.dart';
import 'package:dhyana/screens/home/home_screen.dart';
import 'package:dhyana/screens/meditation/meditation_list_screen.dart';
import 'package:dhyana/screens/meditation/meditation_detail_screen.dart';
import 'package:dhyana/screens/meditation/meditation_player_screen.dart';
import 'package:dhyana/screens/articles/article_list_screen.dart';
import 'package:dhyana/screens/articles/article_detail_screen.dart';
import 'package:dhyana/screens/journal/journal_list_screen.dart';
import 'package:dhyana/screens/journal/journal_entry_screen.dart';
import 'package:dhyana/screens/chatbot/chatbot_screen.dart';
import 'package:dhyana/screens/progress/progress_screen.dart';
import 'package:dhyana/screens/stress_relief/stress_relief_suggestions_screen.dart';
import 'package:dhyana/screens/stress_relief/exercise_demo_screen.dart';
import 'package:dhyana/screens/settings/settings_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider);

    final GoRouter router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/',
      routes: [
        // --- Onboarding & Auth ---
        GoRoute(
          path: '/',
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot_password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/profile-setup',
          name: 'profile_setup',
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        // --- Main App Screens ---
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        // --- Meditation Feature ---
        GoRoute(
          path: '/meditate',
          name: 'meditate',
          builder: (context, state) => const MeditationHubScreen(),
        ),
        GoRoute(
          path: '/meditate/breathing',
          name: 'breathing_techniques_list',
          builder: (context, state) => const BreathingTechniquesListScreen(),
        ),
        GoRoute(
          path: '/meditate/breathing/:techniqueId',
          name: 'breathing_technique_detail',
          builder: (context, state) {
            final techniqueId = state.pathParameters['techniqueId']!;
            return BreathingTechniqueDetailScreen(techniqueId: techniqueId);
          },
        ),
        GoRoute(
          path: '/meditations',
          name: 'meditations',
          builder: (context, state) => const MeditationListScreen(),
        ),
        GoRoute(
          path: '/meditation-detail/:id',
          name: 'meditation_detail',
          builder: (context, state) {
            final meditationId = state.pathParameters['id']!;
            return MeditationDetailScreen(meditationId: meditationId);
          },
        ),
        GoRoute(
          path: '/meditation-player/:id',
          name: 'meditation_player',
          builder: (context, state) {
            final meditationId = state.pathParameters['id'];
            return MeditationPlayerScreen(meditationId: meditationId);
          },
        ),
        GoRoute(
          path: '/meditation-complete',
          name: 'meditation_complete',
          builder: (context, state) {
            final meditation = state.extra as MeditationModel;
            return SessionCompleteScreen(meditation: meditation);
          },
        ),
        // --- Reading & Articles ---
        GoRoute(
          path: '/reading-therapy',
          name: 'reading_therapy',
          builder: (context, state) => const ReadingTherapyScreen(),
        ),
        GoRoute(
          path: '/articles',
          name: 'articles',
          builder: (context, state) => const ArticleListScreen(),
        ),
        GoRoute(
          path: '/article-detail/:id',
          name: 'article_detail',
          builder: (context, state) {
            final articleId = state.pathParameters['id'];
            return ArticleDetailScreen(articleId: articleId);
          },
        ),
        // --- Other Features ---
        GoRoute(
          path: '/journal',
          name: 'journal',
          builder: (context, state) => const JournalListScreen(),
        ),
        GoRoute(
          path: '/journal-entry',
          name: 'journal_entry',
          builder: (context, state) {
            final entryId = state.extra as String?;
            return JournalEntryScreen(entryId: entryId);
          },
        ),
        GoRoute(
          path: '/chatbot',
          name: 'chatbot',
          builder: (context, state) => const ChatbotScreen(),
        ),
        GoRoute(
          path: '/progress',
          name: 'progress',
          builder: (context, state) => const ProgressScreen(),
        ),
        GoRoute(
          path: '/stress-relief',
          name: 'stress_relief',
          builder: (context, state) => const StressReliefSuggestionsScreen(),
        ),
        GoRoute(
          path: '/exercise-demo/:id',
          name: 'exercise_demo',
          builder: (context, state) {
            final exerciseId = state.pathParameters['id'];
            return ExerciseDemoScreen(exerciseId: exerciseId);
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authState.valueOrNull != null;
        const unauthenticatedRoutes = ['/', '/login', '/signup', '/forgot-password'];
        final isGoingToUnauthenticatedRoute = unauthenticatedRoutes.contains(state.uri.path);

        if (!isLoggedIn && !isGoingToUnauthenticatedRoute) {
          return '/login';
        } else if (isLoggedIn && isGoingToUnauthenticatedRoute) {
          return '/home';
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Dhyana',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      debugShowCheckedModeBanner: false,
    );
  }
}