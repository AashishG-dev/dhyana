// lib/core/services/auth_service.dart
import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/core/services/storage_service.dart';
import 'package:dhyana/models/journal_entry_model.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String _guestProgressKey = 'guest_progress_data';
const String _guestJournalKey = 'guest_journal_entries';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirestoreService _firestoreService;
  final StorageService _storageService;

  AuthService(this._firestoreService, this._storageService);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ✅ ADDED: Method to clear all local data associated with a guest session.
  Future<void> _clearGuestData() async {
    await _storageService.remove(_guestProgressKey);
    await _storageService.remove(_guestJournalKey);
    debugPrint('Guest data cleared from local storage.');
  }

  Future<void> _syncGuestDataToFirestore(String newUserId) async {
    debugPrint('Checking for guest data to sync...');

    // Sync Progress Data
    final progressJson = _storageService.getJson(_guestProgressKey);
    if (progressJson != null) {
      final guestProgress = ProgressDataModel.fromJson(progressJson).copyWith(userId: newUserId);
      await _firestoreService.saveProgressData(newUserId, guestProgress);
      await _storageService.remove(_guestProgressKey);
      debugPrint('✅ Guest progress data synced and cleared.');
    }

    // Sync Journal Entries
    final journalJsonList = _storageService.getJsonList(_guestJournalKey);
    if (journalJsonList != null && journalJsonList.isNotEmpty) {
      for (final json in journalJsonList) {
        final guestEntry = JournalEntryModel.fromJson(json, json['id']).copyWith(userId: newUserId);
        await _firestoreService.addJournalEntry(newUserId, guestEntry);
      }
      await _storageService.remove(_guestJournalKey);
      debugPrint('✅ Guest journal entries synced and cleared.');
    }
  }

  Future<UserCredential> signup(String email, String password) async {
    try {
      final UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _syncGuestDataToFirestore(userCredential.user!.uid);
      }
      debugPrint('User signed up: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Signup Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Signup Error: $e');
      throw Exception('Failed to sign up. Please try again.');
    }
  }

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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser) {
          await _syncGuestDataToFirestore(userCredential.user!.uid);
        }
      }

      debugPrint('User signed in with Google: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Google Sign-In Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Google Sign-In Error: $e');
      throw Exception('Failed to sign in with Google. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      // ✅ ADDED: Ensure guest data is cleared on logout.
      await _clearGuestData();
      debugPrint('User logged out and guest data cleared.');
    } catch (e) {
      debugPrint('Error logging out: $e');
      throw Exception('Failed to log out. Please try again.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Firebase Auth Reset Password Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Reset Password Error: $e');
      throw Exception('Failed to send password reset email. Please try again.');
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}