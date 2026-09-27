import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/music_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/song_options_dialog.dart';
import '../../models/song.dart';

class SongsScreen extends ConsumerStatefulWidget {
  const SongsScreen({super.key});

  @override
  ConsumerState<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends ConsumerState<SongsScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedSongIds = {};

  void _toggleSelection(String songId) {
    setState(() {
      if (_selectedSongIds.contains(songId)) {
        _selectedSongIds.remove(songId);
        if (_selectedSongIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedSongIds.add(songId);
      }
    });
  }

  void _enterSelectionMode(String songId) {
    setState(() {
      _isSelectionMode = true;
      _selectedSongIds.add(songId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedSongIds.clear();
    });
  }

  void _selectAll(List<Song> songs) {
    setState(() {
      if (_selectedSongIds.length == songs.length) {
        _selectedSongIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedSongIds.addAll(songs.map((s) => s.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicProvider);

    if (musicState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)));
    }

    if (musicState.songs.isEmpty) {
      return const Center(child: Text('No local songs found.', style: TextStyle(color: Colors.grey)));
    }

    final allSelected = _selectedSongIds.length == musicState.songs.length;

    return Column(
      children: [
        if (_isSelectionMode)
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancel selection',
                  onPressed: _exitSelectionMode,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedSongIds.length} selected',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _selectAll(musicState.songs),
                  icon: Icon(allSelected ? Icons.deselect : Icons.select_all, size: 20, color: const Color(0xFF1DB954)),
                  label: Text(
                    allSelected ? 'Deselect All' : 'Select All',
                    style: const TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  tooltip: 'Delete Selected Songs',
                  onPressed: () async {
                    final selectedSongs = musicState.songs.where((s) => _selectedSongIds.contains(s.id)).toList();
                    final deleted = await showPermanentDeleteConfirmDialog(context, ref, selectedSongs);
                    if (deleted) {
                      _exitSelectionMode();
                    }
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: musicState.songs.length,
            itemBuilder: (context, index) {
              final song = musicState.songs[index];
              final isSelected = _selectedSongIds.contains(song.id);

              return SongTile(
                song: song,
                isSelectionMode: _isSelectionMode,
                isSelected: isSelected,
                onSelectionChanged: (_) => _toggleSelection(song.id),
                onLongPress: () => _enterSelectionMode(song.id),
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(song.id);
                  } else {
                    ref.read(playerProvider.notifier).playQueue(musicState.songs, initialIndex: index);
                    ref.read(playlistProvider.notifier).addToHistory(song.id);
                  }
                },
                onMoreTap: () => showSongOptionsMenu(context, ref, song),
              );
            },
          ),
        ),
      ],
    );
  }
}
