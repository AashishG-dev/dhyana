// lib/screens/stress_relief/exercise_demo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/stress_relief_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';

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
          setState(() {});
          _videoController?.setLooping(true);
          _videoController?.play();
        }).catchError((error) {
          debugPrint('Error initializing video player: $error');
          _videoController = null;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final exerciseAsync = ref.watch(stressReliefExerciseByIdProvider(widget.exerciseId ?? ''));

    return Scaffold(
      appBar: const CustomAppBar(
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
                  style: AppTextStyles.bodyMedium,
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
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Category: ${exercise.category} • ${exercise.estimatedDurationMinutes} min',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
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
                                    Icon(Icons.videocam_off, size: 50, color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.5)),
                                    const SizedBox(height: AppConstants.paddingSmall),
                                    Text(
                                      'Failed to load video demo.',
                                      style: AppTextStyles.bodyMedium,
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
                                  const Icon(Icons.error_outline, size: 50, color: AppColors.errorColor),
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
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Text(
                    'Instructions:',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    exercise.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge * 2),
                  Center(
                    child: CustomButton(
                      text: 'Practice Now',
                      onPressed: () {
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
                style: const TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
    );
  }
}
