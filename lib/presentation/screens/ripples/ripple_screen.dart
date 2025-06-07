import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mentro/presentation/screens/ripples/updateRippleScreen.dart';
import 'package:mentro/presentation/screens/ripples/view_ripple_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RippleScreen extends StatefulWidget {
  final String userId;
  const RippleScreen({super.key, required this.userId});

  @override
  State<RippleScreen> createState() => _RippleScreenState();
}

class _RippleScreenState extends State<RippleScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Ripples"),
        backgroundColor: const Color(0xFF4ECDC4),
        actions: [
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
            .doc(widget.userId)
            .collection('ripples')
            .where('isArchived', isEqualTo: showArchived)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              isAuthenticating) {
            return const Center(child: CircularProgressIndicator());
          }

          final ripples = snapshot.data!.docs;

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
              final date = (data['date'] as Timestamp).toDate();
              final emotion = data['emotion'] ?? '';
              final trigger = data['trigger'] ?? '';
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
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/images/${emotion.toLowerCase()}.png'),
                      backgroundColor: Colors.white,
                    ),
                    title: Text(
                      emotion,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trigger),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(date),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'view') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateRippleScreen(rippleId: docId),
                            ),
                          );
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Ripple',
                                  style: TextStyle(color: Colors.red)),
                              content: const Text(
                                'Are you sure you want to delete this ripple? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel',
                                      style:
                                          TextStyle(color: Color(0xFF4ECDC4))),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final userId =
                                        FirebaseAuth.instance.currentUser?.uid;
                                    if (userId == null) return;

                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userId)
                                          .collection('ripples')
                                          .doc(docId)
                                          .delete();
                                      Navigator.pop(context);
                                    } catch (e) {
                                      debugPrint("Delete failed: $e");
                                    }
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'view', child: Text('Edit')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete')),
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
}
