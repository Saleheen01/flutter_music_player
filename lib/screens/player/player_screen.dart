import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../providers/player_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  String? _overlayText;
  Timer? _overlayTimer;

  void _showOverlay(String text) {
    _overlayTimer?.cancel();
    setState(() {
      _overlayText = text;
    });
    _overlayTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _overlayText = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final notifier = ref.read(playerProvider.notifier);
    final currentSong = playerState.currentSong;

    if (currentSong == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text('No song currently playing', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final songId = int.tryParse(currentSong.id) ?? 0;
    final maxDurationMs = playerState.duration.inMilliseconds > 0
        ? playerState.duration.inMilliseconds.toDouble()
        : 1.0;
    final currentPosMs = playerState.position.inMilliseconds.toDouble().clamp(0.0, maxDurationMs);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'PLAYING FROM LIBRARY',
              style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              currentSong.album,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                children: [
                  const Spacer(),
                  // Album Artwork
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: currentSong.isDownloaded || songId == 0
                            ? Container(
                                color: const Color(0xFF1DB954).withValues(alpha: 0.2),
                                child: const Icon(Icons.music_note, size: 120, color: Color(0xFF1DB954)),
                              )
                            : QueryArtworkWidget(
                                id: songId,
                                type: ArtworkType.AUDIO,
                                artworkWidth: double.infinity,
                                artworkHeight: double.infinity,
                                nullArtworkWidget: Container(
                                  color: Colors.grey[850],
                                  child: const Icon(Icons.music_note, size: 120, color: Colors.white54),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Song Info
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentSong.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF1DB954),
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: currentPosMs,
                      min: 0.0,
                      max: maxDurationMs,
                      onChanged: (value) {
                        notifier.seek(Duration(milliseconds: value.round()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(playerState.position), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        Text(_formatDuration(playerState.duration), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Main Controls Row: Rewind 10s -> Previous -> Play/Pause -> Next -> Fast Forward 10s
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Rewind 10s
                      IconButton(
                        iconSize: 36,
                        tooltip: 'Rewind 10 seconds',
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed: () {
                          notifier.rewind10Seconds();
                          _showOverlay('−10s');
                        },
                      ),
                      // Previous
                      IconButton(
                        iconSize: 42,
                        tooltip: 'Previous song',
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        onPressed: notifier.playPrevious,
                      ),
                      // Play / Pause
                      IconButton(
                        iconSize: 68,
                        tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                        icon: Icon(
                          playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: const Color(0xFF1DB954),
                        ),
                        onPressed: notifier.togglePlayPause,
                      ),
                      // Next
                      IconButton(
                        iconSize: 42,
                        tooltip: 'Next song',
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        onPressed: notifier.playNext,
                      ),
                      // Fast Forward 10s
                      IconButton(
                        iconSize: 36,
                        tooltip: 'Fast Forward 10 seconds',
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        onPressed: () {
                          notifier.fastForward10Seconds();
                          _showOverlay('+10s');
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // Brief Feedback Overlay (-10s / +10s)
          if (_overlayText != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _overlayText!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1DB954),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
