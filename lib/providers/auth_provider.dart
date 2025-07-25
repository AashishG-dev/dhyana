// lib/core/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:dhyana/core/services/auth_service.dart'; // Import AuthService
import 'package:dhyana/core/services/firestore_service.dart'; // Import FirestoreService
import 'package:dhyana/core/services/api_service.dart'; // Import ApiService
import 'package:dhyana/core/services/cloudinary_service.dart'; // Import CloudinaryService
// import 'package:dhyana/core/models/user_model.dart'; // Not needed here anymore as currentUserProfileProvider is moved

/// Provider for the [AuthService].
/// This allows other parts of the app to access authentication functionalities.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider that exposes the current authentication state (User or null).
/// It listens to Firebase Auth state changes and provides the current [User] object.
/// This is crucial for redirecting users based on their login status.
final authStateProvider = StreamProvider<User?>((ref) {
  debugPrint('Auth state provider initialized.');
  return ref.read(authServiceProvider).authStateChanges;
});

// --- Core Service Providers (Moved from data_providers.dart) ---
// Note: These providers are placed here as a central location to adhere
// to the request of not creating new files, but ideally, core services
// might reside in a dedicated 'core_service_providers.dart' file.

/// Provides an instance of [FirestoreService].
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Provides an instance of [CloudinaryService].
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

/// Provides an instance of [ApiService] for general HTTP requests.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
