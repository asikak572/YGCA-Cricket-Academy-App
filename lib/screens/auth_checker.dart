import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'admin_dashboard.dart';
import 'coach_dashboard.dart';
import 'parent_dashboard.dart';
import 'student_dashboard.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  Future<Widget> _getStartScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    print("Current User: ${user?.uid}");

    if (user == null) {
      return const HomeScreen();
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      await FirebaseAuth.instance.signOut();
      return const HomeScreen();
    }

    final role = userDoc.data()?['role'];

    switch (role) {
      case 'Admin':
        return const AdminDashboard();

      case 'Coach':
        return const CoachDashboard();

      case 'Parent':
        return const ParentDashboard();

      case 'Student':
        return const StudentDashboard();

      default:
        await FirebaseAuth.instance.signOut();
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartScreen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return snapshot.data!;
      },
    );
  }
}