import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const int totalDuration = 3; // 10 minutes in seconds
  int _secondsLeft = totalDuration;
  bool _isStarted = false;
  bool _completed = false;
  bool _showRestart = false;
  Timer? _timer;
  bool _alreadyReported = false;

  void startWalk() {
    if (_isStarted) return;

    setState(() {
      _isStarted = true;
      _completed = false;
      _showRestart = false;
      _secondsLeft = totalDuration;
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
        widget.onWalkComplete();

        if (!_alreadyReported) {
          widget.onComplete(); // ✅ call only once
          _alreadyReported = true; // ✅ mark as done
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() => _showRestart = true);
        });
      }
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
        const Icon(Icons.park, size: 100, color: Color(0xFF4ECDC4)),
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
          onPressed: _isStarted ? null : startWalk,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4ECDC4),
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
