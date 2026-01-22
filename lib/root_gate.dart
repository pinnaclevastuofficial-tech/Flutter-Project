import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_email_otp_screen.dart';
import 'profile_form_screen.dart';
import 'home_screen.dart';

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?>? _profileFuture;
  String? _loadedUserId;

  Future<Map<String, dynamic>?> _loadProfile(String userId) async {
    return await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  void _refreshProfile() {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    setState(() {
      _profileFuture = _loadProfile(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, _) {
        final user = supabase.auth.currentUser;

        // Not logged in
        if (user == null) {
          _profileFuture = null;
          _loadedUserId = null;
          return const AuthEmailOtpScreen();
        }

        // Logged in: load profile once per user
        if (_loadedUserId != user.id) {
          _loadedUserId = user.id;
          _profileFuture = _loadProfile(user.id);
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("Profile load error:\n${snap.error}"),
                  ),
                ),
              );
            }

            final profile = snap.data;

            // First time user -> profile form
            if (profile == null) {
              return ProfileFormScreen(
                onSaved: _refreshProfile, 
              );
            }

            // Profile exists -> main first screen
            return const HomeScreen();
          },
        );
      },
    );
  }
}
