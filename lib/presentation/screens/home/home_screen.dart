import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              // Logo and Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/logo.png',
                    scale: 1.2,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "How are you feeling today?",
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Emotions Row with Images
              _buildEmotionPicker(),
              const SizedBox(height: 24),

              // Add Ripple Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  label: Text(
                    "Add Emotion Ripple",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: const Color.fromARGB(225, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // Mood This Week Title
              Text(
                "Mood This Week",
                style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 16),

              // Dummy Bar Chart (Static)
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                            return Text(
                              days[value.toInt() % 7],
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (index + 1) * 2.0,
                            color: const Color(0xFF4ECDC4),
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          )
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Recent Entries Title
              Text(
                "Recent Entries",
                style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 16),

              // Dummy List of Recent Entries
              _buildRecentEntry(
                date: "Tuesday Apr 30",
                emotion: "Anxious",
                description: "Struggling with workload at job.",
              ),
              const SizedBox(height: 12),
              _buildRecentEntry(
                date: "Tuesday Apr 4",
                emotion: "Angry",
                description: "Incident with the roommate.",
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
        return AssetImage('assets/images/happy.png');
      case 'sad':
        return AssetImage('assets/images/sad.png');
      case 'angry':
        return AssetImage('assets/images/angry.png');
      case 'anxious':
        return AssetImage('assets/images/anxious.png');
      case 'neutral':
        return AssetImage('assets/images/neutral.png');
      default:
        return AssetImage('assets/images/default.png');
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
        color: const Color.fromARGB(
            255, 255, 255, 255), // light grey background (customize if needed)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(119, 0, 0, 0), // Light grey border
          width: 1,
        ),
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
