import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineVideoService {
  final Dio _dio = Dio();
  static const String _prefKeyPrefix = 'offline_video_';

  /// Download video from [url] and save to local storage.
  /// Returns the local file path.
  Future<String> downloadVideo(String url,Function(int received, int total)? onReceiveProgress) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      // Generate unique filename based on URL hash or last segment
      final fileName = 'video_${url.hashCode}.mp4'; 
      final savePath = '${directory.path}/$fileName';

      // Check if file already exists (maybe interrupted download or valid file not in DB)
      if (await File(savePath).exists()) {
        await _savePathToDb(url, savePath);
        return savePath;
      }

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );

      await _savePathToDb(url, savePath);
      return savePath;
    } catch (e) {
      throw Exception('Failed to download video: $e');
    }
  }

  /// Get local path for a video URL to local DB.
  /// Returns null if not found or file does not exist.
  Future<String?> getLocalVideoPath(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('$_prefKeyPrefix$url');

    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        return path;
      } else {
        // Validation: remove invalid path
        await prefs.remove('$_prefKeyPrefix$url');
      }
    }
    return null;
  }

  /// Save mapping: videoUrl -> localPath
  Future<void> _savePathToDb(String url, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefKeyPrefix$url', path);
  }
}
