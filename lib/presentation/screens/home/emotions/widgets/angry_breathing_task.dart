import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AngryBreathingTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const AngryBreathingTask({
    super.key,
    required this.onComplete,
    required this.isCompleted,
  });

  @override
  State<AngryBreathingTask> createState() => _AngryBreathingTaskState();
}

class _AngryBreathingTaskState extends State<AngryBreathingTask> {
  bool _isCompleted = false;
  Timer? _timer;
  Timer? _breathingCycle;
  int _remaining = 60;

  // Breathing Animation State
  double _circleSize = 100;
  String _phaseText = "Inhale";
  BreathingPhase _phase = BreathingPhase.inhale;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    if (!_isCompleted) {
      loadProgress();
    }
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final saved = prefs.getBool('angry_breathing_done_$uid') ?? false;
    if (saved) {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await prefs.setBool('angry_breathing_done_$uid', true);
  }

  void startBreathing() {
    if (_timer != null && _timer!.isActive) return;
    _startBreathingCycle();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        _stopBreathingCycle();
        setState(() {
          _isCompleted = true;
        });
        widget.onComplete();
        saveProgress();
      } else {
        setState(() {
          _remaining--;
        });
      }
    });
  }

  void _startBreathingCycle() {
    _breathingCycle = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() {
        switch (_phase) {
          case BreathingPhase.inhale:
            _circleSize = 200;
            _phaseText = "Hold";
            _phase = BreathingPhase.hold1;
            break;
          case BreathingPhase.hold1:
            _phaseText = "Exhale";
            _phase = BreathingPhase.exhale;
            break;
          case BreathingPhase.exhale:
            _circleSize = 100;
            _phaseText = "Hold";
            _phase = BreathingPhase.hold2;
            break;
          case BreathingPhase.hold2:
            _phaseText = "Inhale";
            _phase = BreathingPhase.inhale;
            break;
        }
      });
    });
  }

  void _stopBreathingCycle() {
    _breathingCycle?.cancel();
  }

  void restartTask() async {
    _timer?.cancel();
    _stopBreathingCycle();
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.remove('angry_breathing_done_$uid');
    }
    setState(() {
      _remaining = 60;
      _isCompleted = false;
      _phase = BreathingPhase.inhale;
      _circleSize = 100;
      _phaseText = "Inhale";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingCycle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isCompleted
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text(
                  "Breathing Task Complete!",
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: restartTask,
                  icon: const Icon(
                    Icons.replay,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Restart",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
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
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 4),
                  width: _circleSize,
                  height: _circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEF7A87).withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _phaseText,
                  style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF7A87)),
                ),
                const SizedBox(height: 30),
                Text(
                  "⏱️ ${_remaining}s",
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: startBreathing,
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Start Breathing",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
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
                ),
              ],
            ),
          );
  }
}

enum BreathingPhase { inhale, hold1, exhale, hold2 }
