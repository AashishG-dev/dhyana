// lib/screens/meditation/breathing_technique_detail_screen.dart
import 'package:dhyana/data/breathing_techniques_data.dart';
import 'package:dhyana/models/breathing_technique_model.dart';
import 'package:dhyana/screens/meditation/breathing_exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';

class BreathingTechniqueDetailScreen extends StatefulWidget {
  final String techniqueId;
  const BreathingTechniqueDetailScreen({required this.techniqueId, super.key});

  @override
  State<BreathingTechniqueDetailScreen> createState() => _BreathingTechniqueDetailScreenState();
}

class _BreathingTechniqueDetailScreenState extends State<BreathingTechniqueDetailScreen> {
  late final BreathingTechnique technique;
  int _selectedDurationMinutes = 5;

  @override
  void initState() {
    super.initState();
    technique = breathingTechniques.firstWhere((t) => t.id == widget.techniqueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: technique.title, showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 200, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16))),
                  const SizedBox(height: 24),
                  Text(technique.longDescription, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 24),
                  // ✅ ADD: New section to display the steps.
                  Text('How to Practice', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  for (int i = 0; i < technique.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}. ', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(technique.steps[i], style: AppTextStyles.bodyLarge)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Duration Selector and Start Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text('Select Duration', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text('$_selectedDurationMinutes minutes', style: AppTextStyles.headlineSmall),
                Slider(
                  value: _selectedDurationMinutes.toDouble(),
                  min: 1, max: 30, divisions: 29,
                  label: '$_selectedDurationMinutes min',
                  onChanged: (value) => setState(() => _selectedDurationMinutes = value.toInt()),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Start',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BreathingExerciseScreen(
                        technique: technique,
                        durationMinutes: _selectedDurationMinutes,
                      ),
                    ));
                  },
                  icon: Icons.play_arrow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}