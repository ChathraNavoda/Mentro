import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ripples')
          .doc(rippleId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Ripple not found")));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final title = data['title'] ?? '';
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
          body: Column(
            children: [
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
                        minRadius: 60,
                        ripplesCount: 6,
                        child: CircleAvatar(
                          radius: 60,
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
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
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
                                      label: Text("#$tag"),
                                      backgroundColor: const Color(0xFF4ECDC4),
                                      labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w500,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                color: Colors.white,
                child: _BottomIconButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onPressed: () {
                    Share.share('$title\n\n$description');
                  },
                  iconColor: const Color(0xFF4ECDC4),
                ),
              ),
            ],
          ),
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
    'image': 'assets/images/relaxed.png',
    'color': Color(0xFF8ECFE6),
  },
  'Anxious': {
    'image': 'assets/images/anxious.png',
    'color': Color(0xFFB9AA9D),
  },
};
