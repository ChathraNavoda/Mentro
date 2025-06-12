import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DailyAnalysisLoaderScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DailyAnalysisLoaderScreen({super.key, required this.selectedDate});

  @override
  State<DailyAnalysisLoaderScreen> createState() =>
      _DailyAnalysisLoaderScreenState();
}

class _DailyAnalysisLoaderScreenState extends State<DailyAnalysisLoaderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> topEmotionList = [];

  bool isLoading = true;
  String date = '';
  String averageMood = '';
  String mostCommonTag = '';
  int rippleCount = 0;
  int dayIndex = 0;
  String dayLabel = '';
  List<Map<String, dynamic>> moodTimeline = [];
  List<Map<String, dynamic>> moodIntensityByTime = [];
  List<String> topMoods = [];

  static const Map<String, Color> emotionColors = {
    'happy': Color(0xFFEDEEA5),
    'anxious': Color(0xFFB9AA9D),
    'angry': Color(0xFFEF7A87),
    'sad': Color(0xFFBA90D0),
    'neutral': Color(0xFF8ECFE6),
  };

  @override
  void initState() {
    super.initState();
    loadDailyData();
  }

  Future<void> loadDailyData() async {
    final start = DateTime(widget.selectedDate.year, widget.selectedDate.month,
        widget.selectedDate.day);
    final end = start.add(const Duration(days: 1));

    final String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('ripples')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .get();

      final docs = snapshot.docs;

      if (docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data found for this day.')),
          );
          Navigator.pop(context);
        }
        return;
      }

      Map<String, int> emotionCount = {};
      Map<String, int> tagCount = {};

      for (var doc in docs) {
        final data = doc.data();
        final emotion = data['emotion'] ?? 'neutral';
        final time = (data['time'] as Timestamp).toDate();
        final tags = List<String>.from(data['tags'] ?? []);
        final timeStr = TimeOfDay.fromDateTime(time).format(context);

        moodTimeline.add({
          'time': timeStr,
          'emotion': emotion,
          'tag': tags.isNotEmpty ? tags.first : 'untagged',
        });

        moodIntensityByTime.add({
          'time': timeStr,
          'emotion': emotion,
          'intensity': 100.0,
        });

        emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
        for (var tag in tags) {
          tagCount[tag] = (tagCount[tag] ?? 0) + 1;
        }
      }

      setState(() {
        date = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
        rippleCount = docs.length;
        dayIndex = widget.selectedDate.weekday % 7;
        dayLabel = DateFormat('EEEE').format(widget.selectedDate);
        isLoading = false;

        averageMood = 'Neutral (100%)';
        topMoods = [];

        final total = emotionCount.values.fold(0, (a, b) => a + b);

        if (emotionCount.isNotEmpty) {
          final maxCount = emotionCount.values.reduce((a, b) => a > b ? a : b);
          final topEmotions =
              emotionCount.entries.where((e) => e.value == maxCount).toList();

          // Store the mood names for image rendering
          topMoods = topEmotions.map((e) => e.key.toLowerCase()).toList();

          if (topEmotions.length > 1 && total % 2 == 0) {
            averageMood = topEmotions
                .map((e) =>
                    '${e.key[0].toUpperCase()}${e.key.substring(1)} (${((e.value / total) * 100).round()}%)')
                .join(' & ');
          } else {
            final top = topEmotions.first;
            final percent = ((top.value / total) * 100).round();
            averageMood =
                '${top.key[0].toUpperCase()}${top.key.substring(1)} ($percent%)';
          }
        }

        mostCommonTag = tagCount.isNotEmpty
            ? tagCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : 'none';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
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

  List<BarChartGroupData> generateStackedBars() {
    return moodIntensityByTime.asMap().entries.map((entry) {
      final index = entry.key;
      final timeEntry = entry.value;
      final emotion = timeEntry['emotion'] as String;
      final intensity = timeEntry['intensity'] as double;
      final color = emotionColors[emotion.toLowerCase()] ?? Colors.grey;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: intensity,
            color: color,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4ECDC4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$dayLabel Analysis',
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: $date',
                      style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: topMoods
                              .map((mood) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: buildMoodImage(mood, size: 48),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Average Mood: ',
                                style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: const Color.fromARGB(255, 0, 0, 0)),
                              ),
                              Text(
                                averageMood,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF4ECDC4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Most Common Tag: ',
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        Text(
                          mostCommonTag,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4ECDC4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Ripple Count: ',
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        Text(
                          '$rippleCount',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4ECDC4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Mood Breakdown',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                    const SizedBox(height: 12),
                    ...moodTimeline.map((entry) {
                      final time = entry['time'] ?? 'N/A';
                      final emotion = (entry['emotion'] ?? '').toString();
                      final tag = entry['tag'] ?? 'untagged';

                      return ListTile(
                        leading: Text(
                          time,
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        title: Row(
                          children: [
                            buildMoodImage(emotion, size: 40),
                            const SizedBox(width: 8),
                            Text(
                              emotion,
                              style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '#$tag',
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: const Color.fromARGB(255, 51, 50, 50)),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Text(
                      'Mood Intensity By Time',
                      style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 28),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < moodIntensityByTime.length) {
                                    return Text(
                                        moodIntensityByTime[index]['time'],
                                        style: const TextStyle(fontSize: 10));
                                  }
                                  return Text(
                                    '',
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: generateStackedBars(),
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
