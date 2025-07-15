import 'package:confetti/confetti.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class NeutralSparkScreen extends StatefulWidget {
  const NeutralSparkScreen({super.key});

  @override
  State<NeutralSparkScreen> createState() => _NeutralSparkScreenState();
}

class _NeutralSparkScreenState extends State<NeutralSparkScreen> {
  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> sparks = [
    {
      "front": "Try a 1-minute dance break",
      "back": "Put on your favourite song and dance it out for a minute!",
      "icon": Icons.music_note
    },
    {
      "front": "Draw something random",
      "back": "Grab a pen and sketch whatever comes to your mind right now.",
      "icon": Icons.brush
    },
    {
      "front": "Compliment yourself",
      "back": "Look in the mirror and say something kind to yourself.",
      "icon": Icons.star
    },
    {
      "front": "Deep breathing",
      "back": "Take 3 minutes to breathe deeply and calm your mind.",
      "icon": Icons.self_improvement
    },
    {
      "front": "Write gratitude",
      "back": "List 3 things you are grateful for this week.",
      "icon": Icons.favorite
    },
    {
      "front": "Watch motivation",
      "back": "Watch a short motivational or inspirational video.",
      "icon": Icons.ondemand_video
    },
    {
      "front": "Try a new hobby",
      "back": "Explore a new recipe or hobby this week.",
      "icon": Icons.local_dining
    },
    {
      "front": "Change your route",
      "back": "Walk a new path today and notice something different.",
      "icon": Icons.directions_walk
    },
  ];

  // final List<Color> sparkColors = [
  //   Color(0xFFF8BBD0), // pastel rose pink
  //   Color(0xFFFFCCBC), // pastel peach
  //   Color(0xFFB3E5FC), // pastel sky blue
  //   Color(0xFFA5D6A7), // pastel mint green
  //   Color(0xFFCE93D8), // pastel lavender purple
  //   Color(0xFFFFF59D), // pastel yellow
  //   Color(0xFFFFAB91), // pastel coral
  //   Color(0xFF80DEEA), // pastel aqua teal
  //   Color(0xFFC5E1A5), // pastel lime green
  //   Color(0xFFFFF176), // pastel lemon

  // ];

  final List<Color> sparkColors = [
    Color(0xFFEF9A9A), // blush pink
    Color(0xFF90CAF9), // baby blue
    Color(0xFFFFCCBC), // peach
    Color(0xFFAED581), // fresh green apple
    Color(0xFFFFCDD2), // light pink coral
    Color(0xFFA5D6A7), // mint green
    Color(0xFFCE93D8), // lavender purple
    Color(0xFFF8BBD0), // rose pink

    Color(0xFF4DB6AC), // muted teal
    Color(0xFF80DEEA), // aqua teal
    Color(0xFFC5E1A5), // lime green
    Color(0xFFFFF176), // lemon yellow
    Color(0xFFFFAB91), // coral peach
    Color(0xFFB39DDB), // soft violet

    Color(0xFFFFE082), // soft gold yellow

    Color(0xFF81D4FA), // cool sky blue

    Color(0xFFFFB74D), // warm apricot orange
    Color(0xFFE57373), // pastel strawberry
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sparks.shuffle(); // Shuffle for randomness

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4ECDC4),
        title: Text(
          "Your Spark of the Week",
          style: GoogleFonts.outfit(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/lottie/chill.json',
                      height: 200,
                      repeat: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Flip a card and light up your week ",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.flip, color: const Color(0xFF4ECDC4))
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...sparks.asMap().entries.map((entry) {
                      int i = entry.key;
                      var spark = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FlipCard(
                          direction: FlipDirection.HORIZONTAL,
                          onFlipDone: (isFront) {
                            if (!isFront) {
                              _confettiController.play();
                            }
                          },
                          front: Card(
                            color: sparkColors[i % sparkColors.length]
                                .withOpacity(0.8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    spark["icon"],
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    spark["front"],
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          back: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8ECFE6), // Light blue
                                    Color(0xFFBA90D0), // Lavender
                                    Color(0xFF4ECDC4), // Mint green
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                spark["back"],
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.pink,
                Colors.blue,
                Colors.yellow,
                Colors.green,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}
