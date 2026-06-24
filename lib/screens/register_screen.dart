import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentEmailController = TextEditingController();

  String selectedRole = "Student";
  bool isLoading = false;
  bool obscurePassword = true;

  bool get _needsApproval => selectedRole == "Student" || selectedRole == "Coach";

  Color _bg(bool isDark) => isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  Color _card(bool isDark) => isDark ? const Color(0xFF111111) : Colors.white;
  Color _border(bool isDark) => isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  Color _primaryText(bool isDark) => isDark ? Colors.white : const Color(0xFF111827);
  Color _secondaryText(bool isDark) => isDark ? Colors.white60 : const Color(0xFF64748B);

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final emailLower = email.toLowerCase();
    final password = passwordController.text.trim();
    final age = ageController.text.trim();
    final phone = phoneController.text.trim();
    final parentName = parentNameController.text.trim();
    final parentEmail = parentEmailController.text.trim();
    final parentEmailLower = parentEmail.toLowerCase();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill name, email and password")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    if (selectedRole == "Student") {
      if (age.isEmpty || phone.isEmpty || parentName.isEmpty || parentEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill student age, phone and parent details")),
        );
        return;
      }
    }

    if (selectedRole == "Coach" && phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill coach phone number")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final isPending = selectedRole == "Student" || selectedRole == "Coach";

      final userRef = firestore.collection('users').doc(uid);

      final userData = <String, dynamic>{
        'uid': uid,
        'name': name,
        'email': email,
        'emailLower': emailLower,
        'role': selectedRole,
        'approvalStatus': isPending ? 'Pending' : 'Approved',
        'status': isPending ? 'Pending' : 'Active',
        'isApproved': !isPending,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (phone.isNotEmpty) {
        userData['phone'] = phone;
      }

      batch.set(userRef, userData, SetOptions(merge: true));

      if (selectedRole == "Student") {
        final studentRef = firestore.collection('students').doc(uid);

        batch.set(studentRef, {
          'uid': uid,
          'name': name,
          'role': 'Student',
          'email': email,
          'emailLower': emailLower,
          'age': age,
          'phone': phone,
          'parentName': parentName,
          'parentEmail': parentEmail,
          'parentEmailLower': parentEmailLower,
          'approvalStatus': 'Pending',
          'status': 'Pending',
          'isApproved': false,
          'batch': '',
          'rollNo': '',
          'attendance': '0%',
          'feeStatus': 'Pending',
          'presentCount': 0,
          'totalAttendanceCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (selectedRole == "Coach") {
        final coachRef = firestore.collection('coaches').doc(uid);

        batch.set(coachRef, {
          'uid': uid,
          'name': name,
          'email': email,
          'emailLower': emailLower,
          'role': 'Coach',
          'phone': phone,
          'specialization': 'Coach',
          'approvalStatus': 'Pending',
          'status': 'Pending',
          'isApproved': false,
          'assignedBatches': [],
          'batch': '',
          'batchText': '',
          'assignedStudents': '0',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        batch.set(userRef, {
          'assignedBatches': [],
          'batch': '',
          'batchText': '',
          'assignedStudents': '0',
          'phone': phone,
        }, SetOptions(merge: true));
      }

      await batch.commit();
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedRole == "Student"
                ? "Student registered. Waiting for admin approval."
                : selectedRole == "Coach"
                    ? "Coach registered. Waiting for admin approval."
                    : "Parent account registered successfully.",
          ),
          backgroundColor: Colors.green,
        ),
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e"), backgroundColor: Colors.red),
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
    ageController.dispose();
    phoneController.dispose();
    parentNameController.dispose();
    parentEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final h = MediaQuery.of(context).size.height;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  _hero(context, h, isDark),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                    child: Column(
                      children: [
                        _input(
                          isDark: isDark,
                          icon: Icons.person_outline,
                          label: "Full Name",
                          controller: nameController,
                        ),
                        const SizedBox(height: 12),
                        _input(
                          isDark: isDark,
                          icon: Icons.mail_outline,
                          label: "Email Address",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _input(
                          isDark: isDark,
                          icon: Icons.lock_outline,
                          label: "Password",
                          controller: passwordController,
                          obscureText: obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: _secondaryText(isDark),
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        _roleDropdown(isDark),
                        if (_needsApproval) ...[
                          const SizedBox(height: 14),
                          _approvalNoteCard(isDark),
                        ],
                        if (selectedRole == "Student") ...[
                          const SizedBox(height: 12),
                          _input(
                            isDark: isDark,
                            icon: Icons.cake_outlined,
                            label: "Student Age",
                            controller: ageController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          _input(
                            isDark: isDark,
                            icon: Icons.phone_outlined,
                            label: "Phone Number",
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _input(
                            isDark: isDark,
                            icon: Icons.family_restroom,
                            label: "Parent Name",
                            controller: parentNameController,
                          ),
                          const SizedBox(height: 12),
                          _input(
                            isDark: isDark,
                            icon: Icons.email_outlined,
                            label: "Parent Email",
                            controller: parentEmailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                        if (selectedRole == "Coach") ...[
                          const SizedBox(height: 12),
                          _input(
                            isDark: isDark,
                            icon: Icons.phone_outlined,
                            label: "Phone Number",
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                        const SizedBox(height: 16),
                        _registerButton(isDark),
                        const SizedBox(height: 12),
                        _loginText(isDark),
                        const SizedBox(height: 20),
                        _footerMini(isDark),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _hero(BuildContext context, double h, bool isDark) {
    return Container(
      height: h * 0.31,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
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
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.95),
                          darkMaroon.withOpacity(0.82),
                          red.withOpacity(0.45),
                        ]
                      : [
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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Colors.black.withOpacity(0.35),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Colors.black.withOpacity(0.35),
                      child: IconButton(
                        onPressed: ThemeController.toggleTheme,
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/ygca_logo.jpg',
                  height: 74,
                  width: 74,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 6),
                const Text(
                  "CREATE YOUR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "ACCOUNT",
                  style: TextStyle(
                    color: gold,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Join YGCA and start your journey",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required bool isDark,
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: _primaryText(isDark),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: isDark ? gold : maroon,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _secondaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: isDark ? gold : maroon),
        suffixIcon: suffix,
        filled: true,
        fillColor: _card(isDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _border(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? red : gold, width: 1.5),
        ),
      ),
    );
  }

  Widget _roleDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      dropdownColor: _card(isDark),
      style: TextStyle(
        color: _primaryText(isDark),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: "Select Role",
        labelStyle: TextStyle(
          color: _secondaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(Icons.shield_outlined, color: isDark ? gold : maroon),
        filled: true,
        fillColor: _card(isDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _border(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _border(isDark)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "Student", child: Text("Student")),
        DropdownMenuItem(value: "Coach", child: Text("Coach")),
        DropdownMenuItem(value: "Parent", child: Text("Parent")),
      ],
      onChanged: isLoading
          ? null
          : (value) {
              if (value == null) return;
              setState(() => selectedRole = value);
            },
    );
  }

  Widget _approvalNoteCard(bool isDark) {
    final message = selectedRole == "Coach"
        ? "Coach account will be sent to admin approval. Admin will assign batch before dashboard access."
        : "Student account will be sent to admin approval. Admin will assign batch and roll number.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isDark ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_actions, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.orangeAccent : const Color(0xFF92400E),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? red : maroon,
          foregroundColor: isDark ? Colors.white : gold,
          elevation: 8,
          shadowColor: maroon.withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : registerUser,
        icon: isLoading ? const SizedBox() : const Icon(Icons.person_add),
        label: isLoading
            ? CircularProgressIndicator(color: isDark ? Colors.white : gold, strokeWidth: 2)
            : const Text(
                "REGISTER ACCOUNT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _loginText(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: _secondaryText(isDark), fontSize: 12),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Login Now",
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _footerMini(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "♥ Passion  •  ★ Discipline  •  🏆 Success",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? gold : maroon,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
