import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

  void _saveRipple() {
    final ripple = {
      'date': _selectedDate,
      'emotion': _selectedEmotion,
      'trigger': _triggerController.text,
      'description': _descriptionController.text,
      'tags': _tagsController.text
          .split('#')
          .where((tag) => tag.trim().isNotEmpty)
          .toList(),
    };

    print("Ripple saved: $ripple");
    // TODO: Save to database or backend
    Navigator.pop(context); // Return to previous screen
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
        title: Text("Add Ripple",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
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
                    fontSize: 14, color: const Color.fromARGB(255, 0, 0, 0)),
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
                    setState(() {
                      _selectedEmotion = emotion;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected ? Colors.teal : Colors.transparent,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 22,
                          backgroundImage: _getEmotionImage(emotion),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(emotion, style: GoogleFonts.outfit(fontSize: 12)),
                    ],
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
                    fontSize: 16, fontWeight: FontWeight.w500)),
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
              label: Text("Save",
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
  }
}
