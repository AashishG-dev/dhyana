// lib/main.dart
import 'package:dhyana/app.dart';
import 'package:dhyana/core/services/notification_service.dart';
import 'package:dhyana/core/services/storage_service.dart';
import 'package:dhyana/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:dhyana/providers/router_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED: Import for SharedPreferences

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// ✅ ADDED: Global RouteObserver for tracking navigation changes
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FlutterDownloader
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  // ✅ FIX: Initialize SharedPreferences before creating StorageService
  final prefs = await SharedPreferences.getInstance();
  // ✅ FIX: Pass the SharedPreferences instance to the constructor
  final storageService = StorageService(prefs);
  await NotificationService().initialize();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ REMOVED: The storageService.init() method is no longer needed
    // await storageService.init();
  } catch (e) {
    debugPrint('Error during app initialization: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Provide the initialized StorageService instance to the app
        storageServiceProvider.overrideWithValue(storageService),
        rootNavigatorKeyProvider.overrideWithValue(navigatorKey),
        // ✅ ADDED: Provide the global RouteObserver
        routeObserverProvider.overrideWithValue(routeObserver),
      ],
      child: const App(),
    ),
  );
}