import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

import 'screens/initial_splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/auth_checker.dart';

import 'screens/admin_dashboard.dart';
import 'screens/coach_dashboard.dart';
import 'screens/parent_dashboard.dart';
import 'screens/student_dashboard.dart';

import 'screens/student_list_screen.dart';
import 'screens/add_student_screen.dart';

import 'screens/attendance_screen.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/student_attendance_module_screen.dart';

import 'screens/fee_management_screen.dart';
import 'screens/notification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
            return ValueListenableBuilder<bool>(
              valueListenable: ThemeController.largeTextMode,
              builder: (context, largeText, ___) {
                return ValueListenableBuilder<String>(
                  valueListenable: ThemeController.fontFamily,
                  builder: (context, fontFamily, ____) {
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: 'YGCA Management System',

                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(
                              largeText ? 1.15 : 1.0,
                            ),
                          ),
                          child: child ?? const SizedBox.shrink(),
                        );
                      },

                      theme: YGCATheme.lightTheme(
                        fontFamily: ThemeController.selectedFontFamily,
                      ),
                      darkTheme: YGCATheme.darkTheme(
                        fontFamily: ThemeController.selectedFontFamily,
                      ),
                      themeMode: themeMode,

                      home: const InitialSplashScreen(),

                      routes: {
                        '/login': (context) => const LoginScreen(),
                        '/register': (context) => const RegisterScreen(),
                        '/auth-checker': (context) => const AuthChecker(),

                        '/admin': (context) => AdminDashboard(),
                        '/coach': (context) => const CoachDashboard(),
                        '/parent': (context) => const ParentDashboard(),
                        '/student': (context) => const StudentDashboard(),

                        '/student-list': (context) =>
                            const StudentListScreen(),
                        '/add-student': (context) => const AddStudentScreen(),

                        '/mark-attendance': (context) =>
                            const AttendanceScreen(),
                        '/attendance-history': (context) =>
                            const AttendanceHistoryScreen(),
                        '/attendance': (context) =>
                            const AttendanceHistoryScreen(),

                        '/fees': (context) => const FeeManagementScreen(),
                        '/notifications': (context) =>
                            const NotificationScreen(),
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}