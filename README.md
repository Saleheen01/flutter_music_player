# Flutter Music Player 🎵

A feature-rich, modern offline and online music player app built with Flutter, Android platform APIs, Riverpod state management, and Material 3 design.

---

## 👨‍💻 Developer Information

- **Developer:** MD. Saleheen Ferdous
- **Email:** [saleheen.cp@gmail.com](mailto:saleheen.cp@gmail.com)
- **GitHub:** [github.com/Saleheen01](https://github.com/Saleheen01)

---

## ✨ Features

### 🎧 1. Audio Playback System
- **Local Audio Scanning:** Scans and indexes local music files on the Android device via MediaStore.
- **Background Playback & Lock Screen Controls:** Playback controls through `just_audio_background`.
- **Fast Forward & Rewind (10s):** Dedicated 10-second skip controls with visual overlay indicators.
- **Full Player Screen:** Expandable Now Playing screen with album artwork, real-time seek bar, and playback queue navigation.
- **Mini Player:** Persistent bottom mini player widget across screens.

### 📥 2. URL-Based Audio Import
- **URL Import:** Accepts supported video/audio URLs and extracts audio metadata.
- **Background Transfers:** Streams audio data with progress tracking.
- **Library Integration:** Imported tracks are registered in the local music library for offline playback.

**Platform and rights notice:** URL-based extraction may be restricted by the source platform's terms of service. Use this feature only where you have the right and authorization to download or import the content, and comply with the applicable platform terms. The project does not imply affiliation with or endorsement by YouTube.

### 🗑️ 3. Multi-Select Audio Deletion & File Management
- **Multi-Selection Mode:** Long-press a song to enter selection mode with checkboxes and a live selection counter.
- **Select All / Deselect All:** Toggle selection across displayed songs or search results.
- **Device Deletion:** Deletes selected audio files from device storage while cleaning up related queue, playlist, favorite, and history references.
- **Remove from Library vs. Delete:** Hide a song from the app without deleting the physical file, or permanently delete it.

### 📚 4. Library & Playlist Management
- **Organized Views:** Filter by Songs, Albums, Artists, and Playlists.
- **Favorites & Recently Played:** Favorite songs and track playback history.
- **Custom Playlists:** Create, edit, reorder, and manage playlists.
- **Instant Search:** Search songs, artists, and album titles.

### ⚙️ 5. Settings & Customization
- **Theme Modes:** Dark, Light, and System Theme modes.
- **Developer Identity Screen:** Dedicated screen with links to developer contact and GitHub.

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** Flutter (Dart SDK >= 3.0.0 < 4.0.0)
- **State Management:** `flutter_riverpod`
- **Audio Playback:** `just_audio`, `just_audio_background`
- **URL Extraction:** `youtube_explode_dart`
- **Device Audio Query:** `on_audio_query`
- **Permissions:** `permission_handler`
- **Networking:** `dio`
- **External Links:** `url_launcher`
- **Local Storage:** `shared_preferences`, `path_provider`

---

## 🚀 Getting Started & Building

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio / Android SDK](https://developer.android.com/studio) (JDK 17+)

### Run the App
```bash
flutter pub get
flutter run
```

### Build APK
```bash
flutter build apk --release
```

The output APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License

This project is open-source and available for educational and personal use.
