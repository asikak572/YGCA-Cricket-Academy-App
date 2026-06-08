import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  final Color maroon = const Color(0xFF7F0000);
  final Color maroonLight = const Color(0xFF991B1B);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);
  final Color textDark = const Color(0xFF1A1A1A);
  final Color textLight = const Color(0xFF94A3B8);

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception("User role not found");
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final role = data['role']?.toString().trim();

      if (!mounted) return;

     if (role == "Admin") {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/admin',
    (route) => false,
  );
} else if (role == "Coach") {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/coach',
    (route) => false,
  );
} else if (role == "Parent") {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/parent',
    (route) => false,
  );
} else if (role == "Student") {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/student',
    (route) => false,
  );
}else {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid user role")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      } else if (e.code == 'invalid-credential') {
        message = "Invalid email or password";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Container(
          width: 340,
          height: 680,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: border, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                height: 28,
                color: maroon,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "9:41",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    Text(
                      "YGCA",
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 11,
                      ),
                    ),
                    Text("📶 🔋", style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                color: maroon,
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 34),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: maroonLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.sports_cricket, color: gold, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "YOUNG GEN CRICKET ACADEMY",
                      style: TextStyle(
                        color: gold,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Welcome back",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      "Sign in with Firebase",
                      style: TextStyle(
                        color: Color(0xFFE5E7EB),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _label("Email"),
                      _input(
                        "Enter email",
                        false,
                        controller: emailController,
                      ),

                      const SizedBox(height: 10),

                      _label("Password"),
                      _input(
                        "Enter password",
                        true,
                        controller: passwordController,
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(color: gold, fontSize: 11),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroon,
                            foregroundColor: gold,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isLoading ? null : _login,
                          child: Text(
                            isLoading ? "Checking..." : "Sign in",
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New user? ",
                            style: TextStyle(color: textLight, fontSize: 12),
                          ),
                          GestureDetector(
                            onTap: _goToRegister,
                            child: Text(
                              "Register here",
                              style: TextStyle(
                                color: gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      Divider(color: border),
                      const SizedBox(height: 8),

                      Text(
                        "Role will be checked from Firestore users collection",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textLight, fontSize: 10),
                      ),

                      const SizedBox(height: 10),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        childAspectRatio: 3.2,
                        children: [
                          _roleInfo("Admin"),
                          _roleInfo("Coach"),
                          _roleInfo("Parent"),
                          _roleInfo("Student"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ),
    );
  }

  Widget _input(
    String hint,
    bool obscure, {
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: _decoration().copyWith(hintText: hint),
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: gold, width: 1),
      ),
    );
  }

  Widget _roleInfo(String text) {
    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: textDark,
        side: BorderSide(color: border, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}