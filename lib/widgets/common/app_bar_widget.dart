// lib/widgets/common/app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      // ✅ FIX: Made the back button logic safer to prevent crashes.
      leading: showBackButton
          ? IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new, // A slightly more modern back icon
          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            // If there's no screen to pop to, navigate to a safe default like the home screen.
            context.go('/home');
          }
        },
      )
          : leading,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}