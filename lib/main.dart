// lib/main.dart
import 'package:dhyana/app.dart';
import 'package:dhyana/core/services/notification_service.dart';
import 'package:dhyana/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  // Ensure that Flutter widgets binding is initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase using the platform-specific options.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize the notification service.
    await NotificationService().init();

  } catch (e) {
    // Log any errors that occur during the initialization process.
    debugPrint('Error during app initialization: $e');
  }

  // Run the application within a ProviderScope for Riverpod state management.
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}