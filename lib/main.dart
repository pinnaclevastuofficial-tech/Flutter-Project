import 'package:flutter/material.dart';
import 'api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() {
  runApp(const VastuApp());
}

class VastuApp extends StatelessWidget {
  const VastuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vastu AI',
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiClient api = ApiClient();
  final TextEditingController controller = TextEditingController();

  final List<Map<String, String>> messages = [];
  bool loading = false;

  // Temporary user id (later from Supabase login)
  final String userId = "11111111-1111-1111-1111-111111111111";

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty || loading) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      loading = true;
    });
    controller.clear();

    try {
      final res = await api.genericChat(userId: userId, message: text);
      final answer = (res["answer"] ?? "").toString();

      setState(() {
        messages.add({"role": "assistant", "text": answer});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "assistant", "text": "ERROR: $e"});
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget bubble(String role, String text) {
    final isUser = role == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vastu AI Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            onPressed: () async {
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
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, i) =>
                  bubble(messages[i]["role"]!, messages[i]["text"]!),
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Thinking..."),
            ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Type your Vastu question...",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
