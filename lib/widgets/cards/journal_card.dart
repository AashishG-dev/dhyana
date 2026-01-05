// lib/widgets/cards/journal_card.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/models/journal_entry_model.dart';
import 'package:dhyana/core/utils/helpers.dart';

class JournalCard extends StatelessWidget {
  final JournalEntryModel entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPinToggle; // ✅ ADDED: Callback for pinning

  const JournalCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onPinToggle, // ✅ ADDED: To constructor
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // ✅ ADDED: Show pin icon if entry is pinned
                      if (entry.isPinned)
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      if (entry.isPinned) const SizedBox(width: 8),
                      Text(
                        Helpers.formatDate(entry.timestamp, 'MMM dd, yyyy • HH:mm'),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: (isDark
                              ? AppColors.textDark
                              : AppColors.textLight)
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (String result) {
                        switch (result) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                          case 'pin': // ✅ ADDED: Handle pin action
                            onPinToggle?.call();
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        // ✅ ADDED: Pin/Unpin menu item
                        PopupMenuItem<String>(
                          value: 'pin',
                          child: Row(
                            children: [
                              Icon(entry.isPinned
                                  ? Icons.push_pin_outlined
                                  : Icons.push_pin),
                              const SizedBox(width: 8),
                              Text(entry.isPinned ? 'Unpin' : 'Pin'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                entry.content,
                style: AppTextStyles.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Mood: ${entry.moodRating}/5",
                  style: AppTextStyles.labelSmall.copyWith(
                    color: (isDark ? AppColors.textDark : AppColors.textLight)
                        .withOpacity(0.6),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}