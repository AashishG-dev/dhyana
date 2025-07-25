// lib/widgets/cards/journal_card.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/models/journal_entry_model.dart'; // Import JournalEntryModel
import 'package:dhyana/core/utils/helpers.dart'; // For date formatting

/// A reusable card widget to display a summary of a journal entry.
/// It features the entry's timestamp, content snippet, and mood rating.
/// This card adheres to the Dhyana app's Glass Morphism theme.
class JournalCard extends StatelessWidget {
  final JournalEntryModel entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Constructor for JournalCard.
  const JournalCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        // Card widget already provides the Glass Morphism styling via AppTheme
        margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Helpers.formatDate(entry.timestamp, 'MMM dd, yyyy HH:mm'),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue),
                          onPressed: onEdit,
                          tooltip: 'Edit Entry',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: AppColors.errorColor),
                          onPressed: onDelete,
                          tooltip: 'Delete Entry',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                entry.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Mood: ${entry.moodRating}/5', // Assuming mood rating is out of 5
                  style: AppTextStyles.labelSmall.copyWith(
                    color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
