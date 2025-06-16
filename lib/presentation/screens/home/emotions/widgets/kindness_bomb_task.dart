import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KindnessBombTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const KindnessBombTask({
    Key? key,
    required this.onComplete,
    required this.isCompleted,
  }) : super(key: key);

  @override
  State<KindnessBombTask> createState() => _KindnessBombTaskState();
}

class _KindnessBombTaskState extends State<KindnessBombTask>
    with TickerProviderStateMixin {
  final List<String> _prewrittenMessages = [
    "You're amazing!",
    "You matter. 💖",
    "Never give up!",
    "Believe in yourself.",
    "You are loved.",
    "You make a difference."
  ];

  int _selectedTab = 0;
  int? _selectedMessageIndex;
  final TextEditingController _customMessageController =
      TextEditingController();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  Future<void> saveKindnessBombProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.setBool('neutral_kindness_done_$uid', true);
    }
  }

  void _sendKindnessBomb() async {
    String message = '';
    if (_selectedTab == 0 && _selectedMessageIndex != null) {
      message = _prewrittenMessages[_selectedMessageIndex!];
    } else if (_selectedTab == 1 &&
        _customMessageController.text.trim().isNotEmpty) {
      message = _customMessageController.text.trim();
    }

    if (message.isNotEmpty) {
      _confettiController.play();
      await saveKindnessBombProgress();
      widget.onComplete();

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("💌 Kindness Bomb Sent: '$message'"),
          duration: const Duration(seconds: 3),
        ),
      );

      // Actually share the message
      Share.share(message);

      setState(() {
        _selectedMessageIndex = null;
        _customMessageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "🎁 Kindness Bomb",
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  "Spread a little kindness! Choose a message or write your own.",
                  style: GoogleFonts.outfit(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ToggleButtons(
                  isSelected: [_selectedTab == 0, _selectedTab == 1],
                  onPressed: (index) => setState(() => _selectedTab = index),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.black,
                  fillColor: const Color(0xFFEDEEA5),
                  textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Pre-written"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Custom"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_selectedTab == 0)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _prewrittenMessages.length,
                      itemBuilder: (context, index) {
                        final msg = _prewrittenMessages[index];
                        return ListTile(
                          title: Text(msg, style: GoogleFonts.outfit()),
                          leading: Radio<int>(
                            value: index,
                            groupValue: _selectedMessageIndex,
                            onChanged: (val) {
                              setState(() {
                                _selectedMessageIndex = val;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: _customMessageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Type your kind message here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _sendKindnessBomb,
                  icon: const Icon(Icons.send, color: Colors.black),
                  label: const Text("Send Kindness Bomb"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDEEA5),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              maxBlastForce: 10,
              minBlastForce: 4,
              gravity: 0.3,
              emissionFrequency: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
