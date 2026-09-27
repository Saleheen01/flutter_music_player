import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<Song> queue;
  final int currentIndex;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
    this.currentIndex = -1,
  });

  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<Song>? queue,
    int? currentIndex,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  PlayerNotifier() : super(const PlayerState()) {
    _listenToStreams();
  }

  void _listenToStreams() {
    _audioPlayer.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
    });

    _audioPlayer.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _audioPlayer.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });
  }

  Future<void> playQueue(List<Song> songs, {int initialIndex = 0}) async {
    if (songs.isEmpty) return;
    state = state.copyWith(queue: songs, currentIndex: initialIndex);
    await _playSongAtIndex(initialIndex);
  }

  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    final song = state.queue[index];
    state = state.copyWith(currentSong: song, currentIndex: index);

    try {
      final mediaItem = MediaItem(
        id: song.id,
        album: song.album,
        title: song.title,
        artist: song.artist,
      );

      final Uri audioUri = song.path.startsWith('http://') || song.path.startsWith('https://')
          ? Uri.parse(song.path)
          : Uri.file(song.path);

      final audioSource = AudioSource.uri(
        audioUri,
        tag: mediaItem,
      );

      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.play();
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> playNext() async {
    if (state.currentIndex < state.queue.length - 1) {
      await _playSongAtIndex(state.currentIndex + 1);
    }
  }

  Future<void> playPrevious() async {
    if (state.currentIndex > 0) {
      await _playSongAtIndex(state.currentIndex - 1);
    }
  }

  Future<void> rewind10Seconds() async {
    if (state.currentSong == null) return;
    final target = state.position - const Duration(seconds: 10);
    final newPosition = target < Duration.zero ? Duration.zero : target;
    await seek(newPosition);
  }

  Future<void> fastForward10Seconds() async {
    if (state.currentSong == null) return;
    final target = state.position + const Duration(seconds: 10);
    final maxDuration = state.duration;
    if (maxDuration > Duration.zero && target > maxDuration) {
      await seek(maxDuration);
    } else {
      await seek(target);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});
