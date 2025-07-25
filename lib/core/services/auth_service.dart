// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

/// Handles all core authentication logic, interacting directly with
/// Firebase Authentication. This service provides methods for user
/// registration, login, logout, password reset, and retrieving the
/// current authenticated user.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Returns a stream of [User] objects, which notifies about changes
  /// in the user's sign-in state (e.g., user signs in, user signs out).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Registers a new user with email and password.
  ///
  /// Throws a [FirebaseAuthException] if registration fails (e.g., email already in use, weak password).
  Future<UserCredential> signup(String email, String password) async {
    try {
      final UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('User signed up: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Signup Error: ${e.code} - ${e.message}');
      rethrow; // Re-throw the specific Firebase exception
    } catch (e) {
      debugPrint('General Signup Error: $e');
      throw Exception('Failed to sign up. Please try again.'); // Generic error for unexpected issues
    }
  }

  /// Logs in an existing user with email and password.
  ///
  /// Throws a [FirebaseAuthException] if login fails (e.g., invalid credentials).
  Future<UserCredential> login(String email, String password) async {
    try {
      final UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('User logged in: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Login Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Login Error: $e');
      throw Exception('Failed to log in. Please check your credentials.');
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('User logged out.');
    } catch (e) {
      debugPrint('Error logging out: $e');
      throw Exception('Failed to log out. Please try again.');
    }
  }

  /// Sends a password reset email to the specified email address.
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Reset Password Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Reset Password Error: $e');
      throw Exception('Failed to send password reset email. Please try again.');
    }
  }

  /// Returns the currently authenticated [User] object, or `null` if no user is signed in.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
