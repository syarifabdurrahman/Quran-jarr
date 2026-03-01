import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_jarr/core/network/dio_client.dart';

/// Audio Download Service
/// Downloads and manages audio files for offline playback
class AudioDownloadService {
  AudioDownloadService._();

  static final AudioDownloadService _instance = AudioDownloadService._();
  static AudioDownloadService get instance => _instance;

  final Dio _dio = DioClient.instance.dio;
  final String _audioDir = 'quran_audio';

  /// Get the local audio directory
  Future<Directory> _getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/$_audioDir');

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    return audioDir;
  }

  /// Get local file path for a verse key
  Future<String?> getLocalAudioPath(String verseKey) async {
    try {
      final audioDir = await _getAudioDirectory();
      final file = File('${audioDir.path}/$verseKey.mp3');

      if (await file.exists()) {
        return file.path;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Download audio for a verse
  Future<String?> downloadAudio(String verseKey, String audioUrl) async {
    try {
      // Check if already downloaded
      final existingPath = await getLocalAudioPath(verseKey);
      if (existingPath != null) {
        return existingPath;
      }

      // Download audio
      final audioDir = await _getAudioDirectory();
      final filePath = '${audioDir.path}/$verseKey.mp3';

      await _dio.download(
        audioUrl,
        filePath,
        onReceiveProgress: (received, total) {
          // Can be used for progress tracking in the future
        },
      );

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Check if audio is downloaded
  Future<bool> isAudioDownloaded(String verseKey) async {
    final path = await getLocalAudioPath(verseKey);
    return path != null;
  }

  /// Delete downloaded audio for a verse
  Future<void> deleteAudio(String verseKey) async {
    try {
      final audioDir = await _getAudioDirectory();
      final file = File('${audioDir.path}/$verseKey.mp3');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore delete errors
    }
  }

  /// Get total size of downloaded audio files
  Future<int> getTotalAudioSize() async {
    try {
      final audioDir = await _getAudioDirectory();
      final files = audioDir.listSync();

      int totalSize = 0;
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all downloaded audio
  Future<void> clearAllAudio() async {
    try {
      final audioDir = await _getAudioDirectory();
      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
        await audioDir.create(recursive: true);
      }
    } catch (e) {
      // Ignore clear errors
    }
  }

  /// Format bytes to readable size
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
