# Flutter Music Player 🎵

A feature-rich, modern offline and online music player app built with Flutter, Jetpack/Android standards, Riverpod state management, and Material 3 design.

---

## 👨‍💻 Developer Information

- **Developer:** MD. Saleheen Ferdous
- **Email:** [saleheen.cp@gmail.com](mailto:saleheen.cp@gmail.com)
- **GitHub:** [github.com/Saleheen01](https://github.com/Saleheen01)
- **Facebook:** [facebook.com/saleheen.ferdous.2025](https://www.facebook.com/saleheen.ferdous.2025/)

---

## ✨ Features

### 🎧 1. Complete Audio Playback System
- **Local Audio Scanning:** Scans and indexes local music files on the Android device via MediaStore.
- **Background Playback & Lock Screen Controls:** Full lock-screen and notification controls using `just_audio_background`.
- **Fast Forward & Rewind (10s):** Dedicated 10-second fast forward (`forward_10`) and 10-second rewind (`replay_10`) buttons with visual overlay indicators.
- **Full Player Screen:** Expandable Now Playing screen with album artwork, real-time seek bar, and playback queue navigation.
- **Mini Player:** Persistent bottom mini player widget across all screens.

### 📥 2. YouTube & Online Audio Downloader
- **YouTube Audio Extractor:** Download high-quality audio directly by pasting YouTube links (`youtube.com`, `youtu.be`, `music.youtube.com`, `shorts`) or typing video search queries.
- **Chunked Stream Downloading:** Byte-by-byte background audio downloading with progress percentage tracking.
- **Integrated Library Sync:** Downloaded tracks automatically register into your music library, allowing offline playback everywhere in the app.

### 🗑️ 3. Multi-Select Audio Deletion & File Management
- **Multi-Selection Mode:** Long-press any song to enter selection mode with checkboxes and live selection counter.
- **Select All / Deselect All:** Easily toggle selection across all displayed songs or search results.
- **Permanent Device Deletion:** Physically deletes selected audio files from the Android device storage while safely cleaning up queue, playlists, favorites, and play history.
- **Remove from Library vs. Delete Permanently:** Option to hide a song from the app without deleting the physical file, or permanently erase the file from device storage.

### 📚 4. Library & Playlist Management
- **Organized Views:** Filter by Songs, Albums, Artists, and Playlists.
- **Favorites & Recently Played:** Easily favorite songs and track playback history.
- **Custom Playlists:** Create, edit, reorder, and manage custom playlists.
- **Instant Search:** Dynamic search across songs, artists, and album titles.

### ⚙️ 5. Settings & Customization
- **Theme Modes:** Supports Dark, Light, and System Theme modes.
- **Developer Identity Screen:** Dedicated screen featuring developer credentials and interactive links to Email, GitHub, and Facebook.

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** Flutter (Dart SDK >= 3.0.0 < 4.0.0)
- **State Management:** `flutter_riverpod`
- **Audio Playback:** `just_audio`, `just_audio_background`
- **YouTube Extraction:** `youtube_explode_dart`
- **Device Audio Query:** `on_audio_query`
- **Permissions:** `permission_handler`
- **Networking:** `dio`
- **External Links:** `url_launcher`
- **Local Storage:** `shared_preferences`, `path_provider`

---

## 🚀 Getting Started & Building

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.27+ / 3.47+)
- [Android Studio / Android SDK](https://developer.android.com/studio) (JDK 17+)

### Run the App
```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

### Build APK
```bash
# Build Release APK
flutter build apk --release
```
The output APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License

This project is open-source and available for educational and personal use.
