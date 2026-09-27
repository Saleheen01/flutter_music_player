class Playlist {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'song_ids': songIds.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    final songIdsRaw = map['song_ids'] as String? ?? '';
    return Playlist(
      id: map['id'],
      name: map['name'],
      songIds: songIdsRaw.isEmpty ? [] : songIdsRaw.split(','),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}