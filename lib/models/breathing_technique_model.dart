// lib/models/breathing_technique_model.dart

/// Represents a single step in a breathing cycle (e.g., Inhale, Hold).
class BreathingStep {
  final String instruction;
  final int duration; // in seconds
  final bool isAnimated; // true for inhale/exhale, false for hold

  BreathingStep({
    required this.instruction,
    required this.duration,
    this.isAnimated = false,
  });
}

/// Represents a complete breathing technique, including its description,
/// instructions, and the timing for the animation cycle.
class BreathingTechnique {
  final String id;
  final String title;
  final String shortDescription; // For the list card
  final String longDescription;  // For the detail screen
  final List<String> steps;      // The step-by-step instructions for the user
  final List<BreathingStep> cycle; // The data used by the animator

  const BreathingTechnique({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.steps,
    required this.cycle,
  });
}