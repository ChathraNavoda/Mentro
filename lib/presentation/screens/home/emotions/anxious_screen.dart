import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';

class AnxiousScreen extends StatefulWidget {
  const AnxiousScreen({super.key});

  @override
  State<AnxiousScreen> createState() => _AnxiousScreenState();
}

class _AnxiousScreenState extends State<AnxiousScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _completedTasks = {};
  bool _isBookmarked = false;
  bool _isSoundOn = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      setState(() {
        _completedTasks.add(_tabController.index);
      });
    });
  }

  Widget buildMeditationTab() {
    return _MeditationWidget(
      onMeditationComplete: () {
        if (!_completedTasks.contains(0)) {
          setState(() {
            _completedTasks.add(0); // mark meditation as complete
          });
        }
      },
    );
  }

  Widget buildBreathingTab() {
    return Center(
      child: Text(
        "🌬️ Breathe in... Hold... Breathe out...\n(Use an animation here!)",
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontSize: 18),
      ),
    );
  }

  Widget buildYogaTab() {
    return Center(
      child: Text(
        "🧎 Gentle yoga poses to release tension\n(Show images or timer)",
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = _completedTasks.length;
    bool allCompleted = completedCount == 3;

    return Scaffold(
      appBar: AppBar(
        title: Text('Feeling Anxious?', style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF4ECDC4),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.self_improvement), text: 'Meditation'),
            Tab(icon: Icon(Icons.air), text: 'Breathing'),
            Tab(icon: Icon(Icons.accessibility_new), text: 'Yoga'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildMeditationTab(),
                buildBreathingTab(),
                buildYogaTab(),
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
                      ? "🎉 You completed today’s calm journey!"
                      : "Progress: $completedCount/3 tasks completed",
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.purple,
                      ),
                      onPressed: () {
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _isSoundOn ? Icons.volume_up : Icons.volume_off,
                        color: Colors.teal,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSoundOn = !_isSoundOn;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text('Back to Home', style: GoogleFonts.outfit()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///Meditation

class _MeditationWidget extends StatefulWidget {
  final VoidCallback onMeditationComplete;

  const _MeditationWidget({super.key, required this.onMeditationComplete});

  @override
  State<_MeditationWidget> createState() => _MeditationWidgetState();
}

class _MeditationWidgetState extends State<_MeditationWidget> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _completed = false;
  int _secondsLeft = 60;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void startMeditation() async {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
      _secondsLeft = 60;
      _completed = false;
    });

    await _player.setAsset('assets/sounds/memories.mp3');
    _player.play();

    // Timer countdown
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 0) {
        timer.cancel();
        _player.stop();
        setState(() {
          _isPlaying = false;
          _completed = true;
        });
        widget.onMeditationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(
          'assets/lottie/meditation2.json',
          height: 200,
          repeat: _isPlaying,
        ),
        const SizedBox(height: 20),
        Text(
          _completed
              ? '🎉 You completed your mindfulness session!'
              : 'Affirmation: "I am calm, I am in control."',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        Text(
          'Time Left: $_secondsLeft sec',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isPlaying ? null : startMeditation,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24))),
          child: Text(_completed ? 'Completed' : 'Start Meditation'),
        ),
      ],
    );
  }
}
