// // import 'package:dropdown_button2/dropdown_button2.dart';
// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:mentro/presentation/screens/analytics/daily_analysis_screen.dart';

// // class MoodAnalyticsScreen extends StatefulWidget {
// //   const MoodAnalyticsScreen({super.key});

// //   @override
// //   State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
// // }

// // class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
// //   String selectedWeek = 'This Week';
// //   final List<String> weeks = ['This Week', 'Last Week', '2 Weeks Ago'];

// //   final Map<String, Color> moodColors = {
// //     'happy': const Color(0xFFEDEEA5),
// //     'anxious': const Color(0xFFB9AA9D),
// //     'angry': const Color(0xFFEF7A87),
// //     'sad': const Color(0xFFBA90D0),
// //     'neutral': const Color(0xFF8ECFE6),
// //   };

// //   final List<Map<String, dynamic>> moodBreakdown = [
// //     {'mood': 'Sad', 'percent': 12},
// //     {'mood': 'Angry', 'percent': 28},
// //     {'mood': 'Anxious', 'percent': 25},
// //     {'mood': 'Neutral', 'percent': 15},
// //     {'mood': 'Happy', 'percent': 20},
// //   ];

// //   final List<Map<String, dynamic>> emotionImages = [
// //     {'name': 'Happy', 'image': 'assets/images/happy.png'},
// //     {'name': 'Sad', 'image': 'assets/images/sad.png'},
// //     {'name': 'Angry', 'image': 'assets/images/angry.png'},
// //     {'name': 'Anxious', 'image': 'assets/images/anxious.png'},
// //     {'name': 'Neutral', 'image': 'assets/images/neutral.png'},
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFF4ECDC4),
// //         title: Text(
// //           'Mood Analytic',
// //           style: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 20),
// //         ),
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: ListView(
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   'Daily Mood',
// //                   style: GoogleFonts.outfit(
// //                       fontSize: 20, fontWeight: FontWeight.w600),
// //                 ),
// //                 DropdownButton2(
// //                   value: selectedWeek,
// //                   items: weeks
// //                       .map((week) => DropdownMenuItem(
// //                             value: week,
// //                             child: Text(week, style: GoogleFonts.outfit()),
// //                           ))
// //                       .toList(),
// //                   onChanged: (value) {
// //                     setState(() => selectedWeek = value as String);
// //                   },
// //                   dropdownStyleData: DropdownStyleData(
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(10),
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 )
// //               ],
// //             ),
// //             const SizedBox(height: 30),
// //             SizedBox(
// //               height: 150,
// //               child: BarChart(
// //                 BarChartData(
// //                   barGroups: [
// //                     makeGroup(0, [
// //                       {'color': moodColors['neutral'], 'value': 3},
// //                       {'color': moodColors['sad'], 'value': 2},
// //                     ]),
// //                     makeGroup(1, [
// //                       {'color': moodColors['anxious'], 'value': 4},
// //                     ]),
// //                     makeGroup(2, [
// //                       {'color': moodColors['happy'], 'value': 5},
// //                     ]),
// //                     makeGroup(3, [
// //                       {'color': moodColors['angry'], 'value': 2},
// //                     ]),
// //                     makeGroup(4, [
// //                       {'color': moodColors['sad'], 'value': 3},
// //                     ]),
// //                     makeGroup(5, [
// //                       {'color': moodColors['happy'], 'value': 4},
// //                     ]),
// //                     makeGroup(6, [
// //                       {'color': moodColors['anxious'], 'value': 3},
// //                     ]),
// //                   ],
// //                   titlesData: FlTitlesData(
// //                     bottomTitles: AxisTitles(
// //                       sideTitles: SideTitles(
// //                         showTitles: true,
// //                         getTitlesWidget: (value, meta) {
// //                           const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
// //                           return Text(days[value.toInt()],
// //                               style: GoogleFonts.outfit(fontSize: 12));
// //                         },
// //                       ),
// //                       axisNameSize: 16,
// //                     ),
// //                     leftTitles: AxisTitles(
// //                       sideTitles: SideTitles(showTitles: false),
// //                     ),
// //                   ),
// //                   gridData: FlGridData(show: false),
// //                   borderData: FlBorderData(show: false),
// //                   barTouchData: BarTouchData(
// //                     enabled: true,
// //                     touchCallback:
// //                         (FlTouchEvent event, BarTouchResponse? response) {
// //                       if (response != null &&
// //                           response.spot != null &&
// //                           event is FlTapUpEvent) {
// //                         int tappedIndex = response.spot!.touchedBarGroupIndex;
// //                         final days = [
// //                           'Sunday',
// //                           'Monday',
// //                           'Tuesday',
// //                           'Wednesday',
// //                           'Thursday',
// //                           'Friday',
// //                           'Saturday'
// //                         ];
// //                         String selectedDay = days[tappedIndex];
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (_) => DailyAnalysisScreen(
// //                               date: '2025-05-25',
// //                               dayLabel: 'Sunday',
// //                               dayIndex: 0,
// //                               averageMood: 'Sad',
// //                               mostCommonTag: 'relationship',
// //                               rippleCount: 2,
// //                               moodTimeline: [
// //                                 {
// //                                   'time': '8:56 AM',
// //                                   'emotion': 'Sad',
// //                                   'tag': 'relationship'
// //                                 },
// //                                 {
// //                                   'time': '5:40 PM',
// //                                   'emotion': 'Neutral',
// //                                   'tag': 'chores'
// //                                 },
// //                               ],
// //                               moodIntensityByTime: [
// //                                 {
// //                                   'time': '8:56 AM',
// //                                   'intensity': 45.0,
// //                                   'emotion': 'Sad'
// //                                 },
// //                                 {
// //                                   'time': '5:40 PM',
// //                                   'intensity': 20.0,
// //                                   'emotion': 'Neutral'
// //                                 },
// //                               ],
// //                             ),
// //                           ),
// //                         );
// //                       }
// //                     },
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 30),
// //             Text(
// //               '* Tap each bar to view detailed daily analytics',
// //               style:
// //                   GoogleFonts.outfit(fontSize: 12, fontStyle: FontStyle.italic),
// //             ),
// //             const SizedBox(height: 24),
// //             Text(
// //               'Mood Breakdown',
// //               style:
// //                   GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600),
// //             ),
// //             const SizedBox(height: 12),

// //             // ✅ Spread operator must be used inside a list structure
// //             ...moodBreakdown.map((entry) {
// //               final matching = emotionImages.firstWhere(
// //                 (e) => e['name'].toLowerCase() == entry['mood'].toLowerCase(),
// //                 orElse: () => {'image': null},
// //               );

// //               return Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 6.0),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                   children: [
// //                     if (matching['image'] != null)
// //                       Image.asset(
// //                         matching['image'],
// //                         width: 32,
// //                         height: 32,
// //                       )
// //                     else
// //                       const SizedBox(width: 32, height: 32),
// //                     const SizedBox(width: 12),
// //                     Text(
// //                       '${entry['mood']} - ${entry['percent']}%',
// //                       style: GoogleFonts.outfit(fontSize: 16),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             }),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   BarChartGroupData makeGroup(int x, List<Map<String, dynamic>> parts) {
// //     double total = 0;
// //     List<BarChartRodStackItem> stackItems = [];
// //     for (var part in parts) {
// //       double from = total;
// //       double to = total + (part['value']).toDouble();
// //       stackItems.add(BarChartRodStackItem(from, to, part['color']));
// //       total = to;
// //     }
// //     return BarChartGroupData(
// //       x: x,
// //       barRods: [
// //         BarChartRodData(
// //           toY: total,
// //           rodStackItems: stackItems,
// //           width: 18,
// //         ),
// //       ],
// //     );
// //   }
// // }

// //🧠

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// class MoodAnalyticsScreen extends StatefulWidget {
//   const MoodAnalyticsScreen({super.key});

//   @override
//   State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
// }

// class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
//   DateTime selectedDate = DateTime.now(); // default to today

//   Map<String, int> emotionCounts = {};
//   int totalEmotions = 0;
//   bool isLoading = true;
//   Map<String, Map<String, int>> weeklyEmotionCounts = {};
//   bool isWeeklyLoading = true;

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//         isLoading = true;
//       });
//       await fetchEmotionDataForDate(picked);
//       await fetchWeeklyEmotionData(picked);
//     }
//   }

//   List<Color> barColors = [
//     Colors.blue, // Happy
//     Colors.red, // Angry
//     Colors.yellow.shade700, // Surprised
//     Colors.grey, // Neutral
//     Colors.deepPurple, // Sad
//   ];

//   List<String> emotionOrder = ['Happy', 'Sad', 'Angry', 'Surprised', 'Neutral'];

//   @override
//   @override
//   void initState() {
//     super.initState();
//     fetchEmotionDataForDate(selectedDate);
//     fetchWeeklyEmotionData(selectedDate);
//   }

//   Future<void> fetchEmotionDataForDate(DateTime selectedDate) async {
//     final DateTime startOfDay =
//         DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
//     final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('ripples')
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThan: Timestamp.fromDate(endOfDay))
//           .get();

//       Map<String, int> counts = {};
//       for (var doc in snapshot.docs) {
//         String emotion = doc['emotion'];
//         counts[emotion] = (counts[emotion] ?? 0) + 1;
//       }

//       int total = counts.values.fold(0, (a, b) => a + b);

//       setState(() {
//         emotionCounts = counts;
//         totalEmotions = total;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching data: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchWeeklyEmotionData(DateTime selectedDate) async {
//     DateTime sunday =
//         selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
//     Map<String, Map<String, int>> weekData = {};

//     try {
//       for (int i = 0; i < 7; i++) {
//         DateTime day = sunday.add(Duration(days: i));
//         DateTime start = DateTime(day.year, day.month, day.day);
//         DateTime end = start.add(const Duration(days: 1));

//         QuerySnapshot snapshot = await FirebaseFirestore.instance
//             .collection('ripples')
//             .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//             .where('date', isLessThan: Timestamp.fromDate(end))
//             .get();

//         Map<String, int> counts = {};
//         for (var doc in snapshot.docs) {
//           String emotion = doc['emotion'];
//           counts[emotion] = (counts[emotion] ?? 0) + 1;
//         }

//         weekData[DateFormat('E').format(day)] = counts;
//       }

//       setState(() {
//         weeklyEmotionCounts = weekData;
//         isWeeklyLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching weekly data: $e');
//       setState(() {
//         isWeeklyLoading = false;
//       });
//     }
//   }

//   double _calculateMaxY(Map<String, Map<String, int>> data) {
//     double maxY = 0;
//     for (var counts in data.values) {
//       final total = counts.values.fold(0, (a, b) => a + b);
//       if (total > maxY) maxY = total.toDouble();
//     }
//     return maxY + 2;
//   }

//   List<BarChartGroupData> _generateWeeklyBarGroups() {
//     const emotions = ['Happy', 'Sad', 'Angry']; // add more if needed
//     const colors = {
//       'Happy': Colors.green,
//       'Sad': Colors.blue,
//       'Angry': Colors.red,
//     };

//     List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//     List<BarChartGroupData> groups = [];

//     for (int i = 0; i < weekDays.length; i++) {
//       String day = DateFormat('E').format(
//         selectedDate.subtract(Duration(days: selectedDate.weekday % 7 - i)),
//       );

//       Map<String, int> dayCounts = weeklyEmotionCounts[day] ?? {};
//       List<BarChartRodStackItem> stacks = [];

//       double start = 0;
//       for (String emotion in emotions) {
//         int value = dayCounts[emotion] ?? 0;
//         if (value > 0) {
//           stacks.add(BarChartRodStackItem(
//               start, start + value.toDouble(), colors[emotion]!));
//           start += value.toDouble();
//         }
//       }

//       groups.add(
//         BarChartGroupData(
//           x: i,
//           barRods: [
//             BarChartRodData(
//               toY: start,
//               rodStackItems: stacks,
//               width: 20,
//               borderRadius: BorderRadius.circular(4),
//             )
//           ],
//         ),
//       );
//     }

//     return groups;
//   }

//   List<BarChartGroupData> getBarChartData() {
//     List<BarChartRodStackItem> stackItems = [];
//     double cumulative = 0;

//     for (int i = 0; i < emotionOrder.length; i++) {
//       String emotion = emotionOrder[i];
//       int count = emotionCounts[emotion] ?? 0;
//       double percent = totalEmotions > 0 ? (count / totalEmotions) * 100 : 0;

//       stackItems.add(BarChartRodStackItem(
//         cumulative,
//         cumulative + percent,
//         barColors[i],
//       ));
//       cumulative += percent;
//     }

//     return [
//       BarChartGroupData(x: 0, barRods: [
//         BarChartRodData(
//           toY: 100,
//           rodStackItems: stackItems,
//           width: 40,
//           borderRadius: BorderRadius.circular(4),
//         )
//       ]),
//     ];
//   }

//   Widget buildLegend() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: List.generate(emotionOrder.length, (i) {
//         final emotion = emotionOrder[i];
//         final percent = totalEmotions > 0
//             ? ((emotionCounts[emotion] ?? 0) / totalEmotions * 100).round()
//             : 0;

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4.0),
//           child: Row(
//             children: [
//               Container(width: 16, height: 16, color: barColors[i]),
//               const SizedBox(width: 8),
//               Text(
//                 '$emotion: $percent%',
//                 style: GoogleFonts.outfit(fontSize: 16),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFBF5),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFE4D0D0),
//         title: GestureDetector(
//           onTap: () => _selectDate(context),
//           child: Row(
//             children: [
//               const Icon(Icons.calendar_today, size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 ' ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
//                 style: const TextStyle(fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : emotionCounts.isEmpty
//               ? const Center(child: Text("No mood data found for this date."))
//               : Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Text(
//                           'Mood Breakdown for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
//                           style: GoogleFonts.outfit(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//                         AspectRatio(
//                           aspectRatio: 1.5,
//                           child: BarChart(
//                             BarChartData(
//                               barGroups: getBarChartData(),
//                               titlesData: FlTitlesData(show: false),
//                               borderData: FlBorderData(show: false),
//                               gridData: FlGridData(show: false),
//                               barTouchData: BarTouchData(enabled: false),
//                               alignment: BarChartAlignment.center,
//                               maxY: 100,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         buildLegend(),
//                         const SizedBox(height: 40),
//                         Text(
//                           'Weekly Mood Breakdown',
//                           style: GoogleFonts.outfit(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         isWeeklyLoading
//                             ? const CircularProgressIndicator()
//                             : SizedBox(
//                                 height: 250,
//                                 child: BarChart(
//                                   BarChartData(
//                                     alignment: BarChartAlignment.spaceAround,
//                                     barGroups: _generateWeeklyBarGroups(),
//                                     titlesData: FlTitlesData(
//                                       leftTitles: AxisTitles(
//                                         sideTitles:
//                                             SideTitles(showTitles: true),
//                                       ),
//                                       bottomTitles: AxisTitles(
//                                         sideTitles: SideTitles(
//                                           showTitles: true,
//                                           getTitlesWidget: (value, meta) {
//                                             const days = [
//                                               'S',
//                                               'M',
//                                               'T',
//                                               'W',
//                                               'T',
//                                               'F',
//                                               'S'
//                                             ];
//                                             return Text(
//                                               days[value.toInt()],
//                                               style: const TextStyle(
//                                                   fontWeight: FontWeight.bold),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       rightTitles: AxisTitles(
//                                           sideTitles:
//                                               SideTitles(showTitles: false)),
//                                       topTitles: AxisTitles(
//                                           sideTitles:
//                                               SideTitles(showTitles: false)),
//                                     ),
//                                     barTouchData: BarTouchData(enabled: true),
//                                     gridData: FlGridData(show: false),
//                                     borderData: FlBorderData(show: false),
//                                     maxY: _calculateMaxY(weeklyEmotionCounts),
//                                   ),
//                                 ),
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

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
      await fetchEmotionDataForDate(picked);
      await fetchWeeklyEmotionData(picked);
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
    fetchEmotionDataForDate(selectedDate);
    fetchWeeklyEmotionData(selectedDate);
  }

  Future<void> fetchEmotionDataForDate(DateTime selectedDate) async {
    final DateTime startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
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
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchWeeklyEmotionData(DateTime selectedDate) async {
    // Fix: Start the week on Sunday
    // DateTime.weekday returns Monday=1 ... Sunday=7
    // To get Sunday, subtract weekday days and add 7 if needed
    int daysToSunday = selectedDate.weekday % 7; // Sunday = 0 days back

    DateTime sunday = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).subtract(Duration(days: daysToSunday));

    Map<String, Map<String, int>> weekData = {};

    try {
      for (int i = 0; i < 7; i++) {
        DateTime day = sunday.add(Duration(days: i));
        DateTime start = DateTime(day.year, day.month, day.day);
        DateTime end = start.add(const Duration(days: 1));

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('ripples')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end))
            .get();

        Map<String, int> counts = {};
        for (var doc in snapshot.docs) {
          String emotion = doc['emotion'];
          counts[emotion] = (counts[emotion] ?? 0) + 1;
        }

        // Key by short weekday like 'Sun', 'Mon' for consistency
        weekData[DateFormat('E').format(day)] = counts;
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE4D0D0),
        title: GestureDetector(
          onTap: () => _selectDate(context),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Text(
                ' ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
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
                        Text(
                          'Mood Breakdown for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6D4F4F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
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
                                      sectionsSpace: 3,
                                      borderData: FlBorderData(show: false),
                                    ),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6D4F4F),
                          ),
                        ),
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
                                        barTouchData:
                                            BarTouchData(enabled: false),
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
