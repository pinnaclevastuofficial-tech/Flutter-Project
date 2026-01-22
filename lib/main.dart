import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api.dart';
import 'auth_screen.dart';
// import 'app_router.dart';
import 'root_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dvrqyceccshqlceblycy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2cnF5Y2VjY3NocWxjZWJseWN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NzYyMjMsImV4cCI6MjA4NDE1MjIyM30.YDTPMLTXHtsHiOgb8BxuxlNRqiwO0FtkbYeWv8ajvHY',
  );

  runApp(const VastuApp());
}

class VastuApp extends StatelessWidget {
  const VastuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vastu AI',
      home: const RootGate(),

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E6BE6),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7EEF9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7EEF9)),
          ),
        ),
      ),
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

  /// Uses Supabase user id if logged in, otherwise fallback dummy id (so chat still works).
  String get userId {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id ?? "11111111-1111-1111-1111-111111111111";
  }

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
      if (mounted) {
        setState(() => loading = false);
      }
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
          // Backend health check
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Backend error: $e")));
              }
            },
          ),

          // Show Supabase user
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final user = Supabase.instance.client.auth.currentUser;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Supabase user: ${user?.id ?? "NOT LOGGED IN"}",
                  ),
                ),
              );
            },
          ),

          // Login button
          // Login / Account button (permanent email+password)
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () async {
              final ok = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );

              if (!mounted) return;
              if (ok == true) {
                setState(() {}); // refresh UI after login/logout
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
                IconButton(onPressed: send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
