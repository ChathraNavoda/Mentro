import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:mentro/core/services/notification/reminder_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnxiousScreen extends StatefulWidget {
  const AnxiousScreen({super.key});

  @override
  State<AnxiousScreen> createState() => _AnxiousScreenState();
}

class _AnxiousScreenState extends State<AnxiousScreen>
    with SingleTickerProviderStateMixin {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late ConfettiController _confettiController;
  late TabController _tabController;
  final Set<int> _completedTasks = {};
  bool _wasAllCompletedBefore = false;
  Timer? _countdownTimer;
  Duration? _timeLeft;
  DateTime? _completionTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    _requestNotificationPermission();

    // ✅ Check immediately and periodically every minute
    checkCompletionState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      checkCompletionState();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

// ✅ Ask for notification permission
  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Widget buildCountdownBanner() {
    if (_timeLeft == null) return const SizedBox();

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_timeLeft!.inHours);
    final minutes = twoDigits(_timeLeft!.inMinutes.remainder(60));
    final seconds = twoDigits(_timeLeft!.inSeconds.remainder(60));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Color(0xFFB9AA9D)),
          const SizedBox(width: 8),
          Text(
            'Your journey will be restarted in',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            '$hours:$minutes:$seconds',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color.fromARGB(224, 255, 13, 0),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMeditationTab() {
    return _MeditationWidget(
      onMeditationComplete: () {
        if (!_completedTasks.contains(0)) {
          setState(() {
            _completedTasks.add(0); // mark meditation as complete
          });
          saveCompletionState();
        }
      },
    );
  }

  Future<bool> checkCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !mounted) return false;

    final savedTasks = prefs.getStringList('completed_tasks_$uid');
    final timeString = prefs.getString('completion_time_$uid');

    if (savedTasks != null && timeString != null) {
      final savedTime = DateTime.parse(timeString);
      final now = DateTime.now();

      if (now.difference(savedTime).inHours < 24) {
        setState(() {
          _completedTasks
            ..clear()
            ..addAll(savedTasks.map(int.parse));
          _wasAllCompletedBefore = _completedTasks.length == 3;
          _completionTime = savedTime;
          _timeLeft = Duration(hours: 24) - now.difference(savedTime);
        });
        startCountdown();
        return _completedTasks.length < 3; // ✅ INCOMPLETE
      }

      // Clean up expired
      await prefs.remove('completed_tasks_$uid');
      await prefs.remove('completion_time_$uid');
    }

    setState(() {
      _completedTasks.clear();
      _wasAllCompletedBefore = false;
    });

    return false;
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
        setState(() {
          _timeLeft = null;
        });
      } else {
        setState(() {
          _timeLeft = diff;
        });
      }
    });
  }

  // ✅ Save calm task completion
  Future<void> saveCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now().toIso8601String();
    final completedCount = _completedTasks.length;

    await prefs.setStringList(
      'completed_tasks_$uid',
      _completedTasks.map((e) => e.toString()).toList(),
    );
    await prefs.setString('completion_time_$uid', now);

    if (completedCount == 3) {
      await ReminderService.noReminder();
    } else if (completedCount > 0) {
      await ReminderService.oneHourReminder();
      await ReminderService.daily8PMReminder(completedCount);
    } else {
      await ReminderService.noReminder();
    }
  }

  Widget buildBreathingTab() {
    return BreathingTab(
      onBreathingComplete: () {
        if (!_completedTasks.contains(1)) {
          setState(() {
            _completedTasks.add(1); // mark breathing as complete
          });
          saveCompletionState();
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
          saveCompletionState();
        }
      },
    );
  }

  Path drawStar(Size size) {
    // ⭐ Draw star shape
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final path = Path();
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2.5;
    final center = Offset(size.width / 2, size.height / 2);

    double angle = degToRad(360 / numberOfPoints);
    for (int i = 0; i < numberOfPoints * 2; i++) {
      final isEven = i % 2 == 0;
      final radius = isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * cos(i * angle);
      final y = center.dy + radius * sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Widget buildStarConfetti() {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      numberOfParticles: 30,
      maxBlastForce: 20,
      minBlastForce: 8,
      emissionFrequency: 0.05,
      gravity: 0.3,
      createParticlePath: drawStar, // ⭐ use your custom star shape
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = _completedTasks.length;
    bool allCompleted = completedCount == 3;
    // 🎉 Play confetti only once
    if (allCompleted && !_wasAllCompletedBefore) {
      _wasAllCompletedBefore = true;
      _confettiController.play();
      saveCompletionState(); // 🧠 Save only once when all 3 done
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9AA9D), // ✅ AppBar only
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Feeling Anxious?',
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFB9AA9D),
            unselectedLabelColor: Colors.black,
            dividerColor: Colors.black87,
            indicatorColor: const Color(0xFFB9AA9D),
            unselectedLabelStyle:
                GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400),
            labelStyle:
                GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400),
            tabs: const [
              Tab(icon: Icon(Icons.self_improvement_sharp), text: 'Meditation'),
              Tab(icon: Icon(Icons.air), text: 'Breathing'),
              Tab(icon: Icon(Icons.accessibility_new_rounded), text: 'Yoga'),
            ],
          ),
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
          const Divider(height: 1, color: Colors.black87),
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
                Align(
                    alignment: Alignment.topCenter, child: buildStarConfetti()),
                buildCountdownBanner(),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: Text(
                    'Back to Home',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFB9AA9D),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
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

  const _MeditationWidget({required this.onMeditationComplete});

  @override
  State<_MeditationWidget> createState() => _MeditationWidgetState();
}

class _MeditationWidgetState extends State<_MeditationWidget> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _completed = false;
  bool _showRestart = false;
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
      _completed = false;
      _showRestart = false;
      _secondsLeft = 80;
    });

    final random = Random();
    final selectedUrl = _trackUrls[random.nextInt(_trackUrls.length)];

    try {
      await _player.setUrl(selectedUrl);
      _player.play();
    } catch (e) {
      print('Error loading track: $e');
      return;
    }

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

        // Wait 2 seconds, then show restart button
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _showRestart = true;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Lottie.asset(
            'assets/lottie/meditation2.json',
            height: 180,
            repeat: _isPlaying,
          ),
          const SizedBox(height: 15),
          Text(
            _completed ? 'Meditation Complete!' : 'Seconds Left: $_secondsLeft',
            style: GoogleFonts.outfit(fontSize: 20, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.center,
            child: Text(
              _completed
                  ? 'You did great!'
                  : 'Close your eyes. Breathe in deeply. Let the music guide you. You are safe. You are calm. You are present.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Time Left: $_secondsLeft sec',
            style: GoogleFonts.outfit(
                fontSize: 16,
                color: Color(0xFFB9AA9D),
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isPlaying ? null : startMeditation,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFB9AA9D),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              _completed
                  ? (_showRestart
                      ? 'Restart Meditation'
                      : 'Meditation Complete!')
                  : 'Start Meditation',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
  Timer? _timer;
  int _secondsLeft = 60;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _completed = false;
  bool _showRestart = false;

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
      duration: const Duration(seconds: 5),
    );
  }

  void startBreathing() {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
      _completed = false;
      _showRestart = false;
      _secondsLeft = 60;
      _currentIndex = 0;
    });

    _controller.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % _breathingText.length;
        _secondsLeft -= 5;
      });

      if (_secondsLeft <= 0) {
        timer.cancel();
        _controller.stop();

        setState(() {
          _isPlaying = false;
          _completed = true;
        });

        widget.onBreathingComplete(); // notify

        // 🎉 Show "Completed" briefly, then switch to "Restart Breathing"
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _showRestart = true;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          style: GoogleFonts.outfit(fontSize: 20, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Text(
          'Time Left: $_secondsLeft sec',
          style: GoogleFonts.outfit(
              fontSize: 16,
              color: Color(0xFFB9AA9D),
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isPlaying
              ? null
              : _showRestart
                  ? startBreathing // restart
                  : startBreathing, // first time
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFFB9AA9D),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            _completed
                ? (_showRestart ? 'Restart Breathing' : 'Completed')
                : 'Start Breathing',
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

class YogaPose {
  final String name;
  final String benefit;
  final int duration; // seconds

  final String animationUrl;

  YogaPose({
    required this.name,
    required this.benefit,
    required this.duration,
    required this.animationUrl,
  });
}

class YogaTab extends StatefulWidget {
  final VoidCallback onYogaComplete;

  const YogaTab({super.key, required this.onYogaComplete});

  @override
  State<YogaTab> createState() => _YogaTabState();
}

class _YogaTabState extends State<YogaTab> {
  bool _allComplete = false;

  final List<YogaPose> poses = [
    YogaPose(
      name: "Cat-Cow Pose",
      benefit:
          "Improves spinal flexibility and posture while relieving back and neck tension.",
      duration: 180,
      animationUrl:
          "https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/gif/cat_cow_pose.gif",
    ),
    YogaPose(
      name: "Child's Pose",
      benefit:
          "Gently stretches the back, hips, and thighs while calming the mind and relieving stress.",
      duration: 180,
      animationUrl:
          "https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/gif/child_pose.gif",
    ),
    YogaPose(
      name: "Triangle Pose",
      benefit:
          "Strengthens legs and stretches the hips, spine, and chest while improving balance and digestion.",
      duration: 180,
      animationUrl:
          "https://raw.githubusercontent.com/ChathraNavoda/Mentro/main/assets/gif/triangle_pose.gif",
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
      // All poses completed
      setState(() {
        _allComplete = true;
        isStarted = false;
        isPoseComplete = false;
      });
      widget.onYogaComplete(); // optional callback
    }
  }

  void resetSession() {
    setState(() {
      currentPoseIndex = 0;
      secondsLeft = 0;
      isStarted = false;
      isPoseComplete = false;
      _allComplete = false;
    });
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
          Image.network(pose.animationUrl),
          const SizedBox(height: 15),
          Text(pose.name,
              style: GoogleFonts.outfit(fontSize: 20, color: Colors.black87)),
          const SizedBox(height: 5),
          Text(pose.benefit,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 10),
          if (_allComplete)
            Text(
              "Yoga Session Complete!",
              style: GoogleFonts.outfit(fontSize: 20, color: Colors.black87),
            )
          else if (isStarted)
            Text(
              isPoseComplete ? "Pose Complete!" : "Time Left: $secondsLeft sec",
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Color(0xFFB9AA9D),
                  fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _allComplete
                ? resetSession
                : (isStarted ? (isPoseComplete ? nextPose : null) : startPose),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFB9AA9D),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              _allComplete
                  ? "Restart Session"
                  : (isStarted
                      ? (isPoseComplete ? "Next Pose" : "In Progress...")
                      : "Start Pose"),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
