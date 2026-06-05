import 'package:flutter/material.dart';

class CricketActivityScreen extends StatelessWidget {
  const CricketActivityScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        "title": "Match Practice",
        "subtitle": "Sunday morning match simulation",
        "date": "09 Jun 2026",
        "icon": Icons.sports_cricket,
        "status": "Upcoming",
      },
      {
        "title": "Fitness Drill",
        "subtitle": "Speed, stamina and agility training",
        "date": "10 Jun 2026",
        "icon": Icons.fitness_center,
        "status": "Training",
      },
      {
        "title": "Video Analysis",
        "subtitle": "Batting technique review session",
        "date": "12 Jun 2026",
        "icon": Icons.video_camera_back,
        "status": "Learning",
      },
      {
        "title": "Tournament Update",
        "subtitle": "YGCA selected for local academy league",
        "date": "15 Jun 2026",
        "icon": Icons.emoji_events,
        "status": "Event",
      },
      {
        "title": "Achievement",
        "subtitle": "Arjun scored 72 runs in practice match",
        "date": "18 Jun 2026",
        "icon": Icons.star,
        "status": "Highlight",
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Cricket Activities"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recent & Upcoming Activities",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          ...activities.map((activity) {
            return _activityCard(
              title: activity["title"] as String,
              subtitle: activity["subtitle"] as String,
              date: activity["date"] as String,
              icon: activity["icon"] as IconData,
              status: activity["status"] as String,
            );
          }),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.sports_cricket, color: gold, size: 44),
          const SizedBox(height: 10),
          const Text(
            "YGCA Cricket Activities",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Matches, training, tournaments and player highlights",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _activityCard({
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required String status,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Icon(icon, color: gold),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$subtitle\n$date"),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: maroon,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}