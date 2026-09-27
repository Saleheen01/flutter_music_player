import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';

class PlaylistRepository {
  static const String _playlistsKey = 'user_playlists_v1';
  static const String _favoritesKey = 'user_favorites_v1';
  static const String _historyKey = 'user_play_history_v1';

  Future<List<Playlist>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_playlistsKey);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> list = jsonDecode(raw);
    return list.map((item) => Playlist.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> raw = playlists.map((p) => p.toMap()).toList();
    await prefs.setString(_playlistsKey, jsonEncode(raw));
  }

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favs = prefs.getStringList(_favoritesKey);
    return favs?.toSet() ?? {};
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  Future<List<String>> loadPlayHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> savePlayHistory(List<String> historyIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, historyIds);
  }
}