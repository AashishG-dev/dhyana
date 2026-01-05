// lib/providers/laughing_therapy_provider.dart
import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/models/meme_model.dart';
import 'package:dhyana/models/standup_video_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to stream all memes from Firestore
final memesProvider = StreamProvider<List<MemeModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getMemes();
});

// Provider to stream all stand-up videos from Firestore
final standupVideosProvider = StreamProvider<List<StandupVideoModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getStandupVideos();
});

// Notifier for handling CRUD operations
class LaughingTherapyNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  LaughingTherapyNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  // Meme CRUD
  Future<void> addMeme(MemeModel meme) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.addMeme(meme);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateMeme(MemeModel meme) async {
    state = const AsyncValue.loading();
    try {
      // Corrected the typo here from updateMem to updateMeme
      await _firestoreService.updateMeme(meme);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteMeme(String memeId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteMeme(memeId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Stand-up Video CRUD
  Future<void> addStandupVideo(StandupVideoModel video) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.addStandupVideo(video);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateStandupVideo(StandupVideoModel video) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateStandupVideo(video);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteStandupVideo(String videoId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteStandupVideo(videoId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final laughingTherapyNotifierProvider = StateNotifierProvider<LaughingTherapyNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return LaughingTherapyNotifier(firestoreService);
});