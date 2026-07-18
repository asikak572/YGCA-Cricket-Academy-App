import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';

class CoachPaymentStatusScreen extends StatefulWidget {
  const CoachPaymentStatusScreen({super.key});

  @override
  State<CoachPaymentStatusScreen> createState() =>
      _CoachPaymentStatusScreenState();
}

class _CoachPaymentStatusScreenState extends State<CoachPaymentStatusScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loadingUser = true;

  String uid = '';
  String role = '';

  int selectedFilter = 0;

  final filters = const [
    "All",
    "Paid",
    "Pending",
  ];

  String get _currentLanguage =>
      ThemeController.language.value.trim().toLowerCase();

  bool get _isTamil =>
      _currentLanguage.startsWith('ta') ||
      _currentLanguage.contains('tamil') ||
      _currentLanguage.contains('தமிழ்');

  bool get _isHindi =>
      _currentLanguage.startsWith('hi') ||
      _currentLanguage.contains('hindi') ||
      _currentLanguage.contains('हिन्दी') ||
      _currentLanguage.contains('हिंदी');

  String _tr({
    required String en,
    required String ta,
    required String hi,
  }) {
    if (_isTamil) return ta;
    if (_isHindi) return hi;
    return en;
  }

  String _localizedStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'paid':
        return _tr(en: 'Paid', ta: 'செலுத்தப்பட்டது', hi: 'भुगतान किया गया');
      case 'pending':
        return _tr(en: 'Pending', ta: 'நிலுவையில்', hi: 'लंबित');
      default:
        return status;
    }
  }

  String _localizedFilterLabel(int index) {
    switch (index) {
      case 0:
        return _tr(en: 'All', ta: 'அனைத்தும்', hi: 'सभी');
      case 1:
        return _localizedStatus('Paid');
      case 2:
        return _localizedStatus('Pending');
      default:
        return filters[index];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  bool get _isAdmin => role == 'Admin';

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
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

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    uid = user.uid;

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

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filter = filters[selectedFilter];

    if (filter == "All") return docs;

    return docs.where((doc) {
      final data = doc.data();
      final status = _text(data['status']).isEmpty
          ? 'Pending'
          : _text(data['status']);

      return status == filter;
    }).toList();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return _tr(en: 'No Date', ta: 'தேதி இல்லை', hi: 'तारीख उपलब्ध नहीं');

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
      return _tr(en: 'No Date', ta: 'தேதி இல்லை', hi: 'तारीख उपलब्ध नहीं');
    }
  }

  Color _statusColor(String status) {
    return status == "Paid" ? Colors.green : Colors.orange;
  }

  Future<void> _updateSalaryStatus({
    required BuildContext context,
    required String docId,
    required String status,
  }) async {
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
            content: Text(
              "${_tr(en: 'Salary marked as', ta: 'சம்பள நிலை மாற்றப்பட்டது:', hi: 'वेतन की स्थिति बदली गई:')} ${_localizedStatus(status)}",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${_tr(en: 'Update failed', ta: 'புதுப்பிப்பு தோல்வியடைந்தது', hi: 'अपडेट विफल रहा')}: $e",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatusSheet({
    required BuildContext context,
    required bool isDark,
    required String docId,
    required String coachName,
  }) {
    if (!_isAdmin) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: _card(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _tr(
                    en: 'Change Payment Status',
                    ta: 'கட்டண நிலையை மாற்றவும்',
                    hi: 'भुगतान स्थिति बदलें',
                  ),
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  coachName,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _statusAction(
                  isDark: isDark,
                  icon: Icons.verified_rounded,
                  title: _tr(
                    en: 'Mark as Paid',
                    ta: 'செலுத்தப்பட்டது எனக் குறிக்கவும்',
                    hi: 'भुगतान किया गया चिह्नित करें',
                  ),
                  subtitle: _tr(
                    en: 'Salary payment completed',
                    ta: 'சம்பளப் பணம் செலுத்தப்பட்டது',
                    hi: 'वेतन भुगतान पूरा हुआ',
                  ),
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _updateSalaryStatus(
                      context: context,
                      docId: docId,
                      status: "Paid",
                    );
                  },
                ),
                const SizedBox(height: 10),
                _statusAction(
                  isDark: isDark,
                  icon: Icons.pending_actions_rounded,
                  title: _tr(
                    en: 'Mark as Pending',
                    ta: 'நிலுவையில் எனக் குறிக்கவும்',
                    hi: 'लंबित चिह्नित करें',
                  ),
                  subtitle: _tr(
                    en: 'Salary payment not completed',
                    ta: 'சம்பளப் பணம் இன்னும் செலுத்தப்படவில்லை',
                    hi: 'वेतन भुगतान पूरा नहीं हुआ',
                  ),
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _updateSalaryStatus(
                      context: context,
                      docId: docId,
                      status: "Pending",
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusAction({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.12 : 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.16),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
            return Scaffold(
          backgroundColor: _bg(isDark),
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
                                    "${_tr(en: 'Error', ta: 'பிழை', hi: 'त्रुटि')}: ${snapshot.error}",
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

                      final filteredDocs = _filteredDocs(salaryDocs);

                      int paidCount = 0;
                      int pendingCount = 0;
                      int paidAmount = 0;
                      int pendingAmount = 0;

                      for (final doc in salaryDocs) {
                        final data = doc.data();
                        final salary = _toInt(data['salary']);
                        final status = _text(data['status']).isEmpty
                            ? 'Pending'
                            : _text(data['status']);

                        if (status == "Paid") {
                          paidCount++;
                          paidAmount += salary;
                        } else {
                          pendingCount++;
                          pendingAmount += salary;
                        }
                      }

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _topHeader(context, isDark),
                          ),
                          SliverToBoxAdapter(
                            child: _summaryHeader(
                              isDark: isDark,
                              total: salaryDocs.length,
                              paidCount: paidCount,
                              pendingCount: pendingCount,
                              paidAmount: paidAmount,
                              pendingAmount: pendingAmount,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          SliverToBoxAdapter(child: _filterTabs(isDark)),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          SliverToBoxAdapter(
                            child: _sectionTitle(
                              _tr(
                                en: 'PAYMENT STATUS LIST',
                                ta: 'கட்டண நிலைப் பட்டியல்',
                                hi: 'भुगतान स्थिति सूची',
                              ),
                              isDark,
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: filteredDocs.isEmpty
                                ? SliverToBoxAdapter(child: _emptyCard(isDark))
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final doc = filteredDocs[index];
                                        final data = doc.data();

                                        final name =
                                            _text(data['coachName']).isEmpty
                                                ? _tr(
                                                    en: 'Unknown Coach',
                                                    ta: 'தெரியாத பயிற்சியாளர்',
                                                    hi: 'अज्ञात कोच',
                                                  )
                                                : _text(data['coachName']);

                                        final coachRole =
                                            _text(data['role']).isEmpty
                                                ? _tr(
                                                    en: 'Coach',
                                                    ta: 'பயிற்சியாளர்',
                                                    hi: 'कोच',
                                                  )
                                                : _text(data['role']);

                                        final salary = _toInt(data['salary']);

                                        final status =
                                            _text(data['status']).isEmpty
                                                ? 'Pending'
                                                : _text(data['status']);

                                        final date =
                                            _formatDate(data['createdAt']);

                                        return _paymentCard(
                                          context: context,
                                          isDark: isDark,
                                          docId: doc.id,
                                          name: name,
                                          coachRole: coachRole,
                                          salary: salary,
                                          status: status,
                                          date: date,
                                        );
                                      },
                                      childCount: filteredDocs.length,
                                    ),
                                  ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
                  _tr(
                    en: 'PAYMENT STATUS',
                    ta: 'கட்டண நிலை',
                    hi: 'भुगतान स्थिति',
                  ),
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
                      ? _tr(
                          en: 'Update paid and pending salary',
                          ta: 'செலுத்தப்பட்ட மற்றும் நிலுவைச் சம்பளத்தைப் புதுப்பிக்கவும்',
                          hi: 'भुगतान और लंबित वेतन अपडेट करें',
                        )
                      : _tr(
                          en: 'View your salary payment status',
                          ta: 'உங்கள் சம்பளக் கட்டண நிலையைப் பார்க்கவும்',
                          hi: 'अपने वेतन भुगतान की स्थिति देखें',
                        ),
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

  Widget _summaryHeader({
    required bool isDark,
    required int total,
    required int paidCount,
    required int pendingCount,
    required int paidAmount,
    required int pendingAmount,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF130202),
                  const Color(0xFF1A0505),
                  red.withOpacity(0.18),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  gold.withOpacity(0.20),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.75),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: maroon,
                child: const Icon(
                  Icons.payment_rounded,
                  color: gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        en: 'Coach Payment Status',
                        ta: 'பயிற்சியாளர் கட்டண நிலை',
                        hi: 'कोच भुगतान स्थिति',
                      ),
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _tr(
                        en: 'Track paid and pending coach salary payments.',
                        ta: 'பயிற்சியாளரின் செலுத்தப்பட்ட மற்றும் நிலுவைச் சம்பளத்தைக் கண்காணிக்கவும்.',
                        hi: 'कोच के भुगतान और लंबित वेतन को ट्रैक करें।',
                      ),
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  isDark: isDark,
                  label: _tr(en: 'Total', ta: 'மொத்தம்', hi: 'कुल'),
                  value: total.toString(),
                  color: Colors.blueAccent,
                ),
              ),
              Expanded(
                child: _miniStat(
                  isDark: isDark,
                  label: _localizedStatus('Paid'),
                  value: paidCount.toString(),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _miniStat(
                  isDark: isDark,
                  label: _localizedStatus('Pending'),
                  value: pendingCount.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _amountBox(
                  isDark: isDark,
                  label: _tr(
                    en: 'Paid Amount',
                    ta: 'செலுத்திய தொகை',
                    hi: 'भुगतान राशि',
                  ),
                  value: "₹$paidAmount",
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _amountBox(
                  isDark: isDark,
                  label: _tr(
                    en: 'Pending Amount',
                    ta: 'நிலுவைத் தொகை',
                    hi: 'लंबित राशि',
                  ),
                  value: "₹$pendingAmount",
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required bool isDark,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountBox({
    required bool isDark,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTabs(bool isDark) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedFilter;

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              setState(() {
                selectedFilter = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          red.withOpacity(0.92),
                          maroon.withOpacity(0.95),
                        ],
                      )
                    : null,
                color: selected ? null : _card(isDark),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? red.withOpacity(0.40)
                      : isDark
                          ? red.withOpacity(0.20)
                          : const Color(0xFFE5E7EB),
                ),
              ),
              child: Center(
                child: Text(
                  _localizedFilterLabel(index),
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : isDark
                            ? Colors.white70
                            : maroon,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
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

  Widget _paymentCard({
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
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showStatusSheet(
          context: context,
          isDark: isDark,
          docId: docId,
          coachName: name,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: statusColor.withOpacity(0.16),
                child: Icon(
                  status == "Paid"
                      ? Icons.verified_rounded
                      : Icons.pending_actions_rounded,
                  color: statusColor,
                  size: 28,
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
                Icon(
                  Icons.edit_rounded,
                  color: statusColor,
                  size: 24,
                ),
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
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment_rounded,
            size: 42,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            _tr(
              en: 'No Payment Records Found',
              ta: 'கட்டணப் பதிவுகள் எதுவும் இல்லை',
              hi: 'कोई भुगतान रिकॉर्ड नहीं मिला',
            ),
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _tr(
              en: 'No salary payment records available for this filter.',
              ta: 'இந்த வடிகட்டலுக்கு சம்பளக் கட்டணப் பதிவுகள் இல்லை.',
              hi: 'इस फ़िल्टर के लिए कोई वेतन भुगतान रिकॉर्ड उपलब्ध नहीं है।',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}