import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentro/presentation/screens/home/emotions/widgets/affirmation_task.dart';
import 'package:mentro/presentation/screens/home/emotions/widgets/nature_walk_task.dart';
import 'package:mentro/presentation/screens/home/emotions/widgets/step_counter_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SadScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SadScreen({super.key, required this.onComplete});

  @override
  State<SadScreen> createState() => _SadScreenState();
}

class _SadScreenState extends State<SadScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  bool _wasAllCompletedBefore = false;

  late TabController _tabController;
  Set<int> _completedTasks = {};
  DateTime? _completionTime;
  Timer? _countdownTimer;
  Duration? _timeLeft;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: Duration(seconds: 10));

    checkCompletionState();
  }

  void _onTaskComplete(int taskId) async {
    if (_completedTasks.contains(taskId)) return;

    setState(() {
      _completedTasks.add(taskId);

      if (_completedTasks.length == 3 && !_wasAllCompletedBefore) {
        _wasAllCompletedBefore = true;
        _confettiController.play(); // 🎉
      }
    });

    await saveCompletionState();
  }

  bool get allCompleted => _completedTasks.length == 3;

  Future<void> checkCompletionState() async {
    _wasAllCompletedBefore = _completedTasks.length == 3;

    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !mounted) return;

    final savedTasks = prefs.getStringList('sad_tasks_$uid');
    final timeStr = prefs.getString('sad_time_$uid');

    if (savedTasks != null && timeStr != null) {
      final savedTime = DateTime.parse(timeStr);
      final now = DateTime.now();

      if (now.difference(savedTime).inHours < 24) {
        setState(() {
          _completedTasks = savedTasks.map(int.parse).toSet();
          _completionTime = savedTime;
          _timeLeft = Duration(hours: 24) - now.difference(savedTime);
        });
        startCountdown();
        return;
      }

      await prefs.remove('sad_tasks_$uid');
      await prefs.remove('sad_time_$uid');
    }

    setState(() => _completedTasks.clear());
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final path = Path();
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2.5;
    final center = Offset(size.width / 2, size.height / 2);
    double angle = degToRad(360 / numberOfPoints);
    for (int i = 0; i < numberOfPoints * 2; i++) {
      final isEven = i % 2 == 0;
      final radius = isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * cos(i * angle);
      final y = center.dy + radius * sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_completionTime == null) return;
      final now = DateTime.now();
      final diff =
          _completionTime!.add(const Duration(hours: 24)).difference(now);

      if (diff.isNegative) {
        _countdownTimer?.cancel();
        setState(() => _timeLeft = null);
      } else {
        setState(() => _timeLeft = diff);
      }
    });
  }

  Future<void> saveCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await prefs.setStringList(
      'sad_tasks_$uid',
      _completedTasks.map((e) => e.toString()).toList(),
    );
    await prefs.setString('sad_time_$uid', DateTime.now().toIso8601String());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Widget buildStarConfetti() {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      numberOfParticles: 30,
      maxBlastForce: 20,
      minBlastForce: 8,
      emissionFrequency: 0.05,
      gravity: 0.3,
      createParticlePath: drawStar,
    );
  }

  Widget buildCountdownBanner() {
    if (_timeLeft == null) return const SizedBox();

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_timeLeft!.inHours);
    final minutes = twoDigits(_timeLeft!.inMinutes.remainder(60));
    final seconds = twoDigits(_timeLeft!.inSeconds.remainder(60));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Color(0xFFBA90D0)),
          const SizedBox(width: 8),
          Text(
            'Your journey will be restarted in',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$hours:$minutes:$seconds',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color.fromARGB(224, 255, 13, 0),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Feeling Sad?",
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFBA90D0),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFBA90D0),
            unselectedLabelColor: Colors.black,
            dividerColor: Colors.black87,
            indicatorColor: const Color(0xFFBA90D0),
            unselectedLabelStyle:
                GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400),
            labelStyle:
                GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400),
            tabs: const [
              Tab(icon: Icon(Icons.nature_people), text: "Walk"),
              Tab(icon: Icon(Icons.directions_walk), text: "Steps"),
              Tab(icon: Icon(Icons.emoji_emotions), text: "Affirm"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                NatureWalkTask(
                  onComplete: () => _onTaskComplete(0),
                  isCompleted: _completedTasks.contains(0),
                  onWalkComplete: () {},
                ),
                StepCounterTask(
                  onComplete: () => _onTaskComplete(1),
                  isCompleted: _completedTasks.contains(1),
                ),
                AffirmationTask(
                  onComplete: () => _onTaskComplete(2),
                  isCompleted: _completedTasks.contains(2),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  allCompleted
                      ? "🌟 You completed today’s healing journey!"
                      : "Progress: ${_completedTasks.length}/3 tasks completed",
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: buildStarConfetti(),
                ),
                buildCountdownBanner(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Back to Home',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBA90D0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
