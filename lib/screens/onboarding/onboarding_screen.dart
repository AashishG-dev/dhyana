// lib/screens/onboarding/onboarding_screen.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/models/onboarding_page_model.dart';
import 'package:dhyana/providers/onboarding_provider.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      imagePath: 'assets/animations/onboarding_1.json',
      title: 'Welcome to Dhyana',
      description: 'Your personal guide to mindfulness, meditation, and inner peace.',
    ),
    OnboardingPageModel(
      imagePath: 'assets/animations/onboarding_2.json',
      title: 'Find Your Calm',
      description: 'Explore guided meditations, soothing music, and breathing exercises to reduce stress.',
    ),
    OnboardingPageModel(
      imagePath: 'assets/animations/onboarding_3.json',
      title: 'Track Your Journey',
      description: 'Use the journal to reflect on your mood and watch your progress over time.',
    ),
  ];

  void _onOnboardingComplete() {
    ref.read(onboardingNotifierProvider.notifier).setOnboardingSeen();
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final secondaryTextColor = theme.textTheme.bodyLarge?.color?.withAlpha(150);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
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
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Lottie.asset(page.imagePath),
                      ),
                      const SizedBox(height: 40),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              page.title,
                              style: AppTextStyles.headlineMedium.copyWith(color: theme.textTheme.displayLarge?.color),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.description,
                              style: AppTextStyles.bodyLarge.copyWith(color: secondaryTextColor),
                              textAlign: TextAlign.center,
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
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _onOnboardingComplete,
                style: TextButton.styleFrom(foregroundColor: primaryColor),
                child: const Text('Skip'),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: primaryColor,
                      dotColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  CustomButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    isFullWidth: false,
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _onOnboardingComplete();
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