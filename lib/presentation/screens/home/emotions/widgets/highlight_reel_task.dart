import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighlightReelTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;
  final String emotionFilter;

  const HighlightReelTask({
    Key? key,
    required this.onComplete,
    required this.isCompleted,
    required this.emotionFilter,
  }) : super(key: key);

  @override
  State<HighlightReelTask> createState() => _HighlightReelTaskState();
}

class _HighlightReelTaskState extends State<HighlightReelTask> {
  late ConfettiController _confettiController;
  PageController _pageController = PageController();
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _completed = widget.isCompleted;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markTaskComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.setBool('happy_reel_done_$uid', true);
    }
    _confettiController.play();
    setState(() => _completed = true);
    widget.onComplete();
  }

  void _restartTask() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.setBool('happy_reel_done_$uid', false);
    }
    setState(() => _completed = false);
    _pageController.jumpToPage(0);
  }

  String emotionToEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😡';
      case 'neutral':
        return '😐';
      case 'anxious':
        return '😰';
      default:
        return '🙂';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("User not signed in."));
    }

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ripples')
        .where('isArchived', isEqualTo: false)
        .where('emotion',
            isEqualTo: widget.emotionFilter.isNotEmpty
                ? widget.emotionFilter
                : 'Happy')
        .orderBy('time', descending: true);
    print(
        "🟢 Final emotion filter: ${widget.emotionFilter.isNotEmpty ? widget.emotionFilter : 'Happy'}");

    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong."));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final ripples = snapshot.data!.docs;
            print("🟡 Using emotion filter: ${widget.emotionFilter}");
            for (var doc in ripples) {
              print("Ripple doc: ${doc.data()}");
            }

            if (ripples.isEmpty) {
              return const Center(
                  child: Text("Try adding a ripple with that emotion first."));
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: ripples.length,
              itemBuilder: (context, index) {
                final data = ripples[index].data() as Map<String, dynamic>;
                final timestamp = data['time'] as Timestamp?;
                final dateTime = timestamp?.toDate();
                final emotion = data['emotion'] ?? '';
                final emoji = emotionToEmoji(emotion);
                final trigger = data['trigger'] ?? '';

                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_completed)
                        ElevatedButton.icon(
                          onPressed: _restartTask,
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          label: const Text("Restart"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEDEEA5),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      if (index == 0 && !_completed)
                        Column(
                          children: [
                            const Icon(Icons.swipe,
                                size: 28, color: Colors.black54),
                            Text(
                              "Swipe up to explore your highlights",
                              style: GoogleFonts.outfit(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            const Divider(thickness: 1, color: Colors.black12),
                          ],
                        ),
                      const SizedBox(height: 12),

                      /// Header
                      Text("Your Highlight Ripple",
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text('$emoji $emotion',
                          style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),

                      const Divider(
                          thickness: 1, color: Colors.black12, height: 32),

                      /// Trigger / Description
                      if (trigger.isNotEmpty)
                        Text(
                          '"$trigger"',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 12),

                      if (dateTime != null)
                        Text(
                          "${dateTime.toLocal()}".split('.')[0],
                          style: GoogleFonts.outfit(
                              fontSize: 14, color: Colors.grey.shade600),
                        ),

                      const SizedBox(height: 32),
                      const Divider(
                          thickness: 1, color: Colors.black12, height: 16),

                      /// Completion Button
                      if (index == ripples.length - 1 && !_completed)
                        ElevatedButton.icon(
                          onPressed: _markTaskComplete,
                          icon: const Icon(Icons.check, color: Colors.black),
                          label: const Text("Mark as Complete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEDEEA5),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                        ),

                      if (_completed)
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            "You completed this task!",
                            style: GoogleFonts.outfit(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
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
    );
  }
}
