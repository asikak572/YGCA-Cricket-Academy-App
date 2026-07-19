import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final parentEmailController = TextEditingController();
  final aadhaarController = TextEditingController();
  final addressController = TextEditingController();

  String feeStatus = 'Pending';
  String selectedBatch = 'Friday: 6:00 PM – 8:00 PM';
  bool isLoading = false;

  final List<String> batchOptions = const [
    'Friday: 6:00 PM – 8:00 PM',
    'Saturday: 7:00 AM – 9:00 AM',
    'Saturday: 4:00 PM – 6:00 PM',
    'Saturday: 6:00 PM – 8:00 PM',
  ];

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

  String _cleanEmail(String value) {
    return value.trim().toLowerCase();
  }

  Future<String> _generateRollNumber(String studentName) async {
    if (studentName.trim().isEmpty) return 'Y1';

    final firstLetter = studentName.trim()[0].toUpperCase();

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('approvalStatus', isEqualTo: 'Approved')
        .get();

    int count = 0;

    for (final doc in snapshot.docs) {
      final rollNo = doc.data()['rollNo']?.toString().toUpperCase() ?? '';
      if (rollNo.startsWith(firstLetter)) count++;
    }

    return '$firstLetter${count + 1}';
  }

  Future<void> _autoLinkParentToStudent({
    required String studentId,
    required String parentEmailRaw,
  }) async {
    final parentEmailLower = _cleanEmail(parentEmailRaw);
    if (parentEmailLower.isEmpty) return;

    QuerySnapshot<Map<String, dynamic>> parentQuery =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Parent')
            .where('emailLower', isEqualTo: parentEmailLower)
            .limit(1)
            .get();

    if (parentQuery.docs.isEmpty) {
      parentQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Parent')
          .where('email', isEqualTo: parentEmailRaw.trim())
          .limit(1)
          .get();
    }

    if (parentQuery.docs.isEmpty) return;

    final parentDoc = parentQuery.docs.first;

    await FirebaseFirestore.instance.collection('users').doc(parentDoc.id).set({
      'linkedChildrenIds': FieldValue.arrayUnion([studentId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('students').doc(studentId).set({
      'parentUid': parentDoc.id,
      'parentId': parentDoc.id,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      final name = nameController.text.trim();
      final parentEmail = parentEmailController.text.trim();
      final parentEmailLower = _cleanEmail(parentEmail);
      final studentEmail = emailController.text.trim();
      final studentEmailLower = _cleanEmail(studentEmail);
      final generatedRollNo = await _generateRollNumber(name);

      final docRef = await FirebaseFirestore.instance.collection('students').add({
        'name': name,
        'age': ageController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': studentEmail,
        'emailLower': studentEmailLower,
        'parentName': parentNameController.text.trim(),
        'parentPhone': parentPhoneController.text.trim(),
        'parentEmail': parentEmail,
        'parentEmailLower': parentEmailLower,
        'aadhaarNumber': aadhaarController.text.trim(),
        'address': addressController.text.trim(),
        'batch': selectedBatch,
        'rollNo': generatedRollNo,
        'attendance': '0%',
        'presentCount': 0,
        'totalAttendanceCount': 0,
        'feeStatus': feeStatus,
        'role': 'Student',
        'approvalStatus': 'Approved',
        'status': 'Active',
        'isApproved': true,
        'createdBy': 'Admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await docRef.set({
        'uid': docRef.id,
        'studentId': docRef.id,
      }, SetOptions(merge: true));

      await _autoLinkParentToStudent(
        studentId: docRef.id,
        parentEmailRaw: parentEmail,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.studentSavedSuccessfully}. ${AppStrings.rollNo}: $generatedRollNo"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.errorSavingStudent}: $e"),
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
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    parentNameController.dispose();
    parentPhoneController.dispose();
    parentEmailController.dispose();
    aadhaarController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
            final isDark = mode == ThemeMode.dark;

            final screenWidth = MediaQuery.sizeOf(context).width;

            return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom > 0 ? 12 : 0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _topHeader(context, isDark),
                    _heroBanner(isDark, screenWidth),
                    const SizedBox(height: 18),
                    _sectionTitle(AppStrings.studentInformation, isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _field(
                            isDark: isDark,
                            label: "${AppStrings.studentName} *",
                            controller: nameController,
                            icon: Icons.person_rounded,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? AppStrings.enterStudentName
                                    : null,
                          ),
                          _field(
                            isDark: isDark,
                            label: "${AppStrings.age} *",
                            controller: ageController,
                            icon: Icons.cake_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? AppStrings.enterAge
                                    : null,
                          ),
                          _field(
                            isDark: isDark,
                            label: "${AppStrings.phoneNumber} *",
                            controller: phoneController,
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? AppStrings.enterPhoneNumber
                                    : null,
                          ),
                          _field(
                            isDark: isDark,
                            label: AppStrings.studentEmail,
                            controller: emailController,
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _batchDropdown(isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _sectionTitle(AppStrings.parentGuardian, isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _field(
                            isDark: isDark,
                            label: AppStrings.parentName,
                            controller: parentNameController,
                            icon: Icons.family_restroom_rounded,
                          ),
                          _field(
                            isDark: isDark,
                            label: AppStrings.parentPhone,
                            controller: parentPhoneController,
                            icon: Icons.call_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          _field(
                            isDark: isDark,
                            label: AppStrings.parentEmail,
                            controller: parentEmailController,
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _field(
                            isDark: isDark,
                            label: AppStrings.aadhaarNumber,
                            controller: aadhaarController,
                            icon: Icons.badge_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          _field(
                            isDark: isDark,
                            label: AppStrings.address,
                            controller: addressController,
                            icon: Icons.location_on_rounded,
                            maxLines: 3,
                          ),
                          _feeDropdown(isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _saveButton(isDark),
                    const SizedBox(height: 30),
                  ],
                ),
                  ),
                ),
              ),
                );
              },
            ),
          ),
            );
          },
        );
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(isCompact ? 10 : 14, 12, isCompact ? 10 : 14, 10),
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.55),
                ]
              : [
                  maroon,
                  red.withOpacity(0.78),
                  darkMaroon,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? red.withOpacity(0.40) : gold.withOpacity(0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.18) : maroon.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _circleHeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          Image.asset(
            'assets/images/ygca_logo_background.png',
            width: isCompact ? 42 : 55,
            height: isCompact ? 42 : 55,
            fit: BoxFit.contain,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.addStudentTitle,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: gold,
                    fontSize: isCompact ? 14 : 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                if (!isCompact) ...[
                  const SizedBox(height: 3),
                  Text(
                    AppStrings.createNewAcademyPlayerProfile,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;
              return _circleHeaderButton(
                icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

  Widget _heroBanner(bool isDark, double screenWidth) {
    final isCompact = screenWidth < 380;

    return Container(
      height: isCompact ? 190 : 220,
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.20) : maroon.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
                          Colors.black.withOpacity(0.90),
                          darkMaroon.withOpacity(0.88),
                          red.withOpacity(0.35),
                        ]
                      : [
                          maroon.withOpacity(0.92),
                          maroon.withOpacity(0.70),
                          Colors.black.withOpacity(0.25),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -24,
            bottom: -24,
            child: Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isCompact ? 34 : 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: maroon,
                    size: isCompact ? 32 : 42,
                  ),
                ),
                SizedBox(width: isCompact ? 10 : 16),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: isCompact ? 205 : 230,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.newPlayer,
                            style: TextStyle(
                              color: gold,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            AppStrings.student.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 25 : 31,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.registration.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: isCompact ? 19 : 23,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip(AppStrings.autoRollNo),
                              _heroChip(AppStrings.parentLink),
                              _heroChip(AppStrings.approvedProfile),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _secondaryText(isDark), fontSize: 12),
          prefixIcon: Icon(icon, color: isDark ? gold : maroon),
          filled: true,
          fillColor: isDark ? const Color(0xFF111111) : Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: isDark ? red : maroon),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _batchDropdown(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedBatch,
        isExpanded: true,
        dropdownColor: isDark ? const Color(0xFF111111) : Colors.white,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: AppStrings.sessionBatch,
          labelStyle: TextStyle(color: _secondaryText(isDark), fontSize: 12),
          prefixIcon: Icon(
            Icons.groups_rounded,
            color: isDark ? gold : maroon,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF111111) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: isDark ? red : maroon),
          ),
        ),
        items: batchOptions.map((batch) {
          return DropdownMenuItem<String>(
            value: batch,
            child: Text(
              batch,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
        onChanged: isLoading
            ? null
            : (value) {
                if (value == null) return;
                setState(() => selectedBatch = value);
              },
      ),
    );
  }

  Widget _feeDropdown(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: feeStatus,
        isExpanded: true,
        dropdownColor: isDark ? const Color(0xFF111111) : Colors.white,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: AppStrings.feeStatus.replaceAll('\n', ' '),
          labelStyle: TextStyle(color: _secondaryText(isDark), fontSize: 12),
          prefixIcon: Icon(Icons.payments_rounded, color: isDark ? gold : maroon),
          filled: true,
          fillColor: isDark ? const Color(0xFF111111) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: isDark ? red : maroon),
          ),
        ),
        items: [
          DropdownMenuItem(value: 'Pending', child: Text(AppStrings.pending)),
          DropdownMenuItem(value: 'Paid', child: Text(AppStrings.paid)),
          DropdownMenuItem(value: 'Partial', child: Text(AppStrings.partiallyPaid)),
        ],
        onChanged: isLoading
            ? null
            : (value) {
                if (value == null) return;
                setState(() => feeStatus = value);
              },
      ),
    );
  }

  Widget _saveButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? red : maroon,
            foregroundColor: isDark ? Colors.white : gold,
            elevation: 8,
            shadowColor: red.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: isLoading ? null : saveStudent,
          icon: isLoading
              ? const SizedBox()
              : const Icon(Icons.save_alt_rounded, size: 22),
          label: isLoading
              ? CircularProgressIndicator(
                  color: isDark ? Colors.white : gold,
                  strokeWidth: 2,
                )
              : Text(
                  AppStrings.saveStudent,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
