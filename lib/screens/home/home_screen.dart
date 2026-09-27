import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../providers/music_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../models/song.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final favorites = ref.watch(favoriteSongsProvider);
    final recentlyPlayed = ref.watch(recentlyPlayedSongsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getGreeting(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
        ],
      ),
      body: musicState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (favorites.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Favorites', favorites, ref),
                    _buildHorizontalSongList(favorites, ref),
                  ],
                  if (recentlyPlayed.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Recently Played', recentlyPlayed, ref),
                    _buildHorizontalSongList(recentlyPlayed, ref),
                  ],
                  if (musicState.songs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text('No music tracks found on device.', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, List<Song> songs, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {
              if (songs.isNotEmpty) {
                ref.read(playerProvider.notifier).playQueue(songs, initialIndex: 0);
              }
            },
            child: const Text('Play All', style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSongList(List<Song> songs, WidgetRef ref) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          final songId = int.tryParse(song.id) ?? 0;
          return GestureDetector(
            onTap: () {
              ref.read(playerProvider.notifier).playQueue(songs, initialIndex: index);
              ref.read(playlistProvider.notifier).addToHistory(song.id);
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: QueryArtworkWidget(
                      id: songId,
                      type: ArtworkType.AUDIO,
                      artworkWidth: 120,
                      artworkHeight: 120,
                      nullArtworkWidget: Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[850],
                        child: const Icon(Icons.music_note, color: Colors.white54, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}