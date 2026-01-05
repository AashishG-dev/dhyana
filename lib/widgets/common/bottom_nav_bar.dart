// lib/widgets/common/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/journal');
        break;
      case 2:
        context.go('/meditate');
        break;
      case 3:
        context.go('/chatbot');
        break;
    // ✅ ADDED: New case to navigate to the progress screen
      case 4:
        context.go('/progress');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor:
      isDark ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
      unselectedItemColor: isDark
          ? AppColors.textDark.withOpacity(0.6)
          : AppColors.textLight.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined), label: "Journal"),
        BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement), label: "Meditate"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: "Talk"),
        // ✅ ADDED: New item for the Progress screen
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined), label: "Progress"),
      ],
    );
  }
}