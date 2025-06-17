import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTimelineWidget extends StatefulWidget {
  const MoodTimelineWidget({super.key});

  @override
  State<MoodTimelineWidget> createState() => _MoodTimelineWidgetState();
}

class _MoodTimelineWidgetState extends State<MoodTimelineWidget> {
  final Map<DateTime, List<Map<String, dynamic>>> _ripplesByDate = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedRipples = [];

  @override
  void initState() {
    super.initState();
    _fetchRipples();
  }

  Future<void> _fetchRipples() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ripples')
        .orderBy('date', descending: false)
        .get();

    Map<DateTime, List<Map<String, dynamic>>> grouped = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateTime = (data['date'] as Timestamp).toDate();
      final dateKey = DateTime(dateTime.year, dateTime.month, dateTime.day);
      grouped.putIfAbsent(dateKey, () => []).add(data);
    }

    setState(() {
      _ripplesByDate.clear();
      _ripplesByDate.addAll(grouped);
      _selectedDay = _focusedDay;
      _selectedRipples = _ripplesByDate[
              DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day)] ??
          [];
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _ripplesByDate[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Map<String, dynamic>>(
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.utc(2050, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
              _selectedRipples = _getEventsForDay(selected);
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF4ECDC4),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _selectedRipples.isEmpty
              ? const Center(child: Text("No ripples for this day."))
              : ListView.builder(
                  itemCount: _selectedRipples.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, index) {
                    final ripple = _selectedRipples[index];
                    final emotion = ripple['emotion'] ?? 'Unknown';
                    final trigger = ripple['trigger'] ?? '';
                    final date = (ripple['date'] as Timestamp?)?.toDate() ??
                        DateTime.now();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          color: Color(0xFF4ECDC4),
                          width: 0.4,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emotion,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              trigger,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMMM dd, yyyy').format(date),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
