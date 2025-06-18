import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mentro/presentation/screens/analytics/analytic_screen.dart';
import 'package:mentro/presentation/screens/history/history_screen.dart';
import 'package:mentro/presentation/screens/home/home_screen.dart';
import 'package:mentro/presentation/screens/ripples/ripple_screen.dart';
import 'package:mentro/presentation/screens/settings/settings_screen.dart';

class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({super.key});

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  int currentIndex = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      pages = [
        const HomeScreen(),
        RippleScreen(userId: user.uid),
        MoodAnalyticsScreen(userId: user.uid),
        const HistoryScreen(),
        const SettingsScreen(),
      ];
    }
  }

  Future<bool> _onWillPop() async {
    if (currentIndex != 0) {
      // If not on Home tab, go back to Home
      setState(() {
        currentIndex = 0;
      });
      return false; // prevent exiting the app
    } else {
      // Exit app from Home tab
      SystemNavigator.pop();
      return false; // prevent default back behavior
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button behavior
      child: Scaffold(
        body: pages.isNotEmpty ? pages[currentIndex] : const SizedBox(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF4ECDC4),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.waves_outlined), label: 'Ripples'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
