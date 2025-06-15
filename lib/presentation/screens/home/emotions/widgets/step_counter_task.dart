import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const StepCounterTask({
    super.key,
    required this.onComplete,
    required this.isCompleted,
  });

  @override
  State<StepCounterTask> createState() => _StepCounterTaskState();
}

class _StepCounterTaskState extends State<StepCounterTask> {
  static const int targetSteps = 200;
  int _steps = 0;
  int? _initialSteps;
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _subscription;

  bool _sensorAvailable = true;
  bool _trackingStarted = false;
  bool _permissionGranted = false;

  bool _taskCompleted = false;
  bool _showRestart = false;

  String? _userKey;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userKey = 'stepCounterTaskCompleted_$uid';
      _loadTaskCompleted();
    }
  }

  Future<void> _loadTaskCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_userKey!) ?? false;

    setState(() {
      _taskCompleted = completed;
      _showRestart = completed;
    });
  }

  Future<void> _saveTaskCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (_userKey != null) {
      await prefs.setBool(_userKey!, value);
    }
  }

  Future<void> _resetTaskCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userKey != null) {
      await prefs.remove(_userKey!);
    }
  }

  Future<void> _startTracking() async {
    final status = await Permission.activityRecognition.request();

    if (!status.isGranted) {
      setState(() => _permissionGranted = false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please allow activity recognition permission')),
        );
      }
      return;
    }

    setState(() {
      _permissionGranted = true;
      _trackingStarted = true;
    });

    try {
      _stepCountStream = Pedometer.stepCountStream;
      _subscription = _stepCountStream!.listen(onStepCount);
      _subscription!.onError((error) {
        setState(() => _sensorAvailable = false);
      });
    } catch (e) {
      setState(() => _sensorAvailable = false);
    }
  }

  void onStepCount(StepCount event) {
    if (!mounted || _taskCompleted) return;

    setState(() {
      _initialSteps ??= event.steps;
      _steps = max(0, event.steps - _initialSteps!);
    });

    if (_steps >= targetSteps) {
      _completeTask();
    }
  }

  void _simulateSteps() {
    if (_taskCompleted) return;

    setState(() => _steps += 20);

    if (_steps >= targetSteps) {
      _completeTask();
    }
  }

  void _completeTask() {
    _subscription?.cancel();

    setState(() {
      _taskCompleted = true;
      _trackingStarted = false;
      _showRestart = true;
    });

    _saveTaskCompleted(true);
    widget.onComplete();
  }

  void _restartTask() async {
    _subscription?.cancel();
    await _resetTaskCompleted();

    setState(() {
      _steps = 0;
      _initialSteps = null;
      _sensorAvailable = true;
      _trackingStarted = false;
      _permissionGranted = false;
      _taskCompleted = false;
      _showRestart = false;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _taskCompleted || _steps >= targetSteps;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lottie/step_counter.json',
          height: 215,
          width: 215,
          repeat: true,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Text(
          isDone ? "Task Completed! 🎉" : "Steps: $_steps / $targetSteps",
          style: GoogleFonts.outfit(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: LinearProgressIndicator(
            value: (_steps / targetSteps).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            color: const Color(0xFFBA90D0),
          ),
        ),
        const SizedBox(height: 16),
        if (!isDone && !_trackingStarted)
          ElevatedButton.icon(
            onPressed: _startTracking,
            icon: const Icon(Icons.directions_walk, color: Colors.white),
            label: Text(
              "Start Walk",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFBA90D0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        if (isDone && _showRestart)
          ElevatedButton.icon(
            onPressed: _restartTask,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              "Restart Walk",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFBA90D0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          isDone
              ? "You’ve taken a healing walk 💜"
              : !_permissionGranted
                  ? "Permission needed to track steps."
                  : !_trackingStarted
                      ? "Tap 'Start Walk' to begin step tracking."
                      : _sensorAvailable
                          ? "Walk around and keep moving 🦶"
                          : "Oops! 😢 Your device doesn't support step tracking sensors.\nBut you can still simulate steps to complete this task!",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 16),
        ),
        const SizedBox(height: 20),
        if (!_sensorAvailable && !isDone && _trackingStarted)
          ElevatedButton.icon(
            onPressed: _simulateSteps,
            icon: const Icon(Icons.touch_app, color: Colors.white),
            label: Text(
              "Simulate Steps",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFBA90D0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
      ],
    );
  }
}
