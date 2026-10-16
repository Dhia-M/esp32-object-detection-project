import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/video_provider.dart';
import '../providers/clips_provider.dart';

/// Settings screen for configuring app preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _urlController.text = appState.baseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveBaseUrl() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL cannot be empty')),
      );
      return;
    }

    // Validate URL format
    try {
      Uri.parse(newUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL format')),
      );
      return;
    }

    await context.read<AppStateProvider>().updateBaseUrl(newUrl);
    setState(() {
      _isEditing = false;
    });

    // Auto-reconnect the stream with the new URL
    context.read<VideoProvider>().initializeStream();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Base URL updated. Reconnecting stream...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Server Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _urlController,
                        readOnly: !_isEditing,
                        decoration: InputDecoration(
                          labelText: 'Base URL',
                          hintText: 'http://100.x.x.x',
                          border: const OutlineInputBorder(),
                          suffixIcon: _isEditing
                              ? IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: _saveBaseUrl,
                                )
                              : IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  },
                                ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current: ${appState.baseUrl}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Reconnect Stream'),
                        subtitle: const Text('Reinitialize the live video stream'),
                        onTap: () {
                          context.read<VideoProvider>().initializeStream();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reconnecting...')),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Refresh Clips'),
                        subtitle: const Text('Reload the clips list'),
                        onTap: () {
                          context.read<ClipsProvider>().refreshClips();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refreshing clips...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ListTile(
                        title: Text('Version'),
                        subtitle: Text('1.0.0'),
                      ),
                      ListTile(
                        title: const Text('App Name'),
                        subtitle: const Text('AI Camera Client'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

