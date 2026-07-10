import '../../theme/theme_controller.dart';

class AppStrings {
  AppStrings._();

  static String get lang => ThemeController.language.value;

  static String text(String en, String ta, String hi) {
    if (lang == "தமிழ்") return ta;
    if (lang == "हिन्दी") return hi;
    return en;
  }

  // ================= SETTINGS =================
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
  static String get about => text("ABOUT", "பற்றி", "जानकारी");
  static String get appVersion => text("App Version", "செயலி பதிப்பு", "ऐप वर्जन");
  static String get on => text("On", "ஆன்", "चालू");
  static String get off => text("Off", "ஆஃப்", "बंद");

  // ================= COMMON =================
  static String get active => text("Active", "செயலில்", "सक्रिय");
  static String get inactive => text("Inactive", "செயலில் இல்லை", "निष्क्रिय");
  static String get approved => text("Approved", "அங்கீகரிக்கப்பட்டது", "स्वीकृत");
  static String get pending => text("Pending", "நிலுவை", "लंबित");
  static String get rejected => text("Rejected", "நிராகரிக்கப்பட்டது", "अस्वीकृत");
  static String get paid => text("Paid", "செலுத்தப்பட்டது", "भुगतान किया");
  static String get unpaid => text("Unpaid", "செலுத்தப்படவில்லை", "भुगतान नहीं");
  static String get partiallyPaid => text("Partially Paid", "பகுதி செலுத்தப்பட்டது", "आंशिक भुगतान");
  static String get email => text("Email", "மின்னஞ்சல்", "ईमेल");
  static String get phone => text("Phone", "தொலைபேசி", "फोन");
  static String get parent => text("Parent", "பெற்றோர்", "अभिभावक");
  static String get student => text("Student", "மாணவர்", "छात्र");
  static String get students => text("Students", "மாணவர்கள்", "छात्र");
  static String get batch => text("Batch", "பேட்ச்", "बैच");
  static String get rollNo => text("Roll No", "ரோல் எண்", "रोल नंबर");
  static String get status => text("Status", "நிலை", "स्थिति");
  static String get total => text("Total", "மொத்தம்", "कुल");
  static String get average => text("Average", "சராசரி", "औसत");
  static String get all => text("All", "அனைத்தும்", "सभी");
  static String get view => text("View", "பார்", "देखें");
  static String get save => text("Save", "சேமி", "सेव");
  static String get saving => text("Saving...", "சேமிக்கிறது...", "सहेजा जा रहा है...");
  static String get cancel => text("Cancel", "ரத்து", "रद्द");
  static String get delete => text("Delete", "நீக்கு", "हटाएं");
  static String get edit => text("Edit", "திருத்து", "संपாதित करें");
  static String get update => text("Update", "புதுப்பி", "अपडेट");
  static String get error => text("Error", "பிழை", "त्रुटि");
  static String get somethingWentWrong => text("Something went wrong", "ஏதோ தவறு ஏற்பட்டது", "कुछ गलत हुआ");
  static String get noName => text("No Name", "பெயர் இல்லை", "कोई नाम नहीं");
  static String get notAdded => text("Not Added", "சேர்க்கப்படவில்லை", "जोड़ा नहीं गया");
  static String get noBatch => text("No Batch", "பேட்ச் இல்லை", "कोई बैच नहीं");
  static String get noStudentsFound => text("No students found", "மாணவர்கள் இல்லை", "कोई छात्र नहीं मिला");
  static String get noApprovedAssignedStudents => text("No approved or assigned students are available for this account.", "இந்த கணக்கிற்கு அங்கீகரிக்கப்பட்ட அல்லது ஒதுக்கப்பட்ட மாணவர்கள் இல்லை.", "इस खाते के लिए कोई स्वीकृत या असाइन छात्र उपलब्ध नहीं है।");

  // ================= NAVIGATION =================
  static String get home => text("Home", "முகப்பு", "होम");
  static String get attendance => text("Attendance", "வருகை", "उपस्थिति");
  static String get fees => text("Fees", "கட்டணம்", "शुल्क");
  static String get performance => text("Performance", "செயல்திறன்", "प्रदर्शन");
  static String get schedule => text("Schedule", "அட்டவணை", "कार्यक्रम");
  static String get more => text("More", "மேலும்", "और");
  static String get reports => text("Reports", "அறிக்கைகள்", "रिपोर्ट");
  static String get reportsTab => text("Reports", "அறிக்கைகள்", "रिपोर्ट");
  static String get logout => text("Logout", "வெளியேறு", "लॉगआउट");
  static String get main => text("Main", "முதன்மை", "मुख्य");

  // ================= DASHBOARDS =================
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
  static String get sessions => text("Sessions", "அமர்வுகள்", "सेशन");
  static String get thisWeek => text("This week", "இந்த வாரம்", "इस सप्ताह");
  static String get studentApproval => text("Student\nApproval", "மாணவர்\nஅனுமதி", "छात्र\nस्वीकृति");
  static String get coachCenter => text("Coach\nCenter", "பயிற்சியாளர்\nமையம்", "कोच\nसेंटर");
  static String get reportsCenter => text("Reports\nCenter", "அறிக்கை\nமையம்", "रिपोर्ट\nसेंटर");
  static String get feesAndDues => text("Fees\n& Dues", "கட்டணம்\n& நிலுவை", "शुल्क\nऔर बकाया");

  static String get quickActions => text("QUICK ACTIONS", "விரைவு செயல்கள்", "त्वरित कार्य");
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

  // ================= STUDENT LIST =================
  static String get studentCenter => text("STUDENT CENTER", "மாணவர் மையம்", "छात्र केंद्र");
  static String get approvalStudentManagement => text("Approval & student management", "அனுமதி & மாணவர் மேலாண்மை", "स्वीकृति और छात्र प्रबंधन");
  static String get approval => text("Approval", "அனுமதி", "स्वीकृति");
  static String get registered => text("Registered", "பதிவு", "पंजीकृत");
  static String get activePlayers => text("Active Players", "செயலில் உள்ள வீரர்கள்", "सक्रिय खिलाड़ी");
  static String get approvals => text("Approvals", "அனுமதிகள்", "स्वीकृतियाँ");
  static String get searchStudent => text("SEARCH STUDENT", "மாணவரை தேடு", "छात्र खोजें");
  static String get searchStudentHint => text("Search name, phone, parent, batch, roll no", "பெயர், போன், பெற்றோர், பேட்ச், ரோல் எண் தேடு", "नाम, फोन, अभिभावक, बैच, रोल नंबर खोजें");
  static String get pendingApproval => text("PENDING APPROVAL", "நிலுவை அனுமதி", "लंबित स्वीकृति");
  static String get noPendingApprovals => text("No Pending Approvals", "நிலுவை அனுமதிகள் இல்லை", "कोई लंबित स्वीकृति नहीं");
  static String get newStudentsAppearForApproval => text("Newly registered students will appear here for approval.", "புதியதாக பதிவு செய்யப்பட்ட மாணவர்கள் அனுமதிக்காக இங்கே தோன்றுவர்.", "नए पंजीकृत छात्र स्वीकृति के लिए यहाँ दिखाई देंगे।");
  static String get approvedStudents => text("APPROVED STUDENTS", "அங்கீகரிக்கப்பட்ட மாணவர்கள்", "स्वीकृत छात्र");
  static String get noApprovedStudentsFound => text("No Approved Students Found", "அங்கீகரிக்கப்பட்ட மாணவர்கள் இல்லை", "कोई स्वीकृत छात्र नहीं मिला");
  static String get approvedStudentsAppearHere => text("Approved students will appear here after assigning batch and roll number.", "பேட்ச் மற்றும் ரோல் எண் ஒதுக்கிய பிறகு அங்கீகரிக்கப்பட்ட மாணவர்கள் இங்கே தோன்றுவர்.", "बैच और रोल नंबर असाइन करने के बाद स्वीकृत छात्र यहाँ दिखाई देंगे।");
  static String get addStudent => text("Add Student", "மாணவரை சேர்", "छात्र जोड़ें");
  static String get approveStudent => text("Approve Student", "மாணவரை அங்கீகரி", "छात्र स्वीकृत करें");
  static String get studentName => text("Student Name", "மாணவர் பெயர்", "छात्र का नाम");
  static String get parentEmail => text("Parent Email", "பெற்றோர் மின்னஞ்சல்", "अभिभावक ईमेल");
  static String get rollNoAutoGenerated => text("Roll No will be generated automatically after approval", "அனுமதித்த பிறகு ரோல் எண் தானாக உருவாகும்", "स्वीकृति के बाद रोल नंबर अपने आप बनेगा");
  static String get sessionBatch => text("Session Batch", "அமர்வு பேட்ச்", "सेशन बैच");
  static String get studentApprovedParentLinked => text("Student approved and parent linked if parent account exists", "மாணவர் அங்கீகரிக்கப்பட்டார்; பெற்றோர் கணக்கு இருந்தால் இணைக்கப்பட்டது", "छात्र स्वीकृत हुआ और अभिभावक खाता मौजूद होने पर लिंक हुआ");
  static String get approvalFailed => text("Approval failed", "அனுமதி தோல்வியடைந்தது", "स्वीकृति विफल");
  static String get approve => text("Approve", "அங்கீகரி", "स्वीकृत करें");
  static String get rejectStudentQuestion => text("Reject Student?", "மாணவரை நிராகரிக்கவா?", "छात्र अस्वीकार करें?");
  static String get rejectStudentMessage => text("This student will be marked as rejected and will not appear in the active student list.", "இந்த மாணவர் நிராகரிக்கப்பட்டவராக குறிக்கப்படுவார் மற்றும் செயலில் உள்ள மாணவர் பட்டியலில் தோன்ற மாட்டார்.", "यह छात्र अस्वीकृत चिह्नित होगा और सक्रिय छात्र सूची में दिखाई नहीं देगा।");
  static String get reject => text("Reject", "நிராகரி", "अस्वीकार");
  static String get studentRejected => text("Student rejected", "மாணவர் நிராகரிக்கப்பட்டார்", "छात्र अस्वीकृत");
  static String get rejectFailed => text("Reject failed", "நிராகரிப்பு தோல்வியடைந்தது", "अस्वीकार विफल");
  static String get recently => text("Recently", "சமீபத்தில்", "हाल ही में");

  // ================= STUDENT DETAILS / ADD STUDENT =================
  static String get studentPhotoUploaded => text("Student photo uploaded", "மாணவர் புகைப்படம் பதிவேற்றப்பட்டது", "छात्र फोटो अपलोड हुआ");
  static String get photoUploadFailed => text("Photo upload failed", "புகைப்பட பதிவேற்றம் தோல்வியடைந்தது", "फोटो अपलोड विफल");
  static String get studentDeletedSuccessfully => text("Student deleted successfully", "மாணவர் வெற்றிகரமாக நீக்கப்பட்டார்", "छात्र सफलतापूर्वक हटाया गया");
  static String get deleteFailed => text("Delete failed", "நீக்கம் தோல்வியடைந்தது", "हटाना विफल");
  static String get studentUpdatedSuccessfully => text("Student updated successfully", "மாணவர் விவரம் புதுப்பிக்கப்பட்டது", "छात्र सफलतापूर्वक अपडेट हुआ");
  static String get updateFailed => text("Update failed", "புதுப்பிப்பு தோல்வியடைந்தது", "अपडेट विफल");
  static String get deleteStudent => text("Delete Student", "மாணவரை நீக்கு", "छात्र हटाएं");
  static String get deleteStudentConfirm => text("Are you sure you want to delete", "நீங்கள் நிச்சயமாக நீக்க விரும்புகிறீர்களா", "क्या आप वाकई हटाना चाहते हैं");
  static String get editStudent => text("Edit Student", "மாணவரை திருத்து", "छात्र संपादित करें");
  static String get age => text("Age", "வயது", "आयु");
  static String get parentName => text("Parent Name", "பெற்றோர் பெயர்", "अभिभावक का नाम");
  static String get phoneNumber => text("Phone Number", "தொலைபேசி எண்", "फोन नंबर");
  static String get studentNotFound => text("Student not found", "மாணவர் கிடைக்கவில்லை", "छात्र नहीं मिला");
  static String get studentInformation => text("STUDENT INFORMATION", "மாணவர் தகவல்", "छात्र जानकारी");
  static String get fullName => text("Full Name", "முழு பெயர்", "पूरा नाम");
  static String get years => text("Years", "ஆண்டுகள்", "वर्ष");
  static String get calendar => text("Calendar", "காலண்டர்", "कैलेंडर");
  static String get idCard => text("ID Card", "ஐடி கார்டு", "आईडी कार्ड");
  static String get photo => text("Photo", "புகைப்படம்", "फोटो");
  static String get change => text("Change", "மாற்று", "बदलें");
  static String get studentDetailsTitle => text("STUDENT DETAILS", "மாணவர் விவரங்கள்", "छात्र विवरण");
  static String get profileAttendanceIdCard => text("Profile • Attendance • ID Card", "சுயவிவரம் • வருகை • ஐடி கார்டு", "प्रोफाइल • उपस्थिति • आईडी कार्ड");
  static String get ygcaStudent => text("YGCA STUDENT", "YGCA மாணவர்", "YGCA छात्र");
  static String get uploadPhoto => text("Upload Photo", "புகைப்படம் பதிவேற்று", "फोटो अपलोड करें");
  static String get changePhoto => text("Change Photo", "புகைப்படம் மாற்று", "फोटो बदलें");
  static String get fee => text("Fee", "கட்டணம்", "शुल्क");
  static String get studentProgress => text("Student Progress", "மாணவர் முன்னேற்றம்", "छात्र प्रगति");
  static String get good => text("GOOD", "நன்று", "अच्छा");
  static String get focus => text("FOCUS", "கவனம்", "ध्यान");
  static String get studentSavedSuccessfully => text("Student saved successfully", "மாணவர் வெற்றிகரமாக சேமிக்கப்பட்டார்", "छात्र सफलतापूर्वक सेव हुआ");
  static String get errorSavingStudent => text("Error saving student", "மாணவரை சேமிப்பதில் பிழை", "छात्र सेव करने में त्रुटि");
  static String get enterStudentName => text("Enter student name", "மாணவர் பெயரை உள்ளிடவும்", "छात्र का नाम दर्ज करें");
  static String get enterAge => text("Enter age", "வயதை உள்ளிடவும்", "आयु दर्ज करें");
  static String get enterPhoneNumber => text("Enter phone number", "தொலைபேசி எண்ணை உள்ளிடவும்", "फोन नंबर दर्ज करें");
  static String get studentEmail => text("Student Email", "மாணவர் மின்னஞ்சல்", "छात्र ईमेल");
  static String get parentGuardian => text("PARENT / GUARDIAN", "பெற்றோர் / பாதுகாவலர்", "अभिभावक / संरक्षक");
  static String get parentPhone => text("Parent Phone", "பெற்றோர் தொலைபேசி", "अभिभावक फोन");
  static String get aadhaarNumber => text("Aadhaar Number", "ஆதார் எண்", "आधार नंबर");
  static String get address => text("Address", "முகவரி", "पता");
  static String get addStudentTitle => text("ADD STUDENT", "மாணவரை சேர்", "छात्र जोड़ें");
  static String get createNewAcademyPlayerProfile => text("Create new academy player profile", "புதிய அகாடமி வீரர் சுயவிவரத்தை உருவாக்கவும்", "नई अकादमी खिलाड़ी प्रोफाइल बनाएं");
  static String get newPlayer => text("NEW PLAYER", "புதிய வீரர்", "नया खिलाड़ी");
  static String get registration => text("Registration", "பதிவு", "पंजीकरण");
  static String get autoRollNo => text("Auto Roll No", "தானியங்கி ரோல் எண்", "ऑटो रोल नंबर");
  static String get parentLink => text("Parent Link", "பெற்றோர் இணைப்பு", "अभिभावक लिंक");
  static String get approvedProfile => text("Approved Profile", "அங்கீகரிக்கப்பட்ட சுயவிவரம்", "स्वीकृत प्रोफाइल");
  static String get saveStudent => text("SAVE STUDENT", "மாணவரை சேமிக்க", "छात्र सेव करें");

  // ================= ATTENDANCE =================
  static String get markAttendanceTitle => text("MARK ATTENDANCE", "வருகை பதிவு", "उपस्थिति दर्ज करें");
  static String get attendanceSubtitle => text("Weekly assigned session attendance", "வாராந்திர ஒதுக்கப்பட்ட அமர்வு வருகை", "साप्ताहिक असाइन किए गए सेशन की उपस्थिति");
  static String get currentWeekAssignedSession => text("Current Week Assigned Session", "இந்த வார ஒதுக்கப்பட்ட அமர்வு", "वर्तमान सप्ताह का असाइन किया गया सेशन");
  static String get selectTrainingSession => text("Select Training Session", "பயிற்சி அமர்வை தேர்வு செய்க", "प्रशिक्षण सेशन चुनें");
  static String get refresh => text("Refresh", "புதுப்பிக்க", "रीफ़्रेश");
  static String get noAssignedSessionFound => text("No assigned session found", "ஒதுக்கப்பட்ட அமர்வு இல்லை", "कोई असाइन किया गया सेशन नहीं मिला");
  static String get noStudentsInSession => text("No students found in this session", "இந்த அமர்வில் மாணவர்கள் இல்லை", "इस सेशन में कोई छात्र नहीं मिला");
  static String get attendanceSaved => text("Attendance saved successfully", "வருகை வெற்றிகரமாக சேமிக்கப்பட்டது", "उपस्थिति सफलतापूर्वक सहेजी गई");
  static String get errorSavingAttendance => text("Error saving attendance", "வருகையை சேமிப்பதில் பிழை", "उपस्थिति सहेजने में त्रुटि");
  static String get noSessionAssigned => text("No Session Assigned", "அமர்வு ஒதுக்கப்படவில்லை", "कोई सेशन असाइन नहीं");
  static String get noAccess => text("No Access", "அணுகல் இல்லை", "कोई पहुँच नहीं");
  static String get noAccessMessage => text("Only Admin and assigned Coach can mark attendance.", "நிர்வாகியும் ஒதுக்கப்பட்ட பயிற்சியாளரும் மட்டுமே வருகையை பதிவு செய்ய முடியும்.", "केवल एडमिन और असाइन किए गए कोच ही उपस्थिति दर्ज कर सकते हैं।");
  static String get present => text("Present", "வருகை", "उपस्थित");
  static String get absent => text("Absent", "வரவில்லை", "अनुपस्थित");
  static String get currentAttendance => text("Current", "தற்போது", "वर्तमान");
  static String get saveAttendanceButton => text("SAVE ATTENDANCE", "வருகையை சேமிக்க", "उपस्थिति सहेजें");

  static String get attendanceCalendar => text("Attendance Calendar", "வருகை காலண்டர்", "उपस्थिति कैलेंडर");
  static String get studentWiseMonthlyView => text("Student-wise monthly view", "மாணவர் வாரியான மாத பார்வை", "छात्र-वार मासिक दृश्य");
  static String get selectStudent => text("Select Student", "மாணவரை தேர்வு செய்க", "छात्र चुनें");
  static String get unnamedStudent => text("Unnamed Student", "பெயரிடப்படாத மாணவர்", "बिना नाम का छात्र");
  static String get firebaseAttendance => text("Firebase Attendance", "Firebase வருகை", "Firebase उपस्थिति");
  static String get studentWiseAttendanceCalendar => text("Student-wise attendance calendar", "மாணவர் வாரியான வருகை காலண்டர்", "छात्र-वार उपस्थिति कैलेंडर");
  static String get leave => text("Leave", "விடுப்பு", "छुट्टी");
  static String get percent => text("Percent", "சதவீதம்", "प्रतिशत");
  static String get noRecord => text("No Record", "பதிவு இல்லை", "कोई रिकॉर्ड नहीं");
  static String get calendarCurrentMonthNote => text("Calendar shows current month attendance for the selected student.", "தேர்ந்தெடுக்கப்பட்ட மாணவரின் நடப்பு மாத வருகையை காலண்டர் காட்டுகிறது.", "कैलेंडर चयनित छात्र की वर्तमान माह की उपस्थिति दिखाता है।");

  static String get noDate => text("No Date", "தேதி இல்லை", "कोई तारीख नहीं");
  static String get attendanceSummary => text("ATTENDANCE SUMMARY", "வருகை சுருக்கம்", "उपस्थिति सारांश");
  static String get totalDays => text("TOTAL DAYS", "மொத்த நாட்கள்", "कुल दिन");
  static String get recentRecords => text("RECENT RECORDS", "சமீபத்திய பதிவுகள்", "हाल के रिकॉर्ड");
  static String get unknownStudent => text("Unknown Student", "தெரியாத மாணவர்", "अज्ञात छात्र");
  static String get unknownBatch => text("Unknown Batch", "தெரியாத பேட்ச்", "अज्ञात बैच");
  static String get historyDashboard => text("History Dashboard", "வரலாறு டாஷ்போர்டு", "इतिहास डैशबोर्ड");
  static String get history => text("History", "வரலாறு", "इतिहास");
  static String get noAttendanceRecordsFound => text("No attendance records found for this student.", "இந்த மாணவருக்கு வருகை பதிவுகள் இல்லை.", "इस छात्र के लिए कोई उपस्थिति रिकॉर्ड नहीं मिला।");

  static String get attendanceMain => text("Attendance Main", "வருகை முதன்மை", "उपस्थिति मुख्य");
  static String get sessionManagement => text("Session Management", "அமர்வு மேலாண்மை", "सेशन प्रबंधन");
  static String get attendanceReports => text("Attendance Reports", "வருகை அறிக்கைகள்", "उपस्थिति रिपोर्ट");
  static String get attendanceModule => text("Attendance Module", "வருகை மாட்யூல்", "उपस्थिति मॉड्यूल");
  static String get markAttendanceViewCalendarHistory => text("Mark attendance, view calendar and history", "வருகையை பதிவு செய்க, காலண்டர் மற்றும் வரலாற்றைப் பாருங்கள்", "उपस्थिति दर्ज करें, कैलेंडर और इतिहास देखें");
  static String get manageLeaveCancelledMakeup => text("Manage leave, cancelled sessions and makeup sessions", "விடுப்பு, ரத்து செய்யப்பட்ட அமர்வுகள் மற்றும் மேக்கப் அமர்வுகளை நிர்வகிக்கவும்", "छुट्टी, रद्द सेशन और मेकअप सेशन प्रबंधित करें");
  static String get viewAttendanceReportsAnalytics => text("View attendance reports, summaries and analytics", "வருகை அறிக்கைகள், சுருக்கங்கள் மற்றும் பகுப்பாய்வுகளைப் பாருங்கள்", "उपस्थिति रिपोर्ट, सारांश और विश्लेषण देखें");
  static String get takeDailySessionAttendance => text("Take daily session attendance", "தினசரி அமர்வு வருகையை பதிவு செய்க", "दैनिक सेशन उपस्थिति दर्ज करें");
  static String get studentWiseCalendarView => text("Student-wise calendar view", "மாணவர் வாரியான காலண்டர் பார்வை", "छात्र-वार कैलेंडर दृश्य");
  static String get viewPastAttendanceRecords => text("View past attendance records", "முந்தைய வருகை பதிவுகளைப் பாருங்கள்", "पिछले उपस्थिति रिकॉर्ड देखें");
  static String get leaveRequestsSingleLine => text("Leave Requests", "விடுப்பு கோரிக்கைகள்", "छुट्टी अनुरोध");
  static String get approveManageLeaveRequests => text("Approve and manage student leave requests", "மாணவர் விடுப்பு கோரிக்கைகளை அங்கீகரித்து நிர்வகிக்கவும்", "छात्र छुट्टी अनुरोधों को स्वीकृत और प्रबंधित करें");
  static String get cancelSession => text("Cancel Session", "அமர்வை ரத்து செய்க", "सेशन रद्द करें");
  static String get cancelUpdateClassSessions => text("Cancel or update class sessions", "வகுப்பு அமர்வுகளை ரத்து செய்க அல்லது புதுப்பிக்கவும்", "कक्षा सेशन रद्द या अपडेट करें");
  static String get makeupSessions => text("Makeup Sessions", "மேக்கப் அமர்வுகள்", "मेकअप सेशन");
  static String get compensateMissedSessions => text("Compensate missed or cancelled sessions", "தவறிய அல்லது ரத்து செய்யப்பட்ட அமர்வுகளை ஈடு செய்க", "छूटे या रद्द सेशन की भरपाई करें");
  static String get monthlySummary => text("Monthly Summary", "மாதாந்திர சுருக்கம்", "मासिक सारांश");
  static String get viewMonthlySummary => text("View monthly present, absent and leave summary", "மாதாந்திர வருகை, வரவில்லை மற்றும் விடுப்பு சுருக்கத்தைப் பாருங்கள்", "मासिक उपस्थित, अनुपस्थित और छुट्टी सारांश देखें");
  static String get studentAnalytics => text("Student Analytics", "மாணவர் பகுப்பாய்வு", "छात्र विश्लेषण");
  static String get checkStudentAnalytics => text("Check student-wise attendance analytics", "மாணவர் வாரியான வருகை பகுப்பாய்வைப் பாருங்கள்", "छात्र-वार उपस्थिति विश्लेषण देखें");
  static String get makeup => text("Makeup", "மேக்கப்", "मेकअप");
  static String get live => text("Live", "நேரலை", "लाइव");
  static String get month => text("Month", "மாதம்", "माह");
  static String get avg => text("Avg", "சராசரி", "औसत");
  static String get attendanceHistory => text("Attendance History", "வருகை வரலாறு", "उपस्थिति इतिहास");
  static String get viewAttendanceSummaryAnalytics => text("View attendance summary and analytics", "வருகை சுருக்கம் மற்றும் பகுப்பாய்வைப் பாருங்கள்", "उपस्थिति सारांश और विश्लेषण देखें");

  // ================= FEES =================
  static String get addFeePayment => text("Add Fee Payment", "கட்டணப் பதிவை சேர்", "फीस भुगतान जोड़ें");
  static String get totalFee => text("Total Fee", "மொத்த கட்டணம்", "कुल फीस");
  static String get paidAmount => text("Paid Amount", "செலுத்திய தொகை", "भुगतान राशि");
  static String get pleaseSelectStudent => text("Please select a student", "மாணவரை தேர்வு செய்யவும்", "कृपया छात्र चुनें");
  static String get enterValidTotalFee => text("Please enter valid total fee", "சரியான மொத்த கட்டணத்தை உள்ளிடவும்", "कृपया मान्य कुल फीस दर्ज करें");
  static String get enterValidPaidAmount => text("Please enter valid paid amount", "சரியான செலுத்திய தொகையை உள்ளிடவும்", "कृपया मान्य भुगतान राशि दर्ज करें");
  static String get feePaymentSaved => text("Fee payment saved", "கட்டணப் பதிவு சேமிக்கப்பட்டது", "फीस भुगतान सेव हुआ");
  static String get saveFailed => text("Save failed", "சேமிப்பு தோல்வியடைந்தது", "सेव विफल");
  static String get addPayment => text("Add Payment", "கட்டணம் சேர்", "भुगतान जोड़ें");
  static String get feeRecords => text("FEE RECORDS", "கட்டண பதிவுகள்", "फीस रिकॉर्ड");
  static String get feeManagementTitle => text("FEE MANAGEMENT", "கட்டண மேலாண்மை", "फीस प्रबंधन");
  static String get collectManageStudentFees => text("Collect and manage student fees", "மாணவர் கட்டணங்களை வசூலித்து நிர்வகிக்கவும்", "छात्र फीस जमा और प्रबंधित करें");
  static String get viewFeePaymentRecords => text("View fee payment records", "கட்டணப் பதிவுகளைப் பாருங்கள்", "फीस भुगतान रिकॉर्ड देखें");
  static String get totalCollection => text("TOTAL COLLECTION", "மொத்த வசூல்", "कुल कलेक्शन");
  static String get feeRecordsTitle => text("Fee Records", "கட்டண பதிவுகள்", "फीस रिकॉर्ड");
  static String get records => text("Records", "பதிவுகள்", "रिकॉर्ड");
  static String get noFeeRecordsFound => text("No fee records found", "கட்டண பதிவுகள் இல்லை", "कोई फीस रिकॉर्ड नहीं मिला");
  static String get clickAddPaymentCreateOne => text("Click Add Payment to create one", "புதிய பதிவு உருவாக்க Add Payment ஐ அழுத்தவும்", "एक रिकॉर्ड बनाने के लिए Add Payment दबाएं");
  static String get noFeeRecordsAvailable => text("No fee records available for your account", "உங்கள் கணக்கிற்கு கட்டண பதிவுகள் இல்லை", "आपके खाते के लिए कोई फीस रिकॉर्ड उपलब्ध नहीं है");

  static String get feeModule => text("Fee Module", "கட்டண மாட்யூல்", "फीस मॉड्यूल");
  static String get feeCollection => text("Fee Collection", "கட்டண வசூல்", "फीस कलेक्शन");
  static String get payments => text("Payments", "கட்டணங்கள்", "भुगतान");
  static String get feeReports => text("Fee Reports", "கட்டண அறிக்கைகள்", "फीस रिपोर्ट");
  static String get collectFeesTrackDues => text("Collect fees and track pending student dues", "கட்டணங்களை வசூலித்து மாணவர் நிலுவைகளை கண்காணிக்கவும்", "फीस जमा करें और छात्र बकाया ट्रैक करें");
  static String get viewTransactionsStatusReceipts => text("View transactions, status and fee receipts", "பரிவர்த்தனைகள், நிலை மற்றும் ரசீதுகளைப் பாருங்கள்", "लेनदेन, स्थिति और रसीदें देखें");
  static String get analyzeFeeReports => text("Analyze fee collection and pending fee reports", "கட்டண வசூல் மற்றும் நிலுவை அறிக்கைகளை பகுப்பாய்வு செய்க", "फीस कलेक्शन और बकाया रिपोर्ट देखें");
  static String get collectFee => text("Collect Fee", "கட்டணம் வசூலிக்க", "फीस जमा करें");
  static String get recordStudentFeePayment => text("Record student fee payment", "மாணவர் கட்டணப் பதிவை சேமிக்கவும்", "छात्र फीस भुगतान रिकॉर्ड करें");
  static String get pendingFees => text("Pending Fees", "நிலுவை கட்டணங்கள்", "बकाया फीस");
  static String get trackPendingStudentDues => text("Track pending student dues", "மாணவர் நிலுவை கட்டணங்களை கண்காணிக்கவும்", "छात्र बकाया फीस ट्रैक करें");
  static String get paymentHistory => text("Payment History", "கட்டண வரலாறு", "भुगतान इतिहास");
  static String get viewAllFeeTransactions => text("View all fee transactions", "அனைத்து கட்டண பரிவர்த்தனைகளையும் பார்", "सभी फीस लेनदेन देखें");
  static String get paymentStatus => text("Payment Status", "கட்டண நிலை", "भुगतान स्थिति");
  static String get trackPaymentStatus => text("Track paid and pending payment status", "செலுத்திய மற்றும் நிலுவை நிலையை கண்காணிக்கவும்", "भुगतान और बकाया स्थिति ट्रैक करें");
  static String get feeReceipts => text("Fee Receipts", "கட்டண ரசீதுகள்", "फीस रसीदें");
  static String get viewStudentFeeReceipts => text("View student fee receipts", "மாணவர் கட்டண ரசீதுகளைப் பாருங்கள்", "छात्र फीस रसीदें देखें");
  static String get analyzeFeeCollectionStatus => text("Analyze fee collection status", "கட்டண வசூல் நிலையை பகுப்பாய்வு செய்க", "फीस कलेक्शन स्थिति देखें");
  static String get monthlyCollection => text("Monthly Collection", "மாதாந்திர வசூல்", "मासिक कलेक्शन");
  static String get viewMonthlyFeeCollectionSummary => text("View monthly fee collection summary", "மாதாந்திர கட்டண வசூல் சுருக்கத்தைப் பாருங்கள்", "मासिक फीस कलेक्शन सारांश देखें");
  static String get dueFeeAnalytics => text("Due Fee Analytics", "நிலுவை கட்டண பகுப்பாய்வு", "बकाया फीस एनालिटिक्स");
  static String get analyzeStudentPendingFees => text("Analyze student-wise pending fees", "மாணவர் வாரியான நிலுவை கட்டணங்களை பகுப்பாய்வு செய்க", "छात्र-वार बकाया फीस देखें");
  static String get collect => text("Collect", "வசூல்", "जमा");
  static String get dues => text("Dues", "நிலுவை", "बकाया");
  static String get finance => text("Finance", "நிதி", "वित्त");
  static String get track => text("Track", "கண்காணி", "ट्रैक");
  static String get receipt => text("Receipt", "ரசீது", "रसीद");
  static String get growth => text("Growth", "வளர்ச்சி", "विकास");

// Add before the final } in app_strings.dart. Do not duplicate existing getters.

static String get scheduleOptions => text("SCHEDULE OPTIONS", "அட்டவணை விருப்பங்கள்", "कार्यक्रम विकल्प");
static String get trainingSchedule => text("Training Schedule", "பயிற்சி அட்டவணை", "प्रशिक्षण कार्यक्रम");
static String get manageViewTrainingSessions => text("Manage and view training sessions", "பயிற்சி அமர்வுகளை நிர்வகித்து பாருங்கள்", "प्रशिक्षण सेशन प्रबंधित करें और देखें");
static String get viewManageMatchFixtures => text("View and manage match fixtures", "போட்டி அட்டவணைகளை பார்த்து நிர்வகிக்கவும்", "मैच फिक्स्चर देखें और प्रबंधित करें");
static String get todaySchedule => text("Today Schedule", "இன்றைய அட்டவணை", "आज का कार्यक्रम");
static String get checkTodayTrainingMatches => text("Check only today's training and matches", "இன்றைய பயிற்சி மற்றும் போட்டிகளை மட்டும் பாருங்கள்", "केवल आज का प्रशिक्षण और मैच देखें");
static String get monthlySchedule => text("Monthly Schedule", "மாதாந்திர அட்டவணை", "मासिक कार्यक्रम");
static String get viewMonthlyTrainingMatchPlan => text("View this month's training and match plan", "இந்த மாத பயிற்சி மற்றும் போட்டித் திட்டத்தை பாருங்கள்", "इस महीने का प्रशिक्षण और मैच प्लान देखें");
static String get sessionHistory => text("Session History", "அமர்வு வரலாறு", "सेशन इतिहास");
static String get viewPastTrainingMatchRecords => text("View past training and match records", "முந்தைய பயிற்சி மற்றும் போட்டி பதிவுகளை பாருங்கள்", "पिछले प्रशिक्षण और मैच रिकॉर्ड देखें");
static String get scheduleModuleTitle => text("SCHEDULE MODULE", "அட்டவணை மாட்யூல்", "कार्यक्रम मॉड्यूल");
static String get matchesTrainingSchedules => text("Matches, training and schedules", "போட்டிகள், பயிற்சி மற்றும் அட்டவணைகள்", "मैच, प्रशिक्षण और कार्यक्रम");
static String get management => text("Management", "மேலாண்மை", "प्रबंधन");
static String get matches => text("Matches", "போட்டிகள்", "मैच");
static String get scheduleInfoMessage => text(
  "All schedules are organised and updated regularly. Makeup sessions and cancelled sessions are managed inside the Attendance Module.",
  "அனைத்து அட்டவணைகளும் ஒழுங்குபடுத்தப்பட்டு தொடர்ந்து புதுப்பிக்கப்படுகின்றன. மேக்கப் மற்றும் ரத்து செய்யப்பட்ட அமர்வுகள் வருகை மாட்யூலில் நிர்வகிக்கப்படுகின்றன.",
  "सभी कार्यक्रम व्यवस्थित हैं और नियमित रूप से अपडेट किए जाते हैं। मेकअप और रद्द सेशन उपस्थिति मॉड्यूल में प्रबंधित किए जाते हैं।");
static String get matchSchedule =>
    text("Match Schedule", "போட்டி அட்டவணை", "मैच कार्यक्रम");

// Add these before the last } in app_strings.dart.
// Skip a getter if it already exists.

static String get addTraining =>
    text("Add Training", "பயிற்சியை சேர்", "प्रशिक्षण जोड़ें");

static String get date =>
    text("Date", "தேதி", "तारीख");

static String get day =>
    text("Day", "நாள்", "दिन");

static String get time =>
    text("Time", "நேரம்", "समय");

static String get trainingType =>
    text("Training Type", "பயிற்சி வகை", "प्रशिक्षण प्रकार");

static String get exampleMorningBatch =>
    text("Example: Morning Batch", "உதாரணம்: காலை பேட்ச்", "उदाहरण: सुबह बैच");

static String get exampleBattingPractice =>
    text("Example: Batting Practice", "உதாரணம்: பேட்டிங் பயிற்சி", "उदाहरण: बल्लेबाजी अभ्यास");

static String get trainingStatusHint =>
    text("Upcoming / Completed / Cancelled", "வரவுள்ளது / முடிந்தது / ரத்து", "आगामी / पूर्ण / रद्द");

static String get pleaseFillAllFields =>
    text("Please fill all fields", "அனைத்து புலங்களையும் நிரப்பவும்", "कृपया सभी फ़ील्ड भरें");

static String get trainingScheduleAdded =>
    text("Training schedule added", "பயிற்சி அட்டவணை சேர்க்கப்பட்டது", "प्रशिक्षण कार्यक्रम जोड़ा गया");

static String get trainingScheduleDeleted =>
    text("Training schedule deleted", "பயிற்சி அட்டவணை நீக்கப்பட்டது", "प्रशिक्षण कार्यक्रम हटाया गया");

static String get deleteTraining =>
    text("Delete Training", "பயிற்சியை நீக்கு", "प्रशिक्षण हटाएं");

static String get deleteTrainingConfirm =>
    text("Are you sure you want to delete this training schedule?", "இந்த பயிற்சி அட்டவணையை நீக்க விரும்புகிறீர்களா?", "क्या आप यह प्रशिक्षण कार्यक्रम हटाना चाहते हैं?");

static String get noBatchAssigned =>
    text("No batch assigned", "பேட்ச் ஒதுக்கப்படவில்லை", "कोई बैच असाइन नहीं");

static String get askAdminAssignBatchSession =>
    text("Please ask Admin to assign a batch or weekly session.", "பேட்ச் அல்லது வாராந்திர அமர்வை ஒதுக்க அட்மினிடம் கேளுங்கள்.", "कृपया एडमिन से बैच या साप्ताहिक सेशन असाइन करने को कहें।");

static String get noScheduleBecauseNoBatch =>
    text("No schedule is available because no batch is linked.", "பேட்ச் இணைக்கப்படாததால் அட்டவணை கிடைக்கவில்லை.", "बैच लिंक न होने के कारण कोई कार्यक्रम उपलब्ध नहीं है।");

static String get unableLoadSchedule =>
    text("Unable to load schedule", "அட்டவணையை ஏற்ற முடியவில்லை", "कार्यक्रम लोड नहीं हो सका");

static String get trainingSchedules =>
    text("TRAINING SCHEDULES", "பயிற்சி அட்டவணைகள்", "प्रशिक्षण कार्यक्रम");

static String get noDay =>
    text("No Day", "நாள் இல்லை", "दिन उपलब्ध नहीं");

static String get noTime =>
    text("No Time", "நேரம் இல்லை", "समय उपलब्ध नहीं");

static String get manageAcademyTrainingSessions =>
    text("Manage academy training sessions", "அகாடமி பயிற்சி அமர்வுகளை நிர்வகிக்கவும்", "अकादमी प्रशिक्षण सेशन प्रबंधित करें");

static String get viewAssignedTrainingSessions =>
    text("View your assigned training sessions", "உங்களுக்கு ஒதுக்கப்பட்ட பயிற்சி அமர்வுகளை பாருங்கள்", "अपने असाइन किए गए प्रशिक्षण सेशन देखें");

static String get schedulesLabel =>
    text("Schedules", "அட்டவணைகள்", "कार्यक्रम");

static String get fitness =>
    text("Fitness", "உடற்பயிற்சி", "फिटनेस");

static String get skills =>
    text("Skills", "திறன்கள்", "कौशल");

static String get noScheduleAvailable =>
    text("No Schedule Available", "அட்டவணை இல்லை", "कोई कार्यक्रम उपलब्ध नहीं");

static String get clickAddTrainingCreateOne =>
    text("Click Add Training to create one", "புதியதை உருவாக்க Add Training அழுத்தவும்", "नया बनाने के लिए Add Training दबाएं");

static String get noTrainingScheduleForBatch =>
    text("No training schedule available for your batch", "உங்கள் பேட்சிற்கு பயிற்சி அட்டவணை இல்லை", "आपके बैच के लिए कोई प्रशिक्षण कार्यक्रम उपलब्ध नहीं है");

static String get upcoming =>
    text("Upcoming", "வரவுள்ளது", "आगामी");

static String get completed =>
    text("Completed", "முடிந்தது", "पूर्ण");

static String get cancelled =>
    text("Cancelled", "ரத்து செய்யப்பட்டது", "रद्द");

static String get monday =>
    text("Monday", "திங்கள்", "सोमवार");

static String get tuesday =>
    text("Tuesday", "செவ்வாய்", "मंगलवार");

static String get wednesday =>
    text("Wednesday", "புதன்", "बुधवार");

static String get thursday =>
    text("Thursday", "வியாழன்", "गुरुवार");

static String get friday =>
    text("Friday", "வெள்ளி", "शुक्रवार");

static String get saturday =>
    text("Saturday", "சனி", "शनिवार");

static String get sunday =>
    text("Sunday", "ஞாயிறு", "रविवार");
static String get center =>
    text("Center", "மையம்", "केंद्र");
// Add these before the last } in app_strings.dart.
// Skip any getter that already exists.

static String get addMatch =>
    text("Add Match", "போட்டியை சேர்", "मैच जोड़ें");

static String get matchTitle =>
    text("Match Title", "போட்டி தலைப்பு", "मैच शीर्षक");

static String get exampleFriendlyMatch =>
    text("Example: Friendly Match", "உதாரணம்: நட்பு போட்டி", "उदाहरण: मैत्री मैच");

static String get opponent =>
    text("Opponent", "எதிரணி", "प्रतिद्वंद्वी");

static String get exampleAbcAcademy =>
    text("Example: ABC Academy", "உதாரணம்: ABC அகாடமி", "उदाहरण: ABC अकादमी");

static String get venue =>
    text("Venue", "இடம்", "स्थान");

static String get exampleYgcaGround =>
    text("Example: YGCA Ground", "உதாரணம்: YGCA மைதானம்", "उदाहरण: YGCA मैदान");

static String get matchAdded =>
    text("Match added", "போட்டி சேர்க்கப்பட்டது", "मैच जोड़ा गया");

static String get matchDeleted =>
    text("Match deleted", "போட்டி நீக்கப்பட்டது", "मैच हटाया गया");

static String get deleteMatch =>
    text("Delete Match", "போட்டியை நீக்கு", "मैच हटाएं");

static String get deleteMatchConfirm =>
    text("Are you sure you want to delete this match?", "இந்த போட்டியை நீக்க விரும்புகிறீர்களா?", "क्या आप यह मैच हटाना चाहते हैं?");

static String get matchSchedules =>
    text("MATCH SCHEDULES", "போட்டி அட்டவணைகள்", "मैच कार्यक्रम");

static String get manageAcademyMatchUpdates =>
    text("Manage academy match updates", "அகாடமி போட்டி புதுப்பிப்புகளை நிர்வகிக்கவும்", "अकादमी मैच अपडेट प्रबंधित करें");

static String get viewAcademyMatchUpdates =>
    text("View academy match updates", "அகாடமி போட்டி புதுப்பிப்புகளை பாருங்கள்", "अकादमी मैच अपडेट देखें");

static String get match =>
    text("Match", "போட்டி", "मैच");

static String get vs =>
    text("vs", "எதிராக", "बनाम");

static String get noMatchesScheduled =>
    text("No matches scheduled", "போட்டிகள் திட்டமிடப்படவில்லை", "कोई मैच निर्धारित नहीं");

static String get clickAddMatchCreateOne =>
    text("Click Add Match to create one", "புதிய போட்டி உருவாக்க Add Match அழுத்தவும்", "नया मैच बनाने के लिए Add Match दबाएं");

static String get matchUpdatesAppearHere =>
    text("Match updates will appear here", "போட்டி புதுப்பிப்புகள் இங்கே தோன்றும்", "मैच अपडेट यहां दिखाई देंगे");
static String get noTitle =>
    text("No Title", "தலைப்பு இல்லை", "कोई शीर्षक नहीं");
}