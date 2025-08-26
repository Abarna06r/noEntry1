import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiPage extends StatefulWidget {
  const WifiPage({Key? key}) : super(key: key);

  @override
  State<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  List<WifiNetwork> _wifiList = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    setState(() => _loading = true);

    // Request location permission (needed for Wi-Fi scan)
    var status = await Permission.location.request();
    if (status.isGranted) {
      _scanWifi();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required for Wi-Fi scanning.')),
      );
    }
  }

  Future<void> _scanWifi() async {
    try {
      List<WifiNetwork>? networks = await WiFiForIoTPlugin.loadWifiList();
      if (networks != null) {
        // Filter: show only strong signals (-60 dBm or better)
        networks = networks.where((n) => n.level != null && n.level! > -60).toList();
      }
      setState(() {
        _wifiList = networks ?? [];
        _loading = false;
      });
    } catch (e) {
      debugPrint("Wi-Fi scan error: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _connectToWifi(String ssid) async {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect to $ssid'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            hintText: 'Enter Wi-Fi Password',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              bool? connected = await WiFiForIoTPlugin.connect(
                ssid,
                password: passwordController.text,
                joinOnce: true,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    connected == true
                        ? 'Connected to $ssid'
                        : 'Failed to connect to $ssid',
                  ),
                ),
              );
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Networks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _scanWifi,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _wifiList.isEmpty
          ? const Center(child: Text('No strong Wi-Fi networks found.'))
          : ListView.builder(
        itemCount: _wifiList.length,
        itemBuilder: (context, index) {
          final wifi = _wifiList[index];
          return ListTile(
            leading: const Icon(Icons.wifi),
            title: Text(wifi.ssid ?? "Unknown"),
            subtitle: Text("Signal: ${wifi.level ?? 'N/A'} dBm"),
            onTap: () => _connectToWifi(wifi.ssid ?? ""),
          );
        },
      ),
    );
  }
}
