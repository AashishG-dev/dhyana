// lib/screens/meditation/breathing_exercise_screen.dart
import 'dart:async';
import 'package:dhyana/core/services/task_completion_service.dart';
import 'package:dhyana/models/breathing_technique_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/providers/auth_provider.dart';

class BreathingExerciseScreen extends ConsumerStatefulWidget {
  final BreathingTechnique technique;
  final int durationMinutes;

  const BreathingExerciseScreen({
    required this.technique,
    required this.durationMinutes,
    super.key,
  });

  @override
  ConsumerState<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState
    extends ConsumerState<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleAnimation;
  late AnimationController _lottieController;

  Timer? _stepTimer;
  Timer? _countdownTimer;

  String _instruction = 'Get Ready...';
  bool _isRunning = false;
  late int _timeRemainingSeconds;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _timeRemainingSeconds = widget.durationMinutes * 60;

    _circleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _circleAnimation = Tween<double>(begin: 250, end: 350).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );
    _lottieController = AnimationController(vsync: this);

    Timer(const Duration(seconds: 3), _startExercise);
  }

  void _startExercise() {
    if (!mounted) return;
    setState(() => _isRunning = true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _timeRemainingSeconds--;
          });
        }
      } else {
        _stopExercise(completed: true);
      }
    });
    _runCycle();
  }

  void _stopExercise({bool completed = false}) {
    if (!_isRunning) return;
    _isRunning = false;
    _stepTimer?.cancel();
    _countdownTimer?.cancel();
    _circleController.stop();
    _lottieController.stop();

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId != null && completed) {
      ref
          .read(progressNotifierProvider.notifier)
          .logBreathingSession(userId, widget.durationMinutes);

      // Mark the 'practice_breathing' task as complete
      ref.read(taskCompletionServiceProvider).completeTask('practice_breathing');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Great session! Your progress is saved.')));
      }
    }

    // ✅ FIX: Changed navigation to pop back to the detail screen
    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  void _resetExercise() {
    _stepTimer?.cancel();
    _countdownTimer?.cancel();
    _circleController.reset();
    _lottieController.reset();

    if (mounted) {
      setState(() {
        _timeRemainingSeconds = widget.durationMinutes * 60;
        _currentStep = 0;
        _instruction = 'Get Ready...';
        _isRunning = false;
      });
      Timer(const Duration(milliseconds: 500), _startExercise);
    }
  }

  void _runCycle() {
    if (!_isRunning || _timeRemainingSeconds <= 0) return;

    final step = widget.technique.cycle[_currentStep];
    final stepDuration = Duration(seconds: step.duration);

    if (mounted) {
      setState(() {
        _instruction = step.instruction;
        _circleController.duration = stepDuration;
        _lottieController.duration = stepDuration;
      });
    }

    if (step.isAnimated) {
      if (_instruction == 'Inhale') {
        _circleController.forward();
        _lottieController.animateTo(0.5,
            duration: stepDuration, curve: Curves.easeInOut);
      } else if (_instruction == 'Exhale') {
        _circleController.reverse();
        _lottieController.animateTo(1.0,
            duration: stepDuration, curve: Curves.easeInOut);
      }
    }

    _stepTimer = Timer(stepDuration, () {
      if (mounted) {
        if (_instruction == 'Exhale') {
          _lottieController.value = 0.0;
        }
        _currentStep = (_currentStep + 1) % widget.technique.cycle.length;
        _runCycle();
      }
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    _lottieController.dispose();
    _stepTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
    isDarkMode ? AppColors.backgroundDark : const Color(0xFF0D1F2D);
    final textColor = isDarkMode ? AppColors.textDark : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.technique.title,
            style: AppTextStyles.titleLarge.copyWith(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => _stopExercise(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatTime(_timeRemainingSeconds),
              style: AppTextStyles.displayLarge.copyWith(color: textColor),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _circleAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: _circleAnimation.value,
                    height: _circleAnimation.value,
                    child: Center(
                      child: Lottie.asset(
                        'assets/animations/Breathing_Exercise.json',
                        controller: _lottieController,
                        width: _circleAnimation.value,
                        height: _circleAnimation.value,
                      ),
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                Text(_instruction,
                    style:
                    AppTextStyles.headlineMedium.copyWith(color: textColor)),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      context: context,
                      text: 'Stop',
                      icon: Icons.stop,
                      onPressed: () => _stopExercise(),
                    ),
                    const SizedBox(width: 32),
                    _buildControlButton(
                      context: context,
                      text: 'Reset',
                      icon: Icons.refresh,
                      onPressed: _resetExercise,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textDark
        : Colors.white;

    return OutlinedButton.icon(
      icon: Icon(icon, color: textColor.withAlpha(179)),
      label: Text(text,
          style: AppTextStyles.bodyMedium.copyWith(color: textColor.withAlpha(179))),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: textColor.withAlpha(100)),
        shape: const StadiumBorder(),
      ),
    );
  }
}