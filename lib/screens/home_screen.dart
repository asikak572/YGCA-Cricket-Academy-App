import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFFAFAFA);
  static const Color border = Color(0xFFE2E8F0);

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ThemeController.language,
      builder: (context, language, _) {
        return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            return SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.36,
                    child: _hero(context),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                      child: Column(
                        children: [
                          _sectionTitle(AppStrings.homeWhatWeOffer.toUpperCase()),
                          const SizedBox(height: 8),
                          Expanded(
                            flex: 6,
                            child: GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.05,
                              children: [
                                _OfferCard(
                                  icon: Icons.calendar_month_rounded,
                                  title: AppStrings.sessions,
                                ),
                                _OfferCard(
                                  icon: Icons.wb_sunny_rounded,
                                  title: AppStrings.homePractice,
                                ),
                                _OfferCard(
                                  icon: Icons.fitness_center_rounded,
                                  title: AppStrings.fitness,
                                ),
                                _OfferCard(
                                  icon: Icons.videocam_rounded,
                                  title: AppStrings.homeVideo,
                                ),
                                _OfferCard(
                                  icon: Icons.person_rounded,
                                  title: AppStrings.homeProfile,
                                ),
                                _OfferCard(
                                  icon: Icons.sports_cricket_rounded,
                                  title: AppStrings.skills,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _sectionTitle(AppStrings.session.toUpperCase()),
                          const SizedBox(height: 8),
                          _sessionCard(),
                          const SizedBox(height: 8),
                          _contactCard(),
                        ],
                      ),
                    ),
                  ),
                  _footer(),
                ],
              ),
            );
          },
        ),
      ),
        );
      },
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
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
                    maroon.withOpacity(0.82),
                    Colors.black.withOpacity(0.44),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/ygca_logo.jpg',
                  height: 62,
                  width: 62,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.homeYoungGen.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.homeCricketAcademy.toUpperCase(),
                    style: TextStyle(
                      color: gold,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.homeBuildCricketCareer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: gold, size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppStrings.homeLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD977),
                      foregroundColor: maroon,
                      elevation: 6,
                      shadowColor: gold.withOpacity(0.30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => _goToLogin(context),
                    icon: const Icon(Icons.login_rounded, size: 21),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppStrings.homeLoginToContinue.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return SizedBox(
      height: 25,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: maroon,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1.2,
              color: gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard() {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DayChip(day: AppStrings.fri.toUpperCase()),
          _DayChip(day: AppStrings.sat.toUpperCase()),
          _DayChip(day: AppStrings.sun.toUpperCase()),
        ],
      ),
    );
  }

  Widget _contactCard() {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: maroon,
            child: Icon(Icons.phone_rounded, color: gold, size: 21),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              AppStrings.homeContactAcademy,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: maroon,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      height: 48,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: maroon,
        border: Border(
          top: BorderSide(color: gold, width: 1.2),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          AppStrings.homePassionDisciplineSuccess,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: gold,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: HomeScreen.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 75,
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: HomeScreen.maroon,
                size: 27,
              ),
              const SizedBox(height: 7),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day});

  final String day;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HomeScreen.maroon,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        day,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}