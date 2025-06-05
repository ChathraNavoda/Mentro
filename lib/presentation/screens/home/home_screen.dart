import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentro/presentation/screens/home/add_ripple_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String averageMood = '';
  @override
  void initState() {
    super.initState();
    loadDailyData();
  }

  Future<void> loadDailyData() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    final DateTime start = DateTime.now();
    final DateTime todayStart = DateTime(start.year, start.month, start.day);
    final DateTime tomorrowStart = todayStart.add(const Duration(days: 1));

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('ripples')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('date', isLessThan: Timestamp.fromDate(tomorrowStart))
          .get();

      final docs = snapshot.docs;

      if (docs.isEmpty) {
        if (mounted) {
          setState(() {
            averageMood = 'No data';
          });
        }
        return;
      }

      Map<String, int> emotionCount = {};

      for (var doc in docs) {
        final data = doc.data();
        final emotion = data['emotion'] ?? 'neutral';
        emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
      }

      setState(() {
        averageMood = emotionCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load mood data: $e')),
        );
      }
    }
  }

  Widget buildMoodImage(String mood, {double size = 48}) {
    if (mood.isEmpty) {
      return Icon(Icons.sentiment_dissatisfied, size: size);
    }
    return Image.asset(
      'assets/images/${mood.toLowerCase()}.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.broken_image, size: size),
    );
  }

  Widget buildMoodSuggestion(String mood) {
    final suggestions = {
      'happy':
          "You're glowing! Keep the joy flowing – maybe share a ripple of kindness!",
      'sad':
          "It’s okay to feel sad. Try journaling or listening to your favorite music.",
      'angry':
          "Take a few deep breaths. A quick walk might help you cool down.",
      'anxious':
          "Pause for a second. A guided meditation or pet video might help.",
      'neutral':
          "Feeling meh? Let’s shake things up – maybe try something spontaneous!",
    };

    final suggestion = suggestions[mood.toLowerCase()] ?? '';

    if (suggestion.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        color: const Color(0xFFFAF9F6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFF4ECDC4)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion,
                  style: GoogleFonts.outfit(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Image.asset('assets/images/logo.png', scale: 1.2),
                  const SizedBox(height: 30),
                  Text(
                    "How are you feeling today?",
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildEmotionPicker(), buildMoodSuggestion(averageMood),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddRippleScreen()),
                    );
                  },
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: Text(
                    "Add Emotion Ripple",
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Text('Average Mood for Today',
                  style: Theme.of(context).textTheme.titleMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildMoodImage(averageMood),
                  const SizedBox(width: 25),
                  Text(averageMood,
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              buildMoodSuggestion(averageMood), // 👈 Add this
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionPicker() {
    final List<Map<String, dynamic>> emotions = [
      {'name': 'Happy', 'image': 'assets/images/happy.png'},
      {'name': 'Sad', 'image': 'assets/images/sad.png'},
      {'name': 'Angry', 'image': 'assets/images/angry.png'},
      {'name': 'Anxious', 'image': 'assets/images/anxious.png'},
      {'name': 'Neutral', 'image': 'assets/images/neutral.png'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: emotions.map((emotion) {
        return Column(
          children: [
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                emotion['image'],
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emotion['name'],
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
