// lib/widgets/common/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({super.key, this.message = "Loading..."});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark
                ? AppColors.primaryLightGreen
                : AppColors.primaryLightBlue,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: isDark ? AppColors.textDark : AppColors.textLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
