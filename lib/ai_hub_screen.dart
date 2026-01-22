import 'dart:async';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> {
  final PageController _pc = PageController(viewportFraction: 0.90);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pc.hasClients) return;
      _page = (_page + 1) % 2;
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

  Widget slideCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7EEF9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: cs.primary)),
                  const SizedBox(height: 8),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF516173))),
                  const Spacer(),
                  Row(
                    children: const [
                      Icon(Icons.touch_app),
                      SizedBox(width: 6),
                      Text("Tap to open",
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(22),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: cs.primary.withOpacity(0.06),
        elevation: 0,
        title: const Text("AI Assistant"),
      ),
      body: PageView(
        controller: _pc,
        children: [
          slideCard(
            title: "AI Vastu Chat",
            subtitle:
                "Ask any question. Get direction-based remedies & clear guidance.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
          ),
          slideCard(
            title: "Project Vastu Analysis",
            subtitle:
                "Soon: upload/enter map details, entrances & placements to analyse.",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Project AI module coming next")),
              );
            },
          ),
        ],
      ),
    );
  }
}
