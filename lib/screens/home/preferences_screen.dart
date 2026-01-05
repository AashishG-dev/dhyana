// lib/screens/home/preferences_screen.dart
import 'package:dhyana/models/preference_page_model.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/user_profile_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final Map<String, List<String>> _selectedPreferences = {
    'goals': [],
    'activities': [],
    'moods': [],
  };

  final List<PreferencePageModel> _pages = [
    PreferencePageModel(
      title: 'What are your goals?',
      description: 'Select your primary motivations for using Dhyana.',
      lottieAsset: 'assets/animations/onboarding_1.json',
      options: [
        'Reduce Stress',
        'Improve Focus',
        'Increase Happiness',
        'Better Sleep',
        'Self-Esteem'
      ],
      preferenceKey: 'goals',
    ),
    PreferencePageModel(
      title: 'How do you like to relax?',
      description: 'Choose the activities you\'re most interested in.',
      lottieAsset: 'assets/animations/onboarding_2.json',
      options: [
        'Breathing',
        'Reading',
        'Music',
        'Yoga',
        'Laughing',
        'Journaling'
      ],
      preferenceKey: 'activities',
    ),
    PreferencePageModel(
      title: 'How are you feeling now?',
      description: 'This helps us recommend the right content for you.',
      lottieAsset: 'assets/animations/onboarding_3.json',
      options: ['Happy', 'Calm', 'Stressed', 'Anxious', 'Sad', 'Neutral'],
      preferenceKey: 'moods',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile != null) {
      _selectedPreferences['goals'] =
      List<String>.from(userProfile.meditationGoals);
      _selectedPreferences['activities'] =
      List<String>.from(userProfile.preferredActivities);
      if (userProfile.currentMood != null) {
        _selectedPreferences['moods'] = [userProfile.currentMood!];
      }
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);
    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile != null) {
      final updatedUser = userProfile.copyWith(
        meditationGoals: _selectedPreferences['goals'],
        preferredActivities: _selectedPreferences['activities'],
        currentMood: _selectedPreferences['moods']?.isNotEmpty == true
            ? _selectedPreferences['moods']!.first
            : null,
      );
      await ref
          .read(userProfileNotifierProvider.notifier)
          .updateUserProfile(updatedUser);
      if (mounted) {
        context.go('/home');
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Personalize Your Experience',
        showBackButton: true,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (_, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Lottie.asset(page.lottieAsset),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Text(
                              page.title,
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              page.description,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              alignment: WrapAlignment.center,
                              children: page.options.map((option) {
                                final isSelected =
                                _selectedPreferences[
                                page.preferenceKey]!
                                    .contains(option);
                                return ChoiceChip(
                                  label: Text(option),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (page.preferenceKey == 'moods') {
                                        // Allow only one mood selection
                                        _selectedPreferences[
                                        page.preferenceKey]!
                                            .clear();
                                        if (selected) {
                                          _selectedPreferences[
                                          page.preferenceKey]!
                                              .add(option);
                                        }
                                      } else {
                                        // Allow multiple selections for other preferences
                                        if (selected) {
                                          _selectedPreferences[
                                          page.preferenceKey]!
                                              .add(option);
                                        } else {
                                          _selectedPreferences[
                                          page.preferenceKey]!
                                              .remove(option);
                                        }
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    ),
                  // Centered Page Indicator
                  Expanded(
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: theme.colorScheme.primary,
                          dotColor: theme.disabledColor,
                          dotHeight: 8,
                          dotWidth: 8,
                        ),
                      ),
                    ),
                  ),
                  // Next/Save button
                  CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Save'
                        : 'Next',
                    isFullWidth: false,
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _savePreferences();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}