// lib/screens/meditation/session_complete_screen.dart
import 'dart:math';
import 'package:dhyana/models/meditation_model.dart'; // ✅ ADDED: Import for the meditation model
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/widgets/common/custom_button.dart';

class SessionCompleteScreen extends StatefulWidget {
  // ✅ ADDED: Property to hold the completed meditation details
  final MeditationModel meditation;

  // ✅ UPDATED: Constructor now requires the meditation model
  const SessionCompleteScreen({
    required this.meditation,
    super.key
  });

  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFF0D1F2D);
    final textColor = isDarkMode ? AppColors.textDark : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple,
              AppColors.primaryLightGreen, AppColors.primaryBlue, AppColors.accentPink,
            ],
            createParticlePath: (size) {
              return Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: Random().nextInt(5) + 5));
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLightGreen,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Session completed!',
                    style: AppTextStyles.headlineLarge.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 8),
                  // ✅ UPDATED: Text now uses the specific meditation title
                  Text(
                    'Great job on completing the "${widget.meditation.title}" meditation. You\'re one step closer to inner peace.',
                    style: AppTextStyles.bodyMedium.copyWith(color: textColor.withAlpha(179)),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  CustomButton(
                    text: 'Done',
                    onPressed: () {
                      // Pop back to the breathing list screen
                      context.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}