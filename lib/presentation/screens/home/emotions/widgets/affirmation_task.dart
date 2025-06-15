import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AffirmationTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const AffirmationTask({
    super.key,
    required this.onComplete,
    required this.isCompleted,
  });

  @override
  State<AffirmationTask> createState() => _AffirmationTaskState();
}

class _AffirmationTaskState extends State<AffirmationTask> {
  static const int totalDuration = 10; // adjust as needed
  int _secondsLeft = totalDuration;
  bool _isStarted = false;
  bool _completed = false;
  bool _showRestart = false;
  Timer? _timer;
  bool _alreadyReported = false;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final saved = prefs.getBool('sad_affirmation_done_$uid') ?? false;

    setState(() {
      _completed = saved || widget.isCompleted;
      _showRestart = _completed;
      _alreadyReported = _completed;
    });
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.setBool('sad_affirmation_done_$uid', true);
    }
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.remove('sad_affirmation_done_$uid');
    }
  }

  void startAffirmation() {
    if (_isStarted) return;

    setState(() {
      _isStarted = true;
      _completed = false;
      _showRestart = false;
      _secondsLeft = totalDuration;
      _alreadyReported = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);

      if (_secondsLeft <= 0) {
        timer.cancel();
        setState(() {
          _isStarted = false;
          _completed = true;
        });

        if (!_alreadyReported) {
          widget.onComplete(); // report to parent once
          _alreadyReported = true;
          saveProgress();
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() => _showRestart = true);
        });
      }
    });
  }

  void restartAffirmation() async {
    await resetProgress();
    setState(() {
      _secondsLeft = totalDuration;
      _completed = false;
      _isStarted = false;
      _showRestart = false;
      _alreadyReported = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mins = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lottie/affirmation.json',
          height: 200,
          width: 200,
          repeat: true,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        Text(
          _completed ? "You're Amazing!" : "Time Left: $mins:$secs",
          style: GoogleFonts.outfit(fontSize: 24, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Text(
          _completed
              ? "Positive vibes completed.! 🎉"
              : "Repeat after me:\n“I am worthy. I am healing. I am enough.”",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _completed && _showRestart
              ? restartAffirmation
              : (_isStarted ? null : startAffirmation),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFFBA90D0),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            _completed
                ? (_showRestart ? 'Restart Affirmations' : 'Affirmation Done!')
                : 'Start Affirmations',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
