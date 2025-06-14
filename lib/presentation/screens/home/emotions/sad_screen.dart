import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentro/presentation/screens/home/emotions/widgets/nature_walk_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SadScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SadScreen({super.key, required this.onComplete});

  @override
  State<SadScreen> createState() => _SadScreenState();
}

class _SadScreenState extends State<SadScreen> {
  Set<int> _completedTasks = {};
  DateTime? _completionTime;
  Timer? _countdownTimer;
  Duration? _timeLeft;

  @override
  void initState() {
    super.initState();
    checkCompletionState();
  }

  void _onTaskComplete(int taskId) async {
    if (_completedTasks.contains(taskId)) return;

    setState(() => _completedTasks.add(taskId));
    await saveCompletionState();
  }

  bool get allCompleted => _completedTasks.length == 3;

  Future<void> checkCompletionState() async {
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

      // expired
      await prefs.remove('sad_tasks_$uid');
      await prefs.remove('sad_time_$uid');
    }

    setState(() {
      _completedTasks.clear();
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeling Sad?"),
        backgroundColor: const Color(0xFF74b9ff),
      ),
      body: ListView(
        children: [
          NatureWalkTask(
            onComplete: () => _onTaskComplete(0),
            isCompleted: _completedTasks.contains(0),
            onWalkComplete: () {},
          ),
          // StepCounterTask(
          //   onComplete: () => _onTaskComplete(1),
          //   isCompleted: _completedTasks.contains(1),
          // ),
          // AffirmationTask(
          //   onComplete: () => _onTaskComplete(2),
          //   isCompleted: _completedTasks.contains(2),
          // ),
          const Divider(height: 1, color: Colors.black87),
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
                if (_timeLeft != null)
                  Text(
                      "⏳ Resets in: ${_timeLeft!.inHours}h ${_timeLeft!.inMinutes % 60}m"),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF74b9ff),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
