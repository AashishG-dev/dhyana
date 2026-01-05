import 'package:dhyana/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    await [
      Permission.notification,
      Permission.storage,
      Permission.audio,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
    isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDarkMode ? AppColors.textDark : AppColors.textLight;
    final secondaryTextColor = textColor.withAlpha(150);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Removed the color tint so the original logo displays
                  Image.asset(
                    'assets/icons/logo.png', // or .jpg if that's your actual file
                    height: 230,
                    width: 230,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Dhyana',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Path to Mindful Living',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Lottie.asset(
              'assets/animations/Loading.json',
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}
