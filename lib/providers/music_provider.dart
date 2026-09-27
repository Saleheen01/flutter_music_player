import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import '../services/downloaded_songs_repository.dart';

class MusicState {
  final List<Song> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final bool isLoading;
  final bool hasPermission;

  const MusicState({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.isLoading = false,
    this.hasPermission = false,
  });

  MusicState copyWith({
    List<Song>? songs,
    List<AlbumModel>? albums,
    List<ArtistModel>? artists,
    bool? isLoading,
    bool? hasPermission,
  }) {
    return MusicState(
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

class MusicNotifier extends StateNotifier<MusicState> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final DownloadedSongsRepository _downloadedRepository = DownloadedSongsRepository();

  MusicNotifier() : super(const MusicState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final granted = await requestPermissions();
    if (granted) {
      await loadLocalSongs();
    } else {
      await loadDownloadedSongsOnly();
    }
  }

  Future<bool> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    var audioStatus = await Permission.audio.status;
    if (!audioStatus.isGranted) {
      audioStatus = await Permission.audio.request();
    }
    final isGranted = status.isGranted || audioStatus.isGranted;
    state = state.copyWith(hasPermission: isGranted);
    return isGranted;
  }

  Future<void> loadDownloadedSongsOnly() async {
    try {
      final downloadedSongs = await _downloadedRepository.getDownloadedSongs();
      final validDownloaded = downloadedSongs.where((s) => File(s.path).existsSync()).toList();

      state = state.copyWith(
        songs: validDownloaded,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadLocalSongs() async {
    state = state.copyWith(isLoading: true);
    try {
      List<Song> deviceSongs = [];
      List<AlbumModel> albums = [];
      List<ArtistModel> artists = [];

      try {
        final songModels = await _audioQuery.querySongs(
          sortType: SongSortType.TITLE,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
        deviceSongs = songModels.map((s) => Song.fromAudioQuery(Map<String, dynamic>.from(s.getMap))).toList();
        albums = await _audioQuery.queryAlbums();
        artists = await _audioQuery.queryArtists();
      } catch (_) {}

      final downloadedSongs = await _downloadedRepository.getDownloadedSongs();
      final validDownloaded = downloadedSongs.where((s) => File(s.path).existsSync()).toList();

      final allSongs = [...validDownloaded, ...deviceSongs];

      state = state.copyWith(
        songs: allSongs,
        albums: albums,
        artists: artists,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final musicProvider = StateNotifierProvider<MusicNotifier, MusicState>((ref) {
  return MusicNotifier();
});
