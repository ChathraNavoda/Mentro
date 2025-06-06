import 'dart:async';
import 'dart:math';

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
    return BreathingTab(
      onBreathingComplete: () {
        if (!_completedTasks.contains(1)) {
          setState(() {
            _completedTasks.add(1); // mark breathing as complete
          });
        }
      },
    );
  }

  Widget buildYogaTab() {
    return YogaTab(
      onYogaComplete: () {
        if (!_completedTasks.contains(2)) {
          setState(() {
            _completedTasks.add(2); // mark yoga as complete
          });
        }
      },
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
                        color: Colors.black,
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
                        color: Colors.black,
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
  int _secondsLeft = 80;

  final List<String> _trackUrls = [
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track1.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track2.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track3.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track4.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track5.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track6.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track7.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track8.mp3',
    'https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/sounds/track9.mp3',
  ];

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void startMeditation() async {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
      _secondsLeft = 80;
      _completed = false;
    });
    // Pick a random track
    final random = Random();
    final selectedUrl = _trackUrls[random.nextInt(_trackUrls.length)];

    try {
      await _player.setUrl(selectedUrl);
      _player.play();
    } catch (e) {
      print('Error loading track: $e');
      return;
    }

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
          _completed ? 'Meditation Complete!' : 'Seconds Left: $_secondsLeft',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        Text(
          _completed
              ? 'Meditation Complete!'
              : 'Close your eyes and listen to the music! 💆',
          style: const TextStyle(fontSize: 16),
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

//breath

class BreathingTab extends StatefulWidget {
  final VoidCallback onBreathingComplete;

  const BreathingTab({super.key, required this.onBreathingComplete});

  @override
  State<BreathingTab> createState() => _BreathingTabState();
}

class _BreathingTabState extends State<BreathingTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  int _secondsLeft = 60;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _completed = false;

  final List<String> _breathingText = [
    "🌬️ Breathe in...",
    "😮‍💨 Hold...",
    "😌 Breathe out..."
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void startBreathing() {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
      _completed = false;
      _secondsLeft = 60;
      _currentIndex = 0;
    });

    _controller.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % _breathingText.length;
        _secondsLeft -= 4;
      });

      if (_secondsLeft <= 0) {
        timer.cancel();
        _controller.stop();
        setState(() {
          _isPlaying = false;
          _completed = true;
        });
        widget.onBreathingComplete(); // ✅ trigger progress
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isPlaying || _completed)
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.5).animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut,
            )),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF4ECDC4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        const SizedBox(height: 30),
        Text(
          _completed ? 'Breathing Complete!' : _breathingText[_currentIndex],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Time Left: $_secondsLeft sec',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isPlaying ? null : startBreathing,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4ECDC4),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(_completed ? 'Completed' : 'Start Breathing'),
        ),
      ],
    );
  }
}

class YogaPose {
  final String name;
  final String benefit;
  final int duration; // seconds
  final String animationPath; // Lottie or GIF

  YogaPose({
    required this.name,
    required this.benefit,
    required this.duration,
    required this.animationPath,
  });
}

class YogaTab extends StatefulWidget {
  final VoidCallback onYogaComplete;

  const YogaTab({super.key, required this.onYogaComplete});

  @override
  State<YogaTab> createState() => _YogaTabState();
}

class _YogaTabState extends State<YogaTab> {
  final List<YogaPose> poses = [
    YogaPose(
      name: "Child’s Pose",
      benefit: "Relaxes spine and calms the mind.",
      duration: 30,
      animationPath: "assets/lottie/yoga1.json", // replace later
    ),
    YogaPose(
      name: "Cat-Cow",
      benefit: "Releases back tension and syncs breath.",
      duration: 30,
      animationPath: "assets/lottie/yoga2.json",
    ),
    YogaPose(
      name: "Legs Up the Wall",
      benefit: "Improves blood flow and eases anxiety.",
      duration: 30,
      animationPath: "assets/lottie/yoga3.json",
    ),
  ];

  int currentPoseIndex = 0;
  int secondsLeft = 0;
  bool isStarted = false;
  bool isPoseComplete = false;
  Timer? timer;

  void startPose() {
    final currentPose = poses[currentPoseIndex];

    setState(() {
      secondsLeft = currentPose.duration;
      isStarted = true;
      isPoseComplete = false;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      setState(() {
        secondsLeft--;
      });

      if (secondsLeft <= 0) {
        t.cancel();
        setState(() {
          isPoseComplete = true;
        });
      }
    });
  }

  void nextPose() {
    if (currentPoseIndex < poses.length - 1) {
      setState(() {
        currentPoseIndex++;
        isStarted = false;
        isPoseComplete = false;
      });
    } else {
      // Yoga session complete
      widget.onYogaComplete();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pose = poses[currentPoseIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            pose.animationPath,
            height: 200,
            repeat: isStarted && !isPoseComplete,
          ),
          const SizedBox(height: 20),
          Text(
            pose.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            pose.benefit,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          if (isStarted)
            Text(
              isPoseComplete
                  ? "✅ Pose Complete!"
                  : "Time Left: $secondsLeft sec",
              style: const TextStyle(fontSize: 18),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                isStarted ? (isPoseComplete ? nextPose : null) : startPose,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              isStarted
                  ? (isPoseComplete ? "Next Pose" : "In Progress...")
                  : "Start Pose",
            ),
          ),
        ],
      ),
    );
  }
}
