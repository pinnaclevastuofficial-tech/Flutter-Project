import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final supabase = Supabase.instance.client;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> signUp() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email.isEmpty || pass.length < 6) {
      _msg("Enter email and password (min 6 chars)");
      return;
    }

    setState(() => loading = true);
    try {
      await supabase.auth.signUp(email: email, password: pass);
      _msg("Signup successful. Now login.");
    } catch (e) {
      _msg("Signup error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> login() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _msg("Enter email and password");
      return;
    }

    setState(() => loading = true);
    try {
      await supabase.auth.signInWithPassword(email: email, password: pass);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _msg("Login error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    setState(() => loading = true);
    try {
      await supabase.auth.signOut();
      _msg("Logged out");
      setState(() {}); // refresh UI
    } catch (e) {
      _msg("Logout error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
print("signup");
    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: user != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Logged in as:\n${user.email ?? ""}\n\nUserId:\n${user.id}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: loading ? null : logout,
                    child: Text(loading ? "..." : "Logout"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Back to Chat"),
                  ),
                ],
              )
            : Column(
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
                  TextField(
                    controller: passCtrl,
                    decoration: const InputDecoration(
                      labelText: "Password (min 6 chars)",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading ? null : signUp,
                          child: Text(loading ? "..." : "Sign Up"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          child: Text(loading ? "..." : "Login"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
