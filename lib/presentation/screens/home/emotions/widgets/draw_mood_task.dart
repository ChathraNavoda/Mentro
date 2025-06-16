import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawMoodTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const DrawMoodTask({
    Key? key,
    required this.onComplete,
    required this.isCompleted,
  }) : super(key: key);

  @override
  State<DrawMoodTask> createState() => _DrawMoodTaskState();
}

class _DrawMoodTaskState extends State<DrawMoodTask> {
  List<Map<String, dynamic>> _points = [];
  Color _selectedColor = Colors.black;
  bool _isDrawing = false;
  bool _isCompleted = false;
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();

  final List<Color> _availableColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    if (!_isCompleted) loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final saved = prefs.getBool('neutral_draw_done_$uid') ?? false;
      if (saved) setState(() => _isCompleted = true);
    }
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await prefs.setBool('neutral_draw_done_$uid', true);
  }

  void _startDrawing() => setState(() => _isDrawing = true);

  void _finishDrawing() {
    if (_points.isNotEmpty) {
      _confettiController.play();
      saveProgress();
      setState(() {
        _isCompleted = true;
        _isDrawing = false;
      });
      widget.onComplete();
    }
  }

  void _clearCanvas() => setState(() => _points.clear());

  void _restart() {
    setState(() {
      _points.clear();
      _isDrawing = false;
      _isCompleted = false;
    });
  }

  void _takeScreenshot() async {
    final image = await _screenshotController.capture(pixelRatio: 3.0);
    if (image == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Here's your drawing",
              style: GoogleFonts.outfit(fontSize: 18)),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(image),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_isDrawing && !_isCompleted)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Feeling boring? Draw something!',
                    style: GoogleFonts.outfit(fontSize: 20),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startDrawing,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF8ECFE6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(
                    'Start Drawing',
                  ),
                ),
              ],
            ),
          )
        else if (_isDrawing)
          Column(
            children: [
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Stack(
                  children: [
                    Screenshot(
                      controller: _screenshotController,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          Offset point =
                              renderBox.globalToLocal(details.globalPosition);
                          setState(() => _points
                              .add({'point': point, 'color': _selectedColor}));
                        },
                        onPanEnd: (_) => _points
                            .add({'point': null, 'color': _selectedColor}),
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _MultiColorPainter(_points),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 60,
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: _clearCanvas,
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: 'Clear Canvas',
                          ),
                          IconButton(
                            onPressed: _takeScreenshot,
                            icon:
                                const Icon(Icons.download, color: Colors.blue),
                            tooltip: 'Take Screenshot',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _finishDrawing,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF8ECFE6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child:
                    const Text('Finish', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
            ],
          )
        else if (_isCompleted)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You completed it 🎉',
                    style: GoogleFonts.outfit(
                        fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _restart,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF8ECFE6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text(
                    'Restart',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }
}

class _MultiColorPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;

  _MultiColorPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      var p1 = points[i];
      var p2 = points[i + 1];
      if (p1['point'] != null && p2['point'] != null) {
        final paint = Paint()
          ..color = p1['color']
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4.0;
        canvas.drawLine(p1['point'], p2['point'], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
