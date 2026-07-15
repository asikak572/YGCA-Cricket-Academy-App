import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class CricketActivityScreen extends StatelessWidget {
  const CricketActivityScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ThemeController.language,
      builder: (context, language, _) {
        final activities = [
          {
            "title": AppStrings.cricketActivityMatchPractice,
            "subtitle": AppStrings.cricketActivityMatchPracticeSubtitle,
            "date": "09 Jun 2026",
            "icon": Icons.sports_cricket,
            "statusKey": AppStrings.upcoming,
            "status": AppStrings.upcoming,
            "color": Colors.orange,
          },
          {
            "title": AppStrings.cricketActivityFitnessDrill,
            "subtitle": AppStrings.cricketActivityFitnessDrillSubtitle,
            "date": "10 Jun 2026",
            "icon": Icons.fitness_center,
            "statusKey": "Training",
            "status": AppStrings.training,
            "color": Colors.green,
          },
          {
            "title": AppStrings.cricketActivityVideoAnalysis,
            "subtitle": AppStrings.cricketActivityVideoAnalysisSubtitle,
            "date": "12 Jun 2026",
            "icon": Icons.video_camera_back,
            "statusKey": "Learning",
            "status": AppStrings.cricketActivityLearning,
            "color": Colors.blue,
          },
          {
            "title": AppStrings.cricketActivityTournamentUpdate,
            "subtitle": AppStrings.cricketActivityTournamentUpdateSubtitle,
            "date": "15 Jun 2026",
            "icon": Icons.emoji_events,
            "statusKey": "Event",
            "status": AppStrings.event,
            "color": Colors.purple,
          },
          {
            "title": AppStrings.cricketActivityAchievement,
            "subtitle": AppStrings.cricketActivityAchievementSubtitle,
            "date": "18 Jun 2026",
            "icon": Icons.star,
            "statusKey": "Highlight",
            "status": AppStrings.cricketActivityHighlight,
            "color": Colors.red,
          },
        ];

    final matchCount =
        activities.where((a) => a["statusKey"] == AppStrings.upcoming).length;
    final trainingCount =
        activities.where((a) => a["statusKey"] == "Training").length;
    final eventCount = activities.where((a) => a["statusKey"] == "Event").length;
    final highlightCount =
        activities.where((a) => a["statusKey"] == "Highlight").length;

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _topHeader(context),
            _heroBanner(
              total: activities.length,
              matches: matchCount,
              training: trainingCount,
              highlights: highlightCount,
            ),

            const SizedBox(height: 18),

            _sectionTitle(AppStrings.cricketActivityOverview.toUpperCase()),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.25,
                children: [
                  _statCard(
                    Icons.sports_cricket,
                    AppStrings.matches.toUpperCase(),
                    matchCount.toString(),
                    AppStrings.upcoming,
                    Colors.orange,
                  ),
                  _statCard(
                    Icons.fitness_center,
                    AppStrings.training.toUpperCase(),
                    trainingCount.toString(),
                    AppStrings.cricketActivityDrills,
                    Colors.green,
                  ),
                  _statCard(
                    Icons.emoji_events,
                    AppStrings.events.toUpperCase(),
                    eventCount.toString(),
                    AppStrings.tournament,
                    Colors.purple,
                  ),
                  _statCard(
                    Icons.star,
                    AppStrings.cricketActivityHighlights.toUpperCase(),
                    highlightCount.toString(),
                    AppStrings.cricketActivityAchievements,
                    Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _sectionTitle(AppStrings.cricketActivityFeatured.toUpperCase()),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _featuredCard(),
            ),

            const SizedBox(height: 18),

            _sectionTitle(AppStrings.cricketActivityRecentUpcoming.toUpperCase()),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: activities.map((activity) {
                  return _activityCard(
                    title: activity["title"] as String,
                    subtitle: activity["subtitle"] as String,
                    date: activity["date"] as String,
                    icon: activity["icon"] as IconData,
                    status: activity["status"] as String,
                    color: activity["color"] as Color,
                  );
                }).toList(),
              ),
            ),

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
              AppStrings.cricketActivityTitle.toUpperCase(),
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.sports_cricket, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int total,
    required int matches,
    required int training,
    required int highlights,
  }) {
    return Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border.all(color: gold, width: 1),
      ),
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
                    darkMaroon.withOpacity(0.96),
                    maroon.withOpacity(0.70),
                    Colors.black.withOpacity(0.38),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.sports_cricket, color: maroon, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "YGCA",
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       Text(
                        AppStrings.cricketActivityActivity.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        AppStrings.cricketActivityHub.toUpperCase(),
                        style: TextStyle(
                          color: gold,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("${AppStrings.total}: $total"),
                          _heroChip("${AppStrings.matches}: $matches"),
                          _heroChip("${AppStrings.training}: $training"),
                          _heroChip("${AppStrings.cricketActivityHighlights}: $highlights"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: maroon,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 42, height: 2, color: gold),
        ],
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(Icons.emoji_events, color: maroon, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.cricketActivityFeaturedUpdate,
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                 Text(
                  AppStrings.cricketActivityTournamentUpdateSubtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                 Text(
                  AppStrings.cricketActivityPlayersReceiveScheduleSoon,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
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
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _chip(Icons.calendar_month, date, Colors.blue),
                    _chip(Icons.label, status, color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
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
}