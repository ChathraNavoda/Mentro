import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyMoodInsightsScreen extends StatefulWidget {
  const WeeklyMoodInsightsScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyMoodInsightsScreen> createState() =>
      _WeeklyMoodInsightsScreenState();
}

class _WeeklyMoodInsightsScreenState extends State<WeeklyMoodInsightsScreen> {
  bool isLoading = true;
  List<FlSpot> weeklySpots = [];
  List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  List<String> weeklyEmotions = [];

  final moodLevels = {
    'Happy': 5,
    'Neutral': 3,
    'Sad': 2,
    'Anxious': 1,
    'Angry': 0
  };
  Map<String, int> weeklyCounts = {
    'Happy': 0,
    'Neutral': 0,
    'Sad': 0,
    'Anxious': 0,
    'Angry': 0,
  };

  @override
  void initState() {
    super.initState();
    fetchWeeklyMoodData();
  }

  Future<void> fetchWeeklyMoodData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      isLoading = true;
      // Reset weeklyCounts every fetch to avoid accumulation
      weeklyCounts = {
        'Happy': 0,
        'Neutral': 0,
        'Sad': 0,
        'Anxious': 0,
        'Angry': 0,
      };
    });

    DateTime now = DateTime.now();
    int daysToSunday = now.weekday % 7;
    if (daysToSunday == 0) daysToSunday = 7; // treat Sunday as end of week
    DateTime sunday = now.subtract(Duration(days: daysToSunday));

    List<FlSpot> spots = [];
    List<String> emotions = [];

    try {
      for (int i = 0; i < 7; i++) {
        DateTime day = sunday.add(Duration(days: i));
        DateTime start = DateTime(day.year, day.month, day.day);
        DateTime end = start.add(Duration(days: 1));

        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('ripples')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end))
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Take the most frequent mood for the day
          Map<String, int> counts = {};
          for (var doc in snapshot.docs) {
            String emotion = doc['emotion'];
            counts[emotion] = (counts[emotion] ?? 0) + 1;

            // Update weeklyCounts for each ripple
            weeklyCounts[emotion] = (weeklyCounts[emotion] ?? 0) + 1;
          }

          String mostFrequentEmotion =
              counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

          spots.add(FlSpot(
              i.toDouble(), moodLevels[mostFrequentEmotion]!.toDouble()));
          emotions.add(mostFrequentEmotion);
        } else {
          // No mood recorded, consider neutral or skip
          spots.add(FlSpot(i.toDouble(), moodLevels['Neutral']!.toDouble()));
          emotions.add('Neutral');
        }
      }

      setState(() {
        weeklySpots = spots;
        weeklyEmotions = emotions;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching weekly mood data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String generateWeeklySuggestion(Map<String, int> weeklyCounts) {
    int totalRipples = weeklyCounts.values.fold(0, (a, b) => a + b);

    if (totalRipples == 0) {
      return "No data to analyze this week.";
    }

    final severeEmotions = {'Sad', 'Anxious', 'Angry'};
    int severeRipples = weeklyCounts.entries
        .where((e) => severeEmotions.contains(e.key))
        .fold(0, (sum, e) => sum + e.value);

    double severePercentage = severeRipples / totalRipples;

    if (severePercentage >= 0.5) {
      return "This week seems tough. Consider talking to a friend, journaling deeply, or seeking professional support.";
    }

    if ((weeklyCounts['Happy'] ?? 0) / totalRipples >= 0.5) {
      return "Awesome week! Keep spreading the positivity and maintain your healthy habits.";
    }

    if ((weeklyCounts['Neutral'] ?? 0) / totalRipples >= 0.5) {
      return "Your week was mostly neutral. Try engaging in activities that excite or challenge you.";
    }

    return "A balanced week. Keep tracking to understand your patterns better.";
  }

  Color getColorForEmotion(String emotion) {
    const colors = {
      'Happy': Color(0xFFEDEEA5),
      'Sad': Color(0xFFBA90D0),
      'Angry': Color(0xFFEF7A87),
      'Anxious': Color(0xFFB9AA9D),
      'Neutral': Color(0xFF8ECFE6)
    };
    return colors[emotion] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weekly Mood Insights",
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Your Mood This Week",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: weeklySpots,
                            isCurved: true,
                            color: Colors.black54, // ✅ updated
                            barWidth: 1,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color:
                                      getColorForEmotion(weeklyEmotions[index]),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  weekDays[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 5:
                                    return const Text('Happy',
                                        style: TextStyle(fontSize: 10));
                                  case 3:
                                    return const Text('Neutral',
                                        style: TextStyle(fontSize: 10));
                                  case 2:
                                    return const Text('Sad',
                                        style: TextStyle(fontSize: 10));
                                  case 1:
                                    return const Text('Anxious',
                                        style: TextStyle(fontSize: 10));
                                  case 0:
                                    return const Text('Angry',
                                        style: TextStyle(fontSize: 10));
                                  default:
                                    return const SizedBox.shrink();
                                }
                              },
                              interval: 1,
                            ),
                          ),
                        ),
                        minY: 0,
                        maxY: 5,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: const Color(0xFF4ECDC4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        generateWeeklySuggestion(weeklyCounts),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
