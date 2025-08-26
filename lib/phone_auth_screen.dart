import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithOtp(
        phone: _phoneController.text.trim(),
      );
      setState(() {
        _loading = false;
        _codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📩 OTP sent to your phone")),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send OTP: $e")),
      );
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _loading = true);
    try {
      final res = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: _otpController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final user = res.user;
      if (res.session != null && user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(userId: user.id),
          ),
        );
      } else {
        throw Exception("OTP verification failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Invalid OTP: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Number Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Enter Phone Number (+91XXXXXXXXXX)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send OTP"),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter OTP"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _verifyOtp,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify OTP"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
