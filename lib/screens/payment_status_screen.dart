import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  String selectedFilter = "all";

  final List<String> filters = const [
    "all",
    "paid",
    "pending",
  ];

  String _filterLabel(String filter) {
    switch (filter) {
      case "paid":
        return AppStrings.paid;
      case "pending":
        return AppStrings.pending;
      default:
        return AppStrings.all;
    }
  }

  String _localizedStatus(String status) {
    final value = status.trim().toLowerCase();
    if (value == "paid") return AppStrings.paid;
    if (value == "pending") return AppStrings.pending;
    return status;
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

  Query<Map<String, dynamic>> _feesQuery() {
    return FirebaseFirestore.instance.collection('fees');
  }

  String _statusFromData(Map<String, dynamic> data) {
    final status = _text(data['status']).isNotEmpty
        ? _text(data['status'])
        : _text(data['paymentStatus']).isNotEmpty
            ? _text(data['paymentStatus'])
            : _toInt(data['pendingAmount']) > 0
                ? AppStrings.pending
                : AppStrings.paid;

    return status;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (selectedFilter == "all") return docs;

    return docs.where((doc) {
      final status = _statusFromData(doc.data()).toLowerCase();
      return status == selectedFilter;
    }).toList();
  }

  Color _statusColor(String status) {
    return status.toLowerCase() == "paid" ? Colors.green : Colors.orange;
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
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _feesQuery().snapshots(),
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

                final allDocs = snapshot.data?.docs ?? [];
                final filteredDocs = _filteredDocs(allDocs);

                int paidCount = 0;
                int pendingCount = 0;
                int paidAmount = 0;
                int pendingAmount = 0;

                for (final doc in allDocs) {
                  final data = doc.data();
                  final status = _statusFromData(data);
                  final amount = _toInt(data['amount'] ?? data['paidAmount']);
                  final pending = _toInt(data['pendingAmount']);

                  if (status.toLowerCase() == "paid") {
                    paidCount++;
                    paidAmount += amount;
                  } else {
                    pendingCount++;
                    pendingAmount += pending > 0 ? pending : amount;
                  }
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _topHeader(context, isDark)),
                    SliverToBoxAdapter(
                      child: _summaryHeader(
                        isDark: isDark,
                        total: allDocs.length,
                        paidCount: paidCount,
                        pendingCount: pendingCount,
                        paidAmount: paidAmount,
                        pendingAmount: pendingAmount,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverToBoxAdapter(child: _filterTabs(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.paymentStatusList, isDark),
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

                                  final studentName =
                                      _text(data['studentName']).isNotEmpty
                                          ? _text(data['studentName'])
                                          : _text(data['name']).isNotEmpty
                                              ? _text(data['name'])
                                              : AppStrings.unknownStudent;

                                  final batch = _text(data['batch']).isNotEmpty
                                      ? _text(data['batch'])
                                      : AppStrings.noBatch;

                                  final amount = _toInt(
                                    data['amount'] ?? data['paidAmount'],
                                  );

                                  final pending = _toInt(data['pendingAmount']);

                                  final status = _statusFromData(data);

                                  return _statusCard(
                                    isDark: isDark,
                                    studentName: studentName,
                                    batch: batch,
                                    amount: amount,
                                    pendingAmount: pending,
                                    status: status,
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.paymentStatusTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  AppStrings.paidPendingFeeTracking,
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
                radius: 28,
                backgroundColor: maroon,
                child: const Icon(
                  Icons.payment_rounded,
                  color: gold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  AppStrings.trackPaidPendingStudentFeeStatus,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.total,
                  value: total.toString(),
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.paid,
                  value: paidCount.toString(),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.pending,
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
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.paidAmountLabel,
                  value: "₹$paidAmount",
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.pendingAmountLabel,
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

  Widget _miniBox({
    required bool isDark,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
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
          final filter = filters[index];
          final selected = selectedFilter == filter;

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              setState(() {
                selectedFilter = filter;
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
                  _filterLabel(filter),
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
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
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

  Widget _statusCard({
    required bool isDark,
    required String studentName,
    required String batch,
    required int amount,
    required int pendingAmount,
    required String status,
  }) {
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              status.toLowerCase() == "paid"
                  ? Icons.verified_rounded
                  : Icons.pending_actions_rounded,
              color: color,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
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
                  batch,
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
                      text: "${AppStrings.paid} ₹$amount",
                      color: Colors.green,
                    ),
                    _chip(
                      isDark: isDark,
                      icon: Icons.pending_rounded,
                      text: "${AppStrings.due} ₹$pendingAmount",
                      color: Colors.orange,
                    ),
                    _chip(
                      isDark: isDark,
                      icon: Icons.verified_rounded,
                      text: _localizedStatus(status),
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
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
            AppStrings.noPaymentStatusFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.noFeeRecordsForFilter,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}