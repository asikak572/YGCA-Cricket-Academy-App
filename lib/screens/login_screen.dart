import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_text.dart';
import 'register_screen.dart';
import 'auth_checker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.loginEnterEmailPassword)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signOut();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthChecker()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = AppStrings.loginFailed;

      if (e.code == 'user-not-found') {
        message = AppStrings.loginNoUserFound;
      } else if (e.code == 'wrong-password') {
        message = AppStrings.loginWrongPassword;
      } else if (e.code == 'invalid-email') {
        message = AppStrings.loginInvalidEmail;
      } else if (e.code == 'invalid-credential') {
        message = AppStrings.loginInvalidEmailPassword;
      } else if (e.code == 'network-request-failed') {
        message = AppStrings.loginNetworkError;
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.loginError}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 370;
    final isShort = size.height < 850;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, _) {
            final isDark = mode == ThemeMode.dark;

            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: _bg(isDark),
              body: SafeArea(
                child: Column(
                  children: [
                    _hero(isDark: isDark, height: size.height, isSmall: isSmall),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isSmall ? 16 : 22,
                        isShort ? 10 : 18,
                        isSmall ? 16 : 22,
                        isShort ? 8 : 14,
                      ),
                      child: Column(
                        children: [
                          _loginPanel(isDark: isDark),
                          SizedBox(height: isShort ? 8 : 14),
                          _registerCard(isDark: isDark),
                          SizedBox(height: isShort ? 8 : 16),
                          _footerMini(isDark),
                          SizedBox(height: isShort ? 2 : 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _hero({
    required bool isDark,
    required double height,
    required bool isSmall,
  }) {
    final isShort = height < 850;

    return Container(
  width: double.infinity,
  constraints: BoxConstraints(
    minHeight: isShort ? 240 : (isSmall ? 330 : 350),
  ),
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
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.95),
                          darkMaroon.withOpacity(0.88),
                          red.withOpacity(0.42),
                        ]
                      : [
                          darkMaroon.withOpacity(0.96),
                          maroon.withOpacity(0.72),
                          Colors.black.withOpacity(0.50),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: -32,
            child: Icon(
              Icons.sports_cricket_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 170,
            ),
          ),
          Positioned(
            right: 16,
            top: 14,
            child: _themeButton(isDark),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              isShort ? 10 : (isSmall ? 12 : 16),
              24,
              isShort ? 12 : 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isShort ? 62 : (isSmall ? 68 : 78),
                  height: isShort ? 62 : (isSmall ? 68 : 78),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.42),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: gold.withOpacity(0.70)),
                  ),
                  child: Image.asset(
                    'assets/images/ygca_logo_background.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: isShort ? 14 : 30),
                Text(
                  AppStrings.loginWelcomeBack.toUpperCase(),
                  style: TextStyle(
                    color: gold,
                    fontSize: ResponsiveText.small(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
  AppStrings.loginTitle.toUpperCase(),
  maxLines: 2,
  softWrap: true,
  overflow: TextOverflow.visible,
  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveText.hero(context),
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
                Text(
  AppStrings.loginToContinue.toUpperCase(),
  maxLines: 2,
  softWrap: true,
  overflow: TextOverflow.visible,
  style: TextStyle(
                    color: gold,
                    fontSize: ResponsiveText.heroSubtitle(context),
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  AppStrings.youngGenCricketAcademy,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: ResponsiveText.bodySmall(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeButton(bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: ThemeController.toggleTheme,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: Colors.white,
          size: 21,
        ),
      ),
    );
  }

  Widget _loginPanel({required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? red.withOpacity(0.28) : gold.withOpacity(0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: red.withOpacity(0.14),
                child: Icon(Icons.lock_open_rounded, color: isDark ? gold : maroon),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.loginAccountLogin,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: ResponsiveText.cardTitle(context),
                      ),
                    ),
                    Text(
                      AppStrings.loginRoles,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveText.small(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _field(
            isDark: isDark,
            label: AppStrings.loginEmailAddress,
            controller: emailController,
            icon: Icons.mail_outline_rounded,
            hint: AppStrings.loginEnterEmail,
            obscure: false,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _field(
            isDark: isDark,
            label: AppStrings.loginPassword,
            controller: passwordController,
            icon: Icons.lock_outline_rounded,
            hint: AppStrings.loginEnterPassword,
            obscure: obscurePassword,
            suffix: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          _loginButton(isDark),
        ],
      ),
    );
  }

  Widget _field({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool obscure,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? gold : maroon,
            fontSize: ResponsiveText.small(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction:
              obscure ? TextInputAction.done : TextInputAction.next,
          onSubmitted: obscure ? (_) => _login() : null,
          style: TextStyle(
            color: _primaryText(isDark),
            fontSize: ResponsiveText.input(context),
            fontWeight: FontWeight.w700,
          ),
          cursorColor: isDark ? gold : maroon,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: ResponsiveText.input(context),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: isDark ? gold : maroon),
            suffixIcon: suffix,
            filled: true,
            fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _border(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _border(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? red : gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? red : const Color(0xFFFFC247),
          foregroundColor: isDark ? Colors.white : maroon,
          elevation: 8,
          shadowColor: red.withOpacity(0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : _login,
        icon: isLoading ? const SizedBox() : const Icon(Icons.login_rounded),
        label: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: isDark ? Colors.white : maroon,
                  strokeWidth: 2,
                ),
              )
            : Text(
                AppStrings.loginTitle.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: ResponsiveText.button(context),
                  letterSpacing: 0.8,
                ),
              ),
      ),
    );
  }

  Widget _registerCard({required bool isDark}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark
          ? const Color(0xFF111111)
          : const Color(0xFFFFFBF2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? gold.withOpacity(0.55)
            : const Color(0xFFFDE68A),
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final useColumn =
            constraints.maxWidth < 380 ||
            ThemeController.language.value != 'en';

        final titleWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: isDark ? gold : maroon,
              size: 28,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                AppStrings.loginNewToYgca,
                textAlign:
                    useColumn ? TextAlign.center : TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.w900,
                  fontSize: ResponsiveText.bodySmall(context),
                ),
              ),
            ),
          ],
        );

        final registerButton = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? red : maroon,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _goToRegister,
          child: Text(
            AppStrings.loginRegister.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveText.button(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        if (useColumn) {
          return Column(
            children: [
              titleWidget,
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: registerButton,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: titleWidget),
            const SizedBox(width: 10),
            registerButton,
          ],
        );
      },
    ),
  );
}

 Widget _footerMini(bool isDark) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      AppStrings.loginPassionDisciplineSuccess,
      textAlign: TextAlign.center,
      maxLines: 2,
      softWrap: true,
      style: TextStyle(
        color: isDark ? gold : maroon,
        fontSize: ResponsiveText.caption(context),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
}
