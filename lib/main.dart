import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme_provider.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'firebase_options.dart';
import 'otp_verify_screen.dart';

// ✅ Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: "https://nljgdlanlswevzfszpoy.supabase.co",
    anonKey:
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5samdkbGFubHN3ZXZ6ZnN6cG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MDkzMjgsImV4cCI6MjA3MTA4NTMyOH0.f3dCGxK7jyTH_BnYmuMOWah275zhVfgUeJHTUwYGq44",
  );

  // ✅ Ask for notification permission (iOS + Android 13+)
  await FirebaseMessaging.instance.requestPermission();

  runApp(
    TokenInitializer(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Smart Door Security',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/dashboard': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args == null || args is! String) {
                return const DashboardScreen(userId: "test-user-123");
              }
              return DashboardScreen(userId: args);
            },
          },
        );
      },
    );
  }
}

class TokenInitializer extends StatefulWidget {
  final Widget child;
  const TokenInitializer({super.key, required this.child});

  @override
  State<TokenInitializer> createState() => _TokenInitializerState();
}

class _TokenInitializerState extends State<TokenInitializer> {
  @override
  void initState() {
    super.initState();
    _getAndStoreToken();
  }

  Future<void> _getAndStoreToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // ✅ Get token
      String? token = await messaging.getToken();
      print("🔑 Device FCM Token: $token");

      if (token != null) {
        // ✅ Insert into Supabase
        final supabase = Supabase.instance.client;

        // Optional: Check if token already exists
        final existing = await supabase
            .from('device_tokens')
            .select()
            .eq('token', token)
            .maybeSingle();

        if (existing == null) {
          // 👤 Replace this with your actual user ID
          await supabase.from('device_tokens').insert({
            'user_id': 'test-user-123',
            'token': token,
          });
          print("✅ Token stored in Supabase.");
        } else {
          print("ℹ️ Token already exists in Supabase.");
        }
      }
    } catch (e) {
      print("❌ Error fetching/storing FCM token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
