import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PunchItOutTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const PunchItOutTask({
    super.key,
    required this.onComplete,
    required this.isCompleted,
  });

  @override
  State<PunchItOutTask> createState() => _PunchItOutTaskState();
}

class _PunchItOutTaskState extends State<PunchItOutTask>
    with TickerProviderStateMixin {
  int punchCount = 0;
  final int targetPunches = 20;
  bool _isCompleted = false;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final _player = AudioPlayer();

  final List<String> punchSounds = [
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/punch1.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/punch2.mp3',
  ];

  final String boomSound =
      'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/boom.mp3';

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOut);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    if (!_isCompleted) loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final saved = prefs.getBool('angry_punch_done_$uid') ?? false;
    if (saved) {
      setState(() => _isCompleted = true);
    }
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await prefs.setBool('angry_punch_done_$uid', true);
  }

  Future<void> playPunchSound() async {
    final random = Random();
    final url = punchSounds[random.nextInt(punchSounds.length)];
    try {
      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      print("Error playing punch sound: $e");
    }
  }

  Future<void> playBoomSound() async {
    try {
      await _player.setUrl(boomSound);
      _player.play();
    } catch (e) {
      print("Error playing boom sound: $e");
    }
  }

  void handlePunch() {
    if (_isCompleted) return;

    setState(() => punchCount++);
    _scaleController.forward(from: 0.9);
    _shakeController.forward(from: 0);
    playPunchSound();

    if (punchCount >= targetPunches) {
      setState(() => _isCompleted = true);
      saveProgress();
      playBoomSound();
      widget.onComplete();
    }
  }

  void restartTask() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.remove('angry_punch_done_$uid');
    }

    setState(() {
      punchCount = 0;
      _isCompleted = false;
    });
  }

  String getCrackEmoji() {
    if (punchCount == 0) return "📦";
    if (punchCount < targetPunches * 0.25) return "📦🪨";
    if (punchCount < targetPunches * 0.5) return "📦⚡";
    if (punchCount < targetPunches * 0.75) return "📦💥";
    return "📦🔥";
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shakeController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shake = math.sin(_shakeAnimation.value * pi * 2) * 8;

    return _isCompleted
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("💣💥 BOOM!", style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                Text("You punched it all out! 😤",
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: restartTask,
                  icon: const Icon(Icons.replay, color: Colors.white),
                  label: Text(
                    "Restart",
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEF7A87),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                )
              ],
            ),
          )
        : AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(shake, 0),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Punch the anger away!",
                          style: GoogleFonts.outfit(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                          "Tap the glove ${targetPunches - punchCount} more times!",
                          style: GoogleFonts.outfit(fontSize: 16)),
                      const SizedBox(height: 30),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: GestureDetector(
                          onTap: handlePunch,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF7A87),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade200,
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: const Icon(Icons.sports_mma,
                                size: 60, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text("$punchCount / $targetPunches punches",
                          style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFEF7A87))),
                      const SizedBox(height: 20),
                      Text(getCrackEmoji(),
                          style: const TextStyle(fontSize: 40)),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
