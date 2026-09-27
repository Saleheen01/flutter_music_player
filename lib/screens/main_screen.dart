import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'songs/songs_screen.dart';
import 'albums/albums_screen.dart';
import 'artists/artists_screen.dart';
import 'playlists/playlists_screen.dart';
import 'import/import_download_screen.dart';
import 'settings/settings_screen.dart';
import '../widgets/mini_player.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _libraryTabController;

  @override
  void initState() {
    super.initState();
    _libraryTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _libraryTabController.dispose();
    super.dispose();
  }

  Widget _buildLibraryTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _libraryTabController,
          indicatorColor: const Color(0xFF1DB954),
          labelColor: const Color(0xFF1DB954),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Albums'),
            Tab(text: 'Artists'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _libraryTabController,
        children: const [
          SongsScreen(),
          AlbumsScreen(),
          ArtistsScreen(),
          PlaylistsScreen(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      _buildLibraryTab(),
      const ImportDownloadScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: screens[_currentIndex]),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Import',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}