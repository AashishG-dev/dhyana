// lib/models/achievement_model.dart
import 'package:flutter/material.dart';

class Achievement {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final String? taskId;

  Achievement({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.taskId,
  });
}