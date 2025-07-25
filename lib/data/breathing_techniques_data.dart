// lib/data/breathing_techniques_data.dart
import 'package:dhyana/models/breathing_technique_model.dart';

// This is a static list of all available breathing techniques.
// You can easily add more techniques here or move this to Firestore later.
final List<BreathingTechnique> breathingTechniques = [
  BreathingTechnique(
    id: 'box-breathing',
    title: 'Box Breathing',
    shortDescription: 'For reducing stress and improving focus.',
    longDescription: 'Also known as four-square breathing, this technique can help you return to your natural breathing rhythm. It is very effective for calming the nervous system.',
    steps: [
      "Sit upright in a comfortable chair with your feet flat on the floor.",
      "Inhale slowly through your nose for a count of four.",
      "Hold your breath at the top of the inhale for a count of four.",
      "Exhale completely through your mouth for a count of four.",
      "Hold your breath at the bottom of the exhale for a count of four before repeating."
    ],
    cycle: [
      BreathingStep(instruction: 'Inhale', duration: 4, isAnimated: true),
      BreathingStep(instruction: 'Hold', duration: 4),
      BreathingStep(instruction: 'Exhale', duration: 4, isAnimated: true),
      BreathingStep(instruction: 'Hold', duration: 4),
    ],
  ),
  BreathingTechnique(
    id: '4-7-8-breathing',
    title: '4-7-8 Breathing',
    shortDescription: 'For relaxation and falling asleep faster.',
    longDescription: 'The 4-7-8 breathing technique, also known as "relaxing breath," involves inhaling for 4 seconds, holding the breath for 7 seconds, and exhaling for 8 seconds. It is a powerful tool for managing anxiety and aiding sleep.',
    steps: [
      "Sit with your back straight and place the tip of your tongue against the ridge of tissue just behind your upper front teeth.",
      "Exhale completely through your mouth, making a gentle 'whoosh' sound.",
      "Close your mouth and inhale quietly through your nose to a mental count of four.",
      "Hold your breath for a count of seven.",
      "Exhale completely through your mouth, making a 'whoosh' sound to a count of eight."
    ],
    cycle: [
      BreathingStep(instruction: 'Inhale', duration: 4, isAnimated: true),
      BreathingStep(instruction: 'Hold', duration: 7),
      BreathingStep(instruction: 'Exhale', duration: 8, isAnimated: true),
    ],
  ),
  BreathingTechnique(
    id: 'equal-breathing',
    title: 'Equal Breathing',
    shortDescription: 'For balance and bringing calm to the mind.',
    longDescription: 'Known as Sama Vritti in Sanskrit, this practice involves inhaling for the same length of time as you exhale. It helps to calm the nervous system, reduce stress, and improve focus.',
    steps: [
      "Find a comfortable position, either sitting or lying down.",
      "Inhale through your nose for a count of four.",
      "Exhale through your nose for a count of four.",
      "Continue this pattern, ensuring your inhales and exhales are smooth and equal in length."
    ],
    cycle: [
      BreathingStep(instruction: 'Inhale', duration: 4, isAnimated: true),
      BreathingStep(instruction: 'Exhale', duration: 4, isAnimated: true),
    ],
  ),
];