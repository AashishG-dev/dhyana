// lib/widgets/common/timeline_tile.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class TimelineTile extends StatelessWidget {
  final String title;
  final String description;
  final Widget points;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final bool isCurrent;

  const TimelineTile({
    required this.title,
    required this.description,
    required this.points,
    this.isFirst = false,
    this.isLast = false,
    this.isCompleted = false,
    this.isCurrent = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue;
    final inactiveColor = Colors.grey.shade600;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildIconColumn(activeColor, inactiveColor),
          const SizedBox(width: 24),
          _buildContentColumn(activeColor),
        ],
      ),
    );
  }

  Widget _buildIconColumn(Color activeColor, Color inactiveColor) {
    return Column(
      children: [
        Container(
          width: 2,
          height: 20,
          color: isFirst ? Colors.transparent : inactiveColor,
        ),
        _buildIcon(activeColor),
        Expanded(
          child: Container(
            width: 2,
            color: isLast ? Colors.transparent : inactiveColor,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(Color activeColor) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activeColor,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 24),
      );
    }
    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: activeColor, width: 2),
        ),
        child: Icon(Icons.lock_open, color: activeColor, size: 24),
      );
    }
    // Locked
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: const Icon(Icons.lock, color: Colors.white, size: 24),
    );
  }

  Widget _buildContentColumn(Color activeColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 4),
          Text(description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          if (!isCompleted)
            points,
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}