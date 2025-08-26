import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeTab extends StatefulWidget {
  final String userId;
  const HomeTab({super.key, required this.userId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isScanning = false;
  List<WiFiAccessPoint> _availableDevices = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    try {
      await Permission.nearbyWifiDevices.request();
    } catch (_) {}
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _availableDevices = [];
    });

    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot scan Wi-Fi: $canScan')));
      setState(() => _isScanning = false);
      return;
    }

    await WiFiScan.instance.startScan();
    await Future.delayed(const Duration(seconds: 2));

    final results = await WiFiScan.instance.getScannedResults();
    setState(() {
      _availableDevices = results
          .where((ap) => ap.ssid.isNotEmpty && ap.level > -70)
          .toList()
        ..sort((a, b) => b.level.compareTo(a.level));
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(String ssid) async {
    String deviceId = '';
    String password = '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Connect to $ssid"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Device ID"),
              onChanged: (val) => deviceId = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
              onChanged: (val) => password = val,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _connectWifi(ssid, deviceId, password);
              },
              child: const Text("Connect")),
        ],
      ),
    );
  }

  Future<void> _connectWifi(String ssid, String deviceId, String password) async {
    try {
      bool wifiEnabled = await WiFiForIoTPlugin.isEnabled();
      if (!wifiEnabled) await WiFiForIoTPlugin.setEnabled(true);

      // Connect using wifi_iot
      bool connected = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        joinOnce: true,
        security: NetworkSecurity.WPA,
        withInternet: true,
      );

      if (connected) {
        // Save connected device in Supabase
        await Supabase.instance.client.from('devices').upsert({
          'id': deviceId,
          'name': ssid,
          'status': true,
          'user_id': widget.userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Connected to $ssid ✅")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to connect to $ssid ❌")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _scanDevices,
              icon: const Icon(Icons.wifi_find),
              label: const Text("Scan Nearby Devices"),
            ),
            const SizedBox(height: 20),
            if (_isScanning)
              const CircularProgressIndicator()
            else if (_availableDevices.isEmpty)
              const Text("No nearby devices found")
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _availableDevices.length,
                  itemBuilder: (context, index) {
                    final ap = _availableDevices[index];
                    return ListTile(
                      leading: const Icon(Icons.device_hub),
                      title: Text(ap.ssid),
                      subtitle: Text("Signal: ${ap.level} dBm"),
                      onTap: () => _connectToDevice(ap.ssid),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
