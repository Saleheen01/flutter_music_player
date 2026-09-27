import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/audio_file_deletion_service.dart';

void showSongOptionsMenu(BuildContext context, WidgetRef ref, Song song) {
  final playlistState = ref.read(playlistProvider);
  final isFavorite = playlistState.favoriteSongIds.contains(song.id);

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(song.artist, style: TextStyle(color: Colors.grey[400])),
              leading: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(playerProvider.notifier).playQueue([song], initialIndex: 0);
              },
            ),
            ListTile(
              leading: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : null),
              title: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(playlistProvider.notifier).toggleFavorite(song.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline, color: Colors.amber),
              title: const Text('Remove from Library'),
              subtitle: const Text('Hides song without deleting the physical file', style: TextStyle(fontSize: 11)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(audioFileDeletionServiceProvider).removeSongsFromLibraryOnly([song]);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed song from library.')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text('Delete Permanently', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              subtitle: const Text('Deletes the physical audio file from your device', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                showPermanentDeleteConfirmDialog(context, ref, [song]);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<bool> showPermanentDeleteConfirmDialog(BuildContext context, WidgetRef ref, List<Song> songs) async {
  if (songs.isEmpty) return false;

  final count = songs.length;
  final titleText = count == 1 ? 'Delete song permanently?' : 'Delete $count songs permanently?';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'These audio files will be permanently deleted from your device. This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );

  if (confirmed == true && context.mounted) {
    final deletionService = ref.read(audioFileDeletionServiceProvider);
    final result = await deletionService.deleteSongsPermanently(songs);

    if (context.mounted) {
      if (result.failCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.successCount} song(s) permanently deleted'),
            backgroundColor: const Color(0xFF1DB954),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.successCount} song(s) deleted. ${result.failCount} could not be deleted.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }
    return true;
  }
  return false;
}
