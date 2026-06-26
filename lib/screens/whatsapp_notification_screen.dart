import 'package:flutter/material.dart';

class WhatsAppNotificationScreen extends StatelessWidget {
  const WhatsAppNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7F0000);
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text("WhatsApp Notifications"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
        children: const [
          _WhatsAppCard(
            icon: Icons.currency_rupee,
            title: "Fee Reminder",
            subtitle: "Send pending fee alerts",
          ),
          _WhatsAppCard(
            icon: Icons.fact_check,
            title: "Attendance Alert",
            subtitle: "Send absent alerts",
          ),
          _WhatsAppCard(
            icon: Icons.event_available,
            title: "Leave Status",
            subtitle: "Approved / rejected alerts",
          ),
          _WhatsAppCard(
            icon: Icons.campaign,
            title: "Announcement",
            subtitle: "Academy updates",
          ),
        ],
      ),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}