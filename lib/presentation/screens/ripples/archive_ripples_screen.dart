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
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("You must be logged in to view this page.")),
      );
    }

    final ripplesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('ripples');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Archived Ripples"),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ripplesRef
            .where('isArchived', isEqualTo: true)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final archivedDocs = snapshot.data?.docs ?? [];

          if (archivedDocs.isEmpty) {
            return const Center(child: Text("No archived ripples found."));
          }

          return ListView.builder(
            itemCount: archivedDocs.length,
            itemBuilder: (context, index) {
              final doc = archivedDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              final emotion = data['emotion'] ?? 'Neutral';
              final imagePath = 'assets/images/${emotion.toLowerCase()}.png';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(imagePath),
                  backgroundColor: Colors.transparent,
                ),
                title: Text(emotion),
                subtitle: Text(
                  data['trigger'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.unarchive),
                  onPressed: () async {
                    try {
                      await ripplesRef.doc(doc.id).update({
                        'isArchived': false,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Ripple unarchived successfully")),
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
