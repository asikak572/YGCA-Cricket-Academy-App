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
  static String get switchToDark => text("Switch to Dark Mode", "டார்க் மோடுக்கு மாற்று", "डार्क मोड पर जाएं");
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

  static String get adminControlCenter => text("Admin Control Center", "அட்மின் கட்டுப்பாட்டு மையம்", "एडमिन नियंत्रण केंद्र");
  static String get academyOverview => text("ACADEMY OVERVIEW", "அகாடமி விவரம்", "अकादमी अवलोकन");
  static String get admin => text("ADMIN", "அட்மின்", "एडमिन");
  static String get adminControlDashboard => text("CONTROL DASHBOARD", "கட்டுப்பாட்டு டாஷ்போர்டு", "कंट्रोल डैशबोर्ड");
  static String get adminHeroDescription => text("Manage students, coaches,\nattendance and growth.", "மாணவர்கள், பயிற்சியாளர்கள்,\nவருகை மற்றும் வளர்ச்சியை நிர்வகிக்கவும்.", "छात्रों, कोचों,\nउपस्थिति और विकास को प्रबंधित करें।");
  static String get viewAll => text("View all", "அனைத்தையும் பார்", "सभी देखें");
  static String get totalStudents => text("Total Students", "மொத்த மாணவர்கள்", "कुल छात्र");
  static String get registeredPlayers => text("Registered players", "பதிவு செய்யப்பட்ட வீரர்கள்", "पंजीकृत खिलाड़ी");
  static String get todayAverage => text("Today average", "இன்றைய சராசரி", "आज का औसत");
  static String get pendingFees => text("Pending Fees", "நிலுவை கட்டணம்", "लंबित शुल्क");
  static String get sessions => text("Sessions", "அமர்வுகள்", "सेशन");
  static String get thisWeek => text("This week", "இந்த வாரம்", "इस सप्ताह");
  static String get studentApproval => text("Student\nApproval", "மாணவர்\nஅனுமதி", "छात्र\nस्वीकृति");
  static String get coachCenter => text("Coach\nCenter", "பயிற்சியாளர்\nமையம்", "कोच\nसेंटर");
  static String get reportsCenter => text("Reports\nCenter", "அறிக்கை\nமையம்", "रिपोर्ट\nसेंटर");
  static String get feesAndDues => text("Fees\n& Dues", "கட்டணம்\n& நிலுவை", "शुल्क\nऔर बकाया");

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

  static String get markAttendanceTitle => text("MARK ATTENDANCE", "வருகை பதிவு", "उपस्थिति दर्ज करें");
  static String get attendanceSubtitle => text("Weekly assigned session attendance", "வாராந்திர ஒதுக்கப்பட்ட அமர்வு வருகை", "साप्ताहिक असाइन किए गए सेशन की उपस्थिति");
  static String get currentWeekAssignedSession => text("Current Week Assigned Session", "இந்த வார ஒதுக்கப்பட்ட அமர்வு", "वर्तमान सप्ताह का असाइन किया गया सेशन");
  static String get selectTrainingSession => text("Select Training Session", "பயிற்சி அமர்வை தேர்வு செய்க", "प्रशिक्षण सेशन चुनें");
  static String get refresh => text("Refresh", "புதுப்பிக்க", "रीफ़्रेश");
  static String get noSessionAssigned => text("No Session Assigned", "அமர்வு ஒதுக்கப்படவில்லை", "कोई सेशन असाइन नहीं");
  static String get noAccess => text("No Access", "அணுகல் இல்லை", "कोई पहुँच नहीं");
  static String get noAccessMessage => text("Only Admin and assigned Coach can mark attendance.", "நிர்வாகியும் ஒதுக்கப்பட்ட பயிற்சியாளரும் மட்டுமே வருகையை பதிவு செய்ய முடியும்.", "केवल एडमिन और असाइन किए गए कोच ही उपस्थिति दर्ज कर सकते हैं।");
  static String get noStudentsFound => text("No students found", "மாணவர்கள் இல்லை", "कोई छात्र नहीं मिला");
  static String get present => text("Present", "வருகை", "उपस्थित");
  static String get absent => text("Absent", "வரவில்லை", "अनुपस्थित");
  static String get currentAttendance => text("Current", "தற்போது", "वर्तमान");
  static String get saveAttendanceButton => text("SAVE ATTENDANCE", "வருகையை சேமிக்க", "उपस्थिति सहेजें");
  static String get attendanceSaved => text("Attendance saved successfully", "வருகை வெற்றிகரமாக சேமிக்கப்பட்டது", "उपस्थिति सफलतापूर्वक सहेजी गई");
  static String get errorSavingAttendance => text("Error saving attendance", "வருகையை சேமிப்பதில் பிழை", "उपस्थिति सहेजने में त्रुटि");
  static String get noAssignedSessionFound => text("No assigned session found", "ஒதுக்கப்பட்ட அமர்வு இல்லை", "कोई असाइन किया गया सेशन नहीं मिला");
  static String get noStudentsInSession => text("No students found in this session", "இந்த அமர்வில் மாணவர்கள் இல்லை", "इस सेशन में कोई छात्र नहीं मिला");
  static String get loadingUserAccess => text("Loading user access...", "பயனர் அணுகல் ஏற்றப்படுகிறது...", "उपयोगकर्ता पहुँच लोड हो रही है");

  static String get attendanceModule => text("Attendance Module", "வருகை மாட்யூல்", "उपस्थिति मॉड्यूल");
  static String get attendanceMain => text("Attendance Main", "வருகை முதன்மை", "उपस्थिति मुख्य");
  static String get sessionManagement => text("Session Management", "அமர்வு மேலாண்மை", "सेशन प्रबंधन");
  static String get attendanceReports => text("Attendance Reports", "வருகை அறிக்கைகள்", "उपस्थिति रिपोर्ट");
  static String get markAttendanceViewCalendarHistory => text("Mark attendance, view calendar and history", "வருகையை பதிவு செய்க, காலண்டர் மற்றும் வரலாற்றைப் பாருங்கள்", "उपस्थिति दर्ज करें, कैलेंडर और इतिहास देखें");
  static String get manageLeaveCancelledMakeup => text("Manage leave, cancelled sessions and makeup sessions", "விடுப்பு, ரத்து செய்யப்பட்ட அமர்வுகள் மற்றும் மேக்கப் அமர்வுகளை நிர்வகிக்கவும்", "छुट्टी, रद्द सेशन और मेकअप सेशन प्रबंधित करें");
  static String get viewAttendanceReportsAnalytics => text("View attendance reports, summaries and analytics", "வருகை அறிக்கைகள், சுருக்கங்கள் மற்றும் பகுப்பாய்வுகளைப் பாருங்கள்", "उपस्थिति रिपोर्ट, सारांश और विश्लेषण देखें");
  static String get attendanceCalendar => text("Attendance Calendar", "வருகை காலண்டர்", "उपस्थिति कैलेंडर");
  static String get attendanceHistory => text("Attendance History", "வருகை வரலாறு", "उपस्थिति इतिहास");
  static String get takeDailySessionAttendance => text("Take daily session attendance", "தினசரி அமர்வு வருகையை பதிவு செய்க", "दैनिक सेशन उपस्थिति दर्ज करें");
  static String get studentWiseCalendarView => text("Student-wise calendar view", "மாணவர் வாரியான காலண்டர் பார்வை", "छात्र-वार कैलेंडर दृश्य");
  static String get viewPastAttendanceRecords => text("View past attendance records", "முந்தைய வருகை பதிவுகளைப் பாருங்கள்", "पिछले उपस्थिति रिकॉर्ड देखें");
  static String get leaveRequestsSingleLine => text("Leave Requests", "விடுப்பு கோரிக்கைகள்", "छुट्टी अनुरोध");
  static String get approveManageLeaveRequests => text("Approve and manage student leave requests", "மாணவர் விடுப்பு கோரிக்கைகளை அங்கீகரித்து நிர்வகிக்கவும்", "छात्र छुट्टी अनुरोधों को स्वीकृत और प्रबंधित करें");
  static String get cancelSession => text("Cancel Session", "அமர்வை ரத்து செய்க", "सेशन रद्द करें");
  static String get cancelUpdateClassSessions => text("Cancel or update class sessions", "வகுப்பு அமர்வுகளை ரத்து செய்க அல்லது புதுப்பிக்கவும்", "कक्षा सेशन रद्द या अपडेट करें");
  static String get makeupSessions => text("Makeup Sessions", "மேக்கப் அமர்வுகள்", "मेकअप सेशन");
  static String get compensateMissedSessions => text("Compensate missed or cancelled sessions", "தவறிய அல்லது ரத்து செய்யப்பட்ட அமர்வுகளை ஈடு செய்க", "छूटे या रद्द सेशन की भरपाई करें");
  static String get viewAttendanceSummaryAnalytics => text("View attendance summary and analytics", "வருகை சுருக்கம் மற்றும் பகுப்பாய்வைப் பாருங்கள்", "उपस्थिति सारांश और विश्लेषण देखें");
  static String get monthlySummary => text("Monthly Summary", "மாதாந்திர சுருக்கம்", "मासिक सारांश");
  static String get viewMonthlySummary => text("View monthly present, absent and leave summary", "மாதாந்திர வருகை, வரவில்லை மற்றும் விடுப்பு சுருக்கத்தைப் பாருங்கள்", "मासिक उपस्थित, अनुपस्थित और छुट्टी सारांश देखें");
  static String get studentAnalytics => text("Student Analytics", "மாணவர் பகுப்பாய்வு", "छात्र विश्लेषण");
  static String get checkStudentAnalytics => text("Check student-wise attendance analytics", "மாணவர் வாரியான வருகை பகுப்பாய்வைப் பாருங்கள்", "छात्र-वार उपस्थिति विश्लेषण देखें");
  static String get leave => text("Leave", "விடுப்பு", "छुट्टी");
  static String get history => text("History", "வரலாறு", "इतिहास");
  static String get cancel => text("Cancel", "ரத்து", "रद्द");
  static String get makeup => text("Makeup", "மேக்கப்", "मेकअप");
  static String get live => text("Live", "நேரலை", "लाइव");
  static String get reportsTab => text("Reports", "அறிக்கைகள்", "रिपोर्ट");
  static String get month => text("Month", "மாதம்", "माह");
  static String get view => text("View", "பார்", "देखें");
  static String get avg => text("Avg", "சராசரி", "औसत");
  static String get main => text("Main", "முதன்மை", "मुख्य");
  static String get all => text("All", "அனைத்தும்", "सभी");
  static String get attendanceSummary =>
    text("ATTENDANCE SUMMARY", "வருகை சுருக்கம்", "उपस्थिति सारांश");

static String get totalDays =>
    text("TOTAL DAYS", "மொத்த நாட்கள்", "कुल दिन");

static String get recentRecords =>
    text("RECENT RECORDS", "சமீபத்திய பதிவுகள்", "हाल के रिकॉर्ड");

static String get noDate =>
    text("No Date", "தேதி இல்லை", "कोई तारीख नहीं");

static String get error =>
    text("Error", "பிழை", "त्रुटि");

static String get unknownStudent =>
    text("Unknown Student", "தெரியாத மாணவர்", "अज्ञात छात्र");

static String get unknownBatch =>
    text("Unknown Batch", "தெரியாத பேட்ச்", "अज्ञात बैच");

static String get noApprovedAssignedStudents => text(
    "No approved or assigned students are available for this account.",
    "இந்த கணக்கிற்கு அங்கீகரிக்கப்பட்ட அல்லது ஒதுக்கப்பட்ட மாணவர்கள் இல்லை.",
    "इस खाते के लिए कोई स्वीकृत या असाइन छात्र उपलब्ध नहीं है।");

static String get selectStudent =>
    text("Select Student", "மாணவரை தேர்வு செய்க", "छात्र चुनें");

static String get unnamedStudent =>
    text("Unnamed Student", "பெயரிடப்படாத மாணவர்", "बिना नाम का छात्र");

static String get student =>
    text("Student", "மாணவர்", "छात्र");

static String get noBatch =>
    text("No Batch", "பேட்ச் இல்லை", "कोई बैच नहीं");

static String get historyDashboard =>
    text("History Dashboard", "வரலாறு டாஷ்போர்டு", "इतिहास डैशबोर्ड");

static String get noAttendanceRecordsFound => text(
    "No attendance records found for this student.",
    "இந்த மாணவருக்கு வருகை பதிவுகள் இல்லை.",
    "इस छात्र के लिए कोई उपस्थिति रिकॉर्ड नहीं मिला।");

static String get total =>
    text("Total", "மொத்தம்", "कुल");
static String get studentWiseMonthlyView =>
    text("Student-wise monthly view", "மாணவர் வாரியான மாத பார்வை", "छात्र-वार मासिक दृश्य");

static String get firebaseAttendance =>
    text("Firebase Attendance", "Firebase வருகை", "Firebase उपस्थिति");

static String get studentWiseAttendanceCalendar =>
    text("Student-wise attendance calendar", "மாணவர் வாரியான வருகை காலண்டர்", "छात्र-वार उपस्थिति कैलेंडर");

static String get percent =>
    text("Percent", "சதவீதம்", "प्रतिशत");

static String get noRecord =>
    text("No Record", "பதிவு இல்லை", "कोई रिकॉर्ड नहीं");

static String get calendarCurrentMonthNote => text(
    "Calendar shows current month attendance for the selected student.",
    "தேர்ந்தெடுக்கப்பட்ட மாணவரின் நடப்பு மாத வருகையை காலண்டர் காட்டுகிறது.",
    "कैलेंडर चयनित छात्र की वर्तमान माह की उपस्थिति दिखाता है।");


}
