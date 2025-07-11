import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HappyParadiseScreen extends StatelessWidget {
  const HappyParadiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      "Drink a glass of water and hydrate yourself.",
      "Do a random act of kindness today.",
      "Smile at a stranger and brighten their day.",
      "Donate to a cause you care about.",
      "Take a deep breath and feel gratitude for life.",
      "Compliment someone genuinely today.",
      "Visualize your goals and manifest positivity.",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4ECDC4),
        title: Text(
          "Happy Paradise",
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white,
              Color(0xFFEDEEA5).withOpacity(0.1),
              Color(0xFFEDEEA5).withOpacity(0.3),
              Color(0xFF8ECFE6).withOpacity(0.2),
              Color(0xFF8ECFE6).withOpacity(0.2),
              Color(0xFFEF7A87).withOpacity(0.2),
              Color(0xFFEF7A87).withOpacity(0.2),
              Color(0xFFBA90D0).withOpacity(0.3),
              Color(0xFFBA90D0).withOpacity(0.3),
              Color(0xFFB9AA9D).withOpacity(0.5),
              Color(0xFFB9AA9D).withOpacity(0.5),
              Color(0xFF4ECDC4).withOpacity(0.3),
              Color(0xFF4ECDC4).withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/happy.png',
                    scale: 6,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome to Your Happy Paradise!",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Lottie.asset(
                    'assets/lottie/paradise.json',
                    height: 270,
                    width: 270,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Manifest Positive Energy",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Repeat after me:\n\n"
                    "\"I radiate love and happiness.\n"
                    "I attract positivity.\n"
                    "I am grateful for my life.\"",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Good Deeds This Week",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...suggestions.map((item) => Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            width: 2,
                            // color: Color(0xFF4ECDC4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            item,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Back to Insights",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
