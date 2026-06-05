import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/coach_dashboard.dart';
import 'screens/parent_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/student_list_screen.dart';
import 'screens/add_student_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/fee_management_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YGCA Management System',

      // App starts with Home Screen
      home: const HomeScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),

        '/admin': (context) => const AdminDashboard(),
        '/coach': (context) => const CoachDashboard(),
        '/parent': (context) => const ParentDashboard(),
        '/student': (context) => const StudentDashboard(),

        '/student-list': (context) => const StudentListScreen(),
        '/add-student': (context) => const AddStudentScreen(),

        '/attendance': (context) => const AttendanceScreen(),
        '/fees': (context) => const FeeManagementScreen(),
      },
    );
  }
}