// Packages
import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        throw Exception("Google Sign-in Aborted by user");
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      log(user?.uid ?? "Unknown UID");
      log(user?.email ?? "Unknown Email ID");
      log(user?.displayName ?? "Unknown Display Name");
      log(user?.photoURL ?? "Unknown Profile Photo URL");

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Error Signin in");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();

    log("User logged out sucessfully");
  }
}
