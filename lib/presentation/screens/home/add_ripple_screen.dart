import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class AddRippleScreen extends StatefulWidget {
  const AddRippleScreen({super.key});

  @override
  State<AddRippleScreen> createState() => _AddRippleScreenState();
}

class _AddRippleScreenState extends State<AddRippleScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedEmotion;
  final _triggerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _emotionLocked = false;

  final List<String> _emotions = [
    'Happy',
    'Sad',
    'Angry',
    'Anxious',
    'Neutral'
  ];

  AssetImage _getEmotionImage(String emotion) {
    return AssetImage('assets/images/${emotion.toLowerCase()}.png');
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ECDC4), // header and selected date
              onPrimary: Colors.white, // text color on selected date
              onSurface: Colors.black, // default text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF4ECDC4), // OK & Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveRipple() async {
    if (_selectedEmotion == null || _triggerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please select an emotion and enter a trigger.")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    try {
      final rippleData = {
        'date': Timestamp.fromDate(_selectedDate),
        'time': Timestamp.now(),
        'emotion': _selectedEmotion,
        'trigger': _triggerController.text.trim(),
        'description': _descriptionController.text.trim(),
        'tags': _tagsController.text
            .split('#')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        'isArchived': false,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('ripples')
          .add(rippleData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ripple added successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add ripple: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4ECDC4),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.pop(context); // Goes back to Home
          },
        ),
        title: Text(
          "Add Ripple",
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today,
                color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: _pickDate,
            tooltip: "Pick Date",
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Text(
                DateFormat('M/d/yy').format(_selectedDate),
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              "How are you feeling?",
              style:
                  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text("Tap to select and double tap to unselect.",
                style: GoogleFonts.outfit(
                    fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _emotions.map((emotion) {
                final isSelected = _selectedEmotion == emotion;

                return GestureDetector(
                  onTap: () {
                    if (!_emotionLocked) {
                      setState(() {
                        _selectedEmotion = emotion;
                        _emotionLocked = true;
                      });
                    }
                  },
                  onDoubleTap: () {
                    if (_emotionLocked && _selectedEmotion == emotion) {
                      setState(() {
                        _selectedEmotion = null;
                        _emotionLocked = false;
                      });
                    }
                  },
                  child: Opacity(
                    opacity: !_emotionLocked || isSelected ? 1.0 : 0.3,
                    child: Column(
                      children: [
                        isSelected
                            ? RippleAnimation(
                                color: _getRippleColor(
                                    emotion), // <-- this line is the magic!
                                delay: const Duration(milliseconds: 400),
                                minRadius: 26,
                                ripplesCount: 3,
                                duration: const Duration(seconds: 6),
                                repeat: true,
                                child: _buildEmotionAvatar(emotion, isSelected),
                              )
                            : _buildEmotionAvatar(emotion, isSelected),
                        const SizedBox(height: 4),
                        Text(
                          emotion,
                          style: GoogleFonts.outfit(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text("What triggered this emotion?",
                style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _triggerController,
              style: GoogleFonts.outfit(),
              decoration: InputDecoration(
                hintText: "e.g., Conflict at work",
                hintStyle: GoogleFonts.outfit(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Text("How did it ripple into your day?",
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: GoogleFonts.outfit(),
              decoration: InputDecoration(
                hintText: "Optional",
                hintStyle: GoogleFonts.outfit(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Text("Tags",
                style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              style: GoogleFonts.outfit(),
              decoration: InputDecoration(
                hintText: "#office #relax",
                hintStyle: GoogleFonts.outfit(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _saveRipple,
              label: Text(
                "Save",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionAvatar(String emotion, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _getRippleColor(emotion).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.all(4),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 22,
        backgroundImage: _getEmotionImage(emotion),
      ),
    );
  }

  Color _getRippleColor(String emotion) {
    switch (emotion) {
      case 'Happy':
        return Color(0xFFEDEEA5);
      case 'Sad':
        return Color(0xFFBA90D0);
      case 'Angry':
        return Color(0xFFEF7A87);
      case 'Anxious':
        return Color(0xFFB9AA9D);
      case 'Neutral':
        return Color(0xFF8ECFE6);
      default:
        return const Color(0xFF4ECDC4); // fallback color
    }
  }
}
