// lib/models/therapy_card_model.dart
import 'package:flutter/material.dart';

class TherapyCardModel {
  final String title;
  final String description;
  final String imageAsset;
  final String route;
  final bool isEnabled;

  const TherapyCardModel({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.route,
    this.isEnabled = true,
  });
}