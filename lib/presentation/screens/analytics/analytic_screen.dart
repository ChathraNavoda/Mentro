import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mentro/presentation/screens/analytics/daily_analysis_loader_screen.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  final String userId;
  // final String rippleId;

  const MoodAnalyticsScreen({
    super.key,
    required this.userId,
    //required this.rippleId,
  });
  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  DateTime selectedDate = DateTime.now(); // default to today

  Map<String, int> emotionCounts = {};
  int totalEmotions = 0;
  bool isLoading = true;

  Map<String, Map<String, int>> weeklyEmotionCounts = {};
  bool isWeeklyLoading = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isLoading = true;
        isWeeklyLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await fetchEmotionDataForDate(picked, user.uid);
        await fetchWeeklyEmotionData(picked, user.uid);
      }
    }
  }

  List<Color> barColors = [
    Color(0xFFEDEEA5), // Happy
    Color(0xFFBA90D0), // Sad
    Color(0xFFEF7A87), // Angry
    Color(0xFFB9AA9D), // Anxious
    Color(0xFF8ECFE6), // Neutral
  ];

  List<String> emotionOrder = ['Happy', 'Sad', 'Angry', 'Anxious', 'Neutral'];

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      fetchEmotionDataForDate(selectedDate, user.uid);
      fetchWeeklyEmotionData(selectedDate, user.uid);
    }
  }

  Future<void> fetchEmotionDataForDate(
      DateTime selectedDate, String userId) async {
    final startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ripples')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        String emotion = doc['emotion'];
        counts[emotion] = (counts[emotion] ?? 0) + 1;
      }

      int total = counts.values.fold(0, (a, b) => a + b);

      setState(() {
        emotionCounts = counts;
        totalEmotions = total;
        isLoading = false;
      });

      print(
          'Fetched ${snapshot.docs.length} docs from $startOfDay to $endOfDay');
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchWeeklyEmotionData(
      DateTime selectedDate, String userId) async {
    int daysToSunday = selectedDate.weekday % 7;
    DateTime sunday = selectedDate.subtract(Duration(days: daysToSunday));
    Map<String, Map<String, int>> weekData = {};

    try {
      for (int i = 0; i < 7; i++) {
        DateTime day = sunday.add(Duration(days: i));
        DateTime start = DateTime(day.year, day.month, day.day);
        DateTime end = start.add(const Duration(days: 1));

        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('ripples')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end))
            .get();

        Map<String, int> counts = {};
        for (var doc in snapshot.docs) {
          String emotion = doc['emotion'];
          counts[emotion] = (counts[emotion] ?? 0) + 1;
        }

        String weekday = DateFormat('E').format(day); // e.g., "Mon"
        weekData[weekday] = counts;
      }

      setState(() {
        weeklyEmotionCounts = weekData;
        isWeeklyLoading = false;
      });
    } catch (e) {
      print('Error fetching weekly data: $e');
      setState(() {
        isWeeklyLoading = false;
      });
    }
  }

  double _calculateMaxY(Map<String, Map<String, int>> data) {
    double maxY = 0;
    for (var counts in data.values) {
      final total = counts.values.fold(0, (a, b) => a + b);
      if (total > maxY) maxY = total.toDouble();
    }
    return maxY + 2;
  }

  List<BarChartGroupData> _generateWeeklyBarGroups() {
    const emotions = [
      'Happy',
      'Sad',
      'Angry',
      'Anxious',
      'Neutral'
    ]; // add more if needed
    const colors = {
      'Happy': Color(0xFFEDEEA5),
      'Sad': Color(0xFFBA90D0),
      'Angry': Color(0xFFEF7A87),
      'Anxious': Color(0xFFB9AA9D),
      'Neutral': Color(0xFF8ECFE6)
    };

    // Fix: Generate days from Sunday to Saturday to align with data keys
    int daysToSunday = selectedDate.weekday % 7;
    DateTime sunday =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
            .subtract(Duration(days: daysToSunday));

    List<BarChartGroupData> groups = [];

    for (int i = 0; i < 7; i++) {
      DateTime day = sunday.add(Duration(days: i));
      String dayKey = DateFormat('E').format(day);

      Map<String, int> dayCounts = weeklyEmotionCounts[dayKey] ?? {};
      List<BarChartRodStackItem> stacks = [];

      double start = 0;
      for (String emotion in emotions) {
        int value = dayCounts[emotion] ?? 0;
        if (value > 0) {
          stacks.add(BarChartRodStackItem(
              start, start + value.toDouble(), colors[emotion]!));
          start += value.toDouble();
        }
      }

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: start,
              rodStackItems: stacks,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      );
    }

    return groups;
  }

  final moodColorMap = {
    'Happy': Color(0xFFEDEEA5),
    'Sad': Color(0xFFBA90D0),
    'Angry': Color(0xFFEF7A87),
    'Anxious': Color(0xFFB9AA9D),
    'Neutral': Color(0xFF8ECFE6)
  };

  List<BarChartGroupData> getBarChartData() {
    List<BarChartRodStackItem> stackItems = [];
    double cumulative = 0;

    for (int i = 0; i < emotionOrder.length; i++) {
      String emotion = emotionOrder[i];
      int count = emotionCounts[emotion] ?? 0;
      double percent = totalEmotions > 0 ? (count / totalEmotions) * 100 : 0;

      stackItems.add(BarChartRodStackItem(
        cumulative,
        cumulative + percent,
        barColors[i],
      ));
      cumulative += percent;
    }

    return [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(
          toY: 100,
          rodStackItems: stackItems,
          width: 40,
          borderRadius: BorderRadius.circular(4),
        )
      ]),
    ];
  }

  List<PieChartSectionData> getMoodPieChartData() {
    List<PieChartSectionData> sections = [];

    for (int i = 0; i < emotionOrder.length; i++) {
      String emotion = emotionOrder[i];
      int count = emotionCounts[emotion] ?? 0;
      if (count == 0) continue;

      double percentage = (count / totalEmotions) * 100;

      sections.add(
        PieChartSectionData(
          color: barColors[i],
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(emotionOrder.length, (i) {
        final emotion = emotionOrder[i];
        final percent = totalEmotions > 0
            ? ((emotionCounts[emotion] ?? 0) / totalEmotions * 100).round()
            : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 16, height: 16, color: barColors[i]),
              const SizedBox(width: 8),
              Text(
                '$emotion: $percent%',
                style: GoogleFonts.outfit(fontSize: 16),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildEmotionPercentages(Map<String, double> emotionPercentages) {
    Map<String, String> emotionImages = {
      'Happy': 'assets/images/happy.png',
      'Sad': 'assets/images/sad.png',
      'Angry': 'assets/images/angry.png',
      'Anxious': 'assets/images/anxious.png',
      'Neutral': 'assets/images/neutral.png',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: emotionPercentages.entries.map((entry) {
        return Column(
          children: [
            Image.asset(
              emotionImages[entry.key]!,
              width: 40,
              height: 40,
            ),
            const SizedBox(height: 4),
            Text(
              '${entry.value.toStringAsFixed(1)}%',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              entry.key,
              style: GoogleFonts.outfit(fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isNavigating = false;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4ECDC4),
        elevation: 0,
        title: Text(
          "Ripple Analytics",
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                      ' ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : emotionCounts.isEmpty
              ? const Center(child: Text("No mood data found for this date."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Mood Breakdown for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: GoogleFonts.outfit(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        buildEmotionPercentages(
                          {
                            for (var e in [
                              'Happy',
                              'Sad',
                              'Angry',
                              'Anxious',
                              'Neutral'
                            ])
                              if (emotionCounts.containsKey(e) &&
                                  totalEmotions > 0)
                                e: (emotionCounts[e]! / totalEmotions) * 100,
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 4,
                                child: BarChart(
                                  BarChartData(
                                    maxY: 100,
                                    barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    gridData: FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    barGroups: getBarChartData(),
                                  ),
                                  swapAnimationDuration: Duration(
                                      milliseconds:
                                          1200), // ⏱ Animate bar growth
                                  swapAnimationCurve: Curves.easeInOut,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: AspectRatio(
                                  aspectRatio: 1,
                                  child: PieChart(
                                    PieChartData(
                                      sections: getMoodPieChartData(),
                                      centerSpaceRadius: 30,
                                      pieTouchData:
                                          PieTouchData(enabled: false),
                                      startDegreeOffset: 270,
                                      sectionsSpace: 3,
                                      borderData: FlBorderData(show: false),
                                    ),
                                    swapAnimationDuration: Duration(
                                        milliseconds: 1000), // ⏱ Animate entry
                                    swapAnimationCurve: Curves.easeInOut,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildLegend(),
                        const SizedBox(height: 32),
                        Divider(color: Colors.grey.shade400),
                        const SizedBox(height: 24),
                        Text(
                          'Weekly Mood Trends (Sun-Sat)',
                          style: GoogleFonts.outfit(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text("Tap on a bar to see the daily mood analytics.",
                            style: GoogleFonts.outfit(
                                fontSize: 11, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        isWeeklyLoading
                            ? const CircularProgressIndicator()
                            : weeklyEmotionCounts.isEmpty
                                ? const Text('No weekly data available.')
                                : AspectRatio(
                                    aspectRatio: 1.7,
                                    child: BarChart(
                                      BarChartData(
                                        maxY:
                                            _calculateMaxY(weeklyEmotionCounts),

                                        ///
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchCallback:
                                              (event, response) async {
                                            if (event
                                                    .isInterestedForInteractions &&
                                                response != null &&
                                                !isNavigating) {
                                              final index = response
                                                  .spot?.touchedBarGroupIndex;
                                              if (index != null) {
                                                isNavigating = true;

                                                final now = DateTime.now();
                                                final weekStartDate =
                                                    now.subtract(Duration(
                                                        days: now.weekday % 7));
                                                final targetDate = weekStartDate
                                                    .add(Duration(days: index));

                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        DailyAnalysisLoaderScreen(
                                                            selectedDate:
                                                                targetDate),
                                                  ),
                                                );

                                                isNavigating =
                                                    false; // reset after coming back
                                              }
                                            }
                                          },
                                        ),

                                        ///
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                int index = value.toInt();
                                                if (index < 0 || index > 6) {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                                // Calculate the correct weekday label
                                                int daysToSunday =
                                                    selectedDate.weekday % 7;
                                                DateTime sunday = DateTime(
                                                        selectedDate.year,
                                                        selectedDate.month,
                                                        selectedDate.day)
                                                    .subtract(Duration(
                                                        days: daysToSunday));
                                                DateTime day = sunday
                                                    .add(Duration(days: index));
                                                String label =
                                                    DateFormat('E').format(day);

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6),
                                                  child: Text(label,
                                                      style: GoogleFonts.outfit(
                                                          fontSize: 14,
                                                          color: Colors.black)),
                                                );
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                        ),
                                        gridData: FlGridData(show: true),
                                        borderData: FlBorderData(show: false),
                                        barGroups: _generateWeeklyBarGroups(),
                                      ),
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
