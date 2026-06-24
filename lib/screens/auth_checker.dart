import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

import 'home_screen.dart';
import 'admin_dashboard.dart';
import 'coach_dashboard.dart';
import 'parent_dashboard.dart';
import 'student_dashboard.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  String _safeText(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  bool _isApproved(Map<String, dynamic> data) {
    final approvalStatus = _safeText(data['approvalStatus']).toLowerCase();
    final status = _safeText(data['status']).toLowerCase();
    final isApproved = data['isApproved'] == true;

    return approvalStatus == 'approved' &&
        status == 'active' &&
        isApproved == true;
  }

  bool _hasAssignedBatch(Map<String, dynamic> data) {
    final rawBatches = data['assignedBatches'];

    if (rawBatches is List) {
      final validBatches = rawBatches
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (validBatches.isNotEmpty) return true;
    }

    final batch = _safeText(data['batch']);
    final assignedBatch = _safeText(data['assignedBatch']);
    final batchText = _safeText(data['batchText']);

    return batch.isNotEmpty || assignedBatch.isNotEmpty || batchText.isNotEmpty;
  }

  Future<Map<String, dynamic>?> _getStudentData(String uid) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .get();

    if (studentDoc.exists && studentDoc.data() != null) {
      return studentDoc.data();
    }

    final query = await FirebaseFirestore.instance
        .collection('students')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }

    return null;
  }

  Future<Widget> _getStartScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    debugPrint("Current User: ${user?.uid}");

    if (user == null) {
      return const HomeScreen();
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || userDoc.data() == null) {
      await FirebaseAuth.instance.signOut();
      return const HomeScreen();
    }

    final userData = userDoc.data() ?? {};
    final role = _safeText(userData['role']).toLowerCase();

    switch (role) {
      case 'admin':
        return const AdminDashboard();

      case 'coach':
        final coachApproved = _isApproved(userData);
        final hasBatch = _hasAssignedBatch(userData);

        if (!coachApproved || !hasBatch) {
          return const PendingApprovalScreen(
            title: "Waiting for Admin Approval",
            message:
                "Your coach account is registered successfully. Admin must approve your account and assign batch before you can enter the dashboard.",
          );
        }

        return const CoachDashboard();

      case 'parent':
        return const ParentDashboard();

      case 'student':
        final studentData = await _getStudentData(user.uid);

        if (studentData == null) {
          return const PendingApprovalScreen(
            title: "Student Profile Not Found",
            message:
                "Your student profile is not available. Please contact admin.",
          );
        }

        if (!_isApproved(studentData)) {
          return const PendingApprovalScreen(
            title: "Waiting for Admin Approval",
            message:
                "Your account is registered successfully. Admin must assign batch and roll number before you can enter the dashboard.",
          );
        }

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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashLoadingScreen();
        }

        if (snapshot.hasError) {
          return ErrorScreen(message: "Auth error: ${snapshot.error}");
        }

        if (!snapshot.hasData) {
          return const HomeScreen();
        }

        return snapshot.data!;
      },
    );
  }
}

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA),
          body: Center(
            child: Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.black,
                          darkMaroon,
                          red.withOpacity(0.35),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFFFFBF2),
                          gold.withOpacity(0.16),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? red.withOpacity(0.18)
                        : maroon.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ygca_logo.jpg',
                    width: 62,
                    height: 62,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 14),
                  CircularProgressIndicator(
                    color: isDark ? gold : maroon,
                    strokeWidth: 2.5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: _card(isDark),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.75),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? red.withOpacity(0.16)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/ygca_logo.jpg',
                        width: 76,
                        height: 76,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 18),
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.orange.withOpacity(0.14),
                        child: const Icon(
                          Icons.pending_actions_rounded,
                          color: Colors.orange,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? gold : maroon,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _secondaryText(isDark),
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : const Color(0xFFFFFBF2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border(isDark)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: isDark ? gold : maroon,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Please wait until admin completes approval.",
                                style: TextStyle(
                                  color: _primaryText(isDark),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? red : maroon,
                            foregroundColor: isDark ? Colors.white : gold,
                            elevation: 8,
                            shadowColor: red.withOpacity(0.25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            "LOGOUT",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: ThemeController.toggleTheme,
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          size: 18,
                        ),
                        label: Text(isDark ? "Light Mode" : "Dark Mode"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.message});

  final String message;

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111111) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? red.withOpacity(0.35)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? red : maroon,
                            foregroundColor: isDark ? Colors.white : gold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _logout(context),
                          child: const Text(
                            "BACK TO HOME",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}