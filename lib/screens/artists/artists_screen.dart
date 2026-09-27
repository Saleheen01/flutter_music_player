import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../providers/music_provider.dart';
import '../../providers/player_provider.dart';

class ArtistsScreen extends ConsumerWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);

    if (musicState.artists.isEmpty) {
      return const Center(child: Text('No artists found', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: musicState.artists.length,
      itemBuilder: (context, index) {
        final artist = musicState.artists[index];
        final artistSongs = musicState.songs.where((s) => s.artist == artist.artist).toList();

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: QueryArtworkWidget(
              id: artist.id,
              type: ArtworkType.ARTIST,
              artworkWidth: 48,
              artworkHeight: 48,
              nullArtworkWidget: CircleAvatar(backgroundColor: Colors.grey[850], child: const Icon(Icons.person, color: Colors.white54)),
            ),
          ),
          title: Text(artist.artist, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${artist.numberOfTracks} songs • ${artist.numberOfAlbums} albums'),
          onTap: () {
            if (artistSongs.isNotEmpty) {
              ref.read(playerProvider.notifier).playQueue(artistSongs, initialIndex: 0);
            }
          },
        );
      },
    );
  }
}