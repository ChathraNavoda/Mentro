import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentro/core/services/auth_service.dart';
import 'package:mentro/core/services/google_service.dart';
import 'package:mentro/presentation/screens/auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await AuthService().logout();
                await GoogleService().googleSignOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              child: Icon(Icons.logout),
            ),
            Image.network('${FirebaseAuth.instance.currentUser!.photoURL}'),
            Text('${FirebaseAuth.instance.currentUser!.displayName}'),
            Text('${FirebaseAuth.instance.currentUser!.email}'),
          ],
        ),
      ),
    );
  }
}
