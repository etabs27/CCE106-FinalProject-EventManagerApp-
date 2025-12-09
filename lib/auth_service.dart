import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Fixed test accounts have been REMOVED
  // All authentication now goes through Firebase

  static Future<String?> signIn(String email, String password) async {
    try {
      // Use Firebase Authentication for email/password sign in
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (userCredential.user != null) {
        // Determine role from email (you can modify this logic as needed)
        return determineRoleFromEmail(userCredential.user!.email!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  static String? displayNameFor(String email) {
    // Get display name from Firebase user or return email prefix
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email == email) {
      return user.displayName ?? email.split('@')[0];
    }
    return email.split('@')[0];
  }

  static Future<String?> signInWithGoogle() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        try {
          final UserCredential userCredential =
              await _auth.signInWithPopup(googleProvider);
          final User? user = userCredential.user;
          return user != null ? 'user' : null;
        } on FirebaseAuthException catch (e) {
          final code = e.code;
          
          print('AuthService.signInWithGoogle web popup error: $code - ${e.message}');
          if (code == 'cancelled-popup-request' || code == 'popup-blocked' || code == 'operation-not-supported-in-this-environment') {
            try {
              await _auth.signInWithRedirect(googleProvider);
              return null;
            } catch (e2) {
              print('AuthService.signInWithGoogle redirect fallback error: $e2');
              return null;
            }
          }
          
          return null;
        }
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;
        return user != null ? 'user' : null;
      }
    } catch (e) {
      print('AuthService.signInWithGoogle error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Ignore Google sign out errors
      }
    } catch (e) {
      // Ignore sign out errors
    }
  }

  static String determineRoleFromEmail(String email) {
    final e = email.trim().toLowerCase();
    // Admin pattern: name.admin@davaoevents.com or name.admin@eventsdavao.com
    final adminPattern = RegExp(r"\.admin@(davaoevents|eventsdavao)\.com$");
    if (adminPattern.hasMatch(e)) return 'admin';

    // Manager domains: either @davaoevents.com or @eventsdavao.com
    if (e.endsWith('@davaoevents.com') || e.endsWith('@eventsdavao.com')) return 'manager';

    return 'user';
  }
}