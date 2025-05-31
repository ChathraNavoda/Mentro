import 'package:flutter/material.dart';

class DailyAnalysisScreen extends StatelessWidget {
  final int dayIndex;
  final String dayLabel;

  const DailyAnalysisScreen({
    super.key,
    required this.dayIndex,
    required this.dayLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$dayLabel Analysis')),
      body: Center(
        child: Text('Detailed mood analysis for $dayLabel'),
      ),
    );
  }
}
