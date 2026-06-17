import 'package:flutter/material.dart';

class SmsNotificationScreen extends StatelessWidget {
  const SmsNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7F0000);
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS Notifications"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SmsCard(
            icon: Icons.currency_rupee,
            title: "Fee Reminder SMS",
            subtitle: "Send fee pending reminders to parents",
          ),
          _SmsCard(
            icon: Icons.fact_check,
            title: "Attendance Alert SMS",
            subtitle: "Notify parents about absent students",
          ),
          _SmsCard(
            icon: Icons.event_available,
            title: "Leave Status SMS",
            subtitle: "Notify leave approved or rejected status",
          ),
          _SmsCard(
            icon: Icons.message,
            title: "Custom SMS",
            subtitle: "Send academy announcements by SMS",
          ),
        ],
      ),
    );
  }
}

class _SmsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SmsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7F0000);
    const gold = Color(0xFFD4AF37);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Icon(icon, color: gold),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}