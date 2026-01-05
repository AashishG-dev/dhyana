// lib/widgets/common/app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if the router can pop the current route.
    final bool canPop = GoRouter.of(context).canPop();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: isDark ? AppColors.primaryBlue : AppColors.primaryPurple,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () {
          // If there's a screen to pop back to, do it.
          if (canPop) {
            context.pop();
          } else {
            // Otherwise, go to the home screen as a fallback.
            context.go('/home');
          }
        },
      )
          : null,
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
