import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_tab.dart';
import 'manage_devices_tab.dart';
import 'settings_tab.dart';
import 'alerts_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // ✅ Listen for FCM messages (when app is in foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = message.data;

      print("📩 FCM Message received in Dashboard: $data");

      if (data['type'] == 'alert' && data['userId'] == widget.userId) {
        // ✅ Insert into Supabase alerts table
        await Supabase.instance.client.from('alerts').insert({
          'user_id': widget.userId,
          'message': data['message'] ?? 'Alert from FCM',
        });

        // ✅ Show dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("🚨 Alert"),
              content: Text(data['message'] ?? "New alert received."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeTab(userId: widget.userId),
      ManageDevicesTab(userId: widget.userId),
      SettingsTab(userId: widget.userId),
      AlertsScreen(userId: widget.userId), // ✅ passed userId for filtering alerts
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_other),
            label: "Manage",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
            label: "Alerts",
          ),
        ],
      ),
    );
  }
}
