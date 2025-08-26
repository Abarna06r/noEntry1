import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageDevicesTab extends StatefulWidget {
  final String userId;
  const ManageDevicesTab({super.key, required this.userId});

  @override
  State<ManageDevicesTab> createState() => _ManageDevicesTabState();
}

class _ManageDevicesTabState extends State<ManageDevicesTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> devices = [];

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    final response = await supabase.from('devices').select();
    setState(() {
      devices = List<Map<String, dynamic>>.from(response as List);
    });
  }

  void _toggleDevice(String deviceId, bool newStatus) async {
    await supabase.from('devices').update({'status': newStatus}).eq('id', deviceId);
    _fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Devices")),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return SwitchListTile(
            title: Text(device['name']),
            value: device['status'] ?? false,
            onChanged: (val) => _toggleDevice(device['id'].toString(), val),
          );
        },
      ),
    );
  }
}
