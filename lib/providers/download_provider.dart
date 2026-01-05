// lib/providers/download_provider.dart
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:dhyana/core/services/article_cache_service.dart';
import 'package:dhyana/models/meditation_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dhyana/models/music_track_model.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dhyana/core/services/image_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DownloadType { music, meditation, video }

class DownloadInfo {
  final String taskId;
  final String title;
  final DownloadTaskStatus status;
  final int progress;
  final String? localImagePath;
  final String? imageUrl;
  final DownloadType type;
  final String originalId;

  DownloadInfo({
    required this.taskId,
    required this.title,
    required this.status,
    required this.progress,
    this.localImagePath,
    this.imageUrl,
    required this.type,
    required this.originalId,
  });

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'title': title,
    'status': status.index,
    'progress': progress,
    'localImagePath': localImagePath,
    'imageUrl': imageUrl,
    'type': type.index,
    'originalId': originalId,
  };

  factory DownloadInfo.fromJson(Map<String, dynamic> json) => DownloadInfo(
    taskId: json['taskId'] as String,
    title: json['title'] as String,
    status: DownloadTaskStatus.fromInt(json['status'] as int),
    progress: json['progress'] as int,
    localImagePath: json['localImagePath'] as String?,
    imageUrl: json['imageUrl'] as String?,
    type: DownloadType.values[json['type'] as int],
    originalId: json['originalId'] as String,
  );
}

class DownloadNotifier extends StateNotifier<Map<String, DownloadInfo>> {
  final ReceivePort _port = ReceivePort();
  final ImageCacheService _imageCacheService;
  final SharedPreferences _prefs;
  static const _storageKey = 'dhyana_download_info_map';

  DownloadNotifier(this._imageCacheService, this._prefs) : super({}) {
    _loadState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _loadState() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString != null) {
      final Map<String, dynamic> decodedMap = json.decode(jsonString);
      state = decodedMap.map(
            (key, value) => MapEntry(
          key,
          DownloadInfo.fromJson(value as Map<String, dynamic>),
        ),
      );
    }
  }

  Future<void> _saveState() async {
    final encodableMap = state.map(
          (key, value) => MapEntry(key, value.toJson()),
    );
    await _prefs.setString(_storageKey, json.encode(encodableMap));
  }

  void _bindBackgroundIsolate() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      final String id = data[0];
      final DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      final int progress = data[2];

      if (state.containsKey(id)) {
        final existingInfo = state[id]!;
        state = {
          ...state,
          id: DownloadInfo(
            taskId: id,
            title: existingInfo.title,
            status: status,
            progress: progress,
            localImagePath: existingInfo.localImagePath,
            imageUrl: existingInfo.imageUrl,
            type: existingInfo.type,
            originalId: existingInfo.originalId,
          ),
        };
        _saveState();
      }
    });
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<void> enqueueMusicDownload(MusicTrackModel track) async {
    final externalDir = await getExternalStorageDirectory();
    if (externalDir == null) return;

    String? localImagePath;
    if (track.imageUrl != null && track.imageUrl!.isNotEmpty) {
      localImagePath = await _imageCacheService.preCacheImage(track.imageUrl!);
    }

    final taskId = await FlutterDownloader.enqueue(
      url: track.audioUrl,
      fileName: '${track.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.mp3',
      savedDir: externalDir.path,
      showNotification: true,
      openFileFromNotification: false,
    );

    if (taskId != null) {
      state = {
        ...state,
        taskId: DownloadInfo(
            taskId: taskId,
            title: track.title,
            status: DownloadTaskStatus.enqueued,
            progress: 0,
            localImagePath: localImagePath,
            imageUrl: track.imageUrl,
            type: DownloadType.music,
            originalId: track.id),
      };
      await _saveState();
    }
  }

  Future<void> enqueueMeditationDownload(MeditationModel meditation) async {
    final externalDir = await getExternalStorageDirectory();
    if (externalDir == null || meditation.audioFilePath == null) return;

    String? localImagePath;
    if (meditation.imageUrl != null && meditation.imageUrl!.isNotEmpty) {
      localImagePath =
      await _imageCacheService.preCacheImage(meditation.imageUrl!);
    }

    final taskId = await FlutterDownloader.enqueue(
      url: meditation.audioFilePath!,
      fileName:
      '${meditation.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.mp3',
      savedDir: externalDir.path,
      showNotification: true,
      openFileFromNotification: false,
    );

    if (taskId != null) {
      state = {
        ...state,
        taskId: DownloadInfo(
          taskId: taskId,
          title: meditation.title,
          status: DownloadTaskStatus.enqueued,
          progress: 0,
          localImagePath: localImagePath,
          imageUrl: meditation.imageUrl,
          type: DownloadType.meditation,
          originalId: meditation.id!,
        ),
      };
      await _saveState();
    }
  }

  Future<void> deleteDownload(String taskId) async {
    try {
      await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
      final newState = Map<String, DownloadInfo>.from(state)..remove(taskId);
      state = newState;
      await _saveState();
    } catch (e) {
      debugPrint('Error deleting download: $e');
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }
}

final downloadProvider =
StateNotifierProvider<DownloadNotifier, Map<String, DownloadInfo>>((ref) {
  final imageCacheService = ref.watch(imageCacheServiceProvider);
  final sharedPrefsAsync = ref.watch(sharedPreferencesProvider);

  return sharedPrefsAsync.when(
    data: (prefs) => DownloadNotifier(imageCacheService, prefs),
    loading: () =>
        DownloadNotifier(imageCacheService, InMemorySharedPreferences()),
    error: (e, st) =>
        DownloadNotifier(imageCacheService, InMemorySharedPreferences()),
  );
});