// lib/screens/journal/journal_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/helpers.dart'; // For date formatting and dialogs
import 'package:dhyana/providers/auth_provider.dart'; // For authStateProvider
import 'package:dhyana/providers/user_profile_provider.dart'; // For currentUserProfileProvider
import 'package:dhyana/providers/journal_provider.dart'; // For userJournalEntriesProvider and journalNotifierProvider
import 'package:dhyana/models/journal_entry_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

/// A screen that displays a list of the user's journal entries.
/// Users can view, edit, and delete their entries, and add new ones.
/// It integrates with `userJournalEntriesProvider` for real-time updates
/// and `journalNotifierProvider` for CRUD operations.
class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final authUser = ref.watch(authStateProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Journal',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF212121)]
                : [AppColors.backgroundLight, const Color(0xFFEEEEEE)],
          ),
        ),
        child: authUser.when(
          data: (user) {
            if (user == null) {
              return Center(
                child: Text(
                  'Please log in to view your journal.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              );
            }

            // Watch the journal entries for the current user
            final journalEntriesAsync = ref.watch(userJournalEntriesProvider(user.uid));

            return journalEntriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No journal entries yet.',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'Tap the "+" button to add your first entry!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
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
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined,
                                          color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue),
                                      onPressed: () {
                                        // Navigate to journal entry screen for editing
                                        context.go('/journal-entry', extra: entry.id);
                                      },
                                      tooltip: 'Edit Entry',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: AppColors.errorColor),
                                      onPressed: () async {
                                        // Show confirmation dialog before deleting
                                        final bool? confirm = await Helpers.showConfirmationDialog(
                                          context,
                                          title: 'Delete Entry',
                                          message: 'Are you sure you want to delete this journal entry?',
                                        );
                                        if (confirm == true) {
                                          await ref.read(journalNotifierProvider.notifier).deleteJournalEntry(user.uid, entry.id!);
                                          if (context.mounted) {
                                            Helpers.showSnackbar(context, 'Entry deleted.');
                                          }
                                        }
                                      },
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
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Loading journal entries...'),
              error: (e, st) => Center(
                child: Text('Error loading journal: $e',
                    style: TextStyle(color: AppColors.errorColor)),
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Checking authentication...'),
          error: (e, st) => Center(
            child: Text('Authentication error: $e',
                style: TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to journal entry screen for adding a new entry
          context.go('/journal-entry');
        },
        backgroundColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
        child: Icon(Icons.add, color: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2), // Highlight Journal tab
    );
  }
}
