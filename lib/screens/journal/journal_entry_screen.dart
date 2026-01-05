// lib/screens/journal/journal_entry_screen.dart
import 'package:dhyana/core/services/task_completion_service.dart';
import 'package:dhyana/core/utils/gamification_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/journal_provider.dart';
import 'package:dhyana/models/journal_entry_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const JournalEntryScreen({
    super.key,
    this.extra,
  });

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  int _moodRating = 3;
  bool _isLoading = false;
  JournalEntryModel? _initialEntry;
  final TextEditingController _gratitudeController = TextEditingController();

  String? entryId;
  String? source;
  Level? level;

  @override
  void initState() {
    super.initState();

    entryId = widget.extra?['entryId'] as String?;
    source = widget.extra?['source'] as String?;
    level = widget.extra?['level'] as Level?;

    if (entryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadJournalEntry();
      });
    }
  }

  Future<void> _loadJournalEntry() async {
    setState(() => _isLoading = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final entries =
      await ref.read(userJournalEntriesProvider(user.uid).future);
      final entry = entries.firstWhere((e) => e.id == entryId);

      if (mounted) {
        setState(() {
          _initialEntry = entry;
          _contentController.text = entry.content;
          _moodRating = entry.moodRating;
          _gratitudeController.text = entry.gratitude;
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(
          context,
          title: 'Error',
          message: 'Could not load entry.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSaveEntry() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      if (mounted) {
        Helpers.showMessageDialog(
          context,
          title: 'Error',
          message: 'No active session. Please log in.',
        );
        context.go('/login');
      }
      return;
    }

    try {
      final journalNotifier = ref.read(journalNotifierProvider.notifier);
      final entry = JournalEntryModel(
        id: _initialEntry?.id,
        userId: user.uid,
        content: _contentController.text.trim(),
        moodRating: _moodRating,
        timestamp: _initialEntry?.timestamp ?? DateTime.now(),
        gratitude: _gratitudeController.text.trim(),
      );

      if (entryId == null) {
        await journalNotifier.addJournalEntry(user.uid, entry);
        ref.read(taskCompletionServiceProvider).completeTask('write_journal');
        if (mounted) Helpers.showSnackbar(context, 'Entry added!');
      } else {
        await journalNotifier.updateJournalEntry(user.uid, entry);
        if (mounted) Helpers.showSnackbar(context, 'Entry updated!');
      }

      if (mounted) {
        if (source == 'level_detail' && level != null) {
          context.go('/level-detail', extra: level);
        } else {
          context.go('/journal');
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(
          context,
          title: 'Save Failed',
          message: 'An error occurred, please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: entryId == null ? '📝 New Entry' : '✏️ Edit Entry',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.backgroundDark, const Color(0xFF1E1E1E)]
                : [AppColors.backgroundLight, const Color(0xFFF9F9F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const LoadingWidget(message: 'Loading entry...')
            : LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
              BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding:
                const EdgeInsets.all(AppConstants.paddingMedium),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'What’s on your mind today?',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _contentController,
                        hintText: 'Write your thoughts here...',
                        maxLines: 12,
                        maxLength: AppConstants.maxJournalEntryLength,
                        keyboardType: TextInputType.multiline,
                        validator: (val) => Validators.isNotEmpty(val,
                            fieldName: 'Content'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'What are you grateful for today?',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _gratitudeController,
                        hintText: 'List three things...',
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'How do you feel?',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final rating = i + 1;
                          return IconButton(
                            icon: Icon(
                              rating <= _moodRating
                                  ? Icons.emoji_emotions
                                  : Icons.emoji_emotions_outlined,
                              size: 40,
                              color: rating <= _moodRating
                                  ? AppColors.accentPink
                                  : (isDark
                                  ? AppColors.textDark
                                  : AppColors.textLight)
                                  .withAlpha(102), // 0.4 opacity
                            ),
                            onPressed: () =>
                                setState(() => _moodRating = rating),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: entryId == null
                            ? 'Add Entry'
                            : 'Update Entry',
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
        }),
      ),
    );
  }
}