import 'package:supabase_flutter/supabase_flutter.dart';

class AlertLogger {
  static final _supabase = Supabase.instance.client;

  // Save alert
  static Future<void> logAlert(String userId, String message) async {
    try {
      await _supabase.from('alerts').insert({
        'user_id': userId,
        'message': message,
        'created_at': DateTime.now().toIso8601String(), // ✅ ensures timestamp
      });
      print("✅ Alert logged for $userId: $message");
    } catch (e) {
      print("❌ Error logging alert: $e");
    }
  }

  // Fetch history
  static Future<List<Map<String, dynamic>>> fetchAlerts(String userId) async {
    final response = await _supabase
        .from('alerts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
