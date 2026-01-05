// lib/data/breathing_techniques_data.dart
import 'package:dhyana/models/breathing_technique_model.dart';
import 'package:flutter/material.dart';

// This is a static list of all available breathing techniques.
// You can easily add more techniques here or move this to Firestore later.
final List<BreathingTechnique> breathingTechniques = [
  BreathingTechnique(
    id: 'box-breathing',
    title: 'Box Breathing',
    shortDescription: 'Calm your nerves and focus before or during high-pressure situations.',
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
    icon: Icons.square_outlined,
    tag: 'Used by Navy SEALs',
    tagColor: Colors.orange.shade300,
    durationText: '1 - 5 min',
    isLocked: false,
    imageUrl: 'assets/breathing/breathing_header_1.svg',
  ),
  BreathingTechnique(
    id: 'physiological-sigh',
    title: 'Physiological Sigh',
    shortDescription: 'Anxiety reduction method approved and used by top neuroscientists.',
    longDescription: 'The physiological sigh is a powerful, real-time tool for stress reduction. It involves two inhales followed by an extended exhale, which helps to offload carbon dioxide and calm the nervous system almost instantly.',
    steps: [
      "Take a deep breath in through your nose.",
      "When your lungs are almost full, take another sharp, short inhale to fully inflate them.",
      "Slowly and fully exhale through your mouth for as long as possible.",
      "Repeat 1-3 times as needed."
    ],
    cycle: [
      BreathingStep(instruction: 'Inhale', duration: 3, isAnimated: true),
      BreathingStep(instruction: 'Inhale', duration: 1, isAnimated: true),
      BreathingStep(instruction: 'Exhale', duration: 6, isAnimated: true),
    ],
    icon: Icons.ssid_chart,
    tag: 'Used by Andrew Huberman',
    tagColor: Colors.purple.shade200,
    durationText: '3 - 5 min',
    isLocked: false,
    imageUrl: 'assets/breathing/breathing_header_2.svg',
  ),
  BreathingTechnique(
    id: '4-7-8-breathing',
    title: '4-7-8 Breathing',
    shortDescription: 'Promote calmness and improve sleep quality. Based on an ancient yogic technique.',
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
    icon: Icons.waves,
    tag: 'Used by Yogis',
    tagColor: Colors.orange.shade300,
    durationText: '2 - 10 min',
    isLocked: false,
    imageUrl: 'assets/breathing/breathing_header_3.svg',
  ),
  BreathingTechnique(
    id: 'alternate-nostril',
    title: 'Alternate Nostril',
    shortDescription: 'Balance your mind and body, and improve respiratory function.',
    longDescription: 'Known as Nadi Shodhana, this yogic practice helps to clear and purify the energy channels of the body, creating a sense of balance and calm. It is excellent for improving focus and calming the mind.',
    steps: [
      "Sit comfortably with your spine straight.",
      "Place your left hand on your left knee.",
      "Lift your right hand and place your thumb on your right nostril to close it.",
      "Inhale slowly through your left nostril.",
      "Close your left nostril with your ring finger, then release your thumb and exhale through your right nostril.",
      "Inhale through the right nostril.",
      "Close your right nostril with your thumb, then release your ring finger and exhale through the left nostril.",
      "This completes one round. Continue for several rounds."
    ],
    cycle: [
      BreathingStep(instruction: 'Inhale Left', duration: 4, isAnimated: true),
      BreathingStep(instruction: 'Exhale Right', duration: 6, isAnimated: true),
      BreathingStep(instruction: 'Inhale Right', duration: 4, isAnimated: true),
      BreathingStep(instruction: 'Exhale Left', duration: 6, isAnimated: true),
    ],
    icon: Icons.sync_alt,
    tag: 'Yogic Practice',
    tagColor: Colors.blue.shade200,
    // ✅ FIX: Added the missing durationText parameter
    durationText: '3 - 10 min',
    isLocked: false,
    imageUrl: 'assets/breathing/breathing_header_4.svg',
  ),
];