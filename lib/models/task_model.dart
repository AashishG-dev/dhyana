// lib/models/task_model.dart
import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String navigationPath; // The route to navigate to on tap
  bool isCompleted;
  final int? minutesRequired;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.navigationPath,
    this.isCompleted = false,
    this.minutesRequired,
  });
}