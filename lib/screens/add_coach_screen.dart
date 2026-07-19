import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class AddCoachScreen extends StatefulWidget {
  const AddCoachScreen({super.key});

  @override
  State<AddCoachScreen> createState() => _AddCoachScreenState();
}

class _AddCoachScreenState extends State<AddCoachScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String selectedSpecialization = AppStrings.battingCoach;
  bool isSaving = false;

  final List<String> specializations = [
    AppStrings.battingCoach,
    AppStrings.bowlingCoach,
    AppStrings.fieldingCoach,
    AppStrings.fitnessCoach,
    AppStrings.headCoach,
    AppStrings.assistantCoach,
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String _cleanEmail(String value) => value.trim().toLowerCase();

  Future<void> _syncCoachUserByEmail({
    required String email,
    required Map<String, dynamic> data,
  }) async {
    final emailLower = _cleanEmail(email);
    if (emailLower.isEmpty) return;

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('emailLower', isEqualTo: emailLower)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
    }

    if (userSnapshot.docs.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userSnapshot.docs.first.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> _saveCoach() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final emailLower = _cleanEmail(email);
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.fillNameEmailPhone),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final coachData = {
        'name': name,
        'email': email,
        'emailLower': emailLower,
        'role': 'Coach',
        'phone': phone,
        'specialization': selectedSpecialization,
        'approvalStatus': 'Approved',
        'status': 'Active',
        'isApproved': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('coaches').add(coachData);

      await _syncCoachUserByEmail(
        email: email,
        data: {
          'name': name,
          'email': email,
          'emailLower': emailLower,
          'role': 'Coach',
          'phone': phone,
          'specialization': selectedSpecialization,
          'approvalStatus': 'Approved',
          'status': 'Active',
          'isApproved': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.coachAddedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.error}: $e"),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => isSaving = false);
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

  InputDecoration _inputDecoration({
    required bool isDark,
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _secondaryText(isDark)),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: isDark ? gold : maroon,
            ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? red : maroon, width: 1.4),
      ),
    );
  }

  Widget _field({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration(
          isDark: isDark,
          label: label,
          icon: icon,
        ),
      ),
    );
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
            final horizontalPadding = screenWidth < 360 ? 10.0 : 16.0;

            return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : maroon,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? red.withOpacity(0.35)
                            : gold.withOpacity(0.55),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: isSaving ? null : () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF111111)
                                : Colors.white.withOpacity(0.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? red.withOpacity(0.28)
                                  : gold.withOpacity(0.55),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: isDark ? Colors.white : gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        'assets/images/ygca_logo.jpg',
                        width: screenWidth < 360 ? 38 : 46,
                        height: screenWidth < 360 ? 38 : 46,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppStrings.addCoach,
                          style: TextStyle(
                            color: isDark ? Colors.white : gold,
                            fontSize: screenWidth < 360 ? 17 : 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Container(
                      padding: EdgeInsets.all(screenWidth < 360 ? 13 : 16),
                      decoration: BoxDecoration(
                        color: _card(isDark),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _border(isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.coachProfileDetails,
                            style: TextStyle(
                              color: _primaryText(isDark),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.weeklySessionsAssignedSeparately,
                            style: TextStyle(
                              color: _secondaryText(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _field(
                            isDark: isDark,
                            label: AppStrings.coachName,
                            controller: nameController,
                            icon: Icons.person_rounded,
                          ),
                          _field(
                            isDark: isDark,
                            label: AppStrings.coachEmail,
                            controller: emailController,
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _field(
                            isDark: isDark,
                            label: AppStrings.phone,
                            controller: phoneController,
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedSpecialization,
                            isExpanded: true,
                            dropdownColor: isDark
                                ? const Color(0xFF111111)
                                : Colors.white,
                            style: TextStyle(
                              color: _primaryText(isDark),
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _inputDecoration(
                              isDark: isDark,
                              label: AppStrings.specialization,
                              icon: Icons.sports_cricket_rounded,
                            ),
                            items: specializations.map((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: isSaving
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    setState(() {
                                      selectedSpecialization = value;
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? red.withOpacity(0.08)
                                  : gold.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? red.withOpacity(0.25)
                                    : gold.withOpacity(0.55),
                              ),
                            ),
                            child: Text(
                              AppStrings.afterAddingCoachAssignWeeklySessions,
                              style: TextStyle(
                                color: _secondaryText(isDark),
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      ),
                    ),
                  ),
                ),
              ],
                );
              },
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                14,
              ),
              decoration: BoxDecoration(
                color: _bg(isDark),
                border: Border(
                  top: BorderSide(color: _border(isDark)),
                ),
              ),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? red : maroon,
                    foregroundColor: isDark ? Colors.white : gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isSaving ? null : _saveCoach,
                  icon: isSaving
                      ? const SizedBox()
                      : const Icon(Icons.save_alt_rounded),
                  label: isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          AppStrings.saveCoach,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                ),
              ),
            ),
          ),
            );
          },
        );
      },
    );
  }
}
