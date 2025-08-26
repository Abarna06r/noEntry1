import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme_provider.dart';

class SettingsTab extends StatefulWidget {
  final String userId;
  const SettingsTab({super.key, required this.userId});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isDarkMode = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    final response = await supabase
        .from('user_settings')
        .select()
        .eq('user_id', widget.userId)
        .maybeSingle();
    if (response != null) {
      setState(() {
        _isDarkMode = response['dark_mode'] ?? false;
        ThemeProvider.themeNotifier.value =
        _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    ThemeProvider.themeNotifier.value =
    value ? ThemeMode.dark : ThemeMode.light;

    await supabase.from('user_settings').update({'dark_mode': value}).eq('user_id', widget.userId);
  }

  void _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _confirmLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { Navigator.pop(context); _logout(); }, child: const Text("Logout")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
            secondary: const Icon(Icons.brightness_6),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout"),
            onTap: _confirmLogoutDialog,
          ),
        ],
      ),
    );
  }
}



