import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mentro/presentation/screens/ripples/updateRippleScreen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class ViewRippleScreen extends StatelessWidget {
  final String rippleId;

  const ViewRippleScreen({super.key, required this.rippleId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ripples')
          .doc(rippleId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Ripple not found")));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final trigger = data['trigger'] ?? '';
        final description = data['description'] ?? '';
        final emotion = data['emotion'] ?? '';
        final timestamp = data['date']?.toDate();
        final tags = List<String>.from(data['tags'] ?? []);

        final formattedDate = timestamp != null
            ? DateFormat('MMMM d, yyyy').format(timestamp)
            : 'Unknown date';
        final formattedTime = timestamp != null
            ? DateFormat('hh:mm a').format(timestamp)
            : 'Unknown time';

        final emotionDetails = emotionData[emotion] ?? {};
        final emotionImage =
            emotionDetails['image'] ?? 'assets/images/default.png';
        final rippleColor =
            emotionDetails['color'] ?? Colors.grey.withOpacity(0.3);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Ripple Detail'),
            centerTitle: true,
            backgroundColor: const Color(0xFF4ECDC4),
          ),
          body: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RippleAnimation(
                      repeat: true,
                      color: rippleColor,
                      minRadius: 40,
                      ripplesCount: 6,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(emotionImage),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      emotion,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4ECDC4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      formattedTime,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        trigger,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (tags.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: tags
                              .map((tag) => Chip(
                                    elevation: 0,
                                    label: Text("#$tag"),
                                    backgroundColor:
                                        Colors.grey[200], // Light grey color
                                    labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    shape: StadiumBorder(
                                      side: BorderSide.none,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BottomIconButton(
                    icon: Icons.edit_square,
                    label: 'Edit',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateRippleScreen(rippleId: rippleId),
                        ),
                      );
                    },
                    iconColor: const Color(0xFF4ECDC4),
                  ),
                  _BottomIconButton(
                    icon: Icons.archive_outlined,
                    label: 'Archive',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Archive Ripple'),
                          content: const Text(
                              'Are you sure you want to archive this ripple?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.outfit(
                                  color: Color(0xFF4ECDC4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Yes',
                                style: GoogleFonts.outfit(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('ripples')
                              .doc(rippleId)
                              .update({'isArchived': true});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Ripple archived successfully")),
                          );

                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Failed to archive ripple: $e")),
                          );
                        }
                      }
                    },
                    iconColor: const Color(0xFF4ECDC4),
                  ),
                  _BottomIconButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onPressed: () {
                      Share.share('$trigger\n\n$description');
                    },
                    iconColor: const Color(0xFF4ECDC4),
                  ),
                ],
              ),
            )
          ]),
        );
      },
    );
  }
}

class _BottomIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? iconColor;

  const _BottomIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor ?? Colors.grey),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

Map<String, dynamic> emotionData = {
  'Happy': {
    'image': 'assets/images/happy.png',
    'color': Color(0xFFEDEEA5),
  },
  'Sad': {
    'image': 'assets/images/sad.png',
    'color': Color(0xFFBA90D0),
  },
  'Angry': {
    'image': 'assets/images/angry.png',
    'color': Color(0xFFEF7A87),
  },
  'Neutral': {
    'image': 'assets/images/neutral.png',
    'color': Color(0xFF8ECFE6),
  },
  'Anxious': {
    'image': 'assets/images/anxious.png',
    'color': Color(0xFFB9AA9D),
  },
};
