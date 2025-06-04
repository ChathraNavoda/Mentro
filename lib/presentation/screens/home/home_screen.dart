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
  late Future<int> _streakFuture;

  @override
  void initState() {
    super.initState();
    _streakFuture = getMoodStreak();
  }

  Future<int> getMoodStreak() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('ripples')
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('date', descending: true)
        .get();

    // Extract unique dates (only year/month/day)
    List<DateTime> rippleDates = snapshot.docs
        .map((doc) {
          Timestamp timestamp = doc['date'];
          final d = timestamp.toDate();
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .toList();

    rippleDates.sort((a, b) => b.compareTo(a)); // Latest first

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < rippleDates.length; i++) {
      if (rippleDates[i].isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
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
              _buildEmotionPicker(),
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
              const SizedBox(height: 32),
              FutureBuilder<int>(
                future: _streakFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  int streak = snapshot.data!;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: Colors.orange.shade100,
                    child: InkWell(
                      onTap: () {
                        // Navigate to Streak Details Screen or show bottom sheet
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                size: 40, color: Colors.orange),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("🔥 Mood Streak",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text("You're on a $streak-day streak!",
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
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

  ImageProvider _getEmotionImage(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return const AssetImage('assets/images/happy.png');
      case 'sad':
        return const AssetImage('assets/images/sad.png');
      case 'angry':
        return const AssetImage('assets/images/angry.png');
      case 'anxious':
        return const AssetImage('assets/images/anxious.png');
      case 'neutral':
        return const AssetImage('assets/images/neutral.png');
      default:
        return const AssetImage('assets/images/default.png');
    }
  }

  Widget _buildRecentEntry({
    required String date,
    required String emotion,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(119, 0, 0, 0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 14,
            backgroundImage: _getEmotionImage(emotion),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$emotion - $date",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
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
