import 'package:flutter/material.dart';
class GuidelineTab extends StatelessWidget {
  final List<String> guidelines = [
    "1. Sign up and log in securely.",
    "2. Connect only to strong signal devices.",
    "3. Manage devices via Manage Devices tab.",
    "4. Follow settings and stay updated.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guidelines")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: guidelines.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(guidelines[index]),
          ),
        ),
      ),
    );
  }
}