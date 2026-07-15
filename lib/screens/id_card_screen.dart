import 'package:flutter/material.dart';

import '../core/language/app_strings.dart';
import '../theme/theme_controller.dart';

class IDCardScreen extends StatelessWidget {
  const IDCardScreen({super.key});

  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFFAFAFA);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ThemeController.language,
      builder: (context, language, _) {
        return Scaffold(
          backgroundColor: bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                const SizedBox(height: 22),
                _idCard(),
                const SizedBox(height: 20),
                _noteCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topHeader(BuildContext context) {
    return Container(
      color: maroon,
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Image.asset('assets/images/ygca_logo.jpg', width: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.studentIdCard.toUpperCase(),
              style: const TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.badge, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _idCard() {
    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _cardHeader(),
          const SizedBox(height: 18),
          _photoSection(),
          const SizedBox(height: 14),
          const Text(
            "ARJUN R",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.idCardActivePlayer.toUpperCase(),
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          _detailsSection(),
          const SizedBox(height: 16),
          _qrSection(),
          const SizedBox(height: 16),
          _signatureSection(),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _cardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: const BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 70,
            height: 70,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.youngGenCricketAcademy.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: gold,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.idCardDisciplineTrainingExcellence,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoSection() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 2),
      ),
      child: const CircleAvatar(
        radius: 48,
        backgroundColor: maroon,
        child: Icon(Icons.person, color: gold, size: 58),
      ),
    );
  }

  Widget _detailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          _detailRow(AppStrings.idCardIdLabel, "YGCA014"),
          _detailRow(AppStrings.batch, AppStrings.idCardMorningBatch),
          _detailRow(AppStrings.phone, "9876543210"),
          _detailRow(AppStrings.attendance, "92%"),
          _detailRow(AppStrings.feeStatus, AppStrings.paid),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.qr_code_2, color: maroon, size: 70),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.idCardScanForVerification,
            style: const TextStyle(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _signatureSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(height: 1, color: Colors.grey.shade400),
                const SizedBox(height: 5),
                Text(
                  AppStrings.idCardStudentSignature,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                Container(height: 1, color: Colors.grey.shade400),
                const SizedBox(height: 5),
                Text(
                  AppStrings.idCardAuthorizedSignature,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteCard() {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.idCardSampleLayoutNote,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
