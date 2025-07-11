import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentro/presentation/screens/analytics/happy_paradise.dart';
import 'package:url_launcher/url_launcher.dart';

class WeeklyMoodInsightsScreen extends StatefulWidget {
  const WeeklyMoodInsightsScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyMoodInsightsScreen> createState() =>
      _WeeklyMoodInsightsScreenState();
}

class _WeeklyMoodInsightsScreenState extends State<WeeklyMoodInsightsScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<FlSpot> weeklySpots = [];
  List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  List<String> weeklyEmotions = [];

  late AnimationController _glowController;

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

    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> fetchWeeklyMoodData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      isLoading = true;
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
    if (daysToSunday == 0) daysToSunday = 7;
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
          Map<String, int> counts = {};
          for (var doc in snapshot.docs) {
            String emotion = doc['emotion'];
            counts[emotion] = (counts[emotion] ?? 0) + 1;
            weeklyCounts[emotion] = (weeklyCounts[emotion] ?? 0) + 1;
          }

          String mostFrequentEmotion =
              counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

          spots.add(FlSpot(
              i.toDouble(), moodLevels[mostFrequentEmotion]!.toDouble()));
          emotions.add(mostFrequentEmotion);
        } else {
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

  Map<String, String> generateWeeklySuggestion(Map<String, int> weeklyCounts) {
    int totalRipples = weeklyCounts.values.fold(0, (a, b) => a + b);

    if (totalRipples == 0) {
      return {'type': 'no_data', 'text': "No data to analyze this week."};
    }

    final severeEmotions = {'Sad', 'Anxious', 'Angry'};
    int severeRipples = weeklyCounts.entries
        .where((e) => severeEmotions.contains(e.key))
        .fold(0, (sum, e) => sum + e.value);

    double severePercentage = severeRipples / totalRipples;

    if (severePercentage >= 0.5) {
      return {
        'type': 'tough_week',
        'text':
            "This week seems tough. Consider talking to a friend, journaling deeply, or seeking professional support."
      };
    }

    if ((weeklyCounts['Happy'] ?? 0) / totalRipples >= 0.5) {
      return {
        'type': 'happy_week',
        'text':
            "Awesome week! Use this joy to set a new goal or visit your Happy Paradise to reflect and continue your positivity journey."
      };
    }

    if ((weeklyCounts['Neutral'] ?? 0) / totalRipples >= 0.5) {
      return {
        'type': 'neutral_week',
        'text':
            "Your week was mostly neutral. Try engaging in activities that excite or challenge you."
      };
    }

    return {
      'type': 'balanced_week',
      'text':
          "A balanced week. Keep tracking to understand your patterns better."
    };
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
    final weeklySuggestion = generateWeeklySuggestion(weeklyCounts);
    final suggestionType = weeklySuggestion['type'];
    final suggestionText = weeklySuggestion['text'];

    return Scaffold(
      backgroundColor: Colors.white,
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
                            color: Colors.black54,
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

                  /// Suggestion Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(width: 1, color: Color(0xFF4ECDC4))),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb, color: Color(0xFF4ECDC4)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              suggestionText ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (suggestionType == 'happy_week')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HappyParadiseScreen()));
                        },
                        icon: Icon(Icons.emoji_emotions, color: Colors.white),
                        label: Text(
                          "Go to Happy Paradise",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4ECDC4),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  /// Conditionally render "Need to talk to someone?" card
                  if (suggestionType == 'tough_week')
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(width: 1, color: Color(0xFF4ECDC4)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1 + (_glowController.value * 0.05),
                                  child: child,
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.call, color: Color(0xFF4ECDC4)),
                                  SizedBox(width: 10),
                                  Text(
                                    "Need to talk to someone?",
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "If you’re in Sri Lanka 🇱🇰 , call the 1926 National Mental Health Helpline (24/7, free, confidential, in Sinhala, Tamil, English).",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Outside Sri Lanka?",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final url =
                                    Uri.parse('https://findahelpline.com');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Could not open the link')),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.public_sharp,
                                      color: Color(0xFF4ECDC4)),
                                  SizedBox(width: 10),
                                  Text(
                                    "Find hotlines in your country here",
                                    style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: Color(0xFF4ECDC4),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  //
                ],
              ),
            ),
    );
  }
}
