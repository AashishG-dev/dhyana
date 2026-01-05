// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhyana/models/feedback_model.dart';
import 'package:dhyana/models/meme_model.dart';
import 'package:dhyana/models/standup_video_model.dart';
import 'package:dhyana/models/yoga_video_model.dart';
import 'package:flutter/foundation.dart';

import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/models/journal_entry_model.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/models/stress_relief_exercise_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructor to enable offline persistence
  FirestoreService() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // --- User Profile Operations ---

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => UserModel.fromJson(doc.data()!))
          .toList();
    });
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.id);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set(user.toJson());
        debugPrint('✅ Created new user profile for ${user.id}');
      } else {
        debugPrint('ℹ️ User profile for ${user.id} already exists.');
      }
    } catch (e, st) {
      debugPrint('❌ Error creating user profile for ${user.id}: $e\n$st');
      rethrow;
    }
  }

  Future<void> createUserProfileIfNotExists(UserModel user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.id);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set(user.toJson());
        debugPrint('✅ Created new user profile for ${user.id}');
      } else {
        debugPrint(
            'ℹ️ User profile for ${user.id} already exists - skipping creation.');
      }
    } catch (e, st) {
      debugPrint('❌ Error creating user profile for ${user.id}: $e\n$st');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final docSnapshot =
      await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e, st) {
      debugPrint('❌ Error fetching user profile for $userId: $e\n$st');
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
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
      debugPrint('✅ Updated user profile for ${user.id}');
    } catch (e, st) {
      debugPrint('❌ Error updating user profile for ${user.id}: $e\n$st');
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);

    final journalEntries = await userRef.collection('journal_entries').get();
    for (var doc in journalEntries.docs) {
      await doc.reference.delete();
    }
    final progress = await userRef.collection('progress').get();
    for (var doc in progress.docs) {
      await doc.reference.delete();
    }

    await userRef.delete();
    debugPrint('✅ Deleted user profile data for $userId');
  }

  Future<void> deleteUserData(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);

    // Delete subcollections
    final journalEntries = await userRef.collection('journal_entries').get();
    for (var doc in journalEntries.docs) {
      await doc.reference.delete();
    }
    final progress = await userRef.collection('progress').get();
    for (var doc in progress.docs) {
      await doc.reference.delete();
    }

    // Delete the user document itself
    await userRef.delete();
    debugPrint('✅ Deleted all data for user $userId');
  }

  Future<bool> isProfileComplete(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile != null && profile.name.isNotEmpty;
    } catch (e, st) {
      debugPrint('❌ Error checking profile completeness for $userId: $e\n$st');
      return false;
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
    } catch (e, st) {
      debugPrint('❌ Error adding journal entry for $userId: $e\n$st');
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
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => JournalEntryModel.fromJson(doc.data()!, doc.id))
          .toList();
    });
  }

  Future<void> updateJournalEntry(
      String userId, JournalEntryModel entry) async {
    if (entry.id == null) throw Exception('Journal entry ID cannot be null');
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal_entries')
          .doc(entry.id)
          .update(entry.toJson());
    } catch (e, st) {
      debugPrint(
          '❌ Error updating journal entry ${entry.id} for $userId: $e\n$st');
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
    } catch (e, st) {
      debugPrint(
          '❌ Error deleting journal entry $entryId for $userId: $e\n$st');
      rethrow;
    }
  }

  // --- Progress Data Operations ---
  Future<void> updateProgressDataInTransaction(String userId,
      ProgressDataModel Function(ProgressDataModel?) updater) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('summary');
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final currentProgress =
      snapshot.exists ? ProgressDataModel.fromJson(snapshot.data()!) : null;
      final updatedProgress = updater(currentProgress);
      transaction.set(docRef, updatedProgress.toJson());
    });
  }

  Future<void> saveProgressData(String userId, ProgressDataModel data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('summary')
          .set(data.toJson(), SetOptions(merge: true));
    } catch (e, st) {
      debugPrint('❌ Error saving progress data for $userId: $e\n$st');
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

  // --- Meditation Operations ---
  Stream<List<MeditationModel>> getMeditationSessions() {
    return _firestore.collection('meditations').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => MeditationModel.fromJson(doc.data()!, doc.id))
          .toList();
    });
  }

  Future<MeditationModel?> getMeditationById(String meditationId) async {
    try {
      final docSnapshot =
      await _firestore.collection('meditations').doc(meditationId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return MeditationModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e, st) {
      debugPrint('❌ Error fetching meditation $meditationId: $e\n$st');
      rethrow;
    }
  }

  // --- Article Operations ---
  Stream<List<ArticleModel>> getArticles() {
    return _firestore.collection('articles').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => ArticleModel.fromJson(doc.data()!, doc.id))
          .toList();
    });
  }

  Future<ArticleModel?> getArticleById(String articleId) async {
    try {
      final docSnapshot =
      await _firestore.collection('articles').doc(articleId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return ArticleModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e, st) {
      debugPrint('❌ Error fetching article $articleId: $e\n$st');
      rethrow;
    }
  }

  Future<String?> getArticleContent(String articleId) async {
    try {
      final docSnapshot =
      await _firestore.collection('articles').doc(articleId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data()!['content'] as String?;
      }
      return null;
    } catch (e, st) {
      debugPrint('❌ Error fetching article content for $articleId: $e\n$st');
      rethrow;
    }
  }

  Future<DocumentReference> addArticle(ArticleModel article) async {
    try {
      return await _firestore.collection('articles').add(article.toJson());
    } catch (e, st) {
      debugPrint('❌ Error adding article: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateArticle(ArticleModel article) async {
    if (article.id == null) {
      throw Exception('Article ID cannot be null for update');
    }
    try {
      await _firestore
          .collection('articles')
          .doc(article.id)
          .update(article.toJson());
    } catch (e, st) {
      debugPrint('❌ Error updating article ${article.id}: $e\n$st');
      rethrow;
    }
  }

  Future<void> deleteArticle(String articleId) async {
    try {
      await _firestore.collection('articles').doc(articleId).delete();
    } catch (e, st) {
      debugPrint('❌ Error deleting article $articleId: $e\n$st');
      rethrow;
    }
  }

  // --- Stress Relief Exercises ---
  Stream<List<StressReliefExerciseModel>> getStressReliefExercises() {
    return _firestore
        .collection('stress_relief_exercises')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) =>
          StressReliefExerciseModel.fromJson(doc.data()!, doc.id))
          .toList();
    });
  }

  Stream<List<StressReliefExerciseModel>> getStressReliefExercisesByCategory(
      String category) {
    return _firestore
        .collection('stress_relief_exercises')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) =>
          StressReliefExerciseModel.fromJson(doc.data()!, doc.id))
          .toList();
    });
  }

  Future<StressReliefExerciseModel?> getStressReliefExerciseById(
      String exerciseId) async {
    try {
      final docSnapshot = await _firestore
          .collection('stress_relief_exercises')
          .doc(exerciseId)
          .get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return StressReliefExerciseModel.fromJson(
            docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e, st) {
      debugPrint(
          '❌ Error fetching stress relief exercise $exerciseId: $e\n$st');
      rethrow;
    }
  }

  // --- Laughing Therapy Operations ---

  Stream<List<MemeModel>> getMemes() {
    return _firestore
        .collection('memes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MemeModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addMeme(MemeModel meme) async {
    await _firestore.collection('memes').add(meme.toJson());
  }

  Future<void> updateMeme(MemeModel meme) async {
    await _firestore.collection('memes').doc(meme.id).update(meme.toJson());
  }

  Future<void> deleteMeme(String memeId) async {
    await _firestore.collection('memes').doc(memeId).delete();
  }

  Stream<List<StandupVideoModel>> getStandupVideos() {
    return _firestore
        .collection('standup_videos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StandupVideoModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addStandupVideo(StandupVideoModel video) async {
    await _firestore.collection('standup_videos').add(video.toJson());
  }

  Future<void> updateStandupVideo(StandupVideoModel video) async {
    await _firestore
        .collection('standup_videos')
        .doc(video.id)
        .update(video.toJson());
  }

  Future<void> deleteStandupVideo(String videoId) async {
    await _firestore.collection('standup_videos').doc(videoId).delete();
  }

  // --- Yoga Therapy Operations ---

  Stream<List<YogaVideoModel>> getYogaVideos() {
    return _firestore.collection('yoga_videos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => YogaVideoModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addYogaVideo(YogaVideoModel video) async {
    await _firestore.collection('yoga_videos').add(video.toFirestore());
  }

  Future<void> updateYogaVideo(YogaVideoModel video) async {
    await _firestore
        .collection('yoga_videos')
        .doc(video.id)
        .update(video.toFirestore());
  }

  Future<void> deleteYogaVideo(String videoId) async {
    await _firestore.collection('yoga_videos').doc(videoId).delete();
  }

  // --- Feedback Operations ---
  Future<void> addFeedback(FeedbackModel feedback) async {
    await _firestore.collection('feedback').add(feedback.toJson());
  }

  Stream<List<FeedbackModel>> getFeedback() {
    return _firestore
        .collection('feedback')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FeedbackModel(
          id: doc.id,
          userId: data['userId'] ?? '',
          type: data['type'] ?? '',
          message: data['message'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          imageUrl: data['imageUrl'] as String?,
        );
      }).toList();
    });
  }

  Future<void> deleteFeedback(String feedbackId) async {
    await _firestore.collection('feedback').doc(feedbackId).delete();
  }
}