import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../providers/player_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/download_provider.dart';
import 'downloaded_songs_repository.dart';

extension IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class DeletionResult {
  final int successCount;
  final int failCount;
  final List<Song> failedSongs;

  DeletionResult({
    required this.successCount,
    required this.failCount,
    required this.failedSongs,
  });
}

class AudioFileDeletionService {
  final Ref ref;
  final DownloadedSongsRepository _downloadedRepo = DownloadedSongsRepository();

  AudioFileDeletionService(this.ref);

  Future<DeletionResult> deleteSongsPermanently(List<Song> songsToDelete) async {
    if (songsToDelete.isEmpty) {
      return DeletionResult(successCount: 0, failCount: 0, failedSongs: []);
    }

    final playerState = ref.read(playerProvider);
    final playerNotifier = ref.read(playerProvider.notifier);
    final playlistNotifier = ref.read(playlistProvider.notifier);
    final downloadNotifier = ref.read(downloadProvider.notifier);
    final musicNotifier = ref.read(musicProvider.notifier);

    // 1. Check if currently playing song is in songsToDelete
    final currentSong = playerState.currentSong;
    if (currentSong != null && songsToDelete.any((s) => s.id == currentSong.id || s.path == currentSong.path)) {
      final remainingQueue = playerState.queue.where((s) => !songsToDelete.any((d) => d.id == s.id || d.path == s.path)).toList();
      if (remainingQueue.isNotEmpty) {
        await playerNotifier.playQueue(remainingQueue, initialIndex: 0);
      } else {
        await playerNotifier.seek(Duration.zero);
        await playerNotifier.playQueue([], initialIndex: 0);
      }
    }

    int successCount = 0;
    int failCount = 0;
    final List<Song> failedSongs = [];

    for (final song in songsToDelete) {
      bool physicalDeleted = false;

      // 2. Physical File Deletion
      try {
        final file = File(song.path);
        if (file.existsSync()) {
          try {
            await file.delete();
            physicalDeleted = !file.existsSync();
          } catch (_) {
            physicalDeleted = !file.existsSync();
          }
        } else {
          // File already missing from device, clean up stale reference
          physicalDeleted = true;
        }
      } catch (_) {
        physicalDeleted = false;
      }

      if (physicalDeleted) {
        successCount++;

        // 3. Cleanup downloaded repository and download task records
        if (song.isDownloaded || song.id.startsWith('yt_')) {
          await _downloadedRepo.deleteSong(song.id);
          final downloadTasks = ref.read(downloadProvider);
          final matchingTask = downloadTasks.firstWhereOrNull((t) => t.localFilePath == song.path || 'yt_${t.videoId}' == song.id);
          if (matchingTask != null) {
            await downloadNotifier.deleteTask(matchingTask.id);
          }
        }

        // 4. Remove from Favorites & Play History & Custom Playlists
        final playlistState = ref.read(playlistProvider);
        if (playlistState.favoriteSongIds.contains(song.id)) {
          await playlistNotifier.toggleFavorite(song.id);
        }
        for (final playlist in playlistState.playlists) {
          if (playlist.songIds.contains(song.id)) {
            await playlistNotifier.removeSongFromPlaylist(playlist.id, song.id);
          }
        }
      } else {
        failCount++;
        failedSongs.add(song);
      }
    }

    // 5. Refresh music library
    await musicNotifier.loadLocalSongs();

    return DeletionResult(
      successCount: successCount,
      failCount: failCount,
      failedSongs: failedSongs,
    );
  }

  Future<void> removeSongsFromLibraryOnly(List<Song> songsToRemove) async {
    final playlistNotifier = ref.read(playlistProvider.notifier);
    final downloadNotifier = ref.read(downloadProvider.notifier);
    final musicNotifier = ref.read(musicProvider.notifier);

    for (final song in songsToRemove) {
      if (song.isDownloaded || song.id.startsWith('yt_')) {
        await _downloadedRepo.deleteSong(song.id);
        final downloadTasks = ref.read(downloadProvider);
        final matchingTask = downloadTasks.firstWhereOrNull((t) => t.localFilePath == song.path || 'yt_${t.videoId}' == song.id);
        if (matchingTask != null) {
          await downloadNotifier.deleteTask(matchingTask.id);
        }
      }

      final playlistState = ref.read(playlistProvider);
      if (playlistState.favoriteSongIds.contains(song.id)) {
        await playlistNotifier.toggleFavorite(song.id);
      }
      for (final playlist in playlistState.playlists) {
        if (playlist.songIds.contains(song.id)) {
          await playlistNotifier.removeSongFromPlaylist(playlist.id, song.id);
        }
      }
    }

    await musicNotifier.loadLocalSongs();
  }
}

final audioFileDeletionServiceProvider = Provider<AudioFileDeletionService>((ref) {
  return AudioFileDeletionService(ref);
});
