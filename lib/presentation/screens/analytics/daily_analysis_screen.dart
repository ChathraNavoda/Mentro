import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailyAnalysisScreen extends StatelessWidget {
  final int dayIndex;
  final String dayLabel;
  final String date;
  final String averageMood;
  final String mostCommonTag;
  final int rippleCount;
  final List<Map<String, dynamic>> moodTimeline;
  final List<Map<String, dynamic>> moodIntensityByTime;

  const DailyAnalysisScreen({
    super.key,
    required this.date,
    required this.averageMood,
    required this.mostCommonTag,
    required this.rippleCount,
    required this.moodTimeline,
    required this.moodIntensityByTime,
    required this.dayIndex,
    required this.dayLabel,
  });

  static const Map<String, Color> emotionColors = {
    'happy': Color(0xFFEDEEA5),
    'anxious': Color(0xFFB9AA9D),
    'angry': Color(0xFFEF7A87),
    'sad': Color(0xFFBA90D0),
    'neutral': Color(0xFF8ECFE6),
  };

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
      appBar: AppBar(
        title: Text('$dayLabel Analysis'),
        backgroundColor: const Color(0xFF4ECDC4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: $date',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  buildMoodImage(averageMood),
                  const SizedBox(width: 12),
                  Text('Average Mood: $averageMood',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text('Most Common Tag: #$mostCommonTag'),
              Text('Ripple Count: $rippleCount'),
              const SizedBox(height: 24),
              const Text('Mood Breakdown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...moodTimeline.map((entry) {
                final time = entry['time'] ?? 'N/A';
                final emotion = (entry['emotion'] ?? '').toString();
                final tag = entry['tag'] ?? 'untagged';

                return ListTile(
                  leading: Text(time),
                  title: Row(
                    children: [
                      buildMoodImage(emotion, size: 32),
                      const SizedBox(width: 8),
                      Text(emotion),
                    ],
                  ),
                  subtitle: Text('#$tag'),
                );
              }),
              const SizedBox(height: 24),
              const Text('Mood Intensity By Time',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 28),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < moodIntensityByTime.length) {
                              return Text(moodIntensityByTime[index]['time'],
                                  style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
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
