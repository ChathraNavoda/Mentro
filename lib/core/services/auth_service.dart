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
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      return 'Please fill in all fields.';
    }

    try {
      // Attempt signup
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'uid': credential.user!.uid,
      });

      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already in use.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        default:
          return 'Signup failed: ${e.message ?? 'Unknown error.'}';
      }
    } catch (e) {
      print('Signup Error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // -------------------- LOGIN --------------------
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return 'Please enter all the fields!';
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Check email verification
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut(); // Sign out to prevent access
        return 'Please verify your email before logging in.';
      }

      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found for this email.';
        case 'wrong-password':
          return 'Incorrect password. Try again.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return 'Login failed: ${e.message ?? 'Unknown error.'}';
      }
    } catch (e) {
      print('Login Error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
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
