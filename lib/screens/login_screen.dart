import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = "Admin";

  final Color maroon = const Color(0xFF7F0000);
  final Color maroonLight = const Color(0xFF991B1B);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);
  final Color textDark = const Color(0xFF1A1A1A);
  final Color textLight = const Color(0xFF94A3B8);

  void _goToDashboard() {
    if (selectedRole == "Admin") {
      Navigator.pushNamed(context, '/admin');
    } else if (selectedRole == "Coach") {
      Navigator.pushNamed(context, '/coach');
    } else if (selectedRole == "Parent") {
      Navigator.pushNamed(context, '/parent');
    } else if (selectedRole == "Player / Student") {
      Navigator.pushNamed(context, '/student');
    }
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
                    Text("9:41", style: TextStyle(color: Colors.white, fontSize: 11)),
                    Text("YGCA", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
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
                      "Sign in to your account",
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
                      _label("Login as"),
                      _dropDown(),
                      const SizedBox(height: 10),
                      _label("Phone / Email"),
                      _input("Enter phone or email", false),
                      const SizedBox(height: 10),
                      _label("Password"),
                      _input("Enter password", true),
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
                          onPressed: _goToDashboard,
                          child: const Text("Sign in"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("New player? ", style: TextStyle(color: textLight, fontSize: 12)),
                          Text("Register here", style: TextStyle(color: gold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Divider(color: border),
                      const SizedBox(height: 8),
                      Text(
                        "Quick role access (POC demo)",
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
                          _roleButton("Admin"),
                          _roleButton("Coach"),
                          _roleButton("Parent"),
                          _roleButton("Student"),
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

  Widget _dropDown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedRole,
      decoration: _decoration(),
      items: const [
        DropdownMenuItem(value: "Admin", child: Text("Admin")),
        DropdownMenuItem(value: "Coach", child: Text("Coach")),
        DropdownMenuItem(value: "Parent", child: Text("Parent")),
        DropdownMenuItem(value: "Player / Student", child: Text("Player / Student")),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          selectedRole = value;
        });
      },
    );
  }

  Widget _input(String hint, bool obscure) {
    return TextField(
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

  Widget _roleButton(String text) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedRole = text == "Student" ? "Player / Student" : text;
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: textDark,
        side: BorderSide(color: border, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}