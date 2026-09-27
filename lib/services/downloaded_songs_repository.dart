import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../models/download_task.dart';

class DownloadedSongsRepository {
  static const String _songsKey = 'downloaded_songs_list_v1';
  static const String _tasksKey = 'download_tasks_list_v1';

  Future<List<Song>> getDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_songsKey) ?? [];
    final List<Song> songs = [];
    for (final jsonStr in jsonList) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        songs.add(Song.fromJson(map));
      } catch (_) {}
    }
    return songs;
  }

  Future<void> saveSong(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await getDownloadedSongs();
    songs.removeWhere((s) => s.id == song.id || s.path == song.path);
    songs.insert(0, song);
    final jsonList = songs.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList(_songsKey, jsonList);
  }

  Future<void> deleteSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await getDownloadedSongs();
    songs.removeWhere((s) => s.id == songId);
    final jsonList = songs.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList(_songsKey, jsonList);
  }

  Future<List<DownloadTask>> getDownloadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_tasksKey) ?? [];
    final List<DownloadTask> tasks = [];
    for (final jsonStr in jsonList) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        tasks.add(DownloadTask.fromJson(map));
      } catch (_) {}
    }
    return tasks;
  }

  Future<void> saveDownloadTasks(List<DownloadTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => json.encode(t.toJson())).toList();
    await prefs.setStringList(_tasksKey, jsonList);
  }
}
