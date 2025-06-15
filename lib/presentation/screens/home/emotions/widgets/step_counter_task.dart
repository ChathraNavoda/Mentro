// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pedometer/pedometer.dart';
// import 'package:permission_handler/permission_handler.dart';

// class StepCounterTask extends StatefulWidget {
//   final VoidCallback onComplete;
//   final bool isCompleted;

//   const StepCounterTask({
//     super.key,
//     required this.onComplete,
//     required this.isCompleted,
//   });

//   @override
//   State<StepCounterTask> createState() => _StepCounterTaskState();
// }

// class _StepCounterTaskState extends State<StepCounterTask> {
//   static const int targetSteps = 200;
//   int _steps = 0;
//   int? _initialSteps;
//   Stream<StepCount>? _stepCountStream;

//   @override
//   void initState() {
//     super.initState();
//     initStepCounter();
//   }

//   // Future<void> initStepCounter() async {
//   //   final permission = await Permission.activityRecognition.request();
//   //   debugPrint("Permission status: $permission");
//   //   if (!permission.isGranted) {
//   //     if (context.mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //             content: Text('Please allow activity recognition permission')),
//   //       );
//   //     }
//   //     return;
//   //   }

//   //   _stepCountStream = Pedometer.stepCountStream;
//   //   _stepCountStream!.listen(onStepCount).onError((error) {
//   //     debugPrint("Step Count Error: $error");
//   //   });
//   // }

//   void onStepCount(StepCount event) {
//     if (!mounted || widget.isCompleted) return;

//     setState(() {
//       _initialSteps ??= event.steps;
//       _steps = event.steps - _initialSteps!;
//     });

//     if (_steps >= targetSteps) {
//       widget.onComplete();
//     }
//   }

//   Future<void> initStepCounter() async {
//     final permission = await Permission.activityRecognition.request();
//     debugPrint("Permission status: $permission");
//     if (!permission.isGranted) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Please allow activity recognition permission')),
//         );
//       }
//       return;
//     }

//     try {
//       _stepCountStream = Pedometer.stepCountStream;
//       _stepCountStream!.listen(onStepCount).onError((error) {
//         debugPrint("Step Count Error: $error");
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('Step counter not supported on this device')),
//           );
//         }
//       });
//     } catch (e) {
//       debugPrint("Exception initializing step counter: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Icon(Icons.directions_walk, size: 100, color: Color(0xFF4ECDC4)),
//         const SizedBox(height: 16),
//         Text(
//           widget.isCompleted
//               ? "🚶 Task Completed!"
//               : "Steps: $_steps / $targetSteps",
//           style: GoogleFonts.outfit(fontSize: 20),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           widget.isCompleted
//               ? "You’ve taken a healing walk 💙"
//               : "Walk around for a bit. Keep moving to feel better.",
//           textAlign: TextAlign.center,
//           style: GoogleFonts.outfit(fontSize: 16),
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () {
//             if (_steps < targetSteps) {
//               setState(() => _steps += 50); // simulate steps
//             }
//             if (_steps >= targetSteps && !widget.isCompleted) {
//               widget.onComplete();
//             }
//           },
//           child: Text("Simulate Walking"),
//         ),
//       ],
//     );
//   }
// }
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted; // You can remove this if no longer needed externally

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
  static const String _prefsTaskCompletedKey = 'stepCounterTaskCompleted';

  int _steps = 0;
  int? _initialSteps;
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _subscription;

  bool _sensorAvailable = true;
  bool _trackingStarted = false;
  bool _permissionGranted = false;

  bool _taskCompleted = false;
  bool _showRestart = false;

  @override
  void initState() {
    super.initState();
    _loadTaskCompleted();
  }

  Future<void> _loadTaskCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_prefsTaskCompletedKey) ?? false;

    setState(() {
      _taskCompleted = completed;
      _showRestart = completed;
    });
  }

  Future<void> _saveTaskCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsTaskCompletedKey, value);
  }

  Future<void> _startTracking() async {
    debugPrint("🟡 Requesting activityRecognition permission...");
    final status = await Permission.activityRecognition.request();

    if (!status.isGranted) {
      debugPrint("❌ Permission denied.");
      setState(() => _permissionGranted = false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please allow activity recognition permission')),
        );
      }
      return;
    }

    debugPrint("✅ Permission granted.");
    setState(() {
      _permissionGranted = true;
      _trackingStarted = true;
    });

    try {
      debugPrint("🟢 Subscribing to stepCountStream...");
      _stepCountStream = Pedometer.stepCountStream;
      debugPrint("✅ Step Count Stream initialized: $_stepCountStream");
      _subscription = _stepCountStream!.listen(onStepCount);
      _subscription!.onError((error) {
        debugPrint("❌ Step Count Error: $error");
        setState(() => _sensorAvailable = false);
      });
    } catch (e) {
      debugPrint("❌ Sensor init failed: $e");
      setState(() => _sensorAvailable = false);
    }
  }

  void onStepCount(StepCount event) {
    debugPrint("📶 New Step Event: ${event.steps}");
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
    debugPrint("✅ Task Completed!");
    _subscription?.cancel();

    setState(() {
      _taskCompleted = true;
      _trackingStarted = false;
      _showRestart = true;
    });

    _saveTaskCompleted(true);

    widget.onComplete();
  }

  void _restartTask() {
    debugPrint("🔁 Restarting step counter task...");
    _subscription?.cancel();

    setState(() {
      _steps = 0;
      _initialSteps = null;
      _sensorAvailable = true;
      _trackingStarted = false;
      _permissionGranted = false;
      _taskCompleted = false;
      _showRestart = false;
    });

    _saveTaskCompleted(false);
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
          'assets/lottie/step_counter.json', // or whatever path you use
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

        // Start or Restart button logic
        if (!isDone && !_trackingStarted)
          ElevatedButton.icon(
            onPressed: _startTracking,
            icon: const Icon(
              Icons.directions_walk,
              color: Colors.white,
            ),
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
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
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
            icon: const Icon(
              Icons.touch_app,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFBA90D0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            label: Text(
              "Simulate Steps",
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
