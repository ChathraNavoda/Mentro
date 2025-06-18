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
      "description": "Discover your emotional world with Mentro.",
      "image": "logo"
    },
    {
      "title": "Ripple Your Emotions",
      "description":
          "Add a daily emotional ripple like a journal — anytime you feel something.",
      "image": "assets/lottie/ripple.json"
    },
    {
      "title": "Secure and Private",
      "description":
          "Your ripples are safely stored and protected — just for you.",
      "image": "assets/lottie/secure.json" // A lock or shield animation
    },
    {
      "title": "Mood Analytics",
      "description":
          "View charts and patterns of your moods by day, week, and intensity.",
      "image": "assets/lottie/analytics.json"
    },
    {
      "title": "Personalized Healing",
      "description":
          "Get daily fun suggestions like yoga, breathing, and reflection.",
      "image": "assets/lottie/suggestions.json"
    },
    {
      "title": "Let’s Begin Your Journey",
      "description":
          "Let’s go with Mentro and start your emotional wellness journey.",
      "image": "assets/lottie/go.json"
    },
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
              onPressed: _completeOnboarding,
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
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
