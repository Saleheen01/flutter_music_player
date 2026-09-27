import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import 'developer_identity_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Appearance', style: TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(settings.themeMode.name.toUpperCase()),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              dropdownColor: const Color(0xFF1E1E1E),
              items: const [
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              ],
              onChanged: (mode) {
                if (mode != null) notifier.setThemeMode(mode);
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('About', style: TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF1DB954)),
            title: const Text('Developer Identity'),
            subtitle: const Text('MD. Saleheen Ferdous'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeveloperIdentityScreen()),
              );
            },
          ),
          const ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0+1'),
          ),
        ],
      ),
    );
  }
}
