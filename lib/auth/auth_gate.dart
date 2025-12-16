import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager_application_finalproject/views/user/user_homepage.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_homepage.dart';
import 'package:event_manager_application_finalproject/views/admin/admin_homepage.dart';
import 'package:event_manager_application_finalproject/homepage.dart';
import 'package:event_manager_application_finalproject/auth_service.dart';

/// Gate that routes the user depending on their auth state and role.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
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
          // A signed-in user -> determine role and route to appropriate dashboard
          return FutureBuilder<String>(
            future: _getUserRole(user),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data ?? 'user';
              switch (role) {
                case 'admin':
                  return const AdminDashboard();
                case 'manager':
                  return const ManagerDashboard();
                default:
                  return const UserHomePageWidget();
              }
            },
          );
        }

        // Not signed in -> show onboarding/login flow
        return const HomeRedirect();
      },
    );
  }

  Future<String> _getUserRole(User user) async {
    try {
      // First check if role is stored in Firestore
      final usersRef = FirebaseFirestore.instance.collection('users');
      final doc = await usersRef.doc(user.uid).get();

      if (doc.exists && doc.data()?['role'] != null) {
        final storedRole = doc.data()!['role'] as String;
        // If stored role is 'user' but email suggests manager/admin, upgrade it
        final derivedRole = AuthService.determineRoleFromEmail(user.email ?? '');
        if (storedRole == 'user' && (derivedRole == 'manager' || derivedRole == 'admin')) {
          // Update the stored role
          await usersRef.doc(user.uid).set({
            'role': derivedRole,
          }, SetOptions(merge: true));
          return derivedRole;
        }
        return storedRole;
      }

      // No stored role, determine from email pattern
      final role = AuthService.determineRoleFromEmail(user.email ?? '');
      // Store the role for future use
      await usersRef.doc(user.uid).set({
        'email': user.email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return role;
    } catch (e) {
      // On error, default to user role
      return 'user';
    }
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
