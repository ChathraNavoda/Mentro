import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentro/presentation/screens/analytics/daily_analysis_screen.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  String selectedWeek = 'This Week';
  final List<String> weeks = ['This Week', 'Last Week', '2 Weeks Ago'];

  final Map<String, Color> moodColors = {
    'happy': const Color(0xFFEDEEA5),
    'anxious': const Color(0xFFB9AA9D),
    'angry': const Color(0xFFEF7A87),
    'sad': const Color(0xFFBA90D0),
    'neutral': const Color(0xFF8ECFE6),
  };

  final List<Map<String, dynamic>> moodBreakdown = [
    {'mood': 'Sad', 'percent': 12},
    {'mood': 'Angry', 'percent': 28},
    {'mood': 'Anxious', 'percent': 25},
    {'mood': 'Neutral', 'percent': 15},
    {'mood': 'Happy', 'percent': 20},
  ];

  final List<Map<String, dynamic>> emotionImages = [
    {'name': 'Happy', 'image': 'assets/images/happy.png'},
    {'name': 'Sad', 'image': 'assets/images/sad.png'},
    {'name': 'Angry', 'image': 'assets/images/angry.png'},
    {'name': 'Anxious', 'image': 'assets/images/anxious.png'},
    {'name': 'Neutral', 'image': 'assets/images/neutral.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4ECDC4),
        title: Text(
          'Mood Analytic',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Mood',
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                DropdownButton2(
                  value: selectedWeek,
                  items: weeks
                      .map((week) => DropdownMenuItem(
                            value: week,
                            child: Text(week, style: GoogleFonts.outfit()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedWeek = value as String);
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    makeGroup(0, [
                      {'color': moodColors['neutral'], 'value': 3},
                      {'color': moodColors['sad'], 'value': 2},
                    ]),
                    makeGroup(1, [
                      {'color': moodColors['anxious'], 'value': 4},
                    ]),
                    makeGroup(2, [
                      {'color': moodColors['happy'], 'value': 5},
                    ]),
                    makeGroup(3, [
                      {'color': moodColors['angry'], 'value': 2},
                    ]),
                    makeGroup(4, [
                      {'color': moodColors['sad'], 'value': 3},
                    ]),
                    makeGroup(5, [
                      {'color': moodColors['happy'], 'value': 4},
                    ]),
                    makeGroup(6, [
                      {'color': moodColors['anxious'], 'value': 3},
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                          return Text(days[value.toInt()],
                              style: GoogleFonts.outfit(fontSize: 12));
                        },
                      ),
                      axisNameSize: 16,
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, BarTouchResponse? response) {
                      if (response != null &&
                          response.spot != null &&
                          event is FlTapUpEvent) {
                        int tappedIndex = response.spot!.touchedBarGroupIndex;
                        final days = [
                          'Sunday',
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday',
                          'Saturday'
                        ];
                        String selectedDay = days[tappedIndex];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DailyAnalysisScreen(
                              date: '2025-05-25',
                              dayLabel: 'Sunday',
                              dayIndex: 0,
                              averageMood: 'Sad',
                              mostCommonTag: 'relationship',
                              rippleCount: 2,
                              moodTimeline: [
                                {
                                  'time': '8:56 AM',
                                  'emotion': 'Sad',
                                  'tag': 'relationship'
                                },
                                {
                                  'time': '5:40 PM',
                                  'emotion': 'Neutral',
                                  'tag': 'chores'
                                },
                              ],
                              moodIntensityByTime: [
                                {
                                  'time': '8:56 AM',
                                  'intensity': 45.0,
                                  'emotion': 'Sad'
                                },
                                {
                                  'time': '5:40 PM',
                                  'intensity': 20.0,
                                  'emotion': 'Neutral'
                                },
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '* Tap each bar to view detailed daily analytics',
              style:
                  GoogleFonts.outfit(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            Text(
              'Mood Breakdown',
              style:
                  GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // ✅ Spread operator must be used inside a list structure
            ...moodBreakdown.map((entry) {
              final matching = emotionImages.firstWhere(
                (e) => e['name'].toLowerCase() == entry['mood'].toLowerCase(),
                orElse: () => {'image': null},
              );

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (matching['image'] != null)
                      Image.asset(
                        matching['image'],
                        width: 32,
                        height: 32,
                      )
                    else
                      const SizedBox(width: 32, height: 32),
                    const SizedBox(width: 12),
                    Text(
                      '${entry['mood']} - ${entry['percent']}%',
                      style: GoogleFonts.outfit(fontSize: 16),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroup(int x, List<Map<String, dynamic>> parts) {
    double total = 0;
    List<BarChartRodStackItem> stackItems = [];
    for (var part in parts) {
      double from = total;
      double to = total + (part['value']).toDouble();
      stackItems.add(BarChartRodStackItem(from, to, part['color']));
      total = to;
    }
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: total,
          rodStackItems: stackItems,
          width: 18,
        ),
      ],
    );
  }
}
