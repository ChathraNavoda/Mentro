import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text("Ripple History"),
        backgroundColor: const Color(0xFF4ECDC4),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Filter & Sort',
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: Icon(showArchived ? Icons.lock_open : Icons.lock),
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
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/images/${emotion.toLowerCase()}.png'),
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                emotion,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isArchived)
                              const Icon(Icons.lock, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(trigger),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(date),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
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
          title: const Text("Filter Ripples"),
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
                          child: Text(e),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: sortDescending,
                onChanged: (val) {
                  setState(() {
                    sortDescending = val;
                  });
                  Navigator.pop(context);
                },
                title: const Text("Sort Newest First"),
              ),
            ],
          ),
        );
      },
    );
  }
}
