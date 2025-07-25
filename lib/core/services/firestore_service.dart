// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/models/journal_entry_model.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/models/stress_relief_exercise_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- User Profile Operations ---
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      debugPrint('Error creating user profile for ${user.id}: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile for $userId: $e');
      rethrow;
    }
  }

  Stream<UserModel?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      debugPrint('Error updating user profile for ${user.id}: $e');
      rethrow;
    }
  }

  // --- Journal Entry Operations ---
  Future<void> addJournalEntry(String userId, JournalEntryModel entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal_entries')
          .add(entry.toJson());
    } catch (e) {
      debugPrint('Error adding journal entry for user ${userId}: $e');
      rethrow;
    }
  }

  Stream<List<JournalEntryModel>> getJournalEntries(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('journal_entries')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      // ✅ FIX: Filter out empty documents before parsing
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => JournalEntryModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateJournalEntry(String userId, JournalEntryModel entry) async {
    try {
      if (entry.id == null) {
        throw Exception('Journal entry ID cannot be null');
      }
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal_entries')
          .doc(entry.id)
          .update(entry.toJson());
    } catch (e) {
      debugPrint('Error updating journal entry for user ${userId}: $e');
      rethrow;
    }
  }

  Future<void> deleteJournalEntry(String userId, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal_entries')
          .doc(entryId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting journal entry for user ${userId}: $e');
      rethrow;
    }
  }

  // --- Progress Data Operations ---
  Future<void> saveProgressData(String userId, ProgressDataModel data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('summary')
          .set(data.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving progress data for user ${userId}: $e');
      rethrow;
    }
  }

  Stream<ProgressDataModel?> getProgressData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('summary')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return ProgressDataModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  // --- Meditation Content Operations ---
  Stream<List<MeditationModel>> getMeditationSessions() {
    return _firestore.collection('meditations').snapshots().map((snapshot) {
      // ✅ FIX: Filter out empty documents before parsing
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => MeditationModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<MeditationModel?> getMeditationById(String meditationId) async {
    try {
      final docSnapshot = await _firestore.collection('meditations').doc(meditationId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return MeditationModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting meditation $meditationId: $e');
      rethrow;
    }
  }

  // --- Article Content Operations ---
  Stream<List<ArticleModel>> getArticles() {
    return _firestore.collection('articles').snapshots().map((snapshot) {
      // ✅ FIX: Filter out empty documents before parsing
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => ArticleModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<ArticleModel?> getArticleById(String articleId) async {
    try {
      final docSnapshot = await _firestore.collection('articles').doc(articleId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return ArticleModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting article $articleId: $e');
      rethrow;
    }
  }

  // --- Stress Relief Exercise Operations ---
  Stream<List<StressReliefExerciseModel>> getStressReliefExercises() {
    return _firestore.collection('stress_relief_exercises').snapshots().map((snapshot) {
      // ✅ FIX: Filter out empty documents before parsing
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => StressReliefExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<StressReliefExerciseModel>> getStressReliefExercisesByCategory(String category) {
    return _firestore
        .collection('stress_relief_exercises')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      // ✅ FIX: Filter out empty documents before parsing
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => StressReliefExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<StressReliefExerciseModel?> getStressReliefExerciseById(String exerciseId) async {
    try {
      final docSnapshot = await _firestore.collection('stress_relief_exercises').doc(exerciseId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return StressReliefExerciseModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting stress relief exercise $exerciseId: $e');
      rethrow;
    }
  }
}