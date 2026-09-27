import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMoreTap;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectionChanged;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onLongPress,
    this.onMoreTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final songId = int.tryParse(song.id) ?? 0;

    return ListTile(
      onTap: isSelectionMode ? () => onSelectionChanged?.call(!isSelected) : onTap,
      onLongPress: onLongPress,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelectionMode)
            Checkbox(
              value: isSelected,
              activeColor: const Color(0xFF1DB954),
              onChanged: onSelectionChanged,
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: song.isDownloaded || songId == 0
                ? Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFF1DB954).withValues(alpha: 0.2),
                    child: const Icon(Icons.download_done_rounded, color: Color(0xFF1DB954), size: 28),
                  )
                : QueryArtworkWidget(
                    id: songId,
                    type: ArtworkType.AUDIO,
                    artworkWidth: 48,
                    artworkHeight: 48,
                    nullArtworkWidget: Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[850],
                      child: const Icon(Icons.music_note, color: Colors.white54),
                    ),
                  ),
          ),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? const Color(0xFF1DB954) : null,
        ),
      ),
      subtitle: Row(
        children: [
          if (song.isDownloaded) ...[
            const Icon(Icons.check_circle, size: 12, color: Color(0xFF1DB954)),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              '${song.artist} • ${song.album}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
      trailing: isSelectionMode
          ? null
          : IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: onMoreTap,
            ),
    );
  }
}
