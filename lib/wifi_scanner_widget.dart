import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiScannerWidget extends StatefulWidget {
  const WifiScannerWidget({Key? key}) : super(key: key);

  @override
  State<WifiScannerWidget> createState() => _WifiScannerWidgetState();
}

class _WifiScannerWidgetState extends State<WifiScannerWidget> {
  List<WiFiAccessPoint> accessPoints = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    setState(() => isScanning = true);

    var locationStatus = await Permission.location.request();
    var nearbyStatus = await Permission.nearbyWifiDevices.request();

    if (locationStatus.isGranted || nearbyStatus.isGranted) {
      await WiFiScan.instance.startScan();
      await Future.delayed(const Duration(seconds: 2)); // simulate scan time
      final results = await WiFiScan.instance.getScannedResults();

      setState(() {
        accessPoints = results.where((ap) => ap.ssid.isNotEmpty).toList();
        isScanning = false;
      });
    } else {
      setState(() => isScanning = false);
      print("❌ Permissions not granted.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied. Cannot scan Wi-Fi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "📶 Available Wi-Fi Networks",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        isScanning
            ? const Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        )
            : accessPoints.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(20),
          child: Text("No Wi-Fi networks found."),
        )
            : Expanded(
          child: ListView.builder(
            itemCount: accessPoints.length,
            itemBuilder: (context, index) {
              final ap = accessPoints[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.wifi),
                  title: Text(ap.ssid),
                  subtitle: Text("Signal: ${ap.level} dBm"),
                  trailing: Text("BSSID: ${ap.bssid}"),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        ElevatedButton.icon(
          onPressed: isScanning ? null : _checkPermissionsAndScan,
          icon: const Icon(Icons.wifi_find),
          label: const Text("Rescan"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}
