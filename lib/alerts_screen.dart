import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key, required String userId}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return const Center(child: Text("No alerts logged yet"));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final message = alert['message'] ?? 'No message';
              final createdAtRaw = alert['created_at'];
              final timestamp = createdAtRaw != null
                  ? DateTime.parse(createdAtRaw).toLocal().toString()
                  : 'Unknown time';

              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(message),
                subtitle: Text(timestamp),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAlerts() async {
    final List<dynamic> data = await supabase
        .from('alerts')
        .select()
        .order('created_at', ascending: false);

    return data.cast<Map<String, dynamic>>();
  }
}
