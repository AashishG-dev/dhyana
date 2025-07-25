// lib/screens/meditation/meditation_player_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/meditation_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';

// ✅ ADD: A new screen for when the session is complete.
class SessionCompleteScreen extends StatelessWidget {
  final MeditationModel meditation;
  const SessionCompleteScreen({required this.meditation, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Session Complete',
        showBackButton: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF2C2C2C)]
                : [AppColors.backgroundLight, const Color(0xFFF0F0F0)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue, size: 80),
                const SizedBox(height: AppConstants.paddingMedium),
                Text('Well done!', style: AppTextStyles.headlineMedium.copyWith(color: isDarkMode ? AppColors.textDark : AppColors.textLight)),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'You have completed the ${meditation.title} meditation.',
                  style: AppTextStyles.bodyLarge.copyWith(color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingLarge * 2),
                CustomButton(
                  text: 'Add a Journal Entry',
                  onPressed: () {
                    // Use push so the user can come back
                    context.push('/journal-entry');
                  },
                  type: ButtonType.primary,
                  icon: Icons.edit_outlined,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                CustomButton(
                  text: 'Back to Meditations',
                  onPressed: () {
                    // Use go to replace the stack and go back to the list
                    context.go('/meditations');
                  },
                  type: ButtonType.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MeditationPlayerScreen extends ConsumerStatefulWidget {
  final String? meditationId;
  const MeditationPlayerScreen({super.key, required this.meditationId});

  @override
  ConsumerState<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends ConsumerState<MeditationPlayerScreen> {
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMeditationListener();
    });
  }

  void _initializeMeditationListener() {
    if (widget.meditationId == null) return;

    final meditationAsync = ref.read(meditationByIdProvider(widget.meditationId!));
    meditationAsync.whenData((meditation) {
      if (meditation != null && mounted) {
        final audioService = ref.read(meditationAudioServiceProvider);
        _playerCompleteSubscription = audioService.onPlayerComplete.listen((_) {
          _updateProgressOnCompletion(meditation);
          if (mounted) {
            context.pushReplacement('/meditation-complete', extra: meditation);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _updateProgressOnCompletion(MeditationModel meditation) async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    final progressNotifier = ref.read(progressNotifierProvider.notifier);
    final currentProgress = await ref.read(userProgressDataProvider(currentUser.uid).future);

    final updatedProgress = (currentProgress ?? ProgressDataModel(userId: currentUser.uid)).copyWith(
      totalMeditationMinutes: (currentProgress?.totalMeditationMinutes ?? 0) + meditation.durationMinutes,
      meditationStreak: (currentProgress?.meditationStreak ?? 0) + 1,
      lastUpdated: DateTime.now(),
    );

    await progressNotifier.saveProgressData(currentUser.uid, updatedProgress);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final meditationAsync = ref.watch(meditationByIdProvider(widget.meditationId ?? ''));
    final playerState = ref.watch(meditationPlayerProvider);
    final position = ref.watch(currentMeditationPositionProvider).value ?? Duration.zero;
    final duration = ref.watch(currentMeditationDurationProvider).value ?? Duration.zero;

    return Scaffold(
      appBar: CustomAppBar(title: 'Meditation Player', showBackButton: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF2C2C2C)]
                : [AppColors.backgroundLight, const Color(0xFFF0F0F0)],
          ),
        ),
        child: meditationAsync.when(
          data: (meditation) {
            if (meditation == null) return const Center(child: Text('Meditation not found.'));

            return Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 200, width: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode ? AppColors.glassDarkSurface : AppColors.glassLightSurface,
                          image: meditation.imageUrl != null && meditation.imageUrl!.isNotEmpty
                              ? DecorationImage(image: NetworkImage(meditation.imageUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: (meditation.imageUrl == null || meditation.imageUrl!.isEmpty)
                            ? Center(child: Icon(Icons.self_improvement, size: 80, color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.5)))
                            : null,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      Text(meditation.title, style: AppTextStyles.headlineLarge.copyWith(color: isDarkMode ? AppColors.textDark : AppColors.textLight), textAlign: TextAlign.center),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text('${meditation.durationMinutes} minutes • ${meditation.category}', style: AppTextStyles.titleMedium.copyWith(color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7))),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      children: [
                        Slider(
                          min: 0.0,
                          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                          value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                          onChanged: (value) => ref.read(meditationPlayerProvider.notifier).seek(Duration(seconds: value.toInt())),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text(_formatDuration(position)), Text(_formatDuration(duration))],
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        playerState.when(
                          data: (state) => IconButton(
                            iconSize: 72,
                            color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                            icon: Icon(state == PlayerState.playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                            onPressed: () {
                              final notifier = ref.read(meditationPlayerProvider.notifier);
                              if (state == PlayerState.playing) {
                                notifier.pauseMeditation();
                              } else {
                                // ✅ FIX: Pass the full meditation object.
                                notifier.playMeditation(meditation);
                              }
                            },
                          ),
                          loading: () => const SizedBox(height: 72, width: 72, child: LoadingWidget()),
                          error: (e, st) => IconButton(iconSize: 72, icon: const Icon(Icons.error), onPressed: () {}, color: AppColors.errorColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Loading meditation...'),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}