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
  static String get appPreferences => text("App preferences and security", "செயலி விருப்பங்கள் மற்றும் பாதுகாப்பு", "ऐप पसंद और सुरक्षा");
  static String get appearance => text("APPEARANCE", "தோற்றம்", "दिखावट");
  static String get switchToLight => text("Switch to Light Mode", "லைட் மோடுக்கு மாற்று", "लाइट मोड पर जाएं");
  static String get switchToDark => text("Switch to Dark Mode", "டார்க் மோடுக்கு மாற்று", "डार்க मोड पर जाएं");
  static String get changeAppearance => text("Change app appearance", "செயலி தோற்றத்தை மாற்று", "ऐप का रूप बदलें");
  static String get language => text("Language", "மொழி", "भाषा");
  static String get appPreferencesTitle => text("APP PREFERENCES", "செயலி விருப்பங்கள்", "ऐप पसंद");
  static String get compactMode => text("Compact Mode", "சுருக்கமான முறை", "कॉम्पैक्ट मोड");
  static String get reduceSpacing => text("Reduce spacing and scrolling", "இடைவெளி மற்றும் ஸ்க்ரோலை குறைக்கும்", "स्पेसिंग और स्क्रॉल कम करें");
  static String get largeTextMode => text("Large Text Mode", "பெரிய எழுத்து முறை", "बड़ा टेक्स्ट मोड");
  static String get betterReadability => text("Better readability for users", "பயனர்களுக்கு எளிதாக படிக்க", "उपयोगकर्ताओं के लिए बेहतर पढ़ना");
  static String get privacySecurity => text("PRIVACY & SECURITY", "தனியுரிமை & பாதுகாப்பு", "गोपनीयता और सुरक्षा");
  static String get changePassword => text("Change Password", "கடவுச்சொல்லை மாற்று", "पासवर्ड बदलें");
  static String get resetLink => text("Send reset link to registered email", "பதிவு செய்த மின்னஞ்சலுக்கு ரீசெட் லிங்க் அனுப்பு", "रजिस्टर्ड ईमेल पर रीसेट लिंक भेजें");
  static String get loginStatus => text("Login Status", "உள்நுழைவு நிலை", "लॉगिन स्थिति");
  static String get active => text("Active", "செயலில்", "सक्रिय");
  static String get inactive => text("Inactive", "செயலில் இல்லை", "निष्क्रिय");
  static String get approved => text("Approved", "அங்கீகரிக்கப்பட்டது", "स्वीकृत");
  static String get paid => text("Paid", "செலுத்தப்பட்டது", "भुगतान किया");
  static String get pending => text("Pending", "நிலுவை", "लंबित");
  static String get unpaid => text("Unpaid", "செலுத்தப்படவில்லை", "भुगतान नहीं");
  static String get partiallyPaid => text("Partially Paid", "பகுதி செலுத்தப்பட்டது", "आंशिक भुगतान");

  static String get about => text("ABOUT", "பற்றி", "जानकारी");
  static String get appVersion => text("App Version", "செயலி பதிப்பு", "ऐप वर्जन");
  static String get on => text("On", "ஆன்", "चालू");
  static String get off => text("Off", "ஆஃப்", "बंद");
  static String get email => text("Email", "மின்னஞ்சல்", "ईमेल");

  static String get home => text("Home", "முகப்பு", "होम");
  static String get attendance => text("Attendance", "வருகை", "उपस्थिति");
  static String get fees => text("Fees", "கட்டணம்", "शुल्क");
  static String get performance => text("Performance", "செயல்திறன்", "प्रदर्शन");
  static String get schedule => text("Schedule", "அட்டவணை", "कार्यक्रम");
  static String get more => text("More", "மேலும்", "और");
  static String get students => text("Students", "மாணவர்கள்", "छात्र");
  static String get reports => text("Reports", "அறிக்கைகள்", "रिपोर्ट");
  static String get logout => text("Logout", "வெளியேறு", "लॉगआउट");

  static String get goodMorning => text("Good Morning", "காலை வணக்கம்", "सुप्रभात");
  static String get goodAfternoon => text("Good Afternoon", "மதிய வணக்கம்", "नमस्कार");
  static String get goodEvening => text("Good Evening", "மாலை வணக்கம்", "शुभ संध्या");

  static String get studentControlCenter => text("Student Control Center", "மாணவர் கட்டுப்பாட்டு மையம்", "छात्र नियंत्रण केंद्र");
  static String get studentOverview => text("STUDENT OVERVIEW", "மாணவர் விவரம்", "छात्र अवलोकन");
  static String get studentDashboard => text("STUDENT DASHBOARD", "மாணவர் டாஷ்போர்டு", "छात्र डैशबोर्ड");

  static String get parentControlCenter => text("Parent Control Center", "பெற்றோர் கட்டுப்பாட்டு மையம்", "अभिभावक नियंत्रण केंद्र");
  static String get parentOverview => text("PARENT OVERVIEW", "பெற்றோர் விவரம்", "अभिभावक अवलोकन");
  static String get parentDashboard => text("PARENT DASHBOARD", "பெற்றோர் டாஷ்போர்டு", "अभिभावक डैशबोर्ड");

  static String get coachControlCenter => text("Coach Control Center", "பயிற்சியாளர் கட்டுப்பாட்டு மையம்", "कोच नियंत्रण केंद्र");
  static String get coachOverview => text("COACH OVERVIEW", "பயிற்சியாளர் விவரம்", "कोच अवलोकन");
  static String get coachDashboard => text("COACH DASHBOARD", "பயிற்சியாளர் டாஷ்போர்டு", "कोच डैशबोर्ड");

  static String get quickActions => text("QUICK ACTIONS", "விரைவு செயல்கள்", "त्वरित कार्य");
  static String get batch => text("Batch", "பேட்ச்", "बैच");
  static String get rollNo => text("Roll No", "ரோல் எண்", "रोल नंबर");
  static String get status => text("Status", "நிலை", "स्थिति");
  static String get overall => text("Overall", "மொத்தம்", "कुल");
  static String get training => text("Training", "பயிற்சி", "प्रशिक्षण");
  static String get studentId => text("Student ID", "மாணவர் ஐடி", "छात्र आईडी");
  static String get feeStatus => text("Fee\nStatus", "கட்டண\nநிலை", "शुल्क\nस्थिति");

  static String get children => text("Children", "குழந்தைகள்", "बच्चे");
  static String get linked => text("Linked", "இணைக்கப்பட்டது", "लिंक किया गया");
  static String get child => text("Child", "குழந்தை", "बच्चा");
  static String get current => text("Current", "தற்போது", "वर्तमान");
  static String get parentAccount => text("Parent account", "பெற்றோர் கணக்கு", "अभिभावक खाता");
  static String get childOverall => text("Child overall", "குழந்தையின் மொத்தம்", "बच्चे का कुल");

  static String get assigned => text("Assigned", "ஒதுக்கப்பட்டது", "असाइन किया गया");
  static String get today => text("Today", "இன்று", "आज");
  static String get markNow => text("Mark now", "இப்போது பதிவு செய்", "अभी दर्ज करें");
  static String get session => text("Session", "அமர்வு", "सेशन");
  static String get currentWeek => text("Current Week", "தற்போதைய வாரம்", "वर्तमान सप्ताह");
  static String get loadingCurrentWeekSessions => text("Loading current week sessions...", "இந்த வார அமர்வுகள் ஏற்றப்படுகின்றன...", "वर्तमान सप्ताह के सेशन लोड हो रहे हैं...");
  static String get currentWeekAssignedSessions => text("CURRENT WEEK ASSIGNED SESSIONS", "இந்த வார ஒதுக்கப்பட்ட அமர்வுகள்", "वर्तमान सप्ताह के असाइन किए गए सेशन");
  static String get noSessionAssignedThisWeek => text("No session assigned for this week.", "இந்த வாரத்திற்கு அமர்வு ஒதுக்கப்படவில்லை.", "इस सप्ताह कोई सेशन असाइन नहीं किया गया।");

  static String get myAttendance => text("My\nAttendance", "என்\nவருகை", "मेरी\nउपस्थिति");
  static String get myPerformance => text("My\nPerformance", "என்\nசெயல்திறன்", "मेरा\nप्रदर्शन");
  static String get mySchedule => text("My\nSchedule", "என்\nஅட்டவணை", "मेरा\nकार्यक्रम");

  static String get childAttendance => text("Child\nAttendance", "குழந்தை\nவருகை", "बच्चे की\nउपस्थिति");
  static String get childPerformance => text("Child\nPerformance", "குழந்தை\nசெயல்திறன்", "बच्चे का\nप्रदर्शन");
  static String get childSchedule => text("Child\nSchedule", "குழந்தை\nஅட்டவணை", "बच्चे का\nकार्यक्रम");

  static String get markAttendance => text("Mark\nAttendance", "வருகை\nபதிவு", "उपस्थिति\nदर्ज करें");
  static String get viewStudents => text("View\nStudents", "மாணவர்களை\nபார்", "छात्र\nदेखें");
  static String get performanceReports => text("Performance\nReports", "செயல்திறன்\nஅறிக்கைகள்", "प्रदर्शन\nरिपोर्ट");
  static String get leaveRequests => text("Leave\nRequests", "விடுப்பு\nகோரிக்கைகள்", "छुट्टी\nअनुरोध");
  static String get scheduleModule => text("Schedule\nModule", "அட்டவணை\nமாட்யூல்", "कार्यक्रम\nमॉड्यूल");

  static String get academyUpdates => text("Academy\nUpdates", "அகாடமி\nஅறிவிப்புகள்", "अकादमी\nअपडेट");
}