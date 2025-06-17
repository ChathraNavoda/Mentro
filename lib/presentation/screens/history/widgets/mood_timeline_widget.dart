import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTimelineWidget extends StatefulWidget {
  final bool isArchiveProtected;
  const MoodTimelineWidget({super.key, required this.isArchiveProtected});

  @override
  State<MoodTimelineWidget> createState() => _MoodTimelineWidgetState();
}

class _MoodTimelineWidgetState extends State<MoodTimelineWidget> {
  final Map<DateTime, List<Map<String, dynamic>>> _visibleRipplesByDate = {};
  final Map<DateTime, List<Map<String, dynamic>>> _archivedRipplesByDate = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedRipples = [];
  bool _archiveUnlocked = false;

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

    Map<DateTime, List<Map<String, dynamic>>> visible = {};
    Map<DateTime, List<Map<String, dynamic>>> archived = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final isArchived = data['isArchived'] ?? false;
      final dateTime = (data['date'] as Timestamp).toDate();
      final dateKey = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (isArchived) {
        archived.putIfAbsent(dateKey, () => []).add(data);
      } else {
        visible.putIfAbsent(dateKey, () => []).add(data);
      }
    }

    setState(() {
      _visibleRipplesByDate.clear();
      _visibleRipplesByDate.addAll(visible);

      _archivedRipplesByDate.clear();
      _archivedRipplesByDate.addAll(archived);

      _selectedDay = _focusedDay;
      _updateSelectedRipples(_focusedDay);
    });
  }

  void _updateSelectedRipples(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final visible = _visibleRipplesByDate[key] ?? [];
    final archived = _archivedRipplesByDate[key] ?? [];

    setState(() {
      _selectedRipples = _archiveUnlocked ? [...visible, ...archived] : visible;
    });
  }

  List<Widget> _getMarkersForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final visibleCount = _visibleRipplesByDate[key]?.length ?? 0;
    final hasArchive = _archivedRipplesByDate[key]?.isNotEmpty ?? false;

    List<Widget> markers = [];
    for (int i = 0; i < visibleCount; i++) {
      markers.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.5),
        child: Icon(Icons.circle, size: 10, color: Colors.orange),
      ));
    }
    if (hasArchive) {
      markers.add(const Padding(
        padding: EdgeInsets.only(left: 2),
        child: Icon(Icons.lock, size: 10, color: Colors.blueGrey),
      ));
    }

    return markers;
  }

  bool _dayHasArchivedRipples(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _archivedRipplesByDate[key]?.isNotEmpty ?? false;
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
          eventLoader: (day) {
            final key = DateTime(day.year, day.month, day.day);
            return _archiveUnlocked
                ? [
                    ...?_visibleRipplesByDate[key],
                    ...?_archivedRipplesByDate[key]
                  ]
                : [...?_visibleRipplesByDate[key]];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final markers = _getMarkersForDay(day);
              if (markers.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(spacing: 1, children: markers),
              );
            },
          ),
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
              _updateSelectedRipples(selected);
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
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null && _dayHasArchivedRipples(_selectedDay!))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                if (!_archiveUnlocked) {
                  // Trying to unlock
                  if (widget.isArchiveProtected) {
                    final auth = LocalAuthentication();
                    final didAuthenticate = await auth.authenticate(
                      localizedReason:
                          'Please authenticate to view archived ripples',
                      options: const AuthenticationOptions(biometricOnly: true),
                    );

                    if (didAuthenticate) {
                      setState(() {
                        _archiveUnlocked = true;
                        _updateSelectedRipples(_selectedDay!);
                      });
                    }
                  } else {
                    // No protection: Unlock directly
                    setState(() {
                      _archiveUnlocked = true;
                      _updateSelectedRipples(_selectedDay!);
                    });
                  }
                } else {
                  // Locking
                  setState(() {
                    _archiveUnlocked = false;
                    _updateSelectedRipples(_selectedDay!);
                  });
                }
              },
              icon: Icon(
                _archiveUnlocked ? Icons.lock : Icons.lock_open,
                color: Colors.white,
              ),
              label: Text(_archiveUnlocked
                  ? "Lock Archived Ripples"
                  : "Unlock Archived Ripples"),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
              ),
            ),
          ),
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
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          width: 0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      elevation: 0,
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
