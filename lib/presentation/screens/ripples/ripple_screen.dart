import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentro/presentation/screens/ripples/updateRippleScreen.dart';

class RippleScreen extends StatelessWidget {
  const RippleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Ripples"),
        backgroundColor: Color(0xFF4ECDC4),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ripples')
            .orderBy('time', descending: true) // sort by time added
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ripples = snapshot.data!.docs;

          if (ripples.isEmpty) {
            return const Center(child: Text("No ripples found."));
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

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/images/${emotion.toLowerCase()}.png'),
                    backgroundColor: Colors.white,
                  ),
                  title: Text(emotion,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trigger),
                      const SizedBox(height: 4),
                      Text(DateFormat('MMMM dd, yyyy').format(date),
                          style: const TextStyle(fontSize: 12)),
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
                            title: const Text(
                              'Delete Ripple',
                              style: TextStyle(color: Colors.red),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this ripple? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context), // Cancel
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF4ECDC4)),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Delete ripple from Firestore
                                  await FirebaseFirestore.instance
                                      .collection('ripples')
                                      .doc(docId)
                                      .delete();

                                  Navigator.pop(context); // Close the dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Ripple deleted')),
                                  );
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('Update'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
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
