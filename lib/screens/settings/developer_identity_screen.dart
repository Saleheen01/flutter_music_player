import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/developer_info.dart';

class DeveloperIdentityScreen extends StatelessWidget {
  final DeveloperInfo info;

  const DeveloperIdentityScreen({
    super.key,
    this.info = const DeveloperInfo(),
  });

  Future<void> _launch(BuildContext context, String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open this link.')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : theme.cardColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Identity', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: const Color(0xFF1DB954).withValues(alpha: 0.2),
                    child: const Icon(Icons.person, size: 52, color: Color(0xFF1DB954)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    info.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.role,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.email_outlined, color: Color(0xFF1DB954)),
                title: const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    info.email,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => _launch(context, 'mailto:${info.email}'),
              ),
            ),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.code, color: Color(0xFF1DB954)),
                title: const Text('GitHub', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    info.githubDisplay,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => _launch(context, info.githubUrl),
              ),
            ),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.public, color: Color(0xFF1DB954)),
                title: const Text('Facebook', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    info.facebookDisplay,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => _launch(context, info.facebookUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
