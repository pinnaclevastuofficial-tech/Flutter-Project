import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiClient api = ApiClient();
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  final List<Map<String, String>> messages = [];
  bool loading = false;

  String get userId {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id ?? "11111111-1111-1111-1111-111111111111";
  }

  @override
  void dispose() {
    controller.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollCtrl.hasClients) return;
      scrollCtrl.animateTo(
        scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty || loading) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      loading = true;
    });
    controller.clear();
    _scrollToBottom();

    try {
      final res = await api.genericChat(userId: userId, message: text);
      final answer = (res["answer"] ?? "").toString();

      setState(() {
        messages.add({"role": "assistant", "text": answer.isEmpty ? "…" : answer});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "assistant", "text": "ERROR: $e"});
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
      _scrollToBottom();
    }
  }

  Widget _bubble({required bool isUser, required String text}) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? cs.primary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
          border: Border.all(
            color: isUser ? cs.primary.withOpacity(0.15) : const Color(0xFFE6ECF5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SelectableText(
          text,
          style: TextStyle(
            fontSize: 15,
            height: 1.35,
            color: isUser ? const Color(0xFF1E2A3A) : const Color(0xFF1E2A3A),
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6ECF5)),
        ),
        child: const Text("Thinking…"),
      ),
    );
  }

  Widget _inputBar() {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Ask your Vastu question…",
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                onSubmitted: (_) => send(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              width: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: loading ? null : send,
                child: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserSnack() async {
    final user = Supabase.instance.client.auth.currentUser;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Supabase user: ${user?.id ?? "NOT LOGGED IN"}")),
    );
  }

  Future<void> _healthCheck() async {
    try {
      final h = await api.health();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Backend: ${h["status"]}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Backend error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("signup");

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vastu AI"),
        backgroundColor: cs.primary.withOpacity(0.06),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            onPressed: _healthCheck,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showUserSnack,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: messages.length + (loading ? 1 : 0),
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, i) {
                if (loading && i == messages.length) {
                  return _typingIndicator();
                }
                final m = messages[i];
                final role = m["role"] ?? "assistant";
                final text = m["text"] ?? "";
                return _bubble(isUser: role == "user", text: text);
              },
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }
}
