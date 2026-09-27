import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioMetadataInfo {
  final String videoId;
  final String title;
  final String artist;
  final Duration? duration;
  final AudioStreamInfo? audioStream;

  AudioMetadataInfo({
    required this.videoId,
    required this.title,
    required this.artist,
    this.duration,
    this.audioStream,
  });
}

class AudioDownloaderService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<AudioMetadataInfo> extractMetadata(String input) async {
    final query = input.trim();
    Video video;

    try {
      final videoId = VideoId(query);
      video = await _yt.videos.get(videoId);
    } catch (_) {
      final searchResults = await _yt.search.search(query);
      if (searchResults.isEmpty) {
        throw Exception('No YouTube video found for "$query"');
      }
      video = searchResults.first;
    }

    final manifest = await _yt.videos.streamsClient.getManifest(video.id);
    final audioStream = manifest.audioOnly.withHighestBitrate();

    return AudioMetadataInfo(
      videoId: video.id.value,
      title: video.title,
      artist: video.author,
      duration: video.duration,
      audioStream: audioStream,
    );
  }

  Future<String> downloadAudioStream({
    required AudioMetadataInfo metadata,
    required Function(int received, int total) onProgress,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/downloads');
    if (!downloadsDir.existsSync()) {
      await downloadsDir.create(recursive: true);
    }

    final sanitizeName = metadata.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final ext = metadata.audioStream?.container.name ?? 'm4a';
    final filePath = '${downloadsDir.path}/${metadata.videoId}_$sanitizeName.$ext';

    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
    }

    if (metadata.audioStream != null) {
      final audioStream = metadata.audioStream!;
      final stream = _yt.videos.streamsClient.get(audioStream);
      final fileStream = file.openWrite();

      var count = 0;
      final total = audioStream.size.totalBytes;

      await for (final chunk in stream) {
        count += chunk.length;
        fileStream.add(chunk);
        onProgress(count, total);
      }

      await fileStream.flush();
      await fileStream.close();
    } else {
      throw Exception('Audio stream not available for this video');
    }

    return filePath;
  }

  void dispose() {
    _yt.close();
  }
}
