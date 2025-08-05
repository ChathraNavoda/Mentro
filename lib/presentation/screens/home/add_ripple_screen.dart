import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_safe/keyboard_safe.dart';
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
    // Dismiss keyboard before showing date picker for better UX
    KeyboardSafe.dismissKeyboard(context);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ECDC4),
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
    // Dismiss keyboard before validation and saving
    KeyboardSafe.dismissKeyboard(context);

    if (_selectedEmotion == null || _triggerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select an emotion and enter a trigger."),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not logged in."),
          backgroundColor: Colors.red,
        ),
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
        SnackBar(
          content: Text("Ripple added successfully!"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add ripple: $e"),
          backgroundColor: Colors.red,
        ),
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
            // Dismiss keyboard before navigation for smoother transition
            KeyboardSafe.dismissKeyboard(context);
            Navigator.pop(context);
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
      body: KeyboardSafe(
        // Enhanced scrolling configuration
        scroll: true,

        // Auto-scroll focused fields into view with more control
        autoScrollToFocused: true,

        // Enhanced tap-to-dismiss behavior
        dismissOnTapOutside: true,

        // Improved padding and spacing
        padding: const EdgeInsets.all(20.0),

        // Better keyboard animations with custom curves
        keyboardAnimationDuration: const Duration(milliseconds: 300),
        keyboardAnimationCurve: Curves.easeInOutCubic, // Smoother curve

        // Enhanced footer with better keyboard awareness
        footer: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _saveRipple,
              child: Text(
                "Save Ripple",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF4ECDC4).withOpacity(0.3),
              ),
            ),
          ),
        ),

        // Main form content with enhanced keyboard handling
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emotion Selection Section
            Text(
              "How are you feeling?",
              style:
                  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              "Tap to select and double tap to unselect.",
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Emotion Selection Row - Enhanced with keyboard dismissal
            GestureDetector(
              onTap: () => KeyboardSafe.dismissKeyboard(context),
              behavior: HitTestBehavior.translucent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _emotions.map((emotion) {
                  final isSelected = _selectedEmotion == emotion;

                  return GestureDetector(
                    onTap: () {
                      // Always dismiss keyboard when interacting with emotions
                      KeyboardSafe.dismissKeyboard(context);

                      if (!_emotionLocked) {
                        setState(() {
                          _selectedEmotion = emotion;
                          _emotionLocked = true;
                        });
                      }
                    },
                    onDoubleTap: () {
                      // Dismiss keyboard on double tap too
                      KeyboardSafe.dismissKeyboard(context);

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
                                  child:
                                      _buildEmotionAvatar(emotion, isSelected),
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
            ),

            const SizedBox(height: 28),

            // Trigger Input with enhanced keyboard behavior
            Text(
              "What triggered this emotion?",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _triggerController,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.outfit(),
              decoration: InputDecoration(
                hintText: "e.g., Conflict at work",
                hintStyle: GoogleFonts.outfit(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                  onPressed: () => _triggerController.clear(),
                ),
              ),
              // Enhanced keyboard behavior for this field
            ),

            const SizedBox(height: 24),

            // Description Input with enhanced multiline handling
            Text(
              "How did it ripple into your day?",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.outfit(),
              decoration: InputDecoration(
                hintText: "Describe the impact... (Optional)",
                hintStyle: GoogleFonts.outfit(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                    onPressed: () => _descriptionController.clear(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tags Input with smart keyboard completion
            Text(
              "Tags",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.outfit(),
              decoration: InputDecoration(
                hintText: "#work #stress #family",
                hintStyle: GoogleFonts.outfit(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Icon(
                  Icons.tag,
                  color: Colors.grey[500],
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                  onPressed: () => _tagsController.clear(),
                ),
              ),
            ),

            // Extra spacing before footer
            const SizedBox(height: 32),

            // Add a subtle hint about keyboard interaction
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: const Color(0xFF4ECDC4).withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tip: Tap outside text fields or press 'Done' to dismiss keyboard",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF4ECDC4).withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
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

  @override
  void dispose() {
    _triggerController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
