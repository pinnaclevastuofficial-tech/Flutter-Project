// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'auth_email_otp_screen.dart';
// import 'profile_form_screen.dart';
// import 'chat_screen.dart';

// class AppRouter extends StatefulWidget {
//   const AppRouter({super.key});

//   @override
//   State<AppRouter> createState() => _AppRouterState();
// }

// class _AppRouterState extends State<AppRouter> {
//   final supabase = Supabase.instance.client;

//   Future<Map<String, dynamic>?>? _profileFuture;
//   String? _loadedUserId;

//   Future<Map<String, dynamic>?> _loadProfile(String userId) async {
//     return await supabase
//         .from('profiles')
//         .select()
//         .eq('id', userId)
//         .maybeSingle();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = supabase.auth.currentUser;

//     if (user == null) {
//       _profileFuture = null;
//       _loadedUserId = null;
//       return const AuthEmailOtpScreen();
//     }

//     if (_loadedUserId != user.id) {
//       _loadedUserId = user.id;
//       _profileFuture = _loadProfile(user.id);
//     }

//     return FutureBuilder<Map<String, dynamic>?>(
//       future: _profileFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text("Profile error:\n${snapshot.error}"),
//               ),
//             ),
//           );
//         }

//         final profile = snapshot.data;

//         // if (profile == null) {
//         //   return const ProfileFormScreen();
//         // }

//         return const ChatScreen();
//       },
//     );
//   }
// }
