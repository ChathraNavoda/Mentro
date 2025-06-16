import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpinWheelTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const SpinWheelTask({
    Key? key,
    required this.onComplete,
    required this.isCompleted,
  }) : super(key: key);

  @override
  State<SpinWheelTask> createState() => _SpinWheelTaskState();
}

class _SpinWheelTaskState extends State<SpinWheelTask> {
  int? _selectedIndex; // add this

  final List<String> _motivations = [
    "Text a friend just to say hi 👋",
    "Stretch and breathe for 30 seconds 🧘‍♂️",
    "Play your favorite song right now 🎵",
    "Smile at your reflection 😄",
    "Take a sip of water 💧",
    "Compliment yourself 🪞",
    "Plan something exciting 🎯",
    "Stand and shake it off 🕺",
  ];

  final List<Color> _sliceColors = [
    Color(0xFF8ECFE6),
    Color(0xFFB2E672),
    Color(0xFFFFD166),
    Color(0xFFF4978E),
    Color(0xFF84DCC6),
    Color(0xFFF2B5D4),
    Color(0xFFCDB4DB),
    Color(0xFF9DE0AD),
  ];

  final StreamController<int> _controller = StreamController<int>();
  late ConfettiController _confettiController;
  bool _hasSpun = false;
  String? _selectedMessage;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 6));
    _loadProgress(); // Load saved message + time
  }

  @override
  void dispose() {
    _controller.close();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final msgKey = 'spin_message_$uid';
    final timeKey = 'spin_time_$uid';

    final savedMessage = prefs.getString(msgKey);
    final savedTime = prefs.getString(timeKey);

    final indexKey = 'spin_index_$uid';
    final savedIndex = prefs.getInt(indexKey);

    if (savedMessage != null && savedTime != null && savedIndex != null) {
      final lastSpin = DateTime.tryParse(savedTime);
      if (lastSpin != null) {
        final now = DateTime.now();
        final difference = now.difference(lastSpin);
        if (difference.inHours < 24) {
          setState(() {
            _hasSpun = true;
            _selectedMessage = savedMessage;
            _selectedIndex = savedIndex;
          });
          return;
        }
      }
    }

    // If 24+ hours passed, reset
    setState(() {
      _hasSpun = false;
      _selectedMessage = null;
    });
  }

  Future<void> _saveProgress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final msgKey = 'spin_message_$uid';
    final timeKey = 'spin_time_$uid';

    await prefs.setString(msgKey, _motivations[index]);
    await prefs.setInt('spin_index_$uid', index);

    await prefs.setString(timeKey, DateTime.now().toIso8601String());

    // If you want to also mark it as completed in shared list:
    final listKey = 'neutral_tasks_$uid';
    List<String> existing = prefs.getStringList(listKey) ?? [];
    if (!existing.contains('0')) {
      existing.add('0');
      await prefs.setStringList(listKey, existing);
    }
  }

  void _spinWheel() {
    if (_hasSpun) return;

    final index = Random().nextInt(_motivations.length);
    _controller.add(index);

    setState(() {
      _hasSpun = true;
      _selectedMessage = _motivations[index];
      _selectedIndex = index;
    });
    _confettiController.play();
    _saveProgress(index); // <-- pass index here
    widget.onComplete();
  }

  Widget _buildResultCard() {
    if (!_hasSpun || _selectedMessage == null || _selectedIndex == null)
      return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sliceColors[_selectedIndex!],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        _selectedMessage!,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      emissionFrequency: 0.05,
      numberOfParticles: 30,
      gravity: 0.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            const SizedBox(height: 40),
            SizedBox(
              height: 270,
              child: FortuneWheel(
                selected: _controller.stream,
                items: List.generate(_motivations.length, (index) {
                  return FortuneItem(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _motivations[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    style: FortuneItemStyle(
                      color: _sliceColors[index % _sliceColors.length],
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  );
                }),
                onAnimationEnd: () {},
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _hasSpun ? null : _spinWheel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8ECFE6),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                _hasSpun ? 'Come back tomorrow!' : 'Spin the Wheel!',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _buildResultCard(),
          ],
        ),
        _buildConfetti(),
      ],
    );
  }
}
