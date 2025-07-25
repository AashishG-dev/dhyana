// lib/widgets/common/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark.withOpacity(0.8) : AppColors.backgroundLight.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            width: 1.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
          // ✅ FIX: Changed this to navigate to the new meditation hub screen.
            case 1:
              context.go('/meditate');
              break;
            case 2:
              context.go('/journal');
              break;
            case 3:
              context.go('/chatbot');
              break;
            case 4:
              context.go('/articles');
              break;
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
        unselectedItemColor: isDarkMode ? AppColors.textDark.withOpacity(0.6) : AppColors.textLight.withOpacity(0.6),
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            activeIcon: Icon(Icons.self_improvement),
            label: 'Meditate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Articles',
          ),
        ],
      ),
    );
  }
}