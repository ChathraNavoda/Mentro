import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DancePartyTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const DancePartyTask({
    Key? key,
    required this.onComplete,
    required this.isCompleted,
  }) : super(key: key);

  @override
  State<DancePartyTask> createState() => _DancePartyTaskState();
}

class _DancePartyTaskState extends State<DancePartyTask> {
  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confettiController;

  int _secondsLeft = 30;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 5));
    if (widget.isCompleted) {
      _completed = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startDanceParty() async {
    if (_isPlaying) return;

    _completed = false;
    _secondsLeft = 30;
    setState(() => _isPlaying = true);

    await _player.setUrl(
      'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/dance-party1.mp3',
    );
    await _player.setVolume(_isMuted ? 0.0 : 1.0);
    await _player.setLoopMode(LoopMode.one);
    _player.play();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);

      if (_secondsLeft <= 0) {
        timer.cancel();
        _player.stop();
        _confettiController.play();
        _saveProgress();
        widget.onComplete();
        setState(() {
          _completed = true;
          _isPlaying = false;
        });
      }
    });
  }

  void _restartDanceParty() {
    _timer?.cancel();
    _player.stop();
    setState(() {
      _secondsLeft = 30;
      _isPlaying = false;
      _completed = false;
    });
    _startDanceParty();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final key = 'neutral_tasks_$uid';
    final timeKey = 'neutral_time_$uid';

    List<String> existing = prefs.getStringList(key) ?? [];
    if (!existing.contains('1')) {
      existing.add('1');
      await prefs.setStringList(key, existing);
      await prefs.setString(timeKey, DateTime.now().toIso8601String());
    }
  }

  Widget _buildConfetti() {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      gravity: 0.4,
      emissionFrequency: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            Lottie.asset(
              'assets/lottie/dance.json',
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 20),
            Text(
              _completed
                  ? "🎉 Dance Complete!"
                  : "Time Left: $_secondsLeft seconds",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _completed ? _restartDanceParty : _startDanceParty,
              icon: Icon(Icons.play_arrow),
              label: Text(
                _completed
                    ? "Dance Again!"
                    : _isPlaying
                        ? "Dancing..."
                        : "Start Dance Party",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8ECFE6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() => _isMuted = !_isMuted);
                _player.setVolume(_isMuted ? 0.0 : 1.0);
              },
            ),
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _buildConfetti(),
        ),
      ],
    );
  }
}
