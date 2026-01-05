// lib/data/yoga_data.dart

import 'package:dhyana/models/yoga_pose_model.dart';
import 'package:dhyana/models/yoga_video_model.dart';

// Main page introductory text
const String yogaPageTitle = "Yoga Enhances Your Life";
const String yogaPageDescription =
    "A mind and body practice combining various styles of physical postures, breathing techniques, and meditation or relaxation: Yoga is an ancient practice that may have originated in India.";

// URL for the header image from Cloudinary
const String yogaHeaderUrl = "https://res.cloudinary.com/djahvdbbq/image/upload/v1756148857/430e1fd9-4423-4e12-b765-812c1bad57ba.png"; // Placeholder, can be changed

// List of benefits for the "Benefits of Yoga" section
const List<String> yogaBenefits = [
  'Yoga benefits in weight loss',
  'Yoga is one of the best solutions for stress relief',
  'Yoga helps for inner peace',
  'Yoga Improves immunity',
  'Practice of Yoga Offers awareness',
  'Yoga improves relationships',
  'Yoga Increases energy',
  'Yoga Gives you Better flexibility and posture',
  'Yoga helps in improving intuition',
];

// List of yoga poses (Asanas) with updated Cloudinary URLs
const List<YogaPoseModel> yogaPoses = [
  YogaPoseModel(
    name: 'Standing Backward Bend',
    sanskritName: 'Ardha Chakrasana',
    description:
    'Ardha Chakrasana, or the Standing Backward Bend Pose, stretches the front upper torso and tones the arms and shoulder muscles. Know the steps of doing the posture, all its benefits, and contraindications by clicking below.',
    imageUrl: 'https://res.cloudinary.com/djahvdbbq/image/upload/v1756148236/da78d6ca-f302-4a7e-8d22-aa62311b8151.png',
    techniqueUrl: 'https://www.artofliving.org/in-en/yoga/yoga-poses/ardha-chakrasana-standing-backward-bend',
  ),
  YogaPoseModel(
    name: 'Warrior Pose',
    sanskritName: 'Virabhadrasana',
    description:
    'Virabhadrasana or Warrior Pose increases stamina, strengthens arms, and brings courage and grace. It is an excellent yoga pose for those in sedentary jobs. It is also very beneficial in the case of frozen shoulders. Know the steps of doing the posture, all its benefits, and contraindications by clicking below.',
    imageUrl: 'https://res.cloudinary.com/djahvdbbq/image/upload/v1756148134/edb7bfa8-0049-463f-999b-1948b97bed6a.png',
    techniqueUrl: 'https://www.artofliving.org/in-en/yoga/yoga-poses/veerabhadrasana-warrior-pose',
  ),
  YogaPoseModel(
    name: 'Reverse Prayer Pose',
    sanskritName: 'Paschim Namaskarasana',
    description:
    'This yoga pose opens the abdomen and stretches the upper back and shoulder joints. Know the steps of doing the posture, all its benefits, and contraindications by clicking below.',
    imageUrl: 'https://res.cloudinary.com/djahvdbbq/image/upload/v1756148142/09861b0b-f4b4-4fae-b962-86cff8fc3ff3.png',
    techniqueUrl: 'https://www.artofliving.org/in-en/yoga/yoga-poses/paschim-namaskarasana-reverse-prayer-pose',
  ),
  YogaPoseModel(
    name: 'Half Spinal Twist Pose',
    sanskritName: 'Ardha Matsyendrasana',
    description:
    'Ardha Matsyendrasana, or the Half Spinal Twist Pose, makes the spine more elastic and increases the oxygen supply to the lungs. Know the steps of doing the posture, all its benefits, and contraindications by clicking below.',
    imageUrl: 'https://res.cloudinary.com/djahvdbbq/image/upload/v1756148153/b69519ec-50e1-40dd-9853-a07cf45d48b1.png',
    techniqueUrl: 'https://www.artofliving.org/in-en/yoga/yoga-poses/ardha-matsyendrasana-sitting-half-spinal-twist',
  ),
  YogaPoseModel(
    name: 'Wide-Legged Forward Bend',
    sanskritName: 'Prasarita Padahastasana',
    description:
    'This yoga pose lengthens the spine, strengthens the legs and feet, and strengthens the abdomen. Know the steps of doing the posture, all its benefits, and contraindications by clicking below.',
    imageUrl: 'https://res.cloudinary.com/djahvdbbq/image/upload/v1756148194/f0c6e17e-c9ca-4d11-801f-cca5b13eb91a.png',
    techniqueUrl: 'https://www.artofliving.org/in-en/yoga/yoga-poses/prasarita-padahastasana-standing-forward-bend-with-feet-apart',
  ),
];

// List of yoga videos for the "Guided Video Routines" section
const List<YogaVideoModel> yogaVideos = [
  YogaVideoModel(
    title: 'Post Workout Stretch | Full Body',
    description: '15 Minutes of Stress Relief & Recovery.',
    thumbnailUrl: 'https://img.youtube.com/vi/dhFCO37us7w/0.jpg',
    videoId: 'dhFCO37us7w',
  ),
  YogaVideoModel(
    title: '15 Min. Full Body Stretch | Daily Routine',
    description: 'Ideal for flexibility, mobility & stress relief.',
    thumbnailUrl: 'https://img.youtube.com/vi/L_xrDAtykMI/0.jpg',
    videoId: 'L_xrDAtykMI',
  ),
];