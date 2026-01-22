import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_screen.dart';

class HomeSliderScreen extends StatefulWidget {
  const HomeSliderScreen({super.key});

  @override
  State<HomeSliderScreen> createState() => _HomeSliderScreenState();
}

class _HomeSliderScreenState extends State<HomeSliderScreen> {
  final PageController _pc = PageController(viewportFraction: 0.88);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();

    // Slow auto-slide every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pc.hasClients) return;
      _page = (_page + 1) % 3;
      _pc.animateToPage(
        _page,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  Widget _card({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE6ECF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: Color(0xFF3B4A5A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(icon, color: cs.primary),
                      const SizedBox(width: 8),
                      const Text(
                        "Tap to open",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right AI Image placeholder (use asset later)
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset("assets/ai.png", fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vastu AI"),
        backgroundColor: cs.primary.withOpacity(0.06),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome${user?.email == null ? "" : ", ${user!.email}"}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3B4A5A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: PageView(
                controller: _pc,
                children: [
                  _card(
                    title: "AI Chat Consultant",
                    subtitle:
                        "Ask any Vastu question and get solutions & remedies instantly.",
                    icon: Icons.chat_bubble_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                  ),
                  _card(
                    title: "Analyse Your Project",
                    subtitle:
                        "Add a case, enter entrance/directions, and get guided remedies.",
                    icon: Icons.home_work_outlined,
                    onTap: () {
                      // Next feature page later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Project module coming next"),
                        ),
                      );
                    },
                  ),
                  _card(
                    title: "Daily Remedies & Reminders",
                    subtitle:
                        "Get day-wise actions and reminders based on your selected remedies.",
                    icon: Icons.notifications_active_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Reminders module coming next"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
