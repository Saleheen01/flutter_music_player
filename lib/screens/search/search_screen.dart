import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/music_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/song_options_dialog.dart';
import '../../models/song.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSelectionMode = false;
  final Set<String> _selectedSongIds = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  void _selectAll(List<Song> matchingSongs) {
    setState(() {
      if (_selectedSongIds.length == matchingSongs.length) {
        _selectedSongIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedSongIds.addAll(matchingSongs.map((s) => s.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicProvider);
    final query = _controller.text.trim().toLowerCase();

    final matchingSongs = query.isEmpty
        ? <Song>[]
        : musicState.songs.where((s) {
            return s.title.toLowerCase().contains(query) ||
                   s.artist.toLowerCase().contains(query) ||
                   s.album.toLowerCase().contains(query);
          }).toList();

    final allSelected = matchingSongs.isNotEmpty && _selectedSongIds.length == matchingSongs.length;

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: const Color(0xFF1E1E1E),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              ),
              title: Text('${_selectedSongIds.length} selected'),
              actions: [
                TextButton.icon(
                  onPressed: () => _selectAll(matchingSongs),
                  icon: Icon(allSelected ? Icons.deselect : Icons.select_all, size: 20, color: const Color(0xFF1DB954)),
                  label: Text(
                    allSelected ? 'Deselect All' : 'Select All',
                    style: const TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  onPressed: () async {
                    final selectedSongs = matchingSongs.where((s) => _selectedSongIds.contains(s.id)).toList();
                    final deleted = await showPermanentDeleteConfirmDialog(context, ref, selectedSongs);
                    if (deleted) {
                      _exitSelectionMode();
                    }
                  },
                ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              title: TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search songs, artists, albums...',
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
      body: matchingSongs.isEmpty
          ? Center(
              child: Text(
                query.isEmpty ? 'Type to search your local library' : 'No results found for "$query"',
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: matchingSongs.length,
              itemBuilder: (context, index) {
                final song = matchingSongs[index];
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
                      ref.read(playerProvider.notifier).playQueue(matchingSongs, initialIndex: index);
                    }
                  },
                  onMoreTap: () => showSongOptionsMenu(context, ref, song),
                );
              },
            ),
    );
  }
}
