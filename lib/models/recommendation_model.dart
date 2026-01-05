// lib/models/recommendation_model.dart
import 'package:flutter/material.dart';

class Recommendation {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const Recommendation({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}