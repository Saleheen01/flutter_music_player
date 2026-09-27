import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/download_task.dart';
import '../../providers/download_provider.dart';

class ImportDownloadScreen extends ConsumerStatefulWidget {
  const ImportDownloadScreen({super.key});

  @override
  ConsumerState<ImportDownloadScreen> createState() => _ImportDownloadScreenState();
}

class _ImportDownloadScreenState extends ConsumerState<ImportDownloadScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _startDownload([String? presetUrl]) {
    final input = presetUrl ?? _urlController.text.trim();
    if (input.isNotEmpty) {
      ref.read(downloadProvider.notifier).enqueueDownload(input);
      if (presetUrl == null) _urlController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio download started...'),
          backgroundColor: Color(0xFF1DB954),
        ),
      );
    }
  }

  Widget _buildStatusBadge(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.pending:
        return const Chip(
          label: Text('Pending', style: TextStyle(fontSize: 11, color: Colors.orangeAccent)),
          backgroundColor: Colors.black45,
        );
      case DownloadStatus.downloading:
        return const Chip(
          label: Text('Downloading...', style: TextStyle(fontSize: 11, color: Colors.lightBlueAccent)),
          backgroundColor: Colors.black45,
        );
      case DownloadStatus.completed:
        return const Chip(
          label: Text('Completed', style: TextStyle(fontSize: 11, color: Color(0xFF1DB954))),
          backgroundColor: Colors.black45,
        );
      case DownloadStatus.failed:
        return const Chip(
          label: Text('Failed', style: TextStyle(fontSize: 11, color: Colors.redAccent)),
          backgroundColor: Colors.black45,
        );
      case DownloadStatus.paused:
        return const Chip(
          label: Text('Paused', style: TextStyle(fontSize: 11, color: Colors.grey)),
          backgroundColor: Colors.black45,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloads = ref.watch(downloadProvider);
    final notifier = ref.read(downloadProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Downloader', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Clear finished downloads',
            icon: const Icon(Icons.cleaning_services),
            onPressed: () => notifier.clearCompleted(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Download Audio from Online',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Paste an audio link or video search query below:',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'https://www.audio..../watch?v=... or song name',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.link, color: Color(0xFF1DB954)),
                        filled: true,
                        fillColor: const Color(0xFF121212),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _startDownload(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _startDownload,
                        icon: const Icon(Icons.download, color: Colors.black),
                        label: const Text('Download Music', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Downloads & Saved Tracks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${downloads.length} tracks', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: downloads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_download_outlined, size: 64, color: Colors.grey[700]),
                          const SizedBox(height: 12),
                          const Text('No downloaded music yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('Downloaded tracks will appear here and in your Library', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: downloads.length,
                      itemBuilder: (context, index) {
                        final task = downloads[index];
                        final isCompleted = task.status == DownloadStatus.completed;
                        final isDownloading = task.status == DownloadStatus.downloading;

                        return Card(
                          color: const Color(0xFF1E1E1E),
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isCompleted ? const Color(0xFF1DB954).withValues(alpha: 0.2) : Colors.grey[850],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isCompleted ? Icons.music_note : Icons.play_circle_fill_outlined,
                                        color: isCompleted ? const Color(0xFF1DB954) : Colors.white54,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            task.artist,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusBadge(task.status),
                                  ],
                                ),
                                if (isDownloading) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: task.progress.clamp(0.0, 1.0),
                                          backgroundColor: Colors.grey[800],
                                          color: const Color(0xFF1DB954),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(task.progress * 100).toStringAsFixed(0)}%',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF1DB954)),
                                      ),
                                    ],
                                  ),
                                ],
                                if (task.errorMessage != null && task.status == DownloadStatus.failed) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error: ${task.errorMessage}',
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isCompleted) ...[
                                      ElevatedButton.icon(
                                        onPressed: () => notifier.playTask(task),
                                        icon: const Icon(Icons.play_arrow, size: 18, color: Colors.black),
                                        label: const Text('Play Now', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1DB954),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      tooltip: 'Delete track',
                                      onPressed: () => notifier.deleteTask(task.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
