import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class CoachSalaryScreen extends StatefulWidget {
  const CoachSalaryScreen({super.key});

  @override
  State<CoachSalaryScreen> createState() => _CoachSalaryScreenState();
}

class _CoachSalaryScreenState extends State<CoachSalaryScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loadingUser = true;

  String uid = '';
  String role = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
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

  bool get _isAdmin => role == 'Admin';

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    uid = user.uid;
    email = _lower(user.email ?? '');

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists || userDoc.data() == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    final data = userDoc.data() ?? {};

    if (!mounted) return;

    setState(() {
      role = _text(data['role']);
      loadingUser = false;
    });
  }

  Query<Map<String, dynamic>> _salaryQuery() {
    final query = FirebaseFirestore.instance.collection('coach_salaries');

    if (role == 'Admin') {
      return query;
    }

    if (role == 'Coach') {
      return query.where('coachUid', isEqualTo: uid);
    }

    return query.where('coachUid', isEqualTo: '__NO_ACCESS__');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortSalaryDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = docs.toList();

    sorted.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return sorted;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return AppStrings.noDate;

    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();

        return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      }

      if (timestamp is DateTime) {
        return "${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}";
      }

      return timestamp.toString();
    } catch (_) {
      return AppStrings.noDate;
    }
  }

  Color _statusColor(String status) {
    return status == "Paid" ? Colors.green : Colors.orange;
  }

  String _localizedStatus(String status) {
    final value = status.trim().toLowerCase();
    if (value == "paid") return AppStrings.paid;
    if (value == "pending") return AppStrings.pending;
    return status;
  }

  Future<void> _updateSalaryStatus(
    BuildContext context,
    String docId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('coach_salaries')
          .doc(docId)
          .set({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.salaryMarkedAs} ${_localizedStatus(status)}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.updateFailed}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSalary(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('coach_salaries')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.salaryRecordDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.deleteFailed}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, String docId, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card(isDark),
        title: Text(
          AppStrings.deleteSalaryRecord,
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          AppStrings.deleteSalaryRecordConfirm,
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
              await _deleteSalary(context, docId);
            },
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _addSalaryDialog(BuildContext context, bool isDark) async {
    final coachNameController = TextEditingController();
    final roleController = TextEditingController();
    final salaryController = TextEditingController();

    String status = "Pending";
    String selectedCoachUid = '';
    String selectedCoachEmail = '';

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: _card(isDark),
            title: Text(
              AppStrings.addCoachSalary,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'Coach')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LinearProgressIndicator(),
                        );
                      }

                      final coaches = snapshot.data?.docs ?? [];

                      if (coaches.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            AppStrings.noCoachUsersFoundEnterManually,
                            style: TextStyle(
                              color: _secondaryText(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DropdownButtonFormField<String>(
                          value:
                              selectedCoachUid.isEmpty ? null : selectedCoachUid,
                          isExpanded: true,
                          dropdownColor:
                              isDark ? const Color(0xFF111111) : Colors.white,
                          style: TextStyle(
                            color: _primaryText(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            labelText: AppStrings.selectCoach,
                            labelStyle: TextStyle(
                              color: _secondaryText(isDark),
                            ),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _border(isDark)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: isDark ? red : maroon),
                            ),
                          ),
                          items: coaches.map((doc) {
                            final data = doc.data();

                            final coachName = _text(data['name']).isNotEmpty
                                ? _text(data['name'])
                                : _text(data['coachName']).isNotEmpty
                                    ? _text(data['coachName'])
                                    : _text(data['email']).isNotEmpty
                                        ? _text(data['email'])
                                        : AppStrings.coachLabel;

                            final coachEmail = _text(data['email']);

                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(
                                coachEmail.isEmpty
                                    ? coachName
                                    : "$coachName - $coachEmail",
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            final selectedDoc = coaches.firstWhere(
                              (doc) => doc.id == value,
                            );

                            final data = selectedDoc.data();

                            final coachName = _text(data['name']).isNotEmpty
                                ? _text(data['name'])
                                : _text(data['coachName']).isNotEmpty
                                    ? _text(data['coachName'])
                                    : _text(data['email']);

                            final coachEmail = _lower(_text(data['email']));

                            setDialogState(() {
                              selectedCoachUid = selectedDoc.id;
                              selectedCoachEmail = coachEmail;
                              coachNameController.text = coachName;
                              roleController.text = AppStrings.coachLabel;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  _dialogField(
                    isDark: isDark,
                    label: AppStrings.coachName,
                    controller: coachNameController,
                  ),
                  _dialogField(
                    isDark: isDark,
                    label: AppStrings.role,
                    controller: roleController,
                  ),
                  _dialogField(
                    isDark: isDark,
                    label: AppStrings.salaryAmount,
                    controller: salaryController,
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    value: status,
                    dropdownColor:
                        isDark ? const Color(0xFF111111) : Colors.white,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      labelText: AppStrings.status,
                      labelStyle: TextStyle(color: _secondaryText(isDark)),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _border(isDark)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDark ? red : maroon),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: "Paid",
                        child: Text(AppStrings.paid),
                      ),
                      DropdownMenuItem(
                        value: "Pending",
                        child: Text(AppStrings.pending),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => status = value);
                    },
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
                  final coachName = coachNameController.text.trim();
                  final coachRole = roleController.text.trim();
                  final salaryText = salaryController.text.trim();

                  if (coachName.isEmpty ||
                      coachRole.isEmpty ||
                      salaryText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.pleaseFillAllFields),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final salary = int.tryParse(salaryText) ?? 0;

                  if (salary <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.enterValidSalaryAmount),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await FirebaseFirestore.instance
                        .collection('coach_salaries')
                        .add({
                      'coachUid': selectedCoachUid,
                      'coachEmail': selectedCoachEmail,
                      'coachEmailLower': selectedCoachEmail,
                      'coachName': coachName,
                      'role': coachRole,
                      'salary': salary,
                      'status': status,
                      'createdBy': uid,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.coachSalarySaved),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${AppStrings.saveFailed}: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(AppStrings.save),
              ),
            ],
          );
        },
      ),
    );

    coachNameController.dispose();
    roleController.dispose();
    salaryController.dispose();
  }

  Widget _dialogField({
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _secondaryText(isDark)),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? red : maroon),
          ),
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

            return Scaffold(
              backgroundColor: _bg(isDark),
          floatingActionButton: _isAdmin
              ? FloatingActionButton.extended(
                  backgroundColor: isDark ? red : maroon,
                  foregroundColor: isDark ? Colors.white : gold,
                  onPressed: () => _addSalaryDialog(context, isDark),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    AppStrings.addSalary,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                )
              : null,
          body: SafeArea(
            child: loadingUser
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _salaryQuery().snapshots(),
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

                      final salaryDocs =
                          _sortSalaryDocs(snapshot.data?.docs ?? []);

                      int totalBudget = 0;
                      int paidBudget = 0;
                      int pendingBudget = 0;

                      for (final doc in salaryDocs) {
                        final data = doc.data();
                        final salary = _toInt(data['salary']);
                        final salaryStatus =
                            _text(data['status']).isEmpty
                                ? 'Pending'
                                : _text(data['status']);

                        totalBudget += salary;

                        if (salaryStatus == "Paid") {
                          paidBudget += salary;
                        } else {
                          pendingBudget += salary;
                        }
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _topHeader(context, isDark),
                            _heroBanner(
                              isDark: isDark,
                              totalBudget: totalBudget,
                              paidBudget: paidBudget,
                              pendingBudget: pendingBudget,
                              records: salaryDocs.length,
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.salaryOverview, isDark),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.18,
                                children: [
                                  _statCard(
                                    isDark: isDark,
                                    icon: Icons.account_balance_wallet_rounded,
                                    title: AppStrings.total.toUpperCase(),
                                    value: "₹$totalBudget",
                                    subtitle: AppStrings.budget,
                                    color: Colors.blueAccent,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    icon: Icons.verified_rounded,
                                    title: AppStrings.paid.toUpperCase(),
                                    value: "₹$paidBudget",
                                    subtitle: AppStrings.completed,
                                    color: Colors.green,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    icon: Icons.pending_actions_rounded,
                                    title: AppStrings.pending.toUpperCase(),
                                    value: "₹$pendingBudget",
                                    subtitle: AppStrings.remaining,
                                    color: Colors.orange,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    icon: Icons.receipt_long_rounded,
                                    title: AppStrings.records.toUpperCase(),
                                    value: salaryDocs.length.toString(),
                                    subtitle: AppStrings.entries,
                                    color: Colors.purpleAccent,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.salaryRecords, isDark),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: salaryDocs.isEmpty
                                  ? _emptyCard(isDark)
                                  : Column(
                                      children: salaryDocs.map((doc) {
                                        final data = doc.data();

                                        final name =
                                            _text(data['coachName']).isEmpty
                                                ? AppStrings.unknownCoach
                                                : _text(data['coachName']);

                                        final coachRole =
                                            _text(data['role']).isEmpty
                                                ? 'Coach'
                                                : _text(data['role']);

                                        final salary = _toInt(data['salary']);

                                        final salaryStatus =
                                            _text(data['status']).isEmpty
                                                ? 'Pending'
                                                : _text(data['status']);

                                        final date =
                                            _formatDate(data['createdAt']);

                                        return _salaryCard(
                                          context: context,
                                          isDark: isDark,
                                          docId: doc.id,
                                          name: name,
                                          coachRole: coachRole,
                                          salary: salary,
                                          status: salaryStatus,
                                          date: date,
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const SizedBox(height: 90),
                          ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.coachSalaryTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _isAdmin
                      ? AppStrings.manageCoachMonthlySalary
                      : AppStrings.viewYourSalaryRecords,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleButton(
                isDark: isDark,
                icon: dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
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
          color: _card(isDark),
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: 21,
        ),
      ),
    );
  }

  Widget _heroBanner({
    required bool isDark,
    required int totalBudget,
    required int paidBudget,
    required int pendingBudget,
    required int records,
  }) {
    return Container(
      height: 220,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.20) : maroon.withOpacity(0.16),
            blurRadius: 22,
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
                          maroon.withOpacity(0.72),
                          Colors.black.withOpacity(0.25),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -25,
            bottom: -25,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.currency_rupee_rounded,
                    color: maroon,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 235,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.monthly.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            AppStrings.salary.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.center.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip("${AppStrings.total}: ₹$totalBudget"),
                              _heroChip("${AppStrings.paid}: ₹$paidBudget"),
                              _heroChip("${AppStrings.pending}: ₹$pendingBudget"),
                              _heroChip("${AppStrings.records}: $records"),
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
      constraints: const BoxConstraints(maxWidth: 165),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
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
              fontSize: 15,
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
                  color.withOpacity(0.16),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  color.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withOpacity(0.10)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 135,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.18),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
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

  Widget _salaryCard({
    required BuildContext context,
    required bool isDark,
    required String docId,
    required String name,
    required String coachRole,
    required int salary,
    required String status,
    required String date,
  }) {
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        borderRadius: BorderRadius.circular(18),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: maroon,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
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
                  "$coachRole • $date",
                  maxLines: 1,
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
                      icon: Icons.currency_rupee_rounded,
                      text: "₹$salary",
                      color: Colors.blueAccent,
                    ),
                    _chip(
                      isDark: isDark,
                      icon: Icons.verified_rounded,
                      text: _localizedStatus(status),
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isAdmin)
            PopupMenuButton<String>(
              color: _card(isDark),
              iconColor: isDark ? Colors.white : maroon,
              onSelected: (value) async {
                if (value == "Paid" || value == "Pending") {
                  await _updateSalaryStatus(
                    context,
                    docId,
                    value,
                  );
                }

                if (value == AppStrings.delete) {
                  _confirmDelete(context, docId, isDark);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "Paid",
                  child: Text(
                    AppStrings.markPaid,
                    style: TextStyle(color: _primaryText(isDark)),
                  ),
                ),
                PopupMenuItem(
                  value: "Pending",
                  child: Text(
                    AppStrings.markPending,
                    style: TextStyle(color: _primaryText(isDark)),
                  ),
                ),
                PopupMenuItem(
                  value: AppStrings.delete,
                  child: Text(
                    AppStrings.delete,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
        ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
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
              fontWeight: FontWeight.w900,
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
            Icons.account_balance_wallet_outlined,
            size: 40,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noSalaryRecordsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isAdmin
                ? AppStrings.clickAddSalaryCreateOne
                : AppStrings.noSalaryRecordForAccount,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}
