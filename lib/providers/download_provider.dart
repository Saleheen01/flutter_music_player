import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/download_task.dart';
import '../models/song.dart';
import '../services/audio_downloader_service.dart';
import '../services/downloaded_songs_repository.dart';
import 'music_provider.dart';
import 'player_provider.dart';

final audioDownloaderServiceProvider = Provider<AudioDownloaderService>((ref) {
  final service = AudioDownloaderService();
  ref.onDispose(() => service.dispose());
  return service;
});

class DownloadNotifier extends StateNotifier<List<DownloadTask>> {
  final AudioDownloaderService _service;
  final Ref _ref;
  final DownloadedSongsRepository _repo = DownloadedSongsRepository();

  DownloadNotifier(this._service, this._ref) : super([]) {
    _loadSavedTasks();
  }

  Future<void> _loadSavedTasks() async {
    final tasks = await _repo.getDownloadTasks();
    state = tasks;
  }

  Future<void> enqueueDownload(String urlOrQuery) async {
    final taskId = const Uuid().v4();

    final initialTask = DownloadTask(
      id: taskId,
      title: 'Searching & extracting...',
      artist: 'YouTube',
      url: urlOrQuery,
      status: DownloadStatus.pending,
    );

    state = [initialTask, ...state];
    await _repo.saveDownloadTasks(state);

    try {
      final meta = await _service.extractMetadata(urlOrQuery);

      _updateTask(taskId, (t) => t.copyWith(
        videoId: meta.videoId,
        title: meta.title,
        artist: meta.artist,
        status: DownloadStatus.downloading,
      ));

      final savedPath = await _service.downloadAudioStream(
        metadata: meta,
        onProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            _updateTask(taskId, (t) => t.copyWith(progress: progress));
          }
        },
      );

      final song = Song(
        id: 'yt_${meta.videoId}',
        title: meta.title,
        artist: meta.artist,
        album: 'YouTube Downloads',
        path: savedPath,
        duration: meta.duration?.inMilliseconds ?? 0,
        dateAdded: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        isDownloaded: true,
      );

      await _repo.saveSong(song);

      _updateTask(taskId, (t) => t.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        localFilePath: savedPath,
      ));

      await _ref.read(musicProvider.notifier).loadLocalSongs();
    } catch (e) {
      _updateTask(taskId, (t) => t.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
      ));
    }
  }

  void _updateTask(String id, DownloadTask Function(DownloadTask) updater) {
    state = state.map((t) => t.id == id ? updater(t) : t).toList();
    _repo.saveDownloadTasks(state);
  }

  Future<void> deleteTask(String taskId) async {
    final task = state.firstWhere((t) => t.id == taskId, orElse: () => state.first);
    if (task.localFilePath != null) {
      final file = File(task.localFilePath!);
      if (file.existsSync()) {
        await file.delete();
      }
      if (task.videoId.isNotEmpty) {
        await _repo.deleteSong('yt_${task.videoId}');
      }
    }
    state = state.where((t) => t.id != taskId).toList();
    await _repo.saveDownloadTasks(state);
    await _ref.read(musicProvider.notifier).loadLocalSongs();
  }

  void playTask(DownloadTask task) {
    if (task.status != DownloadStatus.completed || task.localFilePath == null) return;

    final song = Song(
      id: 'yt_${task.videoId}',
      title: task.title,
      artist: task.artist,
      album: 'YouTube Downloads',
      path: task.localFilePath!,
      duration: 0,
      isDownloaded: true,
    );

    _ref.read(playerProvider.notifier).playQueue([song], initialIndex: 0);
  }

  void clearCompleted() {
    state = state.where((t) => t.status != DownloadStatus.completed).toList();
    _repo.saveDownloadTasks(state);
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, List<DownloadTask>>((ref) {
  final service = ref.watch(audioDownloaderServiceProvider);
  return DownloadNotifier(service, ref);
});
