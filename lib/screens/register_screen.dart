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

  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentEmailController = TextEditingController();

  String selectedRole = "Student";
  bool isLoading = false;
  bool obscurePassword = true;

  bool get _needsApproval {
    return selectedRole == "Student" || selectedRole == "Coach";
  }

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
      if (age.isEmpty ||
          phone.isEmpty ||
          parentName.isEmpty ||
          parentEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill student age, phone and parent details"),
          ),
        );
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final isPending = selectedRole == "Student" || selectedRole == "Coach";

      final userRef = firestore.collection('users').doc(uid);

      batch.set(userRef, {
        'uid': uid,
        'name': name,
        'email': email,
        'emailLower': emailLower,
        'role': selectedRole,
        'approvalStatus': isPending ? 'Pending' : 'Approved',
        'status': isPending ? 'Pending' : 'Active',
        'isApproved': isPending ? false : true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedRole == "Student"
                ? "Student registered. Waiting for admin approval."
                : selectedRole == "Coach"
                    ? "Coach registered. Waiting for admin approval."
                    : "Account registered successfully.",
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
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
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
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _hero(context, h),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                child: Column(
                  children: [
                    _input(
                      icon: Icons.person_outline,
                      label: "Full Name",
                      controller: nameController,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      icon: Icons.mail_outline,
                      label: "Email Address",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      icon: Icons.lock_outline,
                      label: "Password",
                      controller: passwordController,
                      obscureText: obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _roleDropdown(),

                    if (_needsApproval) ...[
                      const SizedBox(height: 14),
                      _approvalNoteCard(),
                    ],

                    if (selectedRole == "Student") ...[
                      const SizedBox(height: 12),
                      _input(
                        icon: Icons.cake_outlined,
                        label: "Student Age",
                        controller: ageController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _input(
                        icon: Icons.phone_outlined,
                        label: "Phone Number",
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _input(
                        icon: Icons.family_restroom,
                        label: "Parent Name",
                        controller: parentNameController,
                      ),
                      const SizedBox(height: 12),
                      _input(
                        icon: Icons.email_outlined,
                        label: "Parent Email",
                        controller: parentEmailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],

                    if (selectedRole == "Coach") ...[
                      const SizedBox(height: 12),
                      _input(
                        icon: Icons.phone_outlined,
                        label: "Phone Number",
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ],

                    const SizedBox(height: 16),
                    _registerButton(),
                    const SizedBox(height: 12),
                    _loginText(),
                    const SizedBox(height: 20),
                    _footerMini(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, double h) {
    return Container(
      height: h * 0.30,
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
      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: Color(0xFF7F0000),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(icon, color: maroon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: gold, width: 1.5),
        ),
      ),
    );
  }

  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      dropdownColor: Colors.white,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: "Select Role",
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(Icons.shield_outlined, color: maroon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "Student", child: Text("Student")),
        DropdownMenuItem(value: "Coach", child: Text("Coach")),
        DropdownMenuItem(value: "Parent", child: Text("Parent")),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => selectedRole = value);
      },
    );
  }

  Widget _approvalNoteCard() {
    final message = selectedRole == "Coach"
        ? "Coach accounts will be sent to admin approval. Admin will assign batch before dashboard access."
        : "Student accounts will be sent to admin approval. Admin will assign batch and roll number.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
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
              style: const TextStyle(
                color: Color(0xFF92400E),
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

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: maroon,
          foregroundColor: gold,
          elevation: 8,
          shadowColor: maroon.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isLoading ? null : registerUser,
        icon: isLoading ? const SizedBox() : const Icon(Icons.person_add),
        label: isLoading
            ? CircularProgressIndicator(color: gold, strokeWidth: 2)
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

  Widget _loginText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Login Now",
            style: TextStyle(
              color: maroon,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _footerMini() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "♥ Passion  •  ★ Discipline  •  🏆 Success",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: maroon,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}