import 'package:flutter/material.dart';

import '../core/language/app_strings.dart';
import '../theme/theme_controller.dart';

class WhatsAppNotificationScreen extends StatelessWidget {
  const WhatsAppNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7F0000);
    const gold = Color(0xFFD4AF37);

    return ValueListenableBuilder<String>(
      valueListenable: ThemeController.language,
      builder: (context, language, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.whatsappNotificationsTitle),
            backgroundColor: maroon,
            foregroundColor: Colors.white,
          ),
          body: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              _WhatsAppCard(
                icon: Icons.currency_rupee,
                title: AppStrings.whatsappFeeReminder,
                subtitle: AppStrings.whatsappSendPendingFeeAlerts,
              ),
              _WhatsAppCard(
                icon: Icons.fact_check,
                title: AppStrings.whatsappAttendanceAlert,
                subtitle: AppStrings.whatsappSendAbsentAlerts,
              ),
              _WhatsAppCard(
                icon: Icons.event_available,
                title: AppStrings.whatsappLeaveStatus,
                subtitle: AppStrings.whatsappApprovedRejectedAlerts,
              ),
              _WhatsAppCard(
                icon: Icons.campaign,
                title: AppStrings.whatsappAnnouncement,
                subtitle: AppStrings.whatsappAcademyUpdates,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WhatsAppCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _WhatsAppCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7F0000);
    const gold = Color(0xFFD4AF37);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: maroon,
            child: Icon(icon, color: gold, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
