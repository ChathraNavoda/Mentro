import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArchivedRipplesScreen extends StatefulWidget {
  const ArchivedRipplesScreen({super.key});

  @override
  State<ArchivedRipplesScreen> createState() => _ArchivedRipplesScreenState();
}

class _ArchivedRipplesScreenState extends State<ArchivedRipplesScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    print("Current user: ${user?.uid}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archived Ripples"),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ripples')
            .where('isArchived', isEqualTo: true) // 👈 fixed field
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print("Snapshot connectionState: ${snapshot.connectionState}");
          print("Snapshot has data: ${snapshot.hasData}");
          print("Snapshot error: ${snapshot.error}");
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final archivedDocs = snapshot.data!.docs;
          print("Archived documents count: ${archivedDocs.length}");
          if (archivedDocs.isEmpty) {
            return const Center(child: Text("No archived ripples found."));
          }

          return ListView.builder(
            itemCount: archivedDocs.length,
            itemBuilder: (context, index) {
              final doc = archivedDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/images/${(data['emotion'] as String).toLowerCase()}.png',
                  ),
                ),
                title: Text(data['emotion'] ?? ''),
                subtitle: Text(
                  data['trigger'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.unarchive),
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('ripples')
                          .doc(doc.id)
                          .update({'isArchived': false}); // 👈 unarchive

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ripple unarchived")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
