import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentro/presentation/screens/auth/login_screen.dart';
import 'package:mentro/presentation/screens/home/custom_bottom_navbar.dart';
import 'package:mentro/presentation/screens/splash/onboarding_screen.dart';
import 'package:mentro/utils/connectivity_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateAfterDelay();
    });
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (_navigated || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isOnboarded = prefs.getBool('isOnboarded') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (_navigated || !mounted) return;
    _navigated = true;

    Widget nextScreen;

    if (user != null) {
      // User logged in -> home
      nextScreen = const CustomBottomNavbar();
    } else if (isOnboarded) {
      // Onboarded but not logged in -> login
      nextScreen = const LoginScreen();
    } else {
      // New user -> onboarding
      nextScreen = const OnboardingWalkthrough();
    }

    // ✅ Wrap the destination with ConnectivityWrapper before navigating
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConnectivityWrapper(child: nextScreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // prevent back on splash
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: RippleAnimation(
            color: const Color(0xFF4ECDC4),
            delay: const Duration(milliseconds: 600),
            repeat: true,
            minRadius: 60,
            ripplesCount: 6,
            duration: const Duration(seconds: 3),
            child: Image.asset(
              'assets/images/logo2.png',
              height: 120,
              width: 120,
            ),
          ),
        ),
      ),
    );
  }
}
