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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   // -------------------- SIGN UP --------------------
//   Future<String> signupUser({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     if (name.trim().isEmpty ||
//         email.trim().isEmpty ||
//         password.trim().isEmpty) {
//       return 'Please fill in all fields.';
//     }

//     try {
//       // Attempt signup
//       UserCredential credential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );

//       // Send verification email
//       await credential.user!.sendEmailVerification();

//       // Save displayName temporarily in FirebaseAuth (used later to create Firestore user)
//       await credential.user!.updateDisplayName(name.trim());

//       // Sign out immediately until verified
//       await _auth.signOut();

//       return 'Please verify your email before logging in. We sent a link to your email. Check your spam folder if not found.';
//     } on FirebaseAuthException catch (e) {
//       switch (e.code) {
//         case 'email-already-in-use':
//           return 'This email is already in use.';
//         case 'invalid-email':
//           return 'The email address is invalid.';
//         case 'weak-password':
//           return 'Password should be at least 6 characters.';
//         default:
//           return 'Signup failed: ${e.message ?? 'Unknown error.'}';
//       }
//     } catch (e) {
//       print('Signup Error: $e');
//       return 'An unexpected error occurred. Please try again.';
//     }
//   }

//   // -------------------- LOGIN --------------------
//   Future<String> loginUser({
//     required String email,
//     required String password,
//   }) async {
//     if (email.trim().isEmpty || password.trim().isEmpty) {
//       return 'Please enter all the fields!';
//     }

//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );

//       User? user = userCredential.user;

//       // Check email verification
//       if (!user!.emailVerified) {
//         await _auth.signOut(); // Sign out to prevent access

//         // Optionally delete unverified accounts to clean DB
//         await user.delete();
//         return 'Please verify your email before logging in. Check your spam folder if you can’t find the verification email.';
//       }

//       // Check if Firestore user document exists
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       if (!userDoc.exists) {
//         await _firestore.collection('users').doc(user.uid).set({
//           'name': user.displayName ?? '', // Using displayName saved at signup
//           'email': user.email ?? '',
//           'uid': user.uid,
//           'createdAt': Timestamp.now(),
//         });
//       }

//       return 'success';
//     } on FirebaseAuthException catch (e) {
//       switch (e.code) {
//         case 'user-not-found':
//           return 'No account found for this email.';
//         case 'wrong-password':
//           return 'Incorrect password. Try again.';
//         case 'invalid-email':
//           return 'Invalid email address.';
//         default:
//           return 'Login failed: ${e.message ?? 'Unknown error.'}';
//       }
//     } catch (e) {
//       print('Login Error: $e');
//       return 'An unexpected error occurred. Please try again.';
//     }
//   }

//   // -------------------- LOGOUT --------------------
//   Future<void> logout() async {
//     try {
//       // Only clear session-related data — DO NOT clear user progress
//       await _auth.signOut();

//       // If using Google Sign-In
//       if (await _googleSignIn.isSignedIn()) {
//         await _googleSignIn.disconnect(); // Optional: revoke access
//         await _googleSignIn.signOut();
//       }

//       // Remove tokens or sensitive session flags only
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('isLoggedIn'); // or similar flags only
//       // DO NOT call prefs.clear()

//       // Remove only session-specific secure data
//       await _secureStorage.delete(key: 'session_token'); // Example
//       // DO NOT call deleteAll()

//       print("User signed out successfully.");
//     } catch (e) {
//       print('Logout Error: $e');
//     }
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
  Future<Map<String, String>> signupUser({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      return {'status': 'error', 'message': 'Please fill in all fields.'};
    }

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await credential.user!.sendEmailVerification();
      await credential.user!.updateDisplayName(name.trim());
      await _auth.signOut();

      return {
        'status': 'success',
        'message':
            'Signup successful! A verification link has been sent to your email. Please verify before logging in.'
      };
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return {
            'status': 'error',
            'message': 'This email is already in use. Try logging in instead.'
          };
        case 'invalid-email':
          return {
            'status': 'error',
            'message': 'Please enter a valid email address.'
          };
        case 'weak-password':
          return {
            'status': 'error',
            'message': 'Password should be at least 6 characters.'
          };
        default:
          return {
            'status': 'error',
            'message': 'Signup failed: ${e.message ?? 'Unknown error.'}'
          };
      }
    } catch (e) {
      print('Signup Error: $e');
      return {
        'status': 'error',
        'message': 'An unexpected error occurred. Please try again.'
      };
    }
  }

  // -------------------- LOGIN --------------------
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return 'Please enter both email and password!';
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      // Check email verification
      if (!user!.emailVerified) {
        await _auth.signOut(); // Sign out to prevent access

        // Optionally delete unverified accounts to clean DB
        await user.delete();
        return 'Your email is not verified yet. Please check your inbox and spam folder for the verification link before logging in.';
      }

      // Check if Firestore user document exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'uid': user.uid,
          'createdAt': Timestamp.now(),
        });
      }

      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found for this email. Please sign up first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
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
      await _auth.signOut();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      await _secureStorage.delete(key: 'session_token');

      print("User signed out successfully.");
    } catch (e) {
      print('Logout Error: $e');
    }
  }
}
