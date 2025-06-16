import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentro/presentation/screens/home/emotions/widgets/dance_party_task.dart';
import 'package:mentro/presentation/screens/home/emotions/widgets/spin_wheel_task.dart';
import 'package:mentro/presentation/screens/home/emotions/widgets/tiny_boost_video_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NeutralScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const NeutralScreen({super.key, required this.onComplete});

  @override
  State<NeutralScreen> createState() => _NeutralScreenState();
}

class _NeutralScreenState extends State<NeutralScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late TabController _tabController;
  Set<int> _completedTasks = {};
  DateTime? _completionTime;
  Timer? _countdownTimer;
  Duration? _timeLeft;
  bool _wasAllCompletedBefore = false;

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
        _confettiController.play();
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

    final savedTasks = prefs.getStringList('neutral_tasks_$uid');
    final timeStr = prefs.getString('neutral_time_$uid');

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

      await prefs.remove('neutral_tasks_$uid');
      await prefs.remove('neutral_time_$uid');
    }

    setState(() => _completedTasks.clear());
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
      'neutral_tasks_$uid',
      _completedTasks.map((e) => e.toString()).toList(),
    );
    await prefs.setString(
        'neutral_time_$uid', DateTime.now().toIso8601String());
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
          const Icon(Icons.timer, color: Color(0xFF8ECFE6)),
          const SizedBox(width: 8),
          Text(
            'Next boost in',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Text(
            '$hours:$minutes:$seconds',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Color(0xFF8ECFE6),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feeling Neutral?",
            style: GoogleFonts.outfit(
              fontSize: 22,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            )),
        elevation: 0,
        backgroundColor: const Color(0xFF8ECFE6),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF8ECFE6),
            unselectedLabelColor: Colors.black,
            dividerColor: Colors.black87,
            indicatorColor: const Color(0xFF8ECFE6),
            tabs: const [
              Tab(icon: Icon(Icons.casino), text: "Spin"),
              Tab(icon: Icon(Icons.music_note), text: "Dance"),
              Tab(icon: Icon(Icons.video_library), text: "Boost"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SpinWheelTask(
                  onComplete: () => _onTaskComplete(0),
                  isCompleted: _completedTasks.contains(0),
                ),
                DancePartyTask(
                  onComplete: () => _onTaskComplete(1),
                  isCompleted: _completedTasks.contains(1),
                ),
                TinyBoostVideoTask(
                    // onComplete: () => _onTaskComplete(2),
                    // isCompleted: _completedTasks.contains(2),
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
                      ? "You completed your neutral boost today!"
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: Text(
                    'Back to Home',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8ECFE6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
