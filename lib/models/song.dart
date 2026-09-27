class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final int duration;
  final int? dateAdded;
  final bool isDownloaded;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
    this.dateAdded,
    this.isDownloaded = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'path': path,
        'duration': duration,
        'dateAdded': dateAdded,
        'isDownloaded': isDownloaded,
      };

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'] ?? 'Downloaded',
      path: json['path'] ?? '',
      duration: json['duration'] ?? 0,
      dateAdded: json['dateAdded'],
      isDownloaded: json['isDownloaded'] ?? true,
    );
  }

  factory Song.fromAudioQuery(Map<String, dynamic> map) {
    return Song(
      id: map['_id'].toString(),
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Unknown Album',
      path: map['_data'] ?? '',
      duration: map['duration'] ?? 0,
      dateAdded: map['date_added'],
      isDownloaded: false,
    );
  }
}
