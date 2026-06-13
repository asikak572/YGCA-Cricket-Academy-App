import 'package:flutter/material.dart';

import 'match_schedule_screen.dart';
import 'training_schedule_screen.dart';
import 'makeup_session_screen.dart';

class CoachScheduleModuleScreen extends StatelessWidget {
  const CoachScheduleModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color maroon = Color(0xFF7F0000);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        title: const Text(
          "Schedule Module",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _moduleCard(
              context,
              Icons.sports_cricket,
              "Match Schedule",
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MatchScheduleScreen(),
                  ),
                );
              },
            ),
            _moduleCard(
              context,
              Icons.calendar_month,
              "Training Schedule",
              Colors.indigo,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TrainingScheduleScreen(),
                  ),
                );
              },
            ),
            _moduleCard(
              context,
              Icons.event_repeat,
              "Makeup Sessions",
              Colors.teal,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MakeupSessionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}