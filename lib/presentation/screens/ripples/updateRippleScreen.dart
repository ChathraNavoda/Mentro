import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class UpdateRippleScreen extends StatefulWidget {
  final String rippleId;
  const UpdateRippleScreen({super.key, required this.rippleId});

  @override
  State<UpdateRippleScreen> createState() => _UpdateRippleScreenState();
}

class _UpdateRippleScreenState extends State<UpdateRippleScreen> {
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
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateRipple() async {
    if (_selectedEmotion == null || _triggerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an emotion and trigger")),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ripples')
          .doc(widget.rippleId)
          .update({
        'date': Timestamp.fromDate(_selectedDate), // Use the picked date
        'emotion': _selectedEmotion,
        'trigger': _triggerController.text.trim(),
        'description': _descriptionController.text.trim(),
        'tags': _tagsController.text
            .split('#')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ripple updated successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating ripple: $e")),
      );
    }
  }

  void _initializeFields(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    if (_selectedEmotion == null) {
      _selectedDate = (data['date'] as Timestamp).toDate();
      _selectedEmotion = data['emotion'];
      _triggerController.text = data['trigger'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _tagsController.text =
          (data['tags'] as List<dynamic>).map((e) => '#$e').join(' ');
      _emotionLocked = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in.")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ripples')
          .doc(widget.rippleId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final doc = snapshot.data!;
        _initializeFields(doc);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF4ECDC4),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Update Ripple",
                style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.black),
                onPressed: _pickDate,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Center(
                  child: Text(
                    DateFormat('M/d/yy').format(_selectedDate),
                    style:
                        GoogleFonts.outfit(fontSize: 14, color: Colors.black),
                  ),
                ),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Text("How are you feeling?",
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w500)),
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
                                    color: _getRippleColor(emotion),
                                    delay: const Duration(milliseconds: 400),
                                    minRadius: 26,
                                    ripplesCount: 3,
                                    duration: const Duration(seconds: 6),
                                    repeat: true,
                                    child: _buildEmotionAvatar(
                                        emotion, isSelected),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Text("How did it ripple into your day?",
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: GoogleFonts.outfit(),
                  decoration: InputDecoration(
                    hintText: "Optional",
                    hintStyle: GoogleFonts.outfit(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _updateRipple,
                  label: Text("Update Ripple",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
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
      },
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
        return const Color(0xFFEDEEA5);
      case 'Sad':
        return const Color(0xFFBA90D0);
      case 'Angry':
        return const Color(0xFFEF7A87);
      case 'Anxious':
        return const Color(0xFFB9AA9D);
      case 'Neutral':
        return const Color(0xFF8ECFE6);
      default:
        return const Color(0xFF4ECDC4);
    }
  }
}
