import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mentro/presentation/screens/ripples/view_ripple_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedEmotion = 'All';
  bool sortDescending = true;
  bool showArchived = false;
  bool isAuthenticating = false;
  bool isArchiveProtected = false;

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadArchiveProtection();
  }

  Future<void> _loadArchiveProtection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isArchiveProtected = prefs.getBool('isArchiveProtected') ?? false;
    });
  }

  Future<void> _authenticateAndToggleArchive() async {
    try {
      setState(() => isAuthenticating = true);

      final canAuth =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuth) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Biometric authentication not available')),
        );
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to view archived ripples',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        setState(() {
          showArchived = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed')),
        );
      }
    } catch (e) {
      debugPrint("Biometric auth failed: $e");
    } finally {
      setState(() => isAuthenticating = false);
    }
  }

  void _toggleArchiveView() {
    if (showArchived) {
      setState(() {
        showArchived = false;
      });
    } else {
      if (isArchiveProtected) {
        _authenticateAndToggleArchive();
      } else {
        setState(() {
          showArchived = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Ripple History",
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_alt,
              color: Colors.black,
            ),
            tooltip: 'Filter & Sort',
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: Icon(
              showArchived ? Icons.lock_open : Icons.lock,
              color: Colors.black,
            ),
            tooltip: showArchived
                ? "Hide Archived Ripples"
                : "View Archived Ripples",
            onPressed: _toggleArchiveView,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('ripples')
            .orderBy('date', descending: sortDescending)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              isAuthenticating) {
            return const Center(child: CircularProgressIndicator());
          }

          final ripples = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isArchived = data['isArchived'] ?? false;

            if (isArchived != showArchived) return false;
            if (selectedEmotion != 'All' &&
                data['emotion'] != selectedEmotion) {
              return false;
            }
            return true;
          }).toList();

          if (ripples.isEmpty) {
            return Center(
              child: Text(showArchived
                  ? "No archived ripples found."
                  : "No ripples found."),
            );
          }

          return ListView.builder(
            itemCount: ripples.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              final ripple = ripples[index];
              final data = ripple.data() as Map<String, dynamic>;

              final emotion = data['emotion'] ?? 'Unknown';
              final trigger = data['trigger'] ?? '';
              final isArchived = data['isArchived'] ?? false;
              final date = (data['date'] as Timestamp).toDate();
              final docId = ripple.id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewRippleScreen(rippleId: docId),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      width: 0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: AssetImage(
                                  'assets/images/${emotion.toLowerCase()}.png'),
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                emotion,
                                style: GoogleFonts.outfit(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ),
                            if (isArchived)
                              const Icon(Icons.lock, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          trigger,
                          style: GoogleFonts.outfit(
                              fontSize: 15, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(date),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Filter Ripples",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedEmotion,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedEmotion = value;
                    });
                    Navigator.pop(context);
                  }
                },
                items: ['All', 'Happy', 'Sad', 'Angry', 'Relaxed']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                activeTrackColor: const Color(0xFF4ECDC4),
                tileColor: Colors.white,
                value: sortDescending,
                onChanged: (val) {
                  setState(() {
                    sortDescending = val;
                  });
                  Navigator.pop(context);
                },
                title: Text(
                  "Sort Newest First",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
