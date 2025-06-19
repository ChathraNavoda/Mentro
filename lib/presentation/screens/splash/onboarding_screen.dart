import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mentro/presentation/screens/auth/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingWalkthrough extends StatefulWidget {
  const OnboardingWalkthrough({super.key});

  @override
  State<OnboardingWalkthrough> createState() => _OnboardingWalkthroughState();
}

class _OnboardingWalkthroughState extends State<OnboardingWalkthrough> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Welcome to Mentro",
      "description":
          "Step into a gentle space crafted for your emotions — where healing begins with awareness.",
      "image": "logo"
    },
    {
      "title": "Ripple Your Emotions",
      "description":
          "Capture your feelings as ripples — like journaling with heart. Every emotion matters.",
      "image": "assets/lottie/ripple2.json"
    },
    {
      "title": "Secure and Private",
      "description":
          "Your emotions are safe here — locked away like whispers in a diary, seen only by you.",
      "image": "assets/lottie/secure2.json"
    },
    {
      "title": "Mood Analytics",
      "description":
          "Visualize your emotional journey — explore patterns, peaks, and gentle valleys of your mood.",
      "image": "assets/lottie/analytics2.json"
    },
    {
      "title": "Personalized Healing",
      "description":
          "Receive mindful suggestions crafted from your unique emotional rhythms — breathe, move, or reflect.",
      "image": "assets/lottie/suggestions2.json"
    },
    {
      "title": "Let’s Begin Your Journey",
      "description":
          "Take your first step with Mentro — towards a brighter, balanced emotional life. You’re not alone.",
      "image": "assets/lottie/go2.json"
    }
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Color(0xFF4ECDC4)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: index == 0
                              ? Image.asset(
                                  'assets/images/logo2.png') // Show logo on 1st
                              : Lottie.asset(
                                  data["image"]!), // Show Lottie for rest
                        ),
                        const SizedBox(height: 20),
                        Text(
                          data["title"]!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data["description"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Color(0xFF4ECDC4)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_currentPage == onboardingData.length - 1) {
                  _completeOnboarding();
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF4ECDC4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _currentPage == onboardingData.length - 1
                    ? "Get Started"
                    : "Next",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
