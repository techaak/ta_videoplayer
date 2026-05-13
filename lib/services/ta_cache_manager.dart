import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class TaCacheManager {
  static const key = 'taVideoCache';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// Pre-caches a video URL
  static Future<void> preCacheVideo(String url) async {
    try {
      await instance.downloadFile(url);
    } catch (e) {
      debugPrint('Error pre-caching video: $e');
    }
  }

  /// Gets a cached file for a URL
  static Future<String?> getCachedPath(String url) async {
    final fileInfo = await instance.getFileFromCache(url);
    return fileInfo?.file.path;
  }
}
