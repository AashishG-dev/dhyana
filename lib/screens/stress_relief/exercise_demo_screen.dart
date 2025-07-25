// lib/screens/stress_relief/exercise_demo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart'; // For video playback

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/stress_relief_provider.dart'; // For stressReliefExerciseByIdProvider
import 'package:dhyana/models/stress_relief_exercise_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';


/// A screen that displays the details and a demo of a specific stress relief exercise.
/// It fetches exercise metadata and plays a video/GIF demonstration.
/// Integrates with `stressReliefExerciseByIdProvider` to get exercise data.
class ExerciseDemoScreen extends ConsumerStatefulWidget {
  final String? exerciseId;

  const ExerciseDemoScreen({super.key, required this.exerciseId});

  @override
  ConsumerState<ExerciseDemoScreen> createState() => _ExerciseDemoScreenState();
}

class _ExerciseDemoScreenState extends ConsumerState<ExerciseDemoScreen> {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _loadExerciseAndVideo();
  }

  /// Loads the exercise details and initializes the video player if a demo URL exists.
  Future<void> _loadExerciseAndVideo() async {
    if (widget.exerciseId == null) {
      debugPrint('Exercise ID is null. Cannot load exercise.');
      return;
    }

    final exerciseAsync = ref.read(stressReliefExerciseByIdProvider(widget.exerciseId!));
    exerciseAsync.whenData((exercise) {
      if (exercise != null && exercise.demoMediaUrl != null && exercise.demoMediaUrl!.isNotEmpty) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(exercise.demoMediaUrl!));
        _initializeVideoPlayerFuture = _videoController?.initialize().then((_) {
          // Ensure the first frame is shown and play the video.
          setState(() {});
          _videoController?.setLooping(true); // Loop the demo video
          _videoController?.play();
        }).catchError((error) {
          debugPrint('Error initializing video player: $error');
          _videoController = null; // Clear controller on error
          _initializeVideoPlayerFuture = null;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load video demo.')),
            );
          }
        });
      } else {
        debugPrint('No demo media URL found for exercise: ${widget.exerciseId}');
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final exerciseAsync = ref.watch(stressReliefExerciseByIdProvider(widget.exerciseId ?? ''));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Exercise Demo',
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
        child: exerciseAsync.when(
          data: (exercise) {
            if (exercise == null) {
              return Center(
                child: Text(
                  'Exercise not found.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Category: ${exercise.category} • ${exercise.estimatedDurationMinutes} min',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Video/GIF Demo Player
                  if (exercise.demoMediaUrl != null && exercise.demoMediaUrl!.isNotEmpty)
                    FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (_videoController != null && _videoController!.value.isInitialized) {
                            return AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            );
                          } else {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.videocam_off, size: 50, color: isDarkMode ? AppColors.textDark.withOpacity(0.5) : AppColors.textLight.withOpacity(0.5)), // Changed icon
                                    const SizedBox(height: AppConstants.paddingSmall),
                                    Text(
                                      'Failed to load video demo.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 50, color: AppColors.errorColor),
                                  const SizedBox(height: AppConstants.paddingSmall),
                                  Text(
                                    'Error loading video: ${snapshot.error}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.errorColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: isDarkMode ? AppColors.glassDarkSurface : AppColors.glassLightSurface,
                            child: const LoadingWidget(message: 'Loading demo...'),
                          );
                        }
                      },
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: isDarkMode ? AppColors.glassDarkSurface : AppColors.glassLightSurface,
                      child: Center(
                        child: Text(
                          'No demo available for this exercise.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  Text(
                    'Instructions:',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    exercise.description, // Use description as instructions
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge * 2),

                  Center(
                    child: CustomButton(
                      text: 'Practice Now',
                      onPressed: () {
                        // Implement logic to start practicing the exercise,
                        // e.g., navigate to a guided practice screen or timer.
                        // For now, just show a snackbar.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Starting ${exercise.title} practice!')),
                        );
                      },
                      type: ButtonType.primary,
                      icon: Icons.play_arrow,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Loading exercise details...'),
          error: (e, st) => Center(
            child: Text('Error loading exercise: $e',
                style: TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
    );
  }
}
