import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../repositories/playlist_repository.dart';
import 'music_provider.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository();
});

class PlaylistState {
  final List<Playlist> playlists;
  final Set<String> favoriteSongIds;
  final List<String> playHistorySongIds;

  const PlaylistState({
    this.playlists = const [],
    this.favoriteSongIds = const {},
    this.playHistorySongIds = const [],
  });

  PlaylistState copyWith({
    List<Playlist>? playlists,
    Set<String>? favoriteSongIds,
    List<String>? playHistorySongIds,
  }) {
    return PlaylistState(
      playlists: playlists ?? this.playlists,
      favoriteSongIds: favoriteSongIds ?? this.favoriteSongIds,
      playHistorySongIds: playHistorySongIds ?? this.playHistorySongIds,
    );
  }
}

class PlaylistNotifier extends StateNotifier<PlaylistState> {
  final PlaylistRepository _repository;

  PlaylistNotifier(this._repository) : super(const PlaylistState()) {
    init();
  }

  Future<void> init() async {
    final loadedPlaylists = await _repository.loadPlaylists();
    final loadedFavs = await _repository.loadFavorites();
    final loadedHistory = await _repository.loadPlayHistory();

    state = state.copyWith(
      playlists: loadedPlaylists,
      favoriteSongIds: loadedFavs,
      playHistorySongIds: loadedHistory,
    );
  }

  Future<void> createPlaylist(String name) async {
    final newPlaylist = Playlist(
      id: const Uuid().v4(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
    );
    final updated = [...state.playlists, newPlaylist];
    state = state.copyWith(playlists: updated);
    await _repository.savePlaylists(updated);
  }

  Future<void> deletePlaylist(String playlistId) async {
    final updated = state.playlists.where((p) => p.id != playlistId).toList();
    state = state.copyWith(playlists: updated);
    await _repository.savePlaylists(updated);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final updated = state.playlists.map((p) {
      if (p.id == playlistId && !p.songIds.contains(songId)) {
        return p.copyWith(songIds: [...p.songIds, songId]);
      }
      return p;
    }).toList();

    state = state.copyWith(playlists: updated);
    await _repository.savePlaylists(updated);
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final updated = state.playlists.map((p) {
      if (p.id == playlistId) {
        return p.copyWith(songIds: p.songIds.where((id) => id != songId).toList());
      }
      return p;
    }).toList();

    state = state.copyWith(playlists: updated);
    await _repository.savePlaylists(updated);
  }

  Future<void> reorderPlaylistSongs(String playlistId, int oldIndex, int newIndex) async {
    final updated = state.playlists.map((p) {
      if (p.id == playlistId) {
        final list = List<String>.from(p.songIds);
        if (newIndex > oldIndex) newIndex -= 1;
        final item = list.removeAt(oldIndex);
        list.insert(newIndex, item);
        return p.copyWith(songIds: list);
      }
      return p;
    }).toList();

    state = state.copyWith(playlists: updated);
    await _repository.savePlaylists(updated);
  }

  Future<void> toggleFavorite(String songId) async {
    final favs = Set<String>.from(state.favoriteSongIds);
    if (favs.contains(songId)) {
      favs.remove(songId);
    } else {
      favs.add(songId);
    }
    state = state.copyWith(favoriteSongIds: favs);
    await _repository.saveFavorites(favs);
  }

  Future<void> addToHistory(String songId) async {
    final history = List<String>.from(state.playHistorySongIds);
    history.remove(songId);
    history.insert(0, songId);
    if (history.length > 50) history.removeLast();

    state = state.copyWith(playHistorySongIds: history);
    await _repository.savePlayHistory(history);
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, PlaylistState>((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  return PlaylistNotifier(repo);
});

final favoriteSongsProvider = Provider<List<Song>>((ref) {
  final musicState = ref.watch(musicProvider);
  final playlistState = ref.watch(playlistProvider);
  return musicState.songs.where((song) => playlistState.favoriteSongIds.contains(song.id)).toList();
});

final recentlyPlayedSongsProvider = Provider<List<Song>>((ref) {
  final musicState = ref.watch(musicProvider);
  final playlistState = ref.watch(playlistProvider);
  final map = {for (var s in musicState.songs) s.id: s};
  return playlistState.playHistorySongIds.map((id) => map[id]).whereType<Song>().toList();
});