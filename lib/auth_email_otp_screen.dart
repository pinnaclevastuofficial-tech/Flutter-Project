import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthEmailOtpScreen extends StatefulWidget {
  const AuthEmailOtpScreen({super.key});

  @override
  State<AuthEmailOtpScreen> createState() => _AuthEmailOtpScreenState();
}

class _AuthEmailOtpScreenState extends State<AuthEmailOtpScreen> {
  final supabase = Supabase.instance.client;

  final emailCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool otpSent = false;
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> sendOtp() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      _snack("Enter email");
      return;
    }

    setState(() => loading = true);
    try {
      await supabase.auth.signInWithOtp(email: email);
      setState(() => otpSent = true);
      _snack("OTP sent to your email");
    } catch (e) {
      _snack("Error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> verifyOtp() async {
    final email = emailCtrl.text.trim();
    final otp = otpCtrl.text.trim();

    if (otp.isEmpty) {
      _snack("Enter OTP");
      return;
    }

    setState(() => loading = true);
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );
      _snack("Logged in successfully");
      // AppRouter will auto-navigate
    } catch (e) {
      _snack("Invalid OTP");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to Vastu AI",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Sign up / Login with email OTP.\nNo password needed.",
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            hintText: "example@gmail.com",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (otpSent) ...[
                          TextField(
                            controller: otpCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "OTP",
                              hintText: "Enter 6-digit OTP",
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: loading
                                ? null
                                : (otpSent ? verifyOtp : sendOtp),
                            child: Text(
                              loading
                                  ? "Please wait..."
                                  : (otpSent ? "Verify OTP" : "Send OTP"),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        if (otpSent) ...[
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: loading
                                ? null
                                : () {
                                    setState(() {
                                      otpSent = false;
                                      otpCtrl.clear();
                                    });
                                  },
                            child: const Text("Change email"),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    "Tip: If OTP email is delayed, check Spam/Promotions tab.",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
