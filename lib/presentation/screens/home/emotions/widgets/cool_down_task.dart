import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoolDownTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const CoolDownTask({
    super.key,
    required this.onComplete,
    required this.isCompleted,
  });

  @override
  State<CoolDownTask> createState() => _CoolDownTaskState();
}

class _CoolDownTaskState extends State<CoolDownTask>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _breathController;
  late ConfettiController _confettiController;

  int coolSeconds = 0;
  final int targetSeconds = 80;
  bool _isCompleted = false;
  bool _isHolding = false;

  final List<String> _bgAudioUrls = [
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track1.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track2.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track3.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    if (!_isCompleted) {
      loadProgress();
      startAmbientAudio();
    }
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final saved = prefs.getBool('angry_cool_done_$uid') ?? false;
    if (saved) {
      setState(() => _isCompleted = true);
    }
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await prefs.setBool('angry_cool_done_$uid', true);
  }

  void startAmbientAudio() async {
    final random = Random();
    final selected = _bgAudioUrls[random.nextInt(_bgAudioUrls.length)];
    await _audioPlayer.setUrl(selected);
    await _audioPlayer.setLoopMode(LoopMode.one);

    _audioPlayer.play();
  }

  void restartTask() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.remove('angry_cool_done_$uid');
    }

    setState(() {
      coolSeconds = 0;
      _isCompleted = false;
    });

    startAmbientAudio();
  }

  void handleHoldStart() {
    _isHolding = true;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isHolding || _isCompleted) {
        timer.cancel();
        return;
      }

      setState(() => coolSeconds++);
      if (coolSeconds >= targetSeconds) {
        timer.cancel();
        completeTask();
      }
    });
  }

  void handleHoldEnd() {
    _isHolding = false;
  }

  void completeTask() {
    setState(() => _isCompleted = true);
    _confettiController.play();
    widget.onComplete();
    saveProgress();
    _audioPlayer.stop();
  }

  String getCoolEmoji() {
    if (coolSeconds == 0) return "🔥🔥🔥";
    if (coolSeconds < targetSeconds * 0.25) return "🔥❄️🔥";
    if (coolSeconds < targetSeconds * 0.5) return "🔥❄️❄️";
    if (coolSeconds < targetSeconds * 0.75) return "❄️❄️❄️";
    return "❄️🌬️❄️";
  }

  @override
  void dispose() {
    _breathController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isCompleted
        ? Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("❄️😌 Chill Mode Activated",
                        style: TextStyle(fontSize: 25)),
                    const SizedBox(height: 20),
                    Text("You're fully cooled down!",
                        style: GoogleFonts.outfit(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: restartTask,
                      icon: const Icon(Icons.replay, color: Colors.white),
                      label: Text("Restart",
                          style: GoogleFonts.outfit(
                              fontSize: 14, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF7A87),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        elevation: 0,
                      ),
                    )
                  ],
                ),
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.blueAccent, Colors.white, Colors.cyan],
              )
            ],
          )
        : Center(
            child: GestureDetector(
              onTapDown: (_) => handleHoldStart(),
              onTapUp: (_) => handleHoldEnd(),
              onTapCancel: () => handleHoldEnd(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Tap and hold to cool down",
                      style: GoogleFonts.outfit(
                          fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text("${targetSeconds - coolSeconds} seconds to go",
                      style: GoogleFonts.outfit(fontSize: 16)),
                  const SizedBox(height: 30),
                  ScaleTransition(
                    scale: _breathController,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4ECDC4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.shade100,
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(Icons.ac_unit_rounded,
                          size: 60, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "$coolSeconds / $targetSeconds sec cooled",
                    style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4ECDC4)),
                  ),
                  const SizedBox(height: 20),
                  Text(getCoolEmoji(), style: const TextStyle(fontSize: 40)),
                ],
              ),
            ),
          );
  }
}
