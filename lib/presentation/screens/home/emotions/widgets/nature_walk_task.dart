import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NatureWalkTask extends StatefulWidget {
  final VoidCallback onWalkComplete;
  final VoidCallback onComplete;

  const NatureWalkTask({
    super.key,
    required this.onWalkComplete,
    required this.onComplete,
    required bool isCompleted,
  });

  @override
  State<NatureWalkTask> createState() => _NatureWalkTaskState();
}

class _NatureWalkTaskState extends State<NatureWalkTask> {
  static const int totalDuration = 3; // use 600 for 10 mins
  int _secondsLeft = totalDuration;
  bool _isStarted = false;
  bool _completed = false;
  bool _showRestart = false;
  Timer? _timer;
  bool _alreadyReported = false;

  String? _userKey;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userKey = 'natureWalkTaskCompleted_$uid';
      _loadCompletionState();
    }
  }

  Future<void> _loadCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_userKey!) ?? false;

    setState(() {
      _completed = completed;
      _showRestart = completed;
      if (completed) {
        _secondsLeft = 0;
        _isStarted = false;
        _alreadyReported = true;
      }
    });
  }

  Future<void> _saveCompletionState(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    if (_userKey != null) {
      await prefs.setBool(_userKey!, completed);
    }
  }

  Future<void> _resetCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userKey != null) {
      await prefs.remove(_userKey!);
    }
  }

  void startWalk() {
    if (_isStarted || _userKey == null) return;

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
          widget.onWalkComplete();
          widget.onComplete();
          _alreadyReported = true;
          _saveCompletionState(true);
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() => _showRestart = true);
        });
      }
    });
  }

  void _restartWalk() async {
    await _resetCompletionState();
    _timer?.cancel();
    setState(() {
      _secondsLeft = totalDuration;
      _completed = false;
      _showRestart = false;
      _isStarted = false;
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
          'assets/lottie/nature_park.json',
          height: 270,
          width: 270,
          repeat: true,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        Text(
          _completed ? "Walk Complete!" : "Time Left: $mins:$secs",
          style: GoogleFonts.outfit(fontSize: 24, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Text(
          _completed
              ? "Nature is healing 🌿"
              : "Walk slowly. Breathe deeply. Let your thoughts go. Feel the earth beneath you.",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isStarted
              ? null
              : _completed && _showRestart
                  ? _restartWalk
                  : startWalk,
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
                ? (_showRestart ? 'Restart Walk' : 'Walk Complete!')
                : 'Start 10-Min Walk',
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
