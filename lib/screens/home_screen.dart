import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  void _goLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _hero(context),
            const SizedBox(height: 22),
            _sectionTitle(Icons.stars, "WHAT WE OFFER"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  _featureCard(Icons.calendar_month, "5 Days / Week\nCoaching",
                      "Regular & consistent\ntraining"),
                  _featureCard(Icons.wb_sunny, "Weekend\nCoaching",
                      "Morning & evening\nsessions"),
                  _featureCard(Icons.fitness_center, "Fitness & Drills",
                      "Build strength &\nimprove agility"),
                  _featureCard(Icons.videocam, "Video Analysis",
                      "Improve technique\nwith smart analysis"),
                  _featureCard(Icons.person, "Individual Focus",
                      "Personal attention\nto every player"),
                  _featureCard(Icons.sports_cricket, "Match Practice",
                      "Real match exposure\n& game awareness"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(Icons.event_note, "SESSION SCHEDULE"),
            _scheduleRow(
              day: "FRIDAY",
              firstIcon: Icons.wb_sunny,
              firstTitle: "Evening 4 – 6 PM",
              firstSub: "Training Session",
              secondIcon: Icons.nights_stay,
              secondTitle: "Flood Lights 6 – 8 PM",
              secondSub: "Night Practice",
            ),
            _scheduleRow(
              day: "SATURDAY",
              firstIcon: Icons.wb_sunny,
              firstTitle: "Morning 7 – 9 AM",
              firstSub: "Training Session",
              secondIcon: Icons.wb_sunny,
              secondTitle: "Evening 4 – 6 PM",
              secondSub: "Training Session",
            ),
            _scheduleRow(
              day: "SUNDAY",
              firstIcon: Icons.wb_sunny,
              firstTitle: "Morning 7 – 9 AM",
              firstSub: "Training Session",
              secondIcon: Icons.wb_sunny,
              secondTitle: "Evening 4 – 6 PM",
              secondSub: "Training Session",
            ),
            const SizedBox(height: 24),
            _sectionTitle(Icons.phone, "CONTACT"),
            _contactCard(Icons.phone, "9941411006"),
            _contactCard(Icons.phone, "8939299555"),
            _contactCard(
              Icons.location_on,
              "12A, Kadambadi Amman Street,\nValasaravakkam, Chennai 600087",
            ),
            const SizedBox(height: 26),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 610,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_hero_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    darkMaroon.withOpacity(0.95),
                    maroon.withOpacity(0.72),
                    Colors.black.withOpacity(0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/ygca_logo.jpg',
                        height: 130,
                        width: 130,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD978),
                          foregroundColor: maroon,
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.25),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => _goLogin(context),
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text(
                          "Login to Continue",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    "YOUNG GEN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "— CRICKET ACADEMY —",
                    style: TextStyle(
                      color: Color(0xFFFF4B4B),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "— ★ —",
                      style: TextStyle(
                        color: gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Build your Cricket Career with us",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.location_on,
                          color: Color(0xFFD4AF37), size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Valasaravakkam, Chennai 600087",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: gold.withOpacity(0.6)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _heroMini(Icons.person, "Expert Coaches"),
                      _heroMini(Icons.apartment, "Modern Facilities"),
                      _heroMini(Icons.emoji_events, "Proven Results"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroMini(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 18),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Icon(icon, color: maroon, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: maroon,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: gold.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: const Color(0xFFFFF4F4),
            child: Icon(icon, color: maroon, size: 27),
          ),
          const SizedBox(height: 11),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Container(width: 22, height: 1.5, color: gold),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleRow({
    required String day,
    required IconData firstIcon,
    required String firstTitle,
    required String firstSub,
    required IconData secondIcon,
    required String secondTitle,
    required String secondSub,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 105,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: maroon,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _timeBlock(firstIcon, firstTitle, firstSub)),
                Container(width: 1, height: 35, color: gold.withOpacity(0.6)),
                Expanded(child: _timeBlock(secondIcon, secondTitle, secondSub)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBlock(IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 22),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: maroon,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: gold),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: 310,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
        ),
        border: Border(top: BorderSide(color: gold, width: 2)),
      ),
      child: Column(
        children: [
          Text(
            "♥  Passion  •  Discipline  •  Success",
            style: TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Since 2022",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}