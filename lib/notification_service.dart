import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alert_logger.dart'; // ✅ Your Supabase logger class

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _alertActive = false; // ✅ Prevents duplicates
  static Timer? _timer;
  static String? _userId;

  // ✅ Call this after login/signup
  static void setUserId(String userId) {
    _userId = userId;
  }

  // ✅ Initialize local notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.actionId == 'DISMISS') {
          cancelAlerts();
        }
      },
    );
  }

  // ✅ Show fullscreen alert and log it
  static Future<void> _showFullScreenAlert(int id) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'door_alert_channel',
      'Door Alerts',
      channelDescription: 'Alerts when door sensor is triggered',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      actions: [
        AndroidNotificationAction(
          'DISMISS',
          'Dismiss',
          cancelNotification: true,
        ),
      ],
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    final message = "🚨 Door Alert - Sensor triggered! (Alert #$id)";

    await _notificationsPlugin.show(
      id, // notification ID
      "🚨 Door Alert",
      "Sensor was triggered! (Alert #$id)",
      details,
    );

    // ✅ Log to Supabase if userId is set
    if (_userId != null) {
      await AlertLogger.logAlert(_userId!, message);
    } else {
      print("⚠️ No userId set. Skipping alert log.");
    }
  }

  // ✅ Start repeating alerts every 1 min (3 times)
  static void startRepeatingAlerts({required message}) {
    if (_alertActive) return; // Already active

    _alertActive = true;
    int count = 0;

    _showFullScreenAlert(count); // First alert now

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      count++;
      if (count >= 3) {
        cancelAlerts();
      } else {
        _showFullScreenAlert(count);
      }
    });
  }

  // ✅ Cancel all notifications and timer
  static void cancelAlerts() {
    _timer?.cancel();
    _notificationsPlugin.cancelAll();
    _alertActive = false;
  }
}
