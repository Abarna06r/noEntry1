import 'package:flutter/material.dart';

class DeviceConnectPage extends StatefulWidget {
  final String deviceName;
  final String userId;
  const DeviceConnectPage({super.key, required this.deviceName, required this.userId});

  @override
  State<DeviceConnectPage> createState() => _DeviceConnectPageState();
}

class _DeviceConnectPageState extends State<DeviceConnectPage> {
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isConnecting = false;

  void _connectToDevice() async {
    final deviceId = _deviceIdController.text.trim();
    final password = _passwordController.text.trim();
    if (deviceId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter ID & Password")));
      return;
    }

    setState(() => _isConnecting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (deviceId == "12345" && password == "admin") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Connected to ${widget.deviceName} ✅")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid ID or Password ❌")));
    }

    setState(() => _isConnecting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connect to ${widget.deviceName}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(labelText: "Device ID"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isConnecting
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _connectToDevice,
              child: const Text("Connect"),
            ),
          ],
        ),
      ),
    );
  }
}

