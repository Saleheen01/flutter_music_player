import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/playlist_provider.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistState = ref.watch(playlistProvider);
    final notifier = ref.read(playlistProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePlaylistDialog(context, notifier),
          ),
        ],
      ),
      body: playlistState.playlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.playlist_play, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No playlists yet', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showCreatePlaylistDialog(context, notifier),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Playlist'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: playlistState.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistState.playlists[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.queue_music, color: Color(0xFF1DB954)),
                  ),
                  title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${playlist.songIds.length} tracks'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'delete') notifier.deletePlaylist(playlist.id);
                    },
                    itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Text('Delete Playlist'))],
                  ),
                );
              },
            ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, PlaylistNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('New Playlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Playlist Name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  notifier.createPlaylist(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}