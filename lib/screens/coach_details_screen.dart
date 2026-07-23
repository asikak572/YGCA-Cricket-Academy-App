import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_text.dart';

import 'coach_salary_screen.dart';
import '../services/cloudinary_profile_photo_service.dart';

class CoachDetailsScreen extends StatefulWidget {
  final String coachId;
  final String name;
  final String role;
  final String phone;
  final String batch;
  final String status;

  const CoachDetailsScreen({
    super.key,
    required this.coachId,
    required this.name,
    required this.role,
    required this.phone,
    required this.batch,
    required this.status,
  });

  @override
  State<CoachDetailsScreen> createState() => _CoachDetailsScreenState();
}

class _CoachDetailsScreenState extends State<CoachDetailsScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);
  bool _uploadingPhoto = false;

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

  String _cleanEmail(String value) => value.trim().toLowerCase();

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString().trim();
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - 1),
    );
  }

  String _dateId(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<String> _resolveCoachUid({
    required String coachUid,
    required String email,
  }) async {
    if (coachUid.trim().isNotEmpty) return coachUid.trim();

    final emailLower = email.trim().toLowerCase();

    if (emailLower.isEmpty) return widget.coachId;

    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('emailLower', isEqualTo: emailLower)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      return userQuery.docs.first.id;
    }

    return widget.coachId;
  }

  Future<List<String>> _loadCurrentWeekSessions({
    required String coachUid,
    required String email,
  }) async {
    final realCoachUid = await _resolveCoachUid(
      coachUid: coachUid,
      email: email,
    );

    final weekId = _dateId(_startOfWeek(DateTime.now()));

    final snapshot = await FirebaseFirestore.instance
        .collection('coach_session_assignments')
        .where('weekStartDate', isEqualTo: weekId)
        .get();

    final sessions = snapshot.docs
        .where((doc) {
          final data = doc.data();
          final savedCoachId = data['coachId']?.toString().trim() ?? '';
          final status = data['status']?.toString().toLowerCase().trim() ?? '';

          return savedCoachId == realCoachUid && status == 'active';
        })
        .map((doc) {
          final data = doc.data();
          final session = data['session']?.toString().trim() ?? '';
          final batch = data['batch']?.toString().trim() ?? '';
          return session.isNotEmpty ? session : batch;
        })
        .where((session) => session.isNotEmpty)
        .toSet()
        .toList();

    return sessions;
  }

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

  Stream<QuerySnapshot<Map<String, dynamic>>> _coachUserPhotoStream(
    String email,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('emailLower', isEqualTo: _cleanEmail(email))
        .limit(1)
        .snapshots();
  }

  Future<void> _updateCoachPhoto({
    required String email,
  }) async {
    if (_uploadingPhoto) return;
    setState(() => _uploadingPhoto = true);

    try {
      final result = await CloudinaryProfilePhotoService.pickAndUpload();
      if (result == null) return;

      final photoData = <String, dynamic>{
        'photoUrl': result.url,
        'photoProvider': 'cloudinary',
        'photoPublicId': result.publicId,
        'photoAssetId': result.assetId,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('coaches')
          .doc(widget.coachId)
          .set(photoData, SetOptions(merge: true));

      await _syncCoachUserByEmail(
        email: email,
        data: photoData,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coach photo updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo upload failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _deleteCoach() async {
    await FirebaseFirestore.instance
        .collection('coaches')
        .doc(widget.coachId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.coachDetailsDeletedSuccessfully),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _updateCoach({
    required String name,
    required String email,
    required String role,
    required String phone,
    required String status,
    required String experience,
    required String specialization,
  }) async {
    final emailLower = _cleanEmail(email);

    final updateData = {
      'name': name.trim(),
      'email': email.trim(),
      'emailLower': emailLower,
      'role': role.trim().isEmpty ? 'Coach' : role.trim(),
      'phone': phone.trim(),
      'status': status.trim(),
      'experience': experience.trim(),
      'specialization': specialization.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('coaches')
        .doc(widget.coachId)
        .set(updateData, SetOptions(merge: true));

    await _syncCoachUserByEmail(
      email: email,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'emailLower': emailLower,
        'role': 'Coach',
        'phone': phone.trim(),
        'status': status.trim(),
        'specialization': specialization.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.coachDetailsUpdatedSuccessfully),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDelete(bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          AppStrings.coachDetailsDeleteCoach,
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "${AppStrings.coachDetailsDeleteConfirm} ${widget.name}?",
          style: TextStyle(color: _secondaryText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: isDark ? Colors.white70 : maroon),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCoach();
            },
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> data, bool isDark) {
    final nameController = TextEditingController(
      text: data['name']?.toString() ?? widget.name,
    );
    final emailController = TextEditingController(
      text: data['email']?.toString() ?? '',
    );
    final roleController = TextEditingController(
      text: data['role']?.toString() ?? widget.role,
    );
    final phoneController = TextEditingController(
      text: data['phone']?.toString() ?? widget.phone,
    );
    final statusController = TextEditingController(
      text: data['status']?.toString() ?? widget.status,
    );
    final experienceController = TextEditingController(
      text: data['experience']?.toString() ?? '5 Years',
    );

    final specializations = [
      AppStrings.coachLabel,
      AppStrings.battingCoach,
      AppStrings.bowlingCoach,
      AppStrings.fieldingCoach,
      AppStrings.fitnessCoach,
      AppStrings.headCoach,
      AppStrings.assistantCoach,
    ];

    final rawSpecialization =
        data['specialization']?.toString().trim() ?? 'Coach';

    String selectedSpecialization =
        specializations.contains(rawSpecialization)
            ? rawSpecialization
            : AppStrings.coachLabel;

    final statusOptions = [AppStrings.active, AppStrings.inactive];

    final rawStatus = statusController.text.trim();
    if (!statusOptions.contains(rawStatus)) {
      statusController.text = AppStrings.active;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: _card(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              AppStrings.coachDetailsEditCoach,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _editField(
                    isDark: isDark,
                    label: AppStrings.coachName,
                    controller: nameController,
                  ),
                  _editField(
                    isDark: isDark,
                    label: AppStrings.coachEmail,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _editField(
                    isDark: isDark,
                    label: AppStrings.roleLabel,
                    controller: roleController,
                  ),
                  _editField(
                    isDark: isDark,
                    label: AppStrings.phoneNumber,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _editField(
                    isDark: isDark,
                    label: AppStrings.experience,
                    controller: experienceController,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedSpecialization,
                    isExpanded: true,
                    dropdownColor:
                        isDark ? const Color(0xFF111111) : Colors.white,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: _inputDecoration(
                      isDark: isDark,
                      label: AppStrings.specialization,
                    ),
                    items: specializations.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => selectedSpecialization = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: statusController.text,
                    isExpanded: true,
                    dropdownColor:
                        isDark ? const Color(0xFF111111) : Colors.white,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: _inputDecoration(
                      isDark: isDark,
                      label: AppStrings.status,
                    ),
                    items: statusOptions.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => statusController.text = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : const Color(0xFFFFFBF2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border(isDark)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: isDark ? gold : maroon,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppStrings.coachDetailsWeeklyAssignmentInfo,
                            style: TextStyle(
                              color: _secondaryText(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.cancel,
                  style: TextStyle(color: isDark ? Colors.white70 : maroon),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? red : maroon,
                  foregroundColor: isDark ? Colors.white : gold,
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
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

                  await _updateCoach(
                    name: name,
                    email: email,
                    role: roleController.text,
                    phone: phone,
                    status: statusController.text,
                    experience: experienceController.text,
                    specialization: selectedSpecialization,
                  );

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(AppStrings.update),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      nameController.dispose();
      emailController.dispose();
      roleController.dispose();
      phoneController.dispose();
      statusController.dispose();
      experienceController.dispose();
    });
  }

  InputDecoration _inputDecoration({
    required bool isDark,
    required String label,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _secondaryText(isDark)),
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

  Widget _editField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration(isDark: isDark, label: label),
      ),
    );
  }

  Widget _currentWeekAssignmentsCard({
    required bool isDark,
    required String coachUid,
    required String email,
  }) {
    return FutureBuilder<List<String>>(
      future: _loadCurrentWeekSessions(
        coachUid: coachUid,
        email: email,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.currentWeekSessions,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? gold : maroon,
                  ),
                ),
              ],
            ),
          );
        }

        final sessions = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppStrings.currentWeekSessions,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: sessions.isEmpty
                    ? Text(
                        AppStrings.noSessionAssigned,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: _primaryText(isDark),
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: sessions.map((session) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              session,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: _primaryText(isDark),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _currentWeekSessionsBox({
    required bool isDark,
    required String coachUid,
    required String email,
  }) {
    return FutureBuilder<List<String>>(
      future: _loadCurrentWeekSessions(
        coachUid: coachUid,
        email: email,
      ),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final sessions = snapshot.data ?? [];

        return _infoCard(
          isDark: isDark,
          title: AppStrings.currentWeekSessions.toUpperCase(),
          children: [
            if (loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? gold : maroon,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppStrings.loadingSessions,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  AppStrings.noCurrentWeekSessionAssignedToCoach,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              )
            else
              ...sessions.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sports_cricket_rounded,
                        color: isDark ? gold : maroon,
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          session,
                          style: TextStyle(
                            color: _primaryText(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
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

            return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('coaches')
              .doc(widget.coachId)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

            final name = _text(data, 'name', widget.name);
            final role = _text(data, 'role', widget.role);
            final phone = _text(data, 'phone', widget.phone);
            final status = _text(data, 'status', widget.status);
            final experience = _text(data, 'experience', '5 Years');
            final specialization = _text(data, 'specialization', 'Coach');
            final email = _text(data, 'email', 'No Email');
            final coachUid = _text(data, 'uid', widget.coachId);
            final photoUrl = _text(data, 'photoUrl', '');

            final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
            final isActive = status.toLowerCase() == "active";

            return Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: _bg(isDark),
              body: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _topHeader(context, isDark),
                    ),
                    SliverToBoxAdapter(
                      child: _profileHero(
                        context: context,
                        isDark: isDark,
                        initial: initial,
                        name: name,
                        role: role,
                        status: status,
                        email: email,
                        photoUrl: photoUrl,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsivePadding.horizontal(context),
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate(
                          [
                            _statCard(
                              isDark: isDark,
                              icon: Icons.event_available_rounded,
                              title: AppStrings.sessions.toUpperCase(),
                              value: AppStrings.weekly,
                              subtitle: AppStrings.assigned,
                              color: Colors.blue,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.verified_rounded,
                              title: AppStrings.status.toUpperCase(),
                              value: status,
                              subtitle: isActive ? AppStrings.working : AppStrings.inactive,
                              color: isActive ? Colors.green : Colors.orange,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.work_history_rounded,
                              title: AppStrings.experience.toUpperCase(),
                              value: experience,
                              subtitle: AppStrings.coaching,
                              color: Colors.orange,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.sports_cricket_rounded,
                              title: AppStrings.speciality.toUpperCase(),
                              value: specialization,
                              subtitle: AppStrings.skillArea,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isTablet(context) ||
                                  ResponsiveHelper.isDesktop(context)
                              ? 4
                              : 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.07,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _infoCard(
                          isDark: isDark,
                          title: AppStrings.coachInformation.toUpperCase(),
                          children: [
                            _infoRow(
                              isDark: isDark,
                              title: "Coach Name",
                              value: name,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: AppStrings.email,
                              value: email,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Role",
                              value: role,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Phone Number",
                              value: phone,
                            ),
                            _currentWeekAssignmentsCard(
                              isDark: isDark,
                              coachUid: coachUid,
                              email: email,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Experience",
                              value: experience,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Specialization",
                              value: specialization,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Status",
                              value: status,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _currentWeekSessionsBox(
                          isDark: isDark,
                          coachUid: coachUid,
                          email: email,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _infoCard(
                          isDark: isDark,
                          title: AppStrings.quickActions.toUpperCase(),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _actionCard(
                                    isDark: isDark,
                                    icon: Icons.edit_rounded,
                                    title: AppStrings.editCoachMultiline,
                                    color: Colors.blue,
                                    onTap: () => _showEditDialog(
                                      data,
                                      isDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _actionCard(
                                    isDark: isDark,
                                    icon: Icons.delete_rounded,
                                    title: AppStrings.deleteCoachMultiline,
                                    color: Colors.red,
                                    onTap: () => _confirmDelete(isDark),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _actionCard(
                              isDark: isDark,
                              icon: Icons.account_balance_wallet_rounded,
                              title: AppStrings.salaryDetails,
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CoachSalaryScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? red : maroon,
                                  foregroundColor:
                                      isDark ? Colors.white : gold,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => _showEditDialog(data, isDark),
                                icon: const Icon(Icons.edit_rounded),
                                label: Text(
                                  AppStrings.editCoach.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      isDark ? Colors.greenAccent : Colors.green,
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.greenAccent
                                        : Colors.green,
                                  ),
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CoachSalaryScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                ),
                                label: Text(
                                  AppStrings.salary.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                ),
              ),
            );
          },
            );
          },
        );
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : maroon,
        border: Border(
          bottom: BorderSide(
            color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/ygca_logo_background.png',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.coachDetails.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleButton(
                isDark: isDark,
                icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF111111) : Colors.white.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? red.withOpacity(0.28) : gold.withOpacity(0.55),
          ),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : gold,
          size: 22,
        ),
      ),
    );
  }

  Widget _profileHero({
    required BuildContext context,
    required bool isDark,
    required String initial,
    required String name,
    required String role,
    required String status,
    required String email,
    required String photoUrl,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = ResponsivePadding.horizontal(context);

    return Container(
      height: isMobile ? 195 : 214,
      margin: EdgeInsets.fromLTRB(
        horizontalPadding,
        14,
        horizontalPadding,
        0,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.16) : maroon.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/home_hero_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.black.withOpacity(0.92),
                    darkMaroon.withOpacity(0.88),
                    red.withOpacity(0.30),
                  ]
                : [
                    darkMaroon.withOpacity(0.92),
                    maroon.withOpacity(0.72),
                    Colors.black.withOpacity(0.26),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -28,
              child: Icon(
                Icons.sports_cricket_rounded,
                color: Colors.white.withOpacity(0.08),
                size: 150,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 18),
              child: Row(
                children: [
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _coachUserPhotoStream(email),
                    builder: (context, userSnapshot) {
                      String resolvedPhotoUrl = photoUrl;

                      if (userSnapshot.hasData &&
                          userSnapshot.data!.docs.isNotEmpty) {
                        final userData =
                            userSnapshot.data!.docs.first.data();
                        final userPhotoUrl =
                            userData['photoUrl']?.toString().trim() ?? '';
                        if (userPhotoUrl.isNotEmpty) {
                          resolvedPhotoUrl = userPhotoUrl;
                        }
                      }

                      return SizedBox(
                        width: isMobile ? 78 : 104,
                        height: isMobile ? 78 : 104,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _uploadingPhoto
                                    ? null
                                    : () =>
                                        _updateCoachPhoto(email: email),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      resolvedPhotoUrl.isNotEmpty
                                          ? NetworkImage(resolvedPhotoUrl)
                                          : null,
                                  child: _uploadingPhoto
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: maroon,
                                        )
                                      : resolvedPhotoUrl.isEmpty
                                          ? Text(
                                              initial,
                                              style: TextStyle(
                                                color: maroon,
                                                fontSize:
                                                    isMobile ? 28 : 34,
                                                fontWeight:
                                                    FontWeight.w900,
                                              ),
                                            )
                                          : null,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: isMobile ? 27 : 31,
                                height: isMobile ? 27 : 31,
                                decoration: const BoxDecoration(
                                  color: gold,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: maroon,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(width: isMobile ? 10 : 16),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: isMobile ? 205 : 230,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveText.pageTitle(context),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              role,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: gold,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _statusChip(status),
                            const SizedBox(height: 10),
                            Text(
                              AppStrings.coachDetailsGuidingExcellence,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
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
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == "active";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.16)
            : Colors.orange.withOpacity(0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.35)
              : Colors.orange.withOpacity(0.35),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.greenAccent : Colors.orangeAccent,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF151515),
                  const Color(0xFF1A0808),
                  color.withOpacity(0.15),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  color.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : gold.withOpacity(0.65),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 31),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: _secondaryText(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow({
    required bool isDark,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(isDark ? 0.11 : 0.06),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
                fontSize: 12,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
