// lib/screens/journal/journal_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart'; // For showing snackbar/dialogs
import 'package:dhyana/providers/auth_provider.dart'; // For authStateProvider
import 'package:dhyana/providers/journal_provider.dart'; // For journalNotifierProvider
import 'package:dhyana/models/journal_entry_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

/// A screen for creating or editing a journal entry.
/// It allows users to input content and a mood rating, and save it to Firestore.
/// If an `entryId` is provided, it fetches and displays the existing entry for editing.
class JournalEntryScreen extends ConsumerStatefulWidget {
  final String? entryId; // Optional: ID of the entry to edit

  const JournalEntryScreen({super.key, this.entryId});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  int _moodRating = 3; // Default mood rating
  bool _isLoading = false;
  JournalEntryModel? _initialEntry; // To store the entry being edited

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadJournalEntry();
    }
  }

  /// Loads an existing journal entry if `entryId` is provided.
  Future<void> _loadJournalEntry() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) {
      debugPrint('No authenticated user to load journal entry.');
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // Fetch the specific entry using its ID
      // Note: userJournalEntriesProvider is a StreamProvider.family,
      // so we need to filter the stream or fetch directly from FirestoreService
      // if we only need a single fetch. For simplicity, we'll assume
      // we can get it from the stream's current value or fetch directly.
      final entriesAsync = ref.read(userJournalEntriesProvider(currentUser.uid));
      entriesAsync.whenData((entries) {
        final entry = entries.firstWhere(
              (e) => e.id == widget.entryId,
          orElse: () => throw Exception('Entry not found'),
        );
        setState(() {
          _initialEntry = entry;
          _contentController.text = entry.content;
          _moodRating = entry.moodRating;
        });
      });
    } catch (e) {
      debugPrint('Error loading journal entry: $e');
      if (mounted) {
        Helpers.showMessageDialog(
          context,
          title: 'Error',
          message: 'Failed to load journal entry. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// Handles saving (adding or updating) a journal entry.
  Future<void> _handleSaveEntry() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) {
        debugPrint('No authenticated user to save journal entry.');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Error',
            message: 'No active user session. Please log in again.',
          );
          context.go('/login');
        }
        setState(() { _isLoading = false; });
        return;
      }

      try {
        final journalNotifier = ref.read(journalNotifierProvider.notifier);
        final newEntry = JournalEntryModel(
          id: _initialEntry?.id, // Keep ID if editing
          userId: currentUser.uid,
          content: _contentController.text.trim(),
          moodRating: _moodRating,
          timestamp: _initialEntry?.timestamp ?? DateTime.now(), // Keep original timestamp if editing
        );

        if (widget.entryId == null) {
          // Add new entry
          await journalNotifier.addJournalEntry(currentUser.uid, newEntry);
          if (mounted) {
            Helpers.showSnackbar(context, 'Journal entry added!');
          }
        } else {
          // Update existing entry
          await journalNotifier.updateJournalEntry(currentUser.uid, newEntry);
          if (mounted) {
            Helpers.showSnackbar(context, 'Journal entry updated!');
          }
        }

        if (mounted) {
          context.pop(); // Go back to journal list
        }
      } catch (e) {
        debugPrint('Error saving journal entry: $e');
        if (mounted) {
          Helpers.showMessageDialog(
            context,
            title: 'Save Failed',
            message: 'An error occurred while saving your entry. Please try again.',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.entryId == null ? 'New Journal Entry' : 'Edit Journal Entry',
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
        child: _isLoading
            ? const LoadingWidget(message: 'Loading entry...')
            : SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What\'s on your mind today?',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                CustomTextField(
                  controller: _contentController,
                  hintText: 'Write your thoughts here...',
                  maxLines: 10,
                  minLines: 5,
                  maxLength: AppConstants.maxJournalEntryLength,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => Validators.isNotEmpty(value, fieldName: 'Journal content'),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                Text(
                  'How are you feeling?',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      return IconButton(
                        icon: Icon(
                          rating <= _moodRating ? Icons.star : Icons.star_border,
                          color: rating <= _moodRating ? AppColors.secondaryOrange : (isDarkMode ? AppColors.textDark.withOpacity(0.5) : AppColors.textLight.withOpacity(0.5)),
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _moodRating = rating;
                          });
                        },
                        tooltip: '$rating star mood',
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge * 2),
                CustomButton(
                  text: widget.entryId == null ? 'Add Entry' : 'Update Entry',
                  onPressed: _handleSaveEntry,
                  type: ButtonType.primary,
                  icon: Icons.save_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
