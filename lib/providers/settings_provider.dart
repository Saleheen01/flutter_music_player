import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String audioQuality;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.audioQuality = '320 kbps',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? audioQuality,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      audioQuality: audioQuality ?? this.audioQuality,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _themeKey = 'pref_theme_mode';
  static const _qualityKey = 'pref_audio_quality';

  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 2;
    final quality = prefs.getString(_qualityKey) ?? '320 kbps';

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      audioQuality: quality,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setAudioQuality(String quality) async {
    state = state.copyWith(audioQuality: quality);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_qualityKey, quality);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});