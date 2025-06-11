import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          SnackBar(
              content: Text(
            'Authentication failed',
            style: GoogleFonts.outfit(),
          )),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          showArchived ? "Archived Ripples" : "Your Ripples",
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        actions: [
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
                  color: Colors.white,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      width: 0,
                      //color: Color(0xFF4ECDC4),
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  elevation: 0,
                  child: ListTile(
                    tileColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/images/${emotion.toLowerCase()}.png'),
                      backgroundColor: Colors.white,
                    ),
                    title: Text(
                      emotion,
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trigger,
                          style: GoogleFonts.outfit(
                              fontSize: 15, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(date),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      color: Colors.white,
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
                              surfaceTintColor: Colors.white,
                              title: Text(
                                'Delete Ripple',
                                style: GoogleFonts.outfit(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                                  child: Text(
                                    'Delete',
                                    style: GoogleFonts.outfit(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (value == 'unarchive') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Unarchive Ripple'),
                              content: Text(
                                'Are you sure you want to unarchive this ripple? It will appear back in the main ripple list.',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.outfit(
                                      color: Color(0xFF4ECDC4),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userId)
                                          .collection('ripples')
                                          .doc(docId)
                                          .update({'isArchived': false});

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text("Ripple unarchived")),
                                      );
                                    } catch (e) {
                                      debugPrint("Unarchive failed: $e");
                                    }
                                  },
                                  child: const Text('Unarchive',
                                      style: TextStyle(color: Colors.green)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        if (!showArchived)
                          PopupMenuItem(
                            value: 'view',
                            child: Text(
                              'Edit',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        if (showArchived)
                          const PopupMenuItem(
                              value: 'unarchive', child: Text('Unarchive')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
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
}
