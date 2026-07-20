import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_padding.dart';

class CoachStatusScreen extends StatefulWidget {
  const CoachStatusScreen({super.key});

  @override
  State<CoachStatusScreen> createState() => _CoachStatusScreenState();
}

class _CoachStatusScreenState extends State<CoachStatusScreen> {
  int selectedFilter = 0;

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  List<String> get filters => [
    AppStrings.all,
    AppStrings.active,
    AppStrings.inactive,
    AppStrings.pending,
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

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString().trim();
  }

  bool _isApproved(Map<String, dynamic> data) {
    final approvalStatus =
        data['approvalStatus']?.toString().toLowerCase().trim() ?? '';
    final status = data['status']?.toString().toLowerCase().trim() ?? '';
    final isApproved = data['isApproved'] == true;

    return approvalStatus == 'approved' || status == 'active' || isApproved;
  }

  bool _isPending(Map<String, dynamic> data) {
    final status = data['status']?.toString().toLowerCase().trim() ?? '';
    final approvalStatus =
        data['approvalStatus']?.toString().toLowerCase().trim() ?? '';

    return status == 'pending' ||
        status == 'waiting' ||
        approvalStatus == 'pending' ||
        !_isApproved(data);
  }

  String _statusText(Map<String, dynamic> data) {
    final status = data['status']?.toString().trim() ?? '';
    final approvalStatus = data['approvalStatus']?.toString().trim() ?? '';

    if (status.isNotEmpty) return status;
    if (approvalStatus.isNotEmpty) return approvalStatus;
    return AppStrings.pending;
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase().trim();

    if (value == "active" || value == "approved") return Colors.green;
    if (value == "inactive") return Colors.redAccent;
    if (value == "pending" || value == "waiting") return Colors.orange;
    return Colors.orange;
  }

  List<String> _batchesFromData(Map<String, dynamic> data) {
    final assignedBatches = data['assignedBatches'];

    if (assignedBatches is List && assignedBatches.isNotEmpty) {
      return assignedBatches
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final oldBatch = data['batch']?.toString().trim() ?? '';
    if (oldBatch.isNotEmpty) return [oldBatch];

    return [];
  }

  String _batchesText(Map<String, dynamic> data) {
    final batches = _batchesFromData(data);
    if (batches.isEmpty) return AppStrings.noBatchAssigned;
    return batches.join(', ');
  }

  List<QueryDocumentSnapshot> _filteredCoaches(
    List<QueryDocumentSnapshot> coaches,
  ) {
    final filter = filters[selectedFilter].toLowerCase();

    if (filter == "all") return coaches;

    return coaches.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = _statusText(data).toLowerCase().trim();

      if (filter == "pending") {
        return _isPending(data);
      }

      return status == filter;
    }).toList();
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required String coachId,
    required Map<String, dynamic> data,
    required String newStatus,
  }) async {
    try {
      final isActive = newStatus == "Active";

      final updateData = {
        'status': newStatus,
        'approvalStatus': isActive ? 'Approved' : newStatus,
        'isApproved': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('coaches')
          .doc(coachId)
          .set(updateData, SetOptions(merge: true));

      final email = data['email']?.toString().trim() ?? '';
      final emailLower = email.toLowerCase();

      if (emailLower.isNotEmpty) {
        final users = await FirebaseFirestore.instance
            .collection('users')
            .where('emailLower', isEqualTo: emailLower)
            .limit(1)
            .get();

        if (users.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(users.docs.first.id)
              .set(updateData, SetOptions(merge: true));
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.coachMarkedAs} $newStatus"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.statusUpdateFailed}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatusSheet({
    required BuildContext context,
    required bool isDark,
    required String coachId,
    required Map<String, dynamic> data,
  }) {
    final name = _text(data, 'name', AppStrings.coachLabel);

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
                  AppStrings.changeCoachStatus,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
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
                  title: AppStrings.markAsActive,
                  subtitle: AppStrings.coachDashboardAccess,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(
                      context: context,
                      coachId: coachId,
                      data: data,
                      newStatus: "Active",
                    );
                  },
                ),
                const SizedBox(height: 10),
                _statusAction(
                  isDark: isDark,
                  icon: Icons.pause_circle_rounded,
                  title: AppStrings.markAsInactive,
                  subtitle: AppStrings.coachAccessStopped,
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(
                      context: context,
                      coachId: coachId,
                      data: data,
                      newStatus: "Inactive",
                    );
                  },
                ),
                const SizedBox(height: 10),
                _statusAction(
                  isDark: isDark,
                  icon: Icons.pending_actions_rounded,
                  title: AppStrings.markAsPending,
                  subtitle: AppStrings.coachWaitingApproval,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(
                      context: context,
                      coachId: coachId,
                      data: data,
                      newStatus: "Pending",
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
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
            final isDark = mode == ThemeMode.dark;

            return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg(isDark),
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
                final filtered = _filteredCoaches(coaches);

                int active = 0;
                int inactive = 0;
                int pending = 0;

                for (final doc in coaches) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = _statusText(data).toLowerCase().trim();

                  if (status == "active" || status == "approved") {
                    active++;
                  } else if (status == "inactive") {
                    inactive++;
                  } else if (_isPending(data)) {
                    pending++;
                  }
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _topHeader(context, isDark)),
                    SliverToBoxAdapter(
                      child: _summaryHeader(
                        isDark: isDark,
                        total: coaches.length,
                        active: active,
                        inactive: inactive,
                        pending: pending,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(child: _filterTabs(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.coachStatusList.toUpperCase(), isDark),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsivePadding.horizontal(context),
                      ),
                      sliver: filtered.isEmpty
                          ? SliverToBoxAdapter(child: _emptyCard(isDark))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final doc = filtered[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  return _coachStatusCard(
                                    context: context,
                                    isDark: isDark,
                                    coachId: doc.id,
                                    data: data,
                                  );
                                },
                                childCount: filtered.length,
                              ),
                            ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 26)),
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
              AppStrings.coachStatus.toUpperCase(),
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

  Widget _summaryHeader({
    required bool isDark,
    required int total,
    required int active,
    required int inactive,
    required int pending,
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
                  Icons.verified_user_rounded,
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
                      AppStrings.coachStatusControl,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppStrings.manageCoachStatus,
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
                  label: AppStrings.total,
                  value: total.toString(),
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _miniStat(
                  isDark: isDark,
                  label: AppStrings.active,
                  value: active.toString(),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _miniStat(
                  isDark: isDark,
                  label: AppStrings.inactive,
                  value: inactive.toString(),
                  color: Colors.redAccent,
                ),
              ),
              Expanded(
                child: _miniStat(
                  isDark: isDark,
                  label: AppStrings.pending,
                  value: pending.toString(),
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

  Widget _filterTabs(bool isDark) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsivePadding.horizontal(context),
        ),
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
              padding: EdgeInsets.symmetric(
                horizontal: ResponsivePadding.horizontal(context),
              ),
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
                  filters[index],
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

  Widget _coachStatusCard({
    required BuildContext context,
    required bool isDark,
    required String coachId,
    required Map<String, dynamic> data,
  }) {
    final name = _text(data, 'name', AppStrings.noName);
    final phone = _text(data, 'phone', AppStrings.noPhone);
    final specialization = _text(data, 'specialization', AppStrings.coachLabel);
    final status = _statusText(data);
    final batch = _batchesText(data);
    final statusColor = _statusColor(status);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

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
          coachId: coachId,
          data: data,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: statusColor.withOpacity(0.18),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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
                      specialization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? gold : maroon,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      batch,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
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
                          text: status,
                          color: statusColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_rounded,
                color: statusColor,
                size: 23,
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
            Icons.verified_user_rounded,
            size: 40,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noCoachesFound,
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
