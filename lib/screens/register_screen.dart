import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = "Student";
  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> registerUser() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account registered successfully")),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";

      if (e.code == 'email-already-in-use') {
        message = "This email is already registered";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
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
            _hero(context),
            _formCard(context),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      height: 430,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
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
                    Colors.black.withOpacity(0.50),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.black.withOpacity(0.35),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Image.asset(
                    'assets/images/ygca_logo.jpg',
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "CREATE YOUR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "ACCOUNT",
                    style: TextStyle(
                      color: gold,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Join YGCA and start your\njourney towards excellence",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.45,
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

  Widget _formCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: maroon,
                child: Icon(Icons.person_add, color: gold, size: 34),
              ),
              const SizedBox(height: 18),

              _premiumInput(
                icon: Icons.person_outline,
                label: "Full Name",
                hint: "Enter your full name",
                controller: nameController,
              ),

              const SizedBox(height: 14),

              _premiumInput(
                icon: Icons.mail_outline,
                label: "Email Address",
                hint: "Enter your email address",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              _premiumInput(
                icon: Icons.lock_outline,
                label: "Password",
                hint: "Enter your password",
                controller: passwordController,
                obscureText: obscurePassword,
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

              const SizedBox(height: 14),

              _roleDropdown(),

              const SizedBox(height: 16),

              _trustBox(),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                    elevation: 8,
                    shadowColor: maroon.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : registerUser,
                  icon: isLoading
                      ? const SizedBox()
                      : const Icon(Icons.arrow_forward, size: 22),
                  label: isLoading
                      ? CircularProgressIndicator(color: gold, strokeWidth: 2)
                      : const Text(
                          "REGISTER ACCOUNT",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(child: Divider(color: border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: border)),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _socialButton(
                      icon: Icons.g_mobiledata,
                      text: "Google",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _socialButton(
                      icon: Icons.apple,
                      text: "Apple",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Login Now",
                      style: TextStyle(
                        color: maroon,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumInput({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: maroon,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: gold, size: 22),
          ),
          suffixIcon: suffix,
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  Widget _roleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Select Role",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: maroon,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield_outlined, color: gold, size: 22),
              ),
            ),
            items: const [
              DropdownMenuItem(value: "Admin", child: Text("Admin")),
              DropdownMenuItem(value: "Coach", child: Text("Coach")),
              DropdownMenuItem(value: "Parent", child: Text("Parent")),
              DropdownMenuItem(value: "Student", child: Text("Student")),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedRole = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _trustBox() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: gold,
            child: const Icon(Icons.verified, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Join thousands of players who trust YGCA",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Best coaches, world-class training and bright futures",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String text,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$text sign up coming soon")),
          );
        },
        icon: Icon(icon, size: 28),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _footer() {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
        decoration: BoxDecoration(
          color: maroon,
          border: Border(top: BorderSide(color: gold, width: 2)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _footerItem(Icons.favorite_border, "PASSION"),
            _footerItem(Icons.star_border, "DISCIPLINE"),
            _footerItem(Icons.emoji_events_outlined, "SUCCESS"),
          ],
        ),
      ),
    );
  }

  Widget _footerItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 28),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}