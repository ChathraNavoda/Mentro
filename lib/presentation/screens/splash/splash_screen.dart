// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:mentro/presentation/screens/auth/login_screen.dart';
// import 'package:mentro/presentation/screens/home/home_screen.dart';
// import 'package:mentro/presentation/screens/splash/onboarding_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _rippleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _startAnimation();
//     _navigateAfterDelay();
//   }

//   void _startAnimation() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _rippleAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }

//   Future<void> _navigateAfterDelay() async {
//     await Future.delayed(const Duration(seconds: 3));

//     final prefs = await SharedPreferences.getInstance();
//     final isOnboarded = prefs.getBool('isOnboarded') ?? false;
//     final user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       // Case 1: Already logged in
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     } else if (isOnboarded) {
//       // Case 2: Seen onboarding before
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     } else {
//       // Case 3: Brand new user
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const OnboardingWalkthrough()),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: ScaleTransition(
//           scale: _rippleAnimation,
//           child: Image.asset(
//             'assets/images/icon.png',
//             height: 120,
//             width: 120,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentro/presentation/screens/auth/login_screen.dart';
import 'package:mentro/presentation/screens/home/custom_bottom_navbar.dart';
import 'package:mentro/presentation/screens/splash/onboarding_screen.dart';
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

    FirebaseAuth.instance.authStateChanges().first.then((user) {
      if (_navigated || !mounted) return;

      if (user != null) {
        _navigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomBottomNavbar()),
        );
      } else if (isOnboarded) {
        _navigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _navigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingWalkthrough()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // prevents back press on Splash
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
