import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_text.dart';

import 'coach_details_screen.dart';
import 'add_coach_screen.dart';

class CoachManagementScreen extends StatelessWidget {
  const CoachManagementScreen({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

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

  bool _isPendingStatus(String status) {
    final value = status.toLowerCase().trim();
    return value == 'pending' || value == 'waiting' || value == 'inactive';
  }

  bool _isApproved(Map<String, dynamic> data) {
    final approvalStatus =
        data['approvalStatus']?.toString().toLowerCase().trim() ?? '';
    final status = data['status']?.toString().toLowerCase().trim() ?? '';
    final isApproved = data['isApproved'] == true;

    return approvalStatus == 'approved' || status == 'active' || isApproved;
  }

  String _sessionInfoText(Map<String, dynamic> data) {
    final assignedBatches = data['assignedBatches'];

    if (assignedBatches is List && assignedBatches.isNotEmpty) {
      return assignedBatches
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join(', ');
    }

    final batch = data['batch']?.toString().trim() ?? '';
    if (batch.isNotEmpty) return batch;

    return AppStrings.coachMgmtWeeklySessionsAssignedSeparately;
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

  Future<void> _addCoachDialog(BuildContext context, bool isDark) async {
    final rootContext = context;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    String selectedSpecialization = AppStrings.coachMgmtBattingCoach;

    final specializations = [
      AppStrings.coachMgmtBattingCoach,
      AppStrings.coachMgmtBowlingCoach,
      AppStrings.coachMgmtFieldingCoach,
      AppStrings.coachMgmtFitnessCoach,
      AppStrings.coachMgmtHeadCoach,
      AppStrings.coachMgmtAssistantCoach,
    ];

    await showDialog(
      context: rootContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _card(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                AppStrings.coachMgmtAddCoach,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(
                      isDark: isDark,
                      label: AppStrings.coachMgmtCoachName,
                      controller: nameController,
                    ),
                    _field(
                      isDark: isDark,
                      label: AppStrings.coachMgmtCoachEmail,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _field(
                      isDark: isDark,
                      label: AppStrings.phone,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
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
                        label: AppStrings.coachMgmtSpecialization,
                      ),
                      items: specializations.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedSpecialization = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
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
                        AppStrings.coachMgmtSessionAssignmentInfo,
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
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
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
                    final emailLower = _cleanEmail(email);
                    final phone = phoneController.text.trim();
                    final specialization = selectedSpecialization;

                    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                      if (!rootContext.mounted) return;

                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        SnackBar(
  content: Text(AppStrings.coachMgmtFillNameEmailPhone),
  backgroundColor: Colors.red,
),
                      );
                      return;
                    }

                    Navigator.of(dialogContext).pop();

                    await Future.delayed(const Duration(milliseconds: 250));

                    try {
                      final coachData = {
                        'name': name,
                        'email': email,
                        'emailLower': emailLower,
                        'role': 'Coach',
                        'phone': phone,
                        'specialization': specialization,
                        'approvalStatus': 'Approved',
                        'status': 'Active',
                        'isApproved': true,
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      await FirebaseFirestore.instance
                          .collection('coaches')
                          .add(coachData);

                      await _syncCoachUserByEmail(
                        email: email,
                        data: {
                          'name': name,
                          'email': email,
                          'emailLower': emailLower,
                          'role': 'Coach',
                          'phone': phone,
                          'specialization': specialization,
                          'approvalStatus': 'Approved',
                          'status': 'Active',
                          'isApproved': true,
                          'updatedAt': FieldValue.serverTimestamp(),
                        },
                      );

                      if (!rootContext.mounted) return;

                      ScaffoldMessenger.of(rootContext).showSnackBar(
                       SnackBar(
  content: Text(AppStrings.coachMgmtCoachAddedSuccessfully),
  backgroundColor: Colors.green,
),
                      );
                    } catch (e) {
                      if (!rootContext.mounted) return;

                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        SnackBar(
                          content: Text("${AppStrings.error}: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(AppStrings.save),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  Future<void> _approveCoach({
    required BuildContext context,
    required String coachId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final email = data['email']?.toString() ?? '';
      final emailLower = _cleanEmail(email);

      final approveData = {
        'role': 'Coach',
        'emailLower': emailLower,
        'approvalStatus': 'Approved',
        'status': 'Active',
        'isApproved': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('coaches')
          .doc(coachId)
          .set(approveData, SetOptions(merge: true));

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(coachId);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        await userRef.set(approveData, SetOptions(merge: true));
      } else {
        await _syncCoachUserByEmail(
          email: email,
          data: approveData,
        );
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
  content: Text(AppStrings.coachMgmtCoachApprovedSuccessfully),
  backgroundColor: Colors.green,
),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.coachMgmtApproveFailed}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Widget _field({
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

  Future<void> _deleteCoach(BuildContext context, String coachId) async {
    await FirebaseFirestore.instance.collection('coaches').doc(coachId).delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
  content: Text(AppStrings.coachMgmtCoachDeleted),
  backgroundColor: Colors.green,
),
      );
    }
  }

  void _confirmDelete(
    BuildContext context,
    bool isDark,
    String coachId,
    String coachName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _card(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          AppStrings.coachMgmtDeleteCoach,
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "${AppStrings.coachMgmtDeleteCoachConfirm} $coachName?",
          style: TextStyle(color: _secondaryText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
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
              Navigator.of(dialogContext).pop();
              await _deleteCoach(context, coachId);
            },
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _openCoachDetails({
    required BuildContext context,
    required String coachId,
    required String name,
    required String role,
    required String phone,
    required String batch,
    required String status,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachDetailsScreen(
          coachId: coachId,
          name: name,
          role: role,
          phone: phone,
          batch: batch,
          status: status,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase().trim();

    if (value == "active" || value == "approved") return Colors.green;
    if (value == "inactive") return Colors.red;
    if (value == "pending" || value == "waiting") return Colors.orange;
    return Colors.orange;
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

            return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg(isDark),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: isDark ? red : maroon,
            foregroundColor: isDark ? Colors.white : gold,
            onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AddCoachScreen(),
    ),
  );
},
            icon: const Icon(Icons.add_rounded),
           label: Text(
  AppStrings.coachMgmtAddCoach,
  style: const TextStyle(fontWeight: FontWeight.w900),
),
          ),
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coaches')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              "${AppStrings.error}: ${snapshot.error}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                final coaches = snapshot.data?.docs ?? [];
                int active = 0;
                int pending = 0;
                final Set<String> specializations = {};

                for (final doc in coaches) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status']?.toString() ?? AppStrings.pending;
                  final specialization =
                      data['specialization']?.toString() ?? '';

                  if (_isApproved(data)) active++;
                  if (_isPendingStatus(status) || !_isApproved(data)) pending++;
                  if (specialization.isNotEmpty) {
                    specializations.add(specialization);
                  }
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _topHeader(context, isDark)),
                    SliverToBoxAdapter(
                      child: _heroBanner(
                        context: context,
                        isDark: isDark,
                        total: coaches.length,
                        active: active,
                        pending: pending,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.coachMgmtCoachOverview, isDark),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate(
                          [
                            _statCard(
                              isDark: isDark,
                              icon: Icons.sports_rounded,
                              title: AppStrings.coachMgmtCoaches,
                              value: coaches.length.toString(),
                              subtitle: AppStrings.total,
                              color: Colors.blue,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.verified_rounded,
                              title: AppStrings.active.toUpperCase(),
                              value: active.toString(),
                              subtitle: AppStrings.approved,
                              color: Colors.green,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.pending_actions_rounded,
                              title: AppStrings.pending.toUpperCase(),
                              value: pending.toString(),
                              subtitle: AppStrings.approval,
                              color: Colors.orange,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.category_rounded,
                              title: AppStrings.coachMgmtSpecial,
                              value: specializations.length.toString(),
                              subtitle: AppStrings.coachMgmtTypes,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.17,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.coachMgmtCoachList, isDark),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: coaches.isEmpty
                          ? SliverToBoxAdapter(child: _emptyCard(isDark))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final doc = coaches[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  final name =
                                      data['name']?.toString() ?? AppStrings.noName;
                                  final role =
                                      data['role']?.toString() ?? AppStrings.coachLabel;
                                  final phone =
                                      data['phone']?.toString() ?? AppStrings.coachMgmtNoPhone;
                                  final batch = _sessionInfoText(data);
                                  final status =
                                      data['status']?.toString() ?? AppStrings.pending;

                                  return _coachCard(
                                    context: context,
                                    isDark: isDark,
                                    coachId: doc.id,
                                    data: data,
                                    name: name,
                                    role: role,
                                    phone: phone,
                                    batch: batch,
                                    status: status,
                                  );
                                },
                                childCount: coaches.length,
                              ),
                            ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
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
            'assets/images/ygca_logo.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.coachMgmtCoachCenter,
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

  Widget _heroBanner({
    required BuildContext context,
    required bool isDark,
    required int total,
    required int active,
    required int pending,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = ResponsivePadding.horizontal(context);

    return Container(
      height: isMobile ? 178 : 188,
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
                          red.withOpacity(0.34),
                        ]
                      : [
                          maroon.withOpacity(0.94),
                          maroon.withOpacity(0.72),
                          Colors.black.withOpacity(0.26),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -28,
            bottom: -30,
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
                CircleAvatar(
                  radius: isMobile ? 34 : 42,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.sports_cricket_rounded,
                    color: maroon,
                    size: isMobile ? 31 : 38,
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 15),
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
                            "YGCA",
                            style: TextStyle(
                              color: gold,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const Text(
                            "COACH",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.center.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip("${AppStrings.total}: $total"),
                              _heroChip("${AppStrings.active}: $active"),
                              _heroChip("${AppStrings.pending}: $pending"),
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
      constraints: const BoxConstraints(maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.16),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coachCard({
    required BuildContext context,
    required bool isDark,
    required String coachId,
    required Map<String, dynamic> data,
    required String name,
    required String role,
    required String phone,
    required String batch,
    required String status,
  }) {
    final color = _statusColor(status);
    final needsApproval = !_isApproved(data);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.26)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _openCoachDetails(
            context: context,
            coachId: coachId,
            name: name,
            role: role,
            phone: phone,
            batch: batch,
            status: status,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: maroon,
                    child: const Icon(
                      Icons.sports_cricket_rounded,
                      color: gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _primaryText(isDark),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$role • $batch",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _secondaryText(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _chip(
                              isDark: isDark,
                              icon: Icons.phone_rounded,
                              text: phone,
                              color: Colors.blue,
                            ),
                            _chip(
                              isDark: isDark,
                              icon: Icons.verified_rounded,
                              text: status.toLowerCase().trim() == 'active' ? AppStrings.active : status,
                              color: color,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                    onPressed: () => _confirmDelete(
                      context,
                      isDark,
                      coachId,
                      name,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: _secondaryText(isDark),
                  ),
                ],
              ),
              if (needsApproval) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? red : maroon,
                      foregroundColor: isDark ? Colors.white : gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _approveCoach(
                      context: context,
                      coachId: coachId,
                      data: data,
                    ),
                    icon: const Icon(Icons.verified_user_rounded),
                   label: Text(
  AppStrings.coachMgmtApproveCoach,
  style: const TextStyle(fontWeight: FontWeight.w900),
),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required bool isDark,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports_cricket_rounded,
            size: 40,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.coachMgmtNoCoachesFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
