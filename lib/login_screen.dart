import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  bool sent = false;
  bool loading = false;

  final supabase = Supabase.instance.client;

  Future<void> sendOtp() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) return;

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true, // important
      );

      if (!mounted) return;
      setState(() => sent = true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP sent to your email")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

Future<void> verifyOtp() async {
  final email = emailCtrl.text.trim();
  final otp = otpCtrl.text.trim();
  if (email.isEmpty || otp.isEmpty) return;

  setState(() => loading = true);

  try {
    await supabase.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: otp,
    );

    if (!mounted) return;
    Navigator.pop(context, true); // login success
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Invalid OTP")),
    );
  } finally {
    if (mounted) setState(() => loading = false);
  }
}


  @override
  void dispose() {
    emailCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("signup");

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            if (sent)
              TextField(
                controller: otpCtrl,
                decoration: const InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : (sent ? verifyOtp : sendOtp),
              child: Text(
                loading ? "Please wait..." : (sent ? "Verify OTP" : "Send OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
