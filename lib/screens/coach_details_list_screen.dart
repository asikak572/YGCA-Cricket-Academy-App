import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_text.dart';

import 'coach_details_screen.dart';

class CoachDetailsListScreen extends StatelessWidget {
  const CoachDetailsListScreen({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
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

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString().trim();
  }
  String _canonicalStatus(String status) {
  final value = status.toLowerCase().trim();

  if (value == 'active' ||
      value == 'approved' ||
      value == 'செயலில்' ||
      value == 'அங்கீகரிக்கப்பட்டது') {
    return 'active';
  }

  if (value == 'inactive' ||
      value == 'செயலில் இல்லை' ||
      value == 'செயலற்றது') {
    return 'inactive';
  }

  if (value == 'pending' ||
      value == 'waiting' ||
      value == 'நிலுவை' ||
      value == 'காத்திருக்கிறது') {
    return 'pending';
  }

  return value;
}

String _localizedStatus(String status) {
  switch (_canonicalStatus(status)) {
    case 'active':
      return AppStrings.active;

    case 'inactive':
      return AppStrings.inactive;

    case 'pending':
      return AppStrings.pending;

    default:
      return status;
  }
}

String _localizedSpecialization(String specialization) {
  final value = specialization.toLowerCase().trim();

  if (value == 'batting coach' ||
      value == 'batting' ||
      value == 'பேட்டிங் பயிற்சியாளர்') {
    return AppStrings.coachMgmtBattingCoach;
  }

  if (value == 'bowling coach' ||
      value == 'bowling' ||
      value == 'பந்துவீச்சு பயிற்சியாளர்') {
    return AppStrings.coachMgmtBowlingCoach;
  }

  if (value == 'fielding coach' ||
      value == 'fielding' ||
      value == 'களத்தடுப்பு பயிற்சியாளர்') {
    return AppStrings.coachMgmtFieldingCoach;
  }

  if (value == 'fitness coach' ||
      value == 'fitness' ||
      value == 'உடற்தகுதி பயிற்சியாளர்') {
    return AppStrings.coachMgmtFitnessCoach;
  }

  if (value == 'head coach' ||
      value == 'தலைமை பயிற்சியாளர்') {
    return AppStrings.coachMgmtHeadCoach;
  }

  if (value == 'assistant coach' ||
      value == 'உதவி பயிற்சியாளர்') {
    return AppStrings.coachMgmtAssistantCoach;
  }

  if (value.isEmpty ||
      value == 'no specialization' ||
      value == 'சிறப்பு துறை இல்லை') {
    return AppStrings.noSpecialization;
  }

  return specialization;
}

 Color _statusColor(String status) {
  final value = _canonicalStatus(status);

    if (value == "active" || value == "approved") return Colors.green;
    if (value == "inactive") return Colors.redAccent;
    if (value == "pending" || value == "waiting") return Colors.orange;
    return Colors.orange;
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
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

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _topHeader(context, isDark)),
                    SliverToBoxAdapter(child: _infoHeader(isDark, coaches.length)),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.coachDetailsList, isDark),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsivePadding.horizontal(context),
                      ),
                      sliver: coaches.isEmpty
                          ? SliverToBoxAdapter(child: _emptyCard(isDark))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final doc = coaches[index];
                                  final data = doc.data() as Map<String, dynamic>;

                                  final name = _text(data, 'name', AppStrings.noName);
                                  final role = _text(data, 'role', AppStrings.coachLabel);
                                  final phone = _text(data, 'phone', AppStrings.noPhone);
                                  final batch = _batchesText(data);
                                  final status = _localizedStatus(
  _text(data, 'status', 'Pending'),
);
                                  final email = _text(data, 'email', AppStrings.noEmail);
                                 final specialization = _localizedSpecialization(
  _text(
    data,
    'specialization',
    'No Specialization',
  ),
);
                                  return _coachDetailsCard(
                                    context: context,
                                    isDark: isDark,
                                    coachId: doc.id,
                                    name: name,
                                    role: role,
                                    phone: phone,
                                    batch: batch,
                                    status: status,
                                    email: email,
                                    specialization: specialization,
                                  );
                                },
                                childCount: coaches.length,
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
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context),
        12,
        ResponsivePadding.horizontal(context),
        14,
      ),
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
            width: ResponsiveHelper.isMobile(context) ? 40 : 46,
            height: ResponsiveHelper.isMobile(context) ? 40 : 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.coachDetails,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : gold,
                fontSize: ResponsiveText.heading(context),
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
          color: isDark ? const Color(0xFF111111) : Colors.white.withOpacity(0.14),
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

  Widget _infoHeader(bool isDark, int total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
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
            radius: 27,
            backgroundColor: maroon,
            child: const Icon(
              Icons.badge_rounded,
              color: gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
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
                const SizedBox(height: 5),
                Text(
                  AppStrings.viewCoachProfileAndBatchDetails,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: gold.withOpacity(isDark ? 0.16 : 0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gold.withOpacity(0.45)),
            ),
            child: Text(
              total.toString(),
              style: TextStyle(
                color: isDark ? gold : maroon,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
        ],
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

  Widget _coachDetailsCard({
    required BuildContext context,
    required bool isDark,
    required String coachId,
    required String name,
    required String role,
    required String phone,
    required String batch,
    required String status,
    required String email,
    required String specialization,
  }) {
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: maroon,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
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
                      email,
                      maxLines: 1,
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
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.black38,
                size: 26,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.badge_rounded,
            size: 40,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noCoachDetailsFound,
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
