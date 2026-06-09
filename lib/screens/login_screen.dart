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
  bool obscurePassword = true;

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);
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

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signOut();

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception("User role not found");
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final role = data['role']?.toString().trim();

      if (!mounted) return;

      if (role == "Admin") {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else if (role == "Coach") {
        Navigator.pushNamedAndRemoveUntil(context, '/coach', (route) => false);
      } else if (role == "Parent") {
        Navigator.pushNamedAndRemoveUntil(context, '/parent', (route) => false);
      } else if (role == "Student") {
        Navigator.pushNamedAndRemoveUntil(context, '/student', (route) => false);
      } else {
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
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _hero(),
            _loginForm(),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      height: 390,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(42),
          bottomRight: Radius.circular(42),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_hero_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    darkMaroon.withOpacity(0.96),
                    maroon.withOpacity(0.72),
                    Colors.black.withOpacity(0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/ygca_logo.jpg',
                    height: 115,
                    width: 115,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        "WELCOME BACK",
                        style: TextStyle(
                          color: gold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 1, color: gold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "LOGIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "TO CONTINUE",
                    style: TextStyle(
                      color: gold,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Build your Cricket Career with us",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
      child: Column(
        children: [
          _label(Icons.mail_outline, "Email Address"),
          _input(
            controller: emailController,
            hint: "Enter your email",
            obscure: false,
          ),
          const SizedBox(height: 18),
          _label(Icons.lock_outline, "Password"),
          _input(
            controller: passwordController,
            hint: "Enter your password",
            obscure: obscurePassword,
            suffix: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() => obscurePassword = !obscurePassword);
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: maroon,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC247),
                foregroundColor: maroon,
                elevation: 8,
                shadowColor: gold.withOpacity(0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: isLoading ? null : _login,
              icon: isLoading ? const SizedBox() : const Icon(Icons.login),
              label: isLoading
                  ? CircularProgressIndicator(color: maroon, strokeWidth: 2)
                  : const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.8,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  "OR",
                  style: TextStyle(
                    color: textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Divider(color: border)),
            ],
          ),
          const SizedBox(height: 18),
          _socialButton(
            icon: Icons.g_mobiledata,
            text: "Continue with Google",
          ),
          const SizedBox(height: 12),
          _socialButton(
            icon: Icons.apple,
            text: "Continue with Apple",
          ),
          const SizedBox(height: 20),
          _registerCard(),
        ],
      ),
    );
  }

  Widget _label(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: maroon, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: gold, width: 1.3),
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$text coming soon")),
          );
        },
        icon: Icon(icon, size: 28),
        label: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _registerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: maroon, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New to YGCA?",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                SizedBox(height: 3),
                Text(
                  "Create an account to get started",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroon,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _goToRegister,
            child: const Text(
              "REGISTER",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: maroon,
        border: Border(top: BorderSide(color: gold, width: 2)),
      ),
      child: Column(
        children: [
          Text(
            "♥  Passion   |   ★  Discipline   |   🏆  Success",
            style: TextStyle(
              color: gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Since 2022",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}