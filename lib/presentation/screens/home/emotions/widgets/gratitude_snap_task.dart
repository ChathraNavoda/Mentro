import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GratitudeSnapTask extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isCompleted;

  const GratitudeSnapTask({
    Key? key,
    required this.onComplete,
    required this.isCompleted,
  }) : super(key: key);

  @override
  State<GratitudeSnapTask> createState() => _GratitudeSnapTaskState();
}

class _GratitudeSnapTaskState extends State<GratitudeSnapTask> {
  File? _imageFile;
  final picker = ImagePicker();
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 4));
    loadSavedImage();
  }

  Future<void> loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final path = prefs.getString('happy_snap_path_$uid');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _imageFile = File(path);
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _imageFile = file);
      await saveImagePath(pickedFile.path);
      widget.onComplete();
      _confettiController.play();
    }
  }

  Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.setString('happy_snap_path_$uid', path);
    }
  }

  Future<void> resetSnap() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.remove('happy_snap_path_$uid');
    }
    setState(() => _imageFile = null);
  }

  Future<void> saveScreenshotToGallery(
      Uint8List imageBytes, BuildContext context) async {
    final dir =
        await getExternalStorageDirectory(); // app-specific external storage
    final picturesDir = Directory('${dir!.path}/Pictures/Mentro');

    if (!await picturesDir.exists()) {
      await picturesDir.create(recursive: true);
    }

    final filename = 'gratitude_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${picturesDir.path}/$filename');

    await file.writeAsBytes(imageBytes);

    // Show Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image saved at ${file.path}'),
        duration: Duration(seconds: 3),
      ),
    );

    print('✅ Saved at: ${file.path}');
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget buildConfetti() {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      emissionFrequency: 0.05,
      numberOfParticles: 20,
      gravity: 0.3,
      shouldLoop: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  "📸 Gratitude Snap",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Take a picture of something you're grateful for today. It could be anything – your pet, the sky, your cozy corner!",
                  style: GoogleFonts.outfit(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _imageFile != null
                    ? Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(
                              _imageFile!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Gratitude Saved!",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: resetSnap,
                                icon: Icon(Icons.refresh),
                                label: Text("Retake"),
                                style: ElevatedButton.styleFrom(
                                  iconColor: Colors.black,
                                  elevation: 0,
                                  backgroundColor: const Color(0xFFEDEEA5),
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  iconColor: Colors.black,
                                  elevation: 0,
                                  backgroundColor: const Color(0xFFEDEEA5),
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_imageFile != null) {
                                    final bytes =
                                        await _imageFile!.readAsBytes();
                                    await saveScreenshotToGallery(
                                        bytes, context);
                                  }
                                },
                                icon: Icon(Icons.download),
                                label: Text("Download"),
                              ),
                            ],
                          ),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: Icon(Icons.camera_alt),
                        label: Text("Take a Gratitude Snap"),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFEDEEA5),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: buildConfetti(),
          ),
        ],
      ),
    );
  }
}
