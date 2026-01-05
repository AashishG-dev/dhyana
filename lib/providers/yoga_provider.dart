// lib/providers/yoga_provider.dart
import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/models/yoga_video_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to stream all yoga videos from Firestore
final yogaVideosProvider = StreamProvider<List<YogaVideoModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getYogaVideos();
});

// Notifier for handling CRUD operations for yoga videos
class YogaNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  YogaNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  Future<void> addYogaVideo(YogaVideoModel video) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.addYogaVideo(video);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateYogaVideo(YogaVideoModel video) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateYogaVideo(video);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteYogaVideo(String videoId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteYogaVideo(videoId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final yogaNotifierProvider = StateNotifierProvider<YogaNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return YogaNotifier(firestoreService);
});