// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<String> signupUser({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     String res = 'Some error occurred!';
//     try {
//       if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
//         UserCredential credential = await _auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         await _firestore.collection('users').doc(credential.user!.uid).set({
//           'name': name,
//           'email': email,
//           'uid': credential.user!.uid,
//         });
//         res = 'success';
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//     return res;
//   }

//   Future<String> loginUser({
//     required String email,
//     required String password,
//   }) async {
//     String res = 'Some error occurred!';
//     try {
//       if (email.isNotEmpty || password.isNotEmpty) {
//         await _auth.signInWithEmailAndPassword(
//             email: email, password: password);
//         res = 'success';
//       } else {
//         res = 'Please enter all the fields!';
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//     return res;
//   }

//   Future<void> logout() async {
//     await _auth.signOut();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // -------------------- SIGN UP --------------------
  Future<String> signupUser({
    required String name,
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred!';
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'uid': credential.user!.uid,
        });

        res = 'success';
      } else {
        res = 'Please fill in all fields.';
      }
    } catch (e) {
      res = e.toString();
      print('Signup Error: $e');
    }
    return res;
  }

  // -------------------- LOGIN --------------------
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred!';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = 'Please enter all the fields!';
      }
    } catch (e) {
      res = e.toString();
      print('Login Error: $e');
    }
    return res;
  }

  // -------------------- LOGOUT --------------------
  Future<void> logout() async {
    try {
      // Only clear session-related data — DO NOT clear user progress
      await _auth.signOut();

      // If using Google Sign-In
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect(); // Optional: revoke access
        await _googleSignIn.signOut();
      }

      // Remove tokens or sensitive session flags only
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn'); // or similar flags only
      // DO NOT call prefs.clear()

      // Remove only session-specific secure data
      await _secureStorage.delete(key: 'session_token'); // Example
      // DO NOT call deleteAll()

      print("User signed out successfully.");
    } catch (e) {
      print('Logout Error: $e');
    }
  }
}
