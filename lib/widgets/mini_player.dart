import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/player_provider.dart';
import '../screens/player/player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final notifier = ref.read(playerProvider.notifier);
    final currentSong = playerState.currentSong;

    if (currentSong == null) return const SizedBox.shrink();

    final songId = int.tryParse(currentSong.id) ?? 0;
    final progress = playerState.duration.inMilliseconds > 0
        ? playerState.position.inMilliseconds / playerState.duration.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlayerScreen()),
        );
      },
      child: Container(
        height: 64,
        color: const Color(0xFF282828),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              color: const Color(0xFF1DB954),
              minHeight: 2,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: currentSong.isDownloaded || songId == 0
                          ? Container(
                              width: 44,
                              height: 44,
                              color: const Color(0xFF1DB954).withValues(alpha: 0.2),
                              child: const Icon(Icons.music_note, color: Color(0xFF1DB954), size: 24),
                            )
                          : QueryArtworkWidget(
                              id: songId,
                              type: ArtworkType.AUDIO,
                              artworkWidth: 44,
                              artworkHeight: 44,
                              nullArtworkWidget: Container(
                                width: 44,
                                height: 44,
                                color: Colors.grey[800],
                                child: const Icon(Icons.music_note, color: Colors.white54),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            currentSong.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: notifier.togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: notifier.playNext,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
