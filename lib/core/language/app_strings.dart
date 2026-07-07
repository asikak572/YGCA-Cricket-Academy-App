import '../../theme/theme_controller.dart';

class AppStrings {
  AppStrings._();

  static String get lang => ThemeController.language.value;

  static String text(String en, String ta, String hi) {
    if (lang == "தமிழ்") return ta;
    if (lang == "हिन्दी") return hi;
    return en;
  }

  static String get settings => text("Settings", "அமைப்புகள்", "सेटिंग्स");
  static String get appPreferences =>
      text("App preferences and security", "செயலி விருப்பங்கள் மற்றும் பாதுகாப்பு", "ऐप पसंद और सुरक्षा");

  static String get appearance => text("APPEARANCE", "தோற்றம்", "दिखावट");
  static String get switchToLight =>
      text("Switch to Light Mode", "லைட் மோடுக்கு மாற்று", "लाइट मोड पर जाएं");
  static String get switchToDark =>
      text("Switch to Dark Mode", "டார்க் மோடுக்கு மாற்று", "डार्क मोड पर जाएं");
  static String get changeAppearance =>
      text("Change app appearance", "செயலி தோற்றத்தை மாற்று", "ऐप का रूप बदलें");

  static String get language => text("Language", "மொழி", "भाषा");

  static String get appPreferencesTitle =>
      text("APP PREFERENCES", "செயலி விருப்பங்கள்", "ऐप पसंद");
  static String get compactMode =>
      text("Compact Mode", "சுருக்கமான முறை", "कॉम्पैक्ट मोड");
  static String get reduceSpacing =>
      text("Reduce spacing and scrolling", "இடைவெளி மற்றும் ஸ்க்ரோலை குறைக்கும்", "स्पेसिंग और स्क्रॉल कम करें");
  static String get largeTextMode =>
      text("Large Text Mode", "பெரிய எழுத்து முறை", "बड़ा टेक्स्ट मोड");
  static String get betterReadability =>
      text("Better readability for users", "பயனர்களுக்கு எளிதாக படிக்க", "उपयोगकर्ताओं के लिए बेहतर पढ़ना");

  static String get privacySecurity =>
      text("PRIVACY & SECURITY", "தனியுரிமை & பாதுகாப்பு", "गोपनीयता और सुरक्षा");
  static String get changePassword =>
      text("Change Password", "கடவுச்சொல்லை மாற்று", "पासवर्ड बदलें");
  static String get resetLink =>
      text("Send reset link to registered email", "பதிவு செய்த மின்னஞ்சலுக்கு ரீசெட் லிங்க் அனுப்பு", "रजिस्टर्ड ईमेल पर रीसेट लिंक भेजें");
  static String get loginStatus =>
      text("Login Status", "உள்நுழைவு நிலை", "लॉगिन स्थिति");
  static String get active => text("Active", "செயலில்", "सक्रिय");

  static String get about => text("ABOUT", "பற்றி", "जानकारी");
  static String get appVersion => text("App Version", "செயலி பதிப்பு", "ऐप वर्जन");

  static String get on => text("On", "ஆன்", "चालू");
  static String get off => text("Off", "ஆஃப்", "बंद");
  static String get email => text("Email", "மின்னஞ்சல்", "ईमेल");
}