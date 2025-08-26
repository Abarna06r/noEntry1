import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String fullName;
  final String phone;
  final String password; // ✅ added

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.password, // ✅ added
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Verify OTP from Supabase `email_otps` table
      final otpRecords = await supabase
          .from('email_otps')
          .select()
          .eq('email', widget.email)
          .eq('otp', _otpController.text.trim())
          .gte('expires_at', DateTime.now().toIso8601String());

      if (otpRecords.isEmpty) throw "Invalid or expired OTP";

      // 2️⃣ Create user in Supabase auth using the password from signup
      final authResponse = await supabase.auth.signUp(
        email: widget.email,
        password: widget.password, // ✅ use the user-entered password
      );

      final user = authResponse.user;
      if (user == null) throw "User creation failed";

      // 3️⃣ Insert profile info
      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': widget.fullName,
        'phone': widget.phone,
      });

      // 4️⃣ Delete used OTP
      await supabase.from('email_otps').delete().eq('email', widget.email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Account created successfully!")),
      );

      // 5️⃣ Navigate to dashboard/home
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Verification Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter the OTP sent to ${widget.email}"),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: "OTP"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || v.isEmpty ? "Enter OTP" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  child: const Text("Verify"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






/*import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String fullName;
  final String phone;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.phone, required String password,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Verify OTP from Supabase `email_otps` table
      final otpRecords = await supabase
          .from('email_otps')
          .select()
          .eq('email', widget.email)
          .eq('otp', _otpController.text.trim())
          .gte('expires_at', DateTime.now().toIso8601String());

      if (otpRecords.isEmpty) throw "Invalid or expired OTP";

      // 2️⃣ Create user in Supabase auth
      final password = generateRandomPassword();
      final authResponse = await supabase.auth.signUp(
        email: widget.email,
        password: password,
      );
      final user = authResponse.user;
      if (user == null) throw "User creation failed";

      // 3️⃣ Insert profile info
      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': widget.fullName,
        'phone': widget.phone,
      });

      // 4️⃣ Delete used OTP
      await supabase.from('email_otps').delete().eq('email', widget.email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Account created successfully!")),
      );

      // 5️⃣ Navigate to dashboard/home
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Verification Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter the OTP sent to ${widget.email}"),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: "OTP"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || v.isEmpty ? "Enter OTP" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  child: const Text("Verify"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/