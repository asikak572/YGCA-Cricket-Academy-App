import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class FeeReceiptsScreen extends StatefulWidget {
  const FeeReceiptsScreen({super.key});

  @override
  State<FeeReceiptsScreen> createState() => _FeeReceiptsScreenState();
}

class _FeeReceiptsScreenState extends State<FeeReceiptsScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  String searchText = '';

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

  Query<Map<String, dynamic>> _feesQuery() {
    return FirebaseFirestore.instance.collection('fees');
  }

  String _localizedStatus(String status) {
    final value = status.trim().toLowerCase();
    if (value == "paid") return AppStrings.paid;
    if (value == "pending") return AppStrings.pending;
    return status;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final query = searchText.trim().toLowerCase();

    if (query.isEmpty) return docs;

    return docs.where((doc) {
      final data = doc.data();

      final studentName = _text(data['studentName']).toLowerCase();
      final name = _text(data['name']).toLowerCase();
      final receiptNo = _text(data['receiptNo']).toLowerCase();
      final rollNo = _text(data['rollNo']).toLowerCase();
      final batch = _text(data['batch']).toLowerCase();

      return studentName.contains(query) ||
          name.contains(query) ||
          receiptNo.contains(query) ||
          rollNo.contains(query) ||
          batch.contains(query);
    }).toList();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = docs.toList();

    sorted.sort((a, b) {
      final aTime = a.data()['createdAt'] ?? a.data()['paymentDate'];
      final bTime = b.data()['createdAt'] ?? b.data()['paymentDate'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return sorted;
  }

  String _receiptNumber(Map<String, dynamic> data, String docId) {
    final existing = _text(data['receiptNo']);
    if (existing.isNotEmpty) return existing;

    final shortId = docId.length >= 6 ? docId.substring(0, 6).toUpperCase() : docId.toUpperCase();
    return "YGCA-$shortId";
  }

  void _showReceiptDetails({
    required BuildContext context,
    required bool isDark,
    required String receiptNo,
    required String studentName,
    required String batch,
    required int amount,
    required int pendingAmount,
    required String date,
    required String status,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card(isDark),
      isScrollControlled: true,
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
                const SizedBox(height: 18),
                CircleAvatar(
                  radius: 34,
                  backgroundColor: maroon,
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: gold,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.feeReceipt,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  receiptNo,
                  style: TextStyle(
                    color: gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _receiptRow(
                  isDark: isDark,
                  label: AppStrings.student,
                  value: studentName,
                ),
                _receiptRow(
                  isDark: isDark,
                  label: AppStrings.batch,
                  value: batch,
                ),
                _receiptRow(
                  isDark: isDark,
                  label: AppStrings.paidAmount,
                  value: "₹$amount",
                ),
                _receiptRow(
                  isDark: isDark,
                  label: AppStrings.pendingAmount,
                  value: "₹$pendingAmount",
                ),
                _receiptRow(
                  isDark: isDark,
                  label: AppStrings.status,
                  value: _localizedStatus(status),
                ),
                _receiptRow(
                  isDark: isDark,
                  label: AppStrings.date,
                  value: date,
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(isDark ? 0.12 : 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: gold.withOpacity(0.35)),
                  ),
                  child: Text(
                    AppStrings.receiptPrintDownloadLater,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? gold : maroon,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _receiptRow({
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
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

                final allDocs = _sortDocs(snapshot.data?.docs ?? []);
                final receipts = _filteredDocs(allDocs);

                int totalAmount = 0;
                for (final doc in allDocs) {
                  final data = doc.data();
                  totalAmount += _toInt(data['amount'] ?? data['paidAmount']);
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _topHeader(context, isDark)),
                    SliverToBoxAdapter(
                      child: _summaryHeader(
                        isDark: isDark,
                        receiptCount: allDocs.length,
                        totalAmount: totalAmount,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverToBoxAdapter(child: _searchBox(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.feeReceiptsList, isDark),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: receipts.isEmpty
                          ? SliverToBoxAdapter(child: _emptyCard(isDark))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final doc = receipts[index];
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

                                  final pendingAmount =
                                      _toInt(data['pendingAmount']);

                                  final status = _text(data['status']).isNotEmpty
                                      ? _text(data['status'])
                                      : pendingAmount > 0
                                          ? "Pending"
                                          : "Paid";

                                  final date = _formatDate(
                                    data['createdAt'] ?? data['paymentDate'],
                                  );

                                  final receiptNo =
                                      _receiptNumber(data, doc.id);

                                  return _receiptCard(
                                    context: context,
                                    isDark: isDark,
                                    receiptNo: receiptNo,
                                    studentName: studentName,
                                    batch: batch,
                                    amount: amount,
                                    pendingAmount: pendingAmount,
                                    date: date,
                                    status: status,
                                  );
                                },
                                childCount: receipts.length,
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
                    AppStrings.feeReceiptsTitle,
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
                  AppStrings.viewStudentFeeReceipts,
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
    required int receiptCount,
    required int totalAmount,
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: maroon,
            child: const Icon(
              Icons.description_rounded,
              color: gold,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.receiptCenter,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "$receiptCount ${AppStrings.receipts} • ₹$totalAmount ${AppStrings.collected}",
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
    );
  }

  Widget _searchBox(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white54 : maroon,
          ),
          hintText: AppStrings.searchStudentReceiptBatch,
          hintStyle: TextStyle(
            color: _secondaryText(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
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

  Widget _receiptCard({
    required BuildContext context,
    required bool isDark,
    required String receiptNo,
    required String studentName,
    required String batch,
    required int amount,
    required int pendingAmount,
    required String date,
    required String status,
  }) {
    final isPaid = status.toLowerCase() == "paid";
    final statusColor = isPaid ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showReceiptDetails(
          context: context,
          isDark: isDark,
          receiptNo: receiptNo,
          studentName: studentName,
          batch: batch,
          amount: amount,
          pendingAmount: pendingAmount,
          date: date,
          status: status,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: maroon,
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: gold,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiptNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                      "$batch • $date",
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
                          text: "₹$amount",
                          color: Colors.green,
                        ),
                        _chip(
                          isDark: isDark,
                          icon: isPaid
                              ? Icons.verified_rounded
                              : Icons.pending_actions_rounded,
                          text: _localizedStatus(status),
                          color: statusColor,
                        ),
                      ],
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
            Icons.receipt_long_rounded,
            size: 42,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noReceiptsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.noFeeReceiptRecordsAvailable,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}