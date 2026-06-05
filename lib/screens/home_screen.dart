import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
              decoration: BoxDecoration(
                color: maroon,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.sports_cricket, color: gold, size: 58),
                  const SizedBox(height: 16),
                  Text(
                    "YOUNG GEN CRICKET ACADEMY",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gold,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Build your Cricket Career with us",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 23),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Valasaravakkam, Chennai 600087",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("What We Offer"),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _featureCard(Icons.calendar_month, "5 Days / Week Coaching"),
                  _featureCard(Icons.sunny, "Weekend Coaching"),
                  _featureCard(Icons.fitness_center, "Fitness & Drills"),
                  _featureCard(Icons.video_camera_back, "Video Analysis"),
                  _featureCard(Icons.person, "Individual Focus"),
                  _featureCard(Icons.sports_cricket, "Match Practice"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Session Schedule"),

            _scheduleCard("Friday", "Evening 4–6 PM • Flood Lights 6–8 PM"),
            _scheduleCard("Saturday", "Morning 7–9 AM • Evening 4–6 PM"),
            _scheduleCard("Sunday", "Morning 7–9 AM • Evening 4–6 PM"),

            const SizedBox(height: 20),

            _sectionTitle("Contact"),

            _contactCard(Icons.phone, "9941411006"),
            _contactCard(Icons.phone, "8939299555"),
            _contactCard(
              Icons.location_on,
              "12A, Kadambadi Amman Street, Valasaravakkam",
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Login to Continue"),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: gold),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard(String day, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Icon(Icons.calendar_today, color: gold),
        ),
        title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
      ),
    );
  }

  Widget _contactCard(IconData icon, String text) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Icon(icon, color: gold),
        ),
        title: Text(text),
      ),
    );
  }
}