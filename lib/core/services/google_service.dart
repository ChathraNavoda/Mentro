import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  final firestore = FirebaseFirestore.instance;

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return 'Sign-in was canceled';
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'uid': user.uid,
            'photoUrl': user.photoURL ?? '',
            'signInMethod': 'google',
          });
        }
        return 'success';
      } else {
        return 'Sign-in failed';
      }
    } on FirebaseAuthException catch (e) {
      print('Google sign-in Firebase error: ${e.message}');
      return 'Sign-in failed: ${e.message}';
    } catch (e) {
      print('Unexpected Google sign-in error: $e');
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> googleSignOut() async {
    try {
      await googleSignIn.signOut();
      await auth.signOut();
      print('User signed out from Google.');
    } catch (e) {
      print('Google SignOut Error: $e');
    }
  }
}
