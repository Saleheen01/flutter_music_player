enum DownloadStatus { pending, downloading, paused, completed, failed }

class DownloadTask {
  final String id;
  final String videoId;
  final String title;
  final String artist;
  final String url;
  final double progress;
  final DownloadStatus status;
  final String? localFilePath;
  final String? errorMessage;

  const DownloadTask({
    required this.id,
    this.videoId = '',
    required this.title,
    required this.artist,
    required this.url,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.localFilePath,
    this.errorMessage,
  });

  DownloadTask copyWith({
    String? id,
    String? videoId,
    String? title,
    String? artist,
    String? url,
    double? progress,
    DownloadStatus? status,
    String? localFilePath,
    String? errorMessage,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      url: url ?? this.url,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      localFilePath: localFilePath ?? this.localFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'videoId': videoId,
        'title': title,
        'artist': artist,
        'url': url,
        'progress': progress,
        'status': status.index,
        'localFilePath': localFilePath,
        'errorMessage': errorMessage,
      };

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] ?? '',
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? 'Unknown',
      artist: json['artist'] ?? 'Unknown',
      url: json['url'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 1.0,
      status: DownloadStatus.values[(json['status'] as int?) ?? DownloadStatus.completed.index],
      localFilePath: json['localFilePath'],
      errorMessage: json['errorMessage'],
    );
  }
}
