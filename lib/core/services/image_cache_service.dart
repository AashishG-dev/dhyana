// lib/core/services/image_cache_service.dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageCacheService {
  final CacheManager _cacheManager;

  ImageCacheService(this._cacheManager);

  // Pre-downloads and caches an image from a URL, and returns the local file path.
  Future<String?> preCacheImage(String imageUrl) async {
    try {
      final fileInfo = await _cacheManager.downloadFile(imageUrl);
      return fileInfo?.file.path;
    } catch (e) {
      // Handle cache download errors gracefully
      return null;
    }
  }

  // Removes a specific image from the cache
  Future<void> removeImageFromCache(String imageUrl) async {
    await _cacheManager.removeFile(imageUrl);
  }
}

// A provider for a custom cache manager instance
final customCacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager(
    Config(
      'dhyanaImageCache', // A unique key for your app's cache
      stalePeriod: const Duration(days: 30), // How long to cache images
      maxNrOfCacheObjects: 200, // Max number of images to cache
    ),
  );
});

// A provider for our image cache service
final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  final cacheManager = ref.watch(customCacheManagerProvider);
  return ImageCacheService(cacheManager);
});