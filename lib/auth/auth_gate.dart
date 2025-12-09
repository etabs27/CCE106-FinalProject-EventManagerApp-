import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/homepage.dart';

/// Simple gate that routes the user depending on their auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          // A signed-in user -> go to user home. Role mapping can be
          // added later if you want manager/admin routing.
          return const UserHomePageWidget();
        }

        // Not signed in -> show onboarding/login flow
        return const HomeRedirect();
      },
    );
  }
}

/// Small helper that shows the existing `HomePageWidget` (onboarding)
/// and navigates to login from there. Kept as a thin wrapper to avoid
/// importing onboarding into many modules.
class HomeRedirect extends StatelessWidget {
  const HomeRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageWidget();
  }
}
