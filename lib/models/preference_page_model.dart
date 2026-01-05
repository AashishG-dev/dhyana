// lib/models/preference_page_model.dart
import 'package:flutter/material.dart';

class PreferencePageModel {
  final String title;
  final String description;
  final String lottieAsset;
  final List<String> options;
  final String preferenceKey;

  PreferencePageModel({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.options,
    required this.preferenceKey,
  });
}