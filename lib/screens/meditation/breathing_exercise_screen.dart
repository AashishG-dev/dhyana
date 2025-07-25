// lib/screens/meditation/breathing_exercise_screen.dart
import 'dart:async';
import 'package:dhyana/models/breathing_technique_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/providers/auth_provider.dart';

class BreathingExerciseScreen extends ConsumerStatefulWidget {
  final BreathingTechnique technique;
  final int durationMinutes;

  const BreathingExerciseScreen({
    required this.technique,
    required this.durationMinutes,
    super.key
  });

  @override
  ConsumerState<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends ConsumerState<BreathingExerciseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _exerciseTimer;

  String _instruction = 'Get Ready...';
  bool _isRunning = false;
  late int _timeRemainingSeconds;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _timeRemainingSeconds = widget.durationMinutes * 60;
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animation = Tween<double>(begin: 150, end: 250).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    Timer(const Duration(seconds: 2), _startExercise);
  }

  void _startExercise() {
    if (mounted) {
      setState(() => _isRunning = true);
      _runCycle();
    }
  }

  void _stopExercise({bool completed = false}) {
    if (!_isRunning) return;
    _isRunning = false;
    _exerciseTimer?.cancel();
    _animationController.stop();

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId != null) {
      final elapsedMinutes = widget.durationMinutes - (_timeRemainingSeconds / 60).ceil();
      if (elapsedMinutes > 0) {
        ref.read(progressNotifierProvider.notifier).logBreathingSession(userId, elapsedMinutes);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(completed ? 'Great session! Your progress is saved.' : 'Session stopped. Progress saved.'))
        );
      }
    }
    if(Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  // ✅ ADD: New method to reset the timer.
  void _resetExercise() {
    _exerciseTimer?.cancel();
    _animationController.reset();
    if (mounted) {
      setState(() {
        _timeRemainingSeconds = widget.durationMinutes * 60;
        _currentStep = 0;
        _instruction = 'Get Ready...';
      });
      // Start again after a brief pause
      Timer(const Duration(milliseconds: 500), _runCycle);
    }
  }

  void _runCycle() {
    if (!_isRunning || _timeRemainingSeconds <= 0) {
      if(_isRunning) _stopExercise(completed: true);
      return;
    }

    final step = widget.technique.cycle[_currentStep];
    final stepDuration = step.duration;

    if (mounted) {
      setState(() {
        _instruction = step.instruction;
        _animationController.duration = Duration(seconds: stepDuration);
      });
    }

    if (step.isAnimated) {
      if (_instruction == 'Inhale') _animationController.forward();
      else if (_instruction == 'Exhale') _animationController.reverse();
    }

    _exerciseTimer = Timer(Duration(seconds: stepDuration), () {
      if (mounted) {
        setState(() {
          _timeRemainingSeconds -= stepDuration;
          if (_timeRemainingSeconds < 0) _timeRemainingSeconds = 0;
          _currentStep = (_currentStep + 1) % widget.technique.cycle.length;
        });
        _runCycle();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _exerciseTimer?.cancel();
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
    return Scaffold(
      appBar: CustomAppBar(title: widget.technique.title, showBackButton: true),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF2C2C2C)]
                : [AppColors.backgroundLight, const Color(0xFFF0F0F0)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(_formatTime(_timeRemainingSeconds), style: AppTextStyles.displaySmall),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: _animation.value, height: _animation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).colorScheme.primary).withOpacity(0.3),
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                  ),
                );
              },
            ),
            Column(
              children: [
                Text(_instruction, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 48),
                // ✅ FIX: Added a Row for the two buttons.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: 'Stop',
                      onPressed: () => _stopExercise(),
                      type: ButtonType.secondary,
                      icon: Icons.stop,
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      text: 'Reset',
                      onPressed: _resetExercise,
                      type: ButtonType.outline,
                      icon: Icons.refresh,
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
}