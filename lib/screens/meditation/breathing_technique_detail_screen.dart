// lib/screens/meditation/breathing_technique_detail_screen.dart
import 'package:dhyana/data/breathing_techniques_data.dart';
import 'package:dhyana/models/breathing_technique_model.dart';
import 'package:dhyana/screens/meditation/breathing_exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ ADDED: Import the SVG package
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:go_router/go_router.dart';

class BreathingTechniqueDetailScreen extends StatefulWidget {
  final String techniqueId;
  const BreathingTechniqueDetailScreen({required this.techniqueId, super.key});

  @override
  State<BreathingTechniqueDetailScreen> createState() => _BreathingTechniqueDetailScreenState();
}

class _BreathingTechniqueDetailScreenState extends State<BreathingTechniqueDetailScreen> {
  late final BreathingTechnique technique;
  int _selectedDurationInSeconds = 90;

  final Map<int, String> _durationOptions = {
    60: '1 min',
    90: '1 min 30 sec',
    120: '2 min',
    180: '3 min',
    240: '4 min',
    300: '5 min',
  };

  @override
  void initState() {
    super.initState();
    technique = breathingTechniques.firstWhere((t) => t.id == widget.techniqueId);
  }

  void _showInstructionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How to Practice', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
              const SizedBox(height: 16),
              Text(technique.longDescription, style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70)),
              const SizedBox(height: 24),
              for (int i = 0; i < technique.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                      Expanded(child: Text(technique.steps[i], style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDurationPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select duration', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  ..._durationOptions.entries.map((entry) {
                    final isSelected = _selectedDurationInSeconds == entry.key;
                    return ListTile(
                      title: Text(entry.value, style: AppTextStyles.bodyLarge.copyWith(color: isSelected ? AppColors.primaryLightGreen : Colors.white)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primaryLightGreen)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedDurationInSeconds = entry.key;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFF0D1F2D);
    final textColor = isDarkMode ? AppColors.textDark : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: CustomButton(
          text: 'Proceed',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BreathingExerciseScreen(
                technique: technique,
                durationMinutes: (_selectedDurationInSeconds / 60).round(),
              ),
            ));
          },
          icon: Icons.arrow_forward,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: backgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              // ✅ UPDATED: Switched to SvgPicture.asset to render SVG images
              background: SvgPicture.asset(
                technique.imageUrl,
                fit: BoxFit.cover,
                // The color overlay is not directly supported on SvgPicture
                // but can be achieved with a ShaderMask if needed.
                // For simplicity, we'll rely on the SVG's design for now.
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(technique.title, style: AppTextStyles.displayMedium.copyWith(color: textColor)),
                  const SizedBox(height: 8),
                  Text(
                    technique.shortDescription,
                    style: AppTextStyles.bodyLarge.copyWith(color: textColor.withAlpha(204)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Instructions'),
                    onPressed: () => _showInstructionsSheet(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: textColor.withAlpha(128)),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => _showDurationPickerSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, color: textColor.withAlpha(179)),
                          const SizedBox(width: 16),
                          Text('Duration', style: AppTextStyles.bodyLarge.copyWith(color: textColor)),
                          const Spacer(),
                          Text(
                            _durationOptions[_selectedDurationInSeconds]!,
                            style: AppTextStyles.bodyLarge.copyWith(color: textColor),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 14, color: textColor.withAlpha(179)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}