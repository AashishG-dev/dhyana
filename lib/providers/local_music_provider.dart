// lib/providers/local_music_provider.dart
import 'package:dhyana/core/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/models/music_track_model.dart';
import 'package:file_picker/file_picker.dart';

class LocalMusicNotifier extends StateNotifier<List<MusicTrackModel>> {
  final StorageService _storageService;
  static const _localMusicKey = 'local_music_files';

  LocalMusicNotifier(this._storageService) : super([]) {
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final filePaths = _storageService.getString(_localMusicKey);
    if (filePaths != null) {
      final paths = filePaths.split(',');
      final tracks = paths.map((path) {
        return MusicTrackModel(
          id: path,
          title: path.split('/').last,
          artist: 'Local File',
          durationSeconds: 0,
          audioUrl: path,
        );
      }).toList();
      state = tracks;
    }
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      final newPaths = result.paths.where((p) => p != null).cast<String>();
      final currentPaths = state.map((t) => t.audioUrl).toList();
      final allPaths = {...currentPaths, ...newPaths}.toList();

      await _storageService.saveString(_localMusicKey, allPaths.join(','));
      _loadFiles(); // Reload to ensure a single source of truth
    }
  }

  void clearLocalMusic() {
    _storageService.remove(_localMusicKey);
    state = [];
  }
}

final localMusicProvider =
StateNotifierProvider<LocalMusicNotifier, List<MusicTrackModel>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return LocalMusicNotifier(storageService);
});