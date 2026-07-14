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
// Add before the final } in app_strings.dart. Skip getters that already exist.

static String get unableLoadTodaySchedule =>
    text("Unable to load today's schedule", "இன்றைய அட்டவணையை ஏற்ற முடியவில்லை", "आज का कार्यक्रम लोड नहीं हो सका");

static String get trainingSession =>
    text("Training Session", "பயிற்சி அமர்வு", "प्रशिक्षण सेशन");

static String get trainingSessionFor =>
    text("Training session for", "பயிற்சி அமர்வு:", "प्रशिक्षण सेशन:");

static String get allBatches =>
    text("All Batches", "அனைத்து பேட்ச்கள்", "सभी बैच");

static String get cancelledSession =>
    text("Cancelled Session", "ரத்து செய்யப்பட்ட அமர்வு", "रद्द सेशन");

static String get todaysSchedule =>
    text("TODAY'S SCHEDULE", "இன்றைய அட்டவணை", "आज का कार्यक्रम");

static String get noTodayScheduleAvailable =>
    text("No Today Schedule Available", "இன்றைய அட்டவணை இல்லை", "आज का कोई कार्यक्रम उपलब्ध नहीं");

static String get noTrainingOrMatchesToday =>
    text("There are no training sessions or matches scheduled for today.", "இன்று பயிற்சி அமர்வுகள் அல்லது போட்டிகள் திட்டமிடப்படவில்லை.", "आज कोई प्रशिक्षण सेशन या मैच निर्धारित नहीं है।");

static String get items =>
    text("Items", "உருப்படிகள்", "आइटम");
static String get sessionCancelled =>
    text(
      "Session cancelled",
      "அமர்வு ரத்து செய்யப்பட்டது",
      "सेशन रद्द किया गया",
    );
// Add these before the last } in app_strings.dart.
// Skip any getter that already exists.

static String get unableLoadMonthlySchedule =>
    text("Unable to load monthly schedule", "மாதாந்திர அட்டவணையை ஏற்ற முடியவில்லை", "मासिक कार्यक्रम लोड नहीं हो सका");

static String get noMonthlyScheduleAvailable =>
    text("No Monthly Schedule Available", "மாதாந்திர அட்டவணை இல்லை", "कोई मासिक कार्यक्रम उपलब्ध नहीं");

static String get noTrainingOrMatchesThisMonth =>
    text("There are no training sessions or matches scheduled for this month.", "இந்த மாதம் பயிற்சி அமர்வுகள் அல்லது போட்டிகள் திட்டமிடப்படவில்லை.", "इस महीने कोई प्रशिक्षण सेशन या मैच निर्धारित नहीं है।");

static String get monthly =>
    text("Monthly", "மாதாந்திர", "मासिक");

static String get plan =>
    text("Plan", "திட்டம்", "योजना");

static String get january => text("January", "ஜனவரி", "जनवरी");
static String get february => text("February", "பிப்ரவரி", "फ़रवरी");
static String get march => text("March", "மார்ச்", "मार्च");
static String get april => text("April", "ஏப்ரல்", "अप्रैल");
static String get may => text("May", "மே", "मई");
static String get june => text("June", "ஜூன்", "जून");
static String get july => text("July", "ஜூலை", "जुलाई");
static String get august => text("August", "ஆகஸ்ட்", "अगस्त");
static String get september => text("September", "செப்டம்பர்", "सितंबर");
static String get october => text("October", "அக்டோபர்", "अक्टूबर");
static String get november => text("November", "நவம்பர்", "नवंबर");
static String get december => text("December", "டிசம்பர்", "दिसंबर");

static String get mon => text("Mon", "தி", "सोम");
static String get tue => text("Tue", "செ", "मंगल");
static String get wed => text("Wed", "பு", "बुध");
static String get thu => text("Thu", "வி", "गुरु");
static String get fri => text("Fri", "வெ", "शुक्र");
static String get sat => text("Sat", "ச", "शनि");
static String get sun => text("Sun", "ஞா", "रवि");

// Add these before the last } in app_strings.dart.
// Skip any getter that already exists.

static String get unableLoadSessionHistory =>
    text("Unable to load session history", "அமர்வு வரலாற்றை ஏற்ற முடியவில்லை", "सेशन इतिहास लोड नहीं हो सका");

static String get trainingSessionCompletedFor =>
    text("Training session completed for", "பயிற்சி அமர்வு முடிந்தது:", "प्रशिक्षण सेशन पूर्ण हुआ:");

static String get noHistoryBecauseNoBatch =>
    text("No history is available because no batch is linked.", "பேட்ச் இணைக்கப்படாததால் வரலாறு கிடைக்கவில்லை.", "बैच लिंक न होने के कारण इतिहास उपलब्ध नहीं है।");

static String get noSessionHistoryAvailable =>
    text("No Session History Available", "அமர்வு வரலாறு இல்லை", "कोई सेशन इतिहास उपलब्ध नहीं");

static String get noPastTrainingOrMatches =>
    text("There are no past training sessions or matches available yet.", "முந்தைய பயிற்சி அமர்வுகள் அல்லது போட்டிகள் இன்னும் இல்லை.", "अभी कोई पिछला प्रशिक्षण सेशन या मैच उपलब्ध नहीं है।");

static String get pastTrainingMatchCancelledSessions =>
    text("Past training, match and cancelled sessions", "முந்தைய பயிற்சி, போட்டி மற்றும் ரத்து அமர்வுகள்", "पिछले प्रशिक्षण, मैच और रद्द सेशन");
// Add these before the final } in app_strings.dart.
// Skip any getter that already exists.

static String get makeupSessionScheduled =>
    text("Makeup session scheduled", "மேக்கப் அமர்வு திட்டமிடப்பட்டது", "मेकअप सेशन निर्धारित किया गया");

static String get makeupSessionMarkedCompleted =>
    text("Makeup session marked as completed", "மேக்கப் அமர்வு முடிந்ததாக குறிக்கப்பட்டது", "मेकअप सेशन पूर्ण चिह्नित किया गया");

static String get makeupSessionDeleted =>
    text("Makeup session deleted", "மேக்கப் அமர்வு நீக்கப்பட்டது", "मेकअप सेशन हटाया गया");

static String get deleteMakeupSession =>
    text("Delete Makeup Session", "மேக்கப் அமர்வை நீக்கு", "मेकअप सेशन हटाएं");

static String get deleteMakeupSessionConfirm =>
    text("Are you sure you want to delete this session?", "இந்த அமர்வை நீக்க விரும்புகிறீர்களா?", "क्या आप यह सेशन हटाना चाहते हैं?");

static String get makeupSessionList =>
    text("MAKEUP SESSION LIST", "மேக்கப் அமர்வு பட்டியல்", "मेकअप सेशन सूची");

static String get makeupSessionsTitle =>
    text("MAKEUP SESSIONS", "மேக்கப் அமர்வுகள்", "मेकअप सेशन");

static String get scheduleCompletionCenter =>
    text("Schedule & completion center", "அட்டவணை மற்றும் நிறைவு மையம்", "कार्यक्रम और पूर्णता केंद्र");

static String get scheduled =>
    text("Scheduled", "திட்டமிடப்பட்டது", "निर्धारित");

static String get complete =>
    text("Complete", "முடிக்க", "पूर्ण करें");

static String get makeupInfoMessage =>
    text("Makeup sessions are created from approved leave requests. Coaches can schedule and complete sessions for their assigned batches.", "அங்கீகரிக்கப்பட்ட விடுப்பு கோரிக்கைகளில் இருந்து மேக்கப் அமர்வுகள் உருவாக்கப்படுகின்றன. பயிற்சியாளர்கள் தங்களுக்கு ஒதுக்கப்பட்ட பேட்ச்களுக்கு அமர்வுகளை திட்டமிட்டு முடிக்கலாம்.", "स्वीकृत छुट्टी अनुरोधों से मेकअप सेशन बनाए जाते हैं। कोच अपने असाइन किए गए बैचों के लिए सेशन निर्धारित और पूर्ण कर सकते हैं।");

static String get notScheduled =>
    text("Not scheduled", "திட்டமிடப்படவில்லை", "निर्धारित नहीं");

static String get makeupSession =>
    text("Makeup Session", "மேக்கப் அமர்வு", "मेकअप सेशन");

static String get originalBatch =>
    text("Original Batch", "மூல பேட்ச்", "मूल बैच");

static String get makeupBatch =>
    text("Makeup Batch", "மேக்கப் பேட்ச்", "मेकअप बैच");

static String get leaveCancelledDate =>
    text("Leave / Cancelled Date", "விடுப்பு / ரத்து தேதி", "छुट्टी / रद्द तारीख");

static String get reason =>
    text("Reason", "காரணம்", "कारण");

static String get makeupDate =>
    text("Makeup Date", "மேக்கப் தேதி", "मेकअप तारीख");

static String get noMakeupSessionsFound =>
    text("No Makeup Sessions Found", "மேக்கப் அமர்வுகள் இல்லை", "कोई मेकअप सेशन नहीं मिला");

static String get approvedLeaveCreatesMakeup =>
    text("Approved leave requests will automatically create makeup sessions.", "அங்கீகரிக்கப்பட்ட விடுப்பு கோரிக்கைகள் தானாக மேக்கப் அமர்வுகளை உருவாக்கும்.", "स्वीकृत छुट्टी अनुरोध अपने आप मेकअप सेशन बनाएंगे।");

static String get unableLoadMakeupSessions =>
    text("Unable to load makeup sessions", "மேக்கப் அமர்வுகளை ஏற்ற முடியவில்லை", "मेकअप सेशन लोड नहीं हो सके");

static String get pleaseFillDateTime =>
    text("Please fill date and time", "தேதி மற்றும் நேரத்தை நிரப்பவும்", "कृपया तारीख और समय भरें");

static String get scheduleFailed =>
    text("Schedule failed", "அட்டவணை தோல்வியடைந்தது", "कार्यक्रम विफल");

static String get scheduleMakeupTitle =>
    text("SCHEDULE MAKEUP", "மேக்கப் அட்டவணை", "मेकअप निर्धारित करें");

static String get addDateAndTime =>
    text("Add date and time", "தேதி மற்றும் நேரத்தை சேர்க்கவும்", "तारीख और समय जोड़ें");

static String get selectMakeupDateTimeInfo =>
    text("Select makeup session date and time. Parents and students will receive the schedule notification.", "மேக்கப் அமர்வின் தேதி மற்றும் நேரத்தை தேர்வு செய்க. பெற்றோரும் மாணவர்களும் அட்டவணை அறிவிப்பைப் பெறுவார்கள்.", "मेकअप सेशन की तारीख और समय चुनें। अभिभावक और छात्र कार्यक्रम सूचना प्राप्त करेंगे।");

static String get selectDate =>
    text("Select date", "தேதியை தேர்வு செய்க", "तारीख चुनें");

static String get makeupTime =>
    text("Makeup Time", "மேக்கப் நேரம்", "मेकअप समय");

static String get selectTime =>
    text("Select time", "நேரத்தை தேர்வு செய்க", "समय चुनें");

static String get saveSchedule =>
    text("Save Schedule", "அட்டவணையை சேமி", "कार्यक्रम सेव करें");
static String get academy =>
    text("Academy", "அகாடமி", "अकादमी");
// Add these before the final } in app_strings.dart.
// Skip any getter that already exists.


static String get sessionCancelledMakeupCreated =>
    text("Session cancelled and makeup created", "அமர்வு ரத்து செய்யப்பட்டு மேக்கப் உருவாக்கப்பட்டது", "सेशन रद्द हुआ और मेकअप बनाया गया");

static String get cancelSessionFailed =>
    text("Cancel session failed", "அமர்வை ரத்து செய்வது தோல்வியடைந்தது", "सेशन रद्द करना विफल");

static String get cancelSessionForm =>
    text("CANCEL SESSION FORM", "அமர்வு ரத்து படிவம்", "सेशन रद्द फ़ॉर्म");

static String get sessionDate =>
    text("Session Date", "அமர்வு தேதி", "सेशन तारीख");

static String get sessionTime =>
    text("Session Time", "அமர்வு நேரம்", "सेशन समय");

static String get creating =>
    text("CREATING...", "உருவாக்கப்படுகிறது...", "बनाया जा रहा है...");

static String get cancelStudentCreateMakeup =>
    text("CANCEL STUDENT & CREATE MAKEUP", "மாணவர் அமர்வை ரத்து செய்து மேக்கப் உருவாக்கு", "छात्र सेशन रद्द करें और मेकअप बनाएं");

static String get cancelBatchCreateMakeup =>
    text("CANCEL BATCH & CREATE MAKEUP", "பேட்ச் அமர்வை ரத்து செய்து மேக்கப் உருவாக்கு", "बैच सेशन रद्द करें और मेकअप बनाएं");

static String get recentlyCancelled =>
    text("RECENTLY CANCELLED", "சமீபத்தில் ரத்து செய்யப்பட்டவை", "हाल ही में रद्द");

static String get fullBatch =>
    text("Full Batch", "முழு பேட்ச்", "पूरा बैच");

static String get individual =>
    text("Individual", "தனிப்பட்ட", "व्यक्तिगत");

static String get selectBatch =>
    text("Select Batch", "பேட்சை தேர்வு செய்க", "बैच चुनें");

static String get selectBatchFirst =>
    text("Select batch first", "முதலில் பேட்சை தேர்வு செய்க", "पहले बैच चुनें");

static String get batchOrIndividualControl =>
    text("Batch or individual session control", "பேட்ச் அல்லது தனிப்பட்ட அமர்வு கட்டுப்பாடு", "बैच या व्यक्तिगत सेशन नियंत्रण");

static String get control =>
    text("Control", "கட்டுப்பாடு", "नियंत्रण");

static String get batches =>
    text("Batches", "பேட்ச்கள்", "बैच");

static String get cancelSessionWarning =>
    text("Cancel a full batch session or only one student's session. Makeup session will be created automatically.", "முழு பேட்ச் அமர்வையோ அல்லது ஒரே மாணவரின் அமர்வையோ ரத்து செய்யலாம். மேக்கப் அமர்வு தானாக உருவாகும்.", "पूरा बैच सेशन या केवल एक छात्र का सेशन रद्द करें। मेकअप सेशन अपने आप बनेगा।");

static String get individualStudent =>
    text("Individual Student", "தனிப்பட்ட மாணவர்", "व्यक्तिगत छात्र");

static String get noCancelledSessionsFound =>
    text("No Cancelled Sessions Found", "ரத்து செய்யப்பட்ட அமர்வுகள் இல்லை", "कोई रद्द सेशन नहीं मिला");

static String get cancelledSessionsAppearHere =>
    text(
      "Cancelled sessions will appear here",
      "ரத்து செய்யப்பட்ட அமர்வுகள் இங்கே தோன்றும்",
      "रद्द सेशन यहां दिखाई देंगे",
    );
    static String get leaveApprovedMakeupCreated =>
    text("Leave approved and makeup session created", "விடுப்பு அங்கீகரிக்கப்பட்டு மேக்கப் அமர்வு உருவாக்கப்பட்டது", "छुट्टी स्वीकृत हुई और मेकअप सेशन बनाया गया");

static String get leaveRejected =>
    text("Leave rejected", "விடுப்பு நிராகரிக்கப்பட்டது", "छुट्टी अस्वीकृत");

static String get leaveRequestDeleted =>
    text("Leave request deleted", "விடுப்பு கோரிக்கை நீக்கப்பட்டது", "छुट्टी अनुरोध हटाया गया");

static String get deleteLeaveRequest =>
    text("Delete Leave Request", "விடுப்பு கோரிக்கையை நீக்கு", "छुट्टी अनुरोध हटाएं");

static String get deleteLeaveRequestConfirm =>
    text("Are you sure you want to delete this leave request?", "இந்த விடுப்பு கோரிக்கையை நீக்க விரும்புகிறீர்களா?", "क्या आप यह छुट्टी अनुरोध हटाना चाहते हैं?");

static String get leaveRequestSubmitted =>
    text("Leave request submitted", "விடுப்பு கோரிக்கை சமர்ப்பிக்கப்பட்டது", "छुट्टी अनुरोध जमा हुआ");

static String get newLeave =>
    text("New Leave", "புதிய விடுப்பு", "नई छुट्टी");

static String get userDataNotFound =>
    text("User data not found", "பயனர் தகவல் கிடைக்கவில்லை", "उपयोगकर्ता डेटा नहीं मिला");

static String get leaveRequestsTitle =>
    text("LEAVE REQUESTS", "விடுப்பு கோரிக்கைகள்", "छुट्टी अनुरोध");

static String get approvalMakeupFlow =>
    text("Approval & makeup session flow", "அங்கீகாரம் மற்றும் மேக்கப் அமர்வு நடைமுறை", "स्वीकृति और मेकअप सेशन प्रक्रिया");

static String get leaveDate =>
    text("Leave Date", "விடுப்பு தேதி", "छुट्टी की तारीख");

static String get requestedBy =>
    text("Requested By", "கோரியவர்", "अनुरोधकर्ता");

static String get created =>
    text("Created", "உருவாக்கப்பட்டது", "बनाया गया");

static String get noLeaveRequestsFound =>
    text("No leave requests found", "விடுப்பு கோரிக்கைகள் இல்லை", "कोई छुट्टी अनुरोध नहीं मिला");

static String get leaveRequestsAppearHere =>
    text("Leave requests will appear here", "விடுப்பு கோரிக்கைகள் இங்கே தோன்றும்", "छुट्टी अनुरोध यहां दिखाई देंगे");

static String get pleaseSelectLinkedStudent =>
    text("Please select linked student", "இணைக்கப்பட்ட மாணவரை தேர்வு செய்யவும்", "कृपया लिंक किए गए छात्र को चुनें");

static String get studentIdNotFound =>
    text("Student ID not found", "மாணவர் ஐடி கிடைக்கவில்லை", "छात्र आईडी नहीं मिली");

static String get submitFailed =>
    text("Submit failed", "சமர்ப்பிப்பு தோல்வியடைந்தது", "जमा करना विफल");

static String get cannotCreateLeaveRequest =>
    text("You cannot create leave request", "நீங்கள் விடுப்பு கோரிக்கை உருவாக்க முடியாது", "आप छुट्टी अनुरोध नहीं बना सकते");

static String get noLinkedStudentForParent =>
    text("No linked student found for this parent", "இந்த பெற்றோருக்கு இணைக்கப்பட்ட மாணவர் இல்லை", "इस अभिभावक के लिए कोई लिंक छात्र नहीं मिला");

static String get selectLeaveDate =>
    text("Select leave date", "விடுப்பு தேதியை தேர்வு செய்க", "छुट्टी की तारीख चुनें");

static String get enterLeaveReason =>
    text("Enter leave reason", "விடுப்பு காரணத்தை உள்ளிடவும்", "छुट्टी का कारण दर्ज करें");

static String get submitting =>
    text("Submitting...", "சமர்ப்பிக்கப்படுகிறது...", "जमा किया जा रहा है...");

static String get submitLeave =>
    text("Submit Leave", "விடுப்பை சமர்ப்பிக்க", "छुट्टी जमा करें");

static String get submitLeaveRequest =>
    text("Submit leave request", "விடுப்பு கோரிக்கையை சமர்ப்பிக்க", "छुट्टी अनुरोध जमा करें");

static String get leaveInfoMessage =>
    text("Submit your leave request. Admin or Coach will approve it, then a makeup session will be created automatically.", "உங்கள் விடுப்பு கோரிக்கையை சமர்ப்பிக்கவும். அட்மின் அல்லது பயிற்சியாளர் அங்கீகரித்த பின் மேக்கப் அமர்வு தானாக உருவாகும்.", "अपना छुट्टी अनुरोध जमा करें। एडमिन या कोच की स्वीकृति के बाद मेकअप सेशन अपने आप बनेगा।");
// Add these before the final } in app_strings.dart.
// Skip any getter that already exists.

static String get totalRecords =>
    text("Total Records", "மொத்த பதிவுகள்", "कुल रिकॉर्ड");

static String get attendancePercentage =>
    text("Attendance %", "வருகை %", "उपस्थिति %");

static String get batchWiseSummary =>
    text("BATCH WISE SUMMARY", "பேட்ச் வாரியான சுருக்கம்", "बैच-वार सारांश");

static String get noBatchReportAvailable =>
    text("No batch report available", "பேட்ச் அறிக்கை இல்லை", "कोई बैच रिपोर्ट उपलब्ध नहीं");

static String get topAttendanceStudents =>
    text("TOP ATTENDANCE STUDENTS", "சிறந்த வருகை மாணவர்கள்", "शीर्ष उपस्थिति छात्र");

static String get noStudentDataAvailable =>
    text("No student data available", "மாணவர் தகவல் இல்லை", "कोई छात्र डेटा उपलब्ध नहीं");

static String get studentAttendanceSummary =>
    text("STUDENT ATTENDANCE SUMMARY", "மாணவர் வருகை சுருக்கம்", "छात्र उपस्थिति सारांश");

static String get noAttendanceDataAvailable =>
    text("No attendance data available", "வருகை தகவல் இல்லை", "कोई उपस्थिति डेटा उपलब्ध नहीं");

static String get lowAttendanceAlert =>
    text("LOW ATTENDANCE ALERT", "குறைந்த வருகை எச்சரிக்கை", "कम उपस्थिति अलर्ट");

static String get needsAttention =>
    text("Needs Attention", "கவனம் தேவை", "ध्यान आवश्यक");

static String get excellent =>
    text("Excellent", "மிகச் சிறப்பு", "उत्कृष्ट");

static String get report =>
    text("Report", "அறிக்கை", "रिपोर्ट");

static String get overallAttendance =>
    text("overall attendance", "மொத்த வருகை", "कुल उपस्थिति");

static String get pdfExportLater =>
    text("PDF export will be added later", "PDF ஏற்றுமதி பின்னர் சேர்க்கப்படும்", "PDF निर्यात बाद में जोड़ा जाएगा");

static String get export =>
    text("Export", "ஏற்றுமதி", "निर्यात");

static String get unknown =>
    text("Unknown", "தெரியாது", "अज्ञात");

static String get noLowAttendanceStudents =>
    text("No low attendance students", "குறைந்த வருகை மாணவர்கள் இல்லை", "कम उपस्थिति वाले छात्र नहीं हैं");

static String get allStudentsAbove75 =>
    text("All students are above 75%", "அனைத்து மாணவர்களும் 75%க்கு மேல் உள்ளனர்", "सभी छात्र 75% से ऊपर हैं");

// Add before the final } in app_strings.dart. Skip existing getters.

static String get studentAttendanceAnalyticsTitle =>
    text("STUDENT ATTENDANCE ANALYTICS", "மாணவர் வருகை பகுப்பாய்வு", "छात्र उपस्थिति विश्लेषण");

static String get noRollNo =>
    text("No Roll No", "ரோல் எண் இல்லை", "रोल नंबर नहीं");

static String get studentWiseAttendancePerformance =>
    text("Student-wise attendance performance", "மாணவர் வாரியான வருகை செயல்திறன்", "छात्र-वार उपस्थिति प्रदर्शन");

static String get studentAttendanceAnalytics =>
    text("Student Attendance Analytics", "மாணவர் வருகை பகுப்பாய்வு", "छात्र उपस्थिति विश्लेषण");

static String get averageAttendance =>
    text("Average attendance", "சராசரி வருகை", "औसत उपस्थिति");

static String get needsFocus =>
    text("Needs Focus", "கவனம் தேவை", "ध्यान आवश्यक");

static String get noData =>
    text("No Data", "தகவல் இல்லை", "कोई डेटा नहीं");

static String get searchNameRollBatch =>
    text("Search by name, roll no or batch", "பெயர், ரோல் எண் அல்லது பேட்ச் மூலம் தேடவும்", "नाम, रोल नंबर या बैच से खोजें");

static String get noStudentRecordsForAnalytics =>
    text("No student records are available for analytics.", "பகுப்பாய்விற்கான மாணவர் பதிவுகள் இல்லை.", "विश्लेषण के लिए कोई छात्र रिकॉर्ड उपलब्ध नहीं है।");
// Add these before the final } in app_strings.dart.
// Skip any getter that already exists.

static String get progress =>
    text("Progress", "முன்னேற்றம்", "प्रगति");

static String get performanceModule =>
    text("Performance Module", "செயல்திறன் மாட்யூல்", "प्रदर्शन मॉड्यूल");

static String get viewCricketSkillPerformance =>
    text("View your cricket skill performance", "உங்கள் கிரிக்கெட் திறன் செயல்திறனை பாருங்கள்", "अपना क्रिकेट कौशल प्रदर्शन देखें");

static String get trackFitnessSkillDevelopment =>
    text("Track fitness and skill development", "உடற்தகுதி மற்றும் திறன் வளர்ச்சியை கண்காணிக்கவும்", "फिटनेस और कौशल विकास ट्रैक करें");

static String get viewPerformanceReportsAnalytics =>
    text("View performance reports and analytics", "செயல்திறன் அறிக்கைகள் மற்றும் பகுப்பாய்வுகளை பாருங்கள்", "प्रदर्शन रिपोर्ट और विश्लेषण देखें");

static String get performanceOverview =>
    text("Performance Overview", "செயல்திறன் கண்ணோட்டம்", "प्रदर्शन अवलोकन");

static String get viewCompletePerformanceSummary =>
    text("View complete performance summary", "முழுமையான செயல்திறன் சுருக்கத்தை பாருங்கள்", "पूर्ण प्रदर्शन सारांश देखें");

static String get battingPerformance =>
    text("Batting Performance", "பேட்டிங் செயல்திறன்", "बल्लेबाजी प्रदर्शन");

static String get checkBattingProgressScoreAnalysis =>
    text("Check batting progress and score analysis", "பேட்டிங் முன்னேற்றம் மற்றும் ஸ்கோர் பகுப்பாய்வை பாருங்கள்", "बल्लेबाजी प्रगति और स्कोर विश्लेषण देखें");

static String get bowlingPerformance =>
    text("Bowling Performance", "பந்துவீச்சு செயல்திறன்", "गेंदबाजी प्रदर्शन");

static String get checkBowlingProgressSkillReport =>
    text("Check bowling progress and skill report", "பந்துவீச்சு முன்னேற்றம் மற்றும் திறன் அறிக்கையை பாருங்கள்", "गेंदबाजी प्रगति और कौशल रिपोर्ट देखें");

static String get fitnessProgress =>
    text("Fitness Progress", "உடற்தகுதி முன்னேற்றம்", "फिटनेस प्रगति");

static String get viewStrengthStaminaFitnessUpdates =>
    text("View strength, stamina and fitness updates", "வலிமை, சகிப்புத்தன்மை மற்றும் உடற்தகுதி புதுப்பிப்புகளை பாருங்கள்", "ताकत, सहनशक्ति और फिटनेस अपडेट देखें");

static String get skillDevelopment =>
    text("Skill Development", "திறன் வளர்ச்சி", "कौशल विकास");

static String get trackCricketSkillImprovement =>
    text("Track cricket skill improvement", "கிரிக்கெட் திறன் மேம்பாட்டை கண்காணிக்கவும்", "क्रिकेट कौशल सुधार ट्रैक करें");

static String get progressReport =>
    text("Progress Report", "முன்னேற்ற அறிக்கை", "प्रगति रिपोर्ट");

static String get viewOverallProgressReport =>
    text("View your overall progress report", "உங்கள் மொத்த முன்னேற்ற அறிக்கையை பாருங்கள்", "अपनी समग्र प्रगति रिपोर्ट देखें");

static String get coachFeedback =>
    text("Coach Feedback", "பயிற்சியாளர் கருத்து", "कोच प्रतिक्रिया");

static String get viewCoachRemarksImprovementNotes =>
    text("View coach remarks and improvement notes", "பயிற்சியாளர் குறிப்புகள் மற்றும் மேம்பாட்டு குறிப்புகளை பாருங்கள்", "कोच टिप्पणियाँ और सुधार नोट्स देखें");

static String get monthlyReport =>
    text("Monthly Report", "மாதாந்திர அறிக்கை", "मासिक रिपोर्ट");

static String get viewMonthlyPerformanceReport =>
    text("View monthly performance report", "மாதாந்திர செயல்திறன் அறிக்கையை பாருங்கள்", "मासिक प्रदर्शन रिपोर्ट देखें");

static String get cricketProgressSkillAnalytics =>
    text("Cricket progress and skill analytics", "கிரிக்கெட் முன்னேற்றம் மற்றும் திறன் பகுப்பாய்வு", "क्रिकेट प्रगति और कौशल विश्लेषण");

static String get reportUpdatesControlledByCoachAdmin =>
    text("Report updates are controlled by Coach/Admin", "அறிக்கை புதுப்பிப்புகள் பயிற்சியாளர்/அட்மின் கட்டுப்பாட்டில் உள்ளன", "रिपोर्ट अपडेट कोच/एडमिन द्वारा नियंत्रित हैं");

static String get studentsViewOwnPerformanceOnly =>
    text("Students can view their own performance reports only. Later we can connect each row to separate dynamic screens.", "மாணவர்கள் தங்களுடைய செயல்திறன் அறிக்கைகளை மட்டுமே பார்க்க முடியும். பின்னர் ஒவ்வொரு வரியையும் தனித்தனி டைனமிக் திரைகளுடன் இணைக்கலாம்.", "छात्र केवल अपनी प्रदर्शन रिपोर्ट देख सकते हैं। बाद में प्रत्येक पंक्ति को अलग डायनेमिक स्क्रीन से जोड़ सकते हैं।");

static String get overview =>
    text("Overview", "கண்ணோட்டம்", "अवलोकन");

static String get batting =>
    text("Batting", "பேட்டிங்", "बल्लेबाजी");

static String get bowling =>
    text("Bowling", "பந்துவீச்சு", "गेंदबाजी");

static String get score =>
    text("Score", "ஸ்கோர்", "स्कोर");

static String get grow =>
    text("Grow", "வளர்ச்சி", "विकास");


static String get coach =>
    text("Coach", "பயிற்சியாளர்", "कोच");
// Add these before the final } in app_strings.dart.
// Skip any getter that already exists.

static String get elite =>
    text("Elite", "உச்சநிலை", "एलीट");

static String get needsWork =>
    text("Needs Work", "மேம்பாடு தேவை", "सुधार आवश्यक");

static String get noBatchAssignedToCoach =>
    text("No batch assigned to this coach", "இந்த பயிற்சியாளருக்கு பேட்ச் ஒதுக்கப்படவில்லை", "इस कोच को कोई बैच असाइन नहीं है");

static String get viewPerformanceAnalytics =>
    text("VIEW PERFORMANCE ANALYTICS", "செயல்திறன் பகுப்பாய்வைப் பாருங்கள்", "प्रदर्शन विश्लेषण देखें");

static String get performanceReportsTitle =>
    text("PERFORMANCE REPORTS", "செயல்திறன் அறிக்கைகள்", "प्रदर्शन रिपोर्ट");

static String get reportsPlayerAnalytics =>
    text("Reports & Player Analytics", "அறிக்கைகள் மற்றும் வீரர் பகுப்பாய்வு", "रिपोर्ट और खिलाड़ी विश्लेषण");

static String get cricHeroes =>
    text("CricHeroes", "CricHeroes", "CricHeroes");

static String get performanceReportsViewOnlyCricHeroesLater =>
    text("Performance reports are view-only now. Data will be updated through CricHeroes integration later.", "செயல்திறன் அறிக்கைகள் தற்போது பார்வைக்கு மட்டும். பின்னர் CricHeroes இணைப்பின் மூலம் தகவல் புதுப்பிக்கப்படும்.", "प्रदर्शन रिपोर्ट अभी केवल देखने के लिए हैं। बाद में CricHeroes एकीकरण से डेटा अपडेट होगा।");

static String get fielding =>
    text("Fielding", "பீல்டிங்", "फील्डिंग");

static String get coachRemarks =>
    text("Coach Remarks", "பயிற்சியாளர் குறிப்புகள்", "कोच टिप्पणियाँ");

static String get coachRemarksNoRemarks =>
    text("Coach Remarks: No remarks added", "பயிற்சியாளர் குறிப்புகள்: குறிப்புகள் சேர்க்கப்படவில்லை", "कोच टिप्पणियाँ: कोई टिप्पणी नहीं जोड़ी गई");

static String get noPerformanceReportsFound =>
    text("No performance reports found", "செயல்திறன் அறிக்கைகள் இல்லை", "कोई प्रदर्शन रिपोर्ट नहीं मिली");

static String get performanceDataSyncCricHeroesLater =>
    text("Performance data will sync from CricHeroes integration later", "செயல்திறன் தகவல் பின்னர் CricHeroes இணைப்பில் இருந்து ஒத்திசைக்கப்படும்", "प्रदर्शन डेटा बाद में CricHeroes एकीकरण से सिंक होगा");
// Add these before the final } in app_strings.dart.
// Skip any getter that already exists.

static String get analytics =>
    text("Analytics", "பகுப்பாய்வு", "विश्लेषण");

static String get performanceInsightCenter =>
    text("Performance insight center", "செயல்திறன் பார்வை மையம்", "प्रदर्शन अंतर्दृष्टि केंद्र");

static String get skillAverageChart =>
    text("SKILL AVERAGE CHART", "திறன் சராசரி விளக்கப்படம்", "कौशल औसत चार्ट");

static String get topPerformers =>
    text("TOP PERFORMERS", "சிறந்த செயல்திறன் வீரர்கள்", "शीर्ष प्रदर्शनकर्ता");

static String get top =>
    text("Top", "சிறந்தவர்", "शीर्ष");

static String get analyticsViewOnlyCricHeroesLater =>
    text("Analytics are view-only now. Data will sync from CricHeroes integration later.", "பகுப்பாய்வு தற்போது பார்வைக்கு மட்டும். பின்னர் CricHeroes இணைப்பிலிருந்து தகவல் ஒத்திசைக்கப்படும்.", "विश्लेषण अभी केवल देखने के लिए है। बाद में CricHeroes एकीकरण से डेटा सिंक होगा।");

static String get battingAverage =>
    text("Batting Avg", "பேட்டிங் சராசரி", "बल्लेबाजी औसत");

static String get bowlingAverage =>
    text("Bowling Avg", "பந்துவீச்சு சராசரி", "गेंदबाजी औसत");

static String get fieldingAverage =>
    text("Fielding Avg", "பீல்டிங் சராசரி", "फील्डिंग औसत");

static String get fitnessAverage =>
    text("Fitness Avg", "உடற்தகுதி சராசரி", "फिटनेस औसत");

static String get batShort =>
    text("BAT", "பேட்", "बैट");

static String get bowlShort =>
    text("BOWL", "பந்து", "बॉल");

static String get fieldShort =>
    text("FIELD", "பீல்டிங்", "फील्ड");

static String get fitShort =>
    text("FIT", "உடல்", "फिट");

static String get noPerformanceRecordsAvailable =>
    text("No performance records available", "செயல்திறன் பதிவுகள் இல்லை", "कोई प्रदर्शन रिकॉर्ड उपलब्ध नहीं");

static String get analyticsDataSyncCricHeroesLater =>
    text("Analytics data will sync from CricHeroes later", "பகுப்பாய்வு தகவல் பின்னர் CricHeroes இலிருந்து ஒத்திசைக்கப்படும்", "विश्लेषण डेटा बाद में CricHeroes से सिंक होगा");
// Add these before the final } in app_strings.dart.
// Skip any getter that already exists.

static String get unableLoadReports =>
    text("Unable to load reports", "அறிக்கைகளை ஏற்ற முடியவில்லை", "रिपोर्ट लोड नहीं हो सकीं");

static String get financeSummary =>
    text("FINANCE SUMMARY", "நிதி சுருக்கம்", "वित्त सारांश");

static String get collected =>
    text("Collected", "வசூலிக்கப்பட்டது", "संग्रहित");

static String get reportOverview =>
    text("REPORT OVERVIEW", "அறிக்கை கண்ணோட்டம்", "रिपोर्ट अवलोकन");

static String get totalRegistered =>
    text("Total registered", "மொத்த பதிவு", "कुल पंजीकृत");

static String get recordsMarked =>
    text("Records marked", "பதிவுகள் குறிக்கப்பட்டது", "रिकॉर्ड दर्ज");

static String get reportsSynced =>
    text("Reports synced", "அறிக்கைகள் ஒத்திசைக்கப்பட்டது", "रिपोर्ट सिंक");

static String get requestsReceived =>
    text("Requests received", "கோரிக்கைகள் பெறப்பட்டது", "अनुरोध प्राप्त");

static String get scheduledMatches =>
    text("Scheduled matches", "திட்டமிடப்பட்ட போட்டிகள்", "निर्धारित मैच");

static String get salaryBudget =>
    text("Salary Budget", "சம்பள பட்ஜெட்", "वेतन बजट");

static String get coachSalaries =>
    text("Coach salaries", "பயிற்சியாளர் சம்பளங்கள்", "कोच वेतन");

static String get reportsDashboardTitle =>
    text("REPORTS DASHBOARD", "அறிக்கை டாஷ்போர்டு", "रिपोर्ट डैशबोर्ड");

static String get academyInsightsSummary =>
    text("Academy insights and summary", "அகாடமி பார்வைகள் மற்றும் சுருக்கம்", "अकादमी अंतर्दृष्टि और सारांश");

static String get dashboard =>
    text("Dashboard", "டாஷ்போர்டு", "डैशबोर्ड");

static String get collectionInsight =>
    text("COLLECTION INSIGHT", "வசூல் பார்வை", "संग्रह अंतर्दृष्टि");

static String get feeCollectionIs =>
    text("Fee collection is", "கட்டண வசூல்", "फीस संग्रह");

static String get salaryBudgetIs =>
    text("Salary budget is", "சம்பள பட்ஜெட்", "वेतन बजट");

static String get attendanceRecords =>
    text("Attendance records", "வருகை பதிவுகள்", "उपस्थिति रिकॉर्ड");

static String get matchesScheduled =>
    text("Matches scheduled", "திட்டமிடப்பட்ட போட்டிகள்", "निर्धारित मैच");

static String get passion =>
    text("Passion", "ஆர்வம்", "जुनून");

static String get discipline =>
    text("Discipline", "ஒழுக்கம்", "अनुशासन");

static String get success =>
    text("Success", "வெற்றி", "सफलता");


static String get dueFeeAnalyticsTitle =>
    text("DUE FEE ANALYTICS", "நிலுவை கட்டண பகுப்பாய்வு", "बकाया शुल्क विश्लेषण");

static String get studentWisePendingFeeAnalysis =>
    text("Student-wise pending fee analysis", "மாணவர் வாரியான நிலுவை கட்டண பகுப்பாய்வு", "छात्र-वार लंबित शुल्क विश्लेषण");

static String get analyzePendingFeesPriority =>
    text("Analyze students with pending fees and prioritize high due payments.", "நிலுவை கட்டணம் உள்ள மாணவர்களை பகுப்பாய்வு செய்து அதிக நிலுவைத் தொகைகளை முன்னுரிமைப்படுத்தவும்.", "लंबित शुल्क वाले छात्रों का विश्लेषण करें और अधिक बकाया भुगतान को प्राथमिकता दें।");

static String get studentsHavePendingDues =>
    text("students have pending dues", "மாணவர்களுக்கு நிலுவை கட்டணம் உள்ளது", "छात्रों का शुल्क लंबित है");

static String get totalDue =>
    text("Total Due", "மொத்த நிலுவை", "कुल बकाया");

static String get dueStudents =>
    text("Due Students", "நிலுவை மாணவர்கள்", "बकाया छात्र");

static String get high =>
    text("High", "அதிகம்", "उच्च");

static String get medium =>
    text("Medium", "நடுத்தரம்", "मध्यम");

static String get low =>
    text("Low", "குறைவு", "कम");

static String get highDue =>
    text("High Due", "அதிக நிலுவை", "उच्च बकाया");

static String get mediumDue =>
    text("Medium Due", "நடுத்தர நிலுவை", "मध्यम बकाया");

static String get lowDue =>
    text("Low Due", "குறைந்த நிலுவை", "कम बकाया");

static String get noDue =>
    text("No Due", "நிலுவை இல்லை", "कोई बकाया नहीं");

static String get searchDueStudents =>
    text("Search due students by name, roll no or batch", "பெயர், ரோல் எண் அல்லது பேட்ச் மூலம் நிலுவை மாணவர்களை தேடவும்", "नाम, रोल नंबर या बैच से बकाया छात्रों को खोजें");

static String get due =>
    text("Due", "நிலுவை", "बकाया");

static String get noDueFeesFound =>
    text("No Due Fees Found", "நிலுவை கட்டணங்கள் இல்லை", "कोई बकाया शुल्क नहीं मिला");

static String get noPendingFeeRecordsAvailable =>
    text("No pending fee records are available.", "நிலுவை கட்டண பதிவுகள் இல்லை.", "कोई लंबित शुल्क रिकॉर्ड उपलब्ध नहीं है।");


static String get pendingOverview =>
    text("PENDING OVERVIEW", "நிலுவை கண்ணோட்டம்", "लंबित अवलोकन");

static String get totalAmount =>
    text("Total Amount", "மொத்த தொகை", "कुल राशि");

static String get withDue =>
    text("With Due", "நிலுவையுடன்", "बकाया सहित");

static String get feeEntries =>
    text("Fee Entries", "கட்டண பதிவுகள்", "शुल्क प्रविष्टियाँ");

static String get pendingFeeList =>
    text("PENDING FEE LIST", "நிலுவை கட்டண பட்டியல்", "लंबित शुल्क सूची");

static String get pendingFeesTitle =>
    text("PENDING FEES", "நிலுவை கட்டணங்கள்", "लंबित शुल्क");

static String get trackUnpaidStudentDues =>
    text("Track unpaid student dues", "செலுத்தாத மாணவர் நிலுவைகளை கண்காணிக்கவும்", "अदत्त छात्र बकाया ट्रैक करें");

static String get noPendingFeesFound =>
    text("No Pending Fees Found", "நிலுவை கட்டணங்கள் இல்லை", "कोई लंबित शुल्क नहीं मिला");

static String get allStudentsAreClear =>
    text("All students are clear", "அனைத்து மாணவர்களும் கட்டணம் செலுத்தியுள்ளனர்", "सभी छात्रों का भुगतान पूरा है");

static String get paymentRecords =>
    text("PAYMENT RECORDS", "கட்டண பதிவுகள்", "भुगतान रिकॉर्ड");

static String get paymentHistoryTitle =>
    text("PAYMENT HISTORY", "கட்டண வரலாறு", "भुगतान इतिहास");

static String get feePaymentTransactionRecords =>
    text("Fee payment transaction records", "கட்டண பரிவர்த்தனை பதிவுகள்", "शुल्क भुगतान लेनदेन रिकॉर्ड");

static String get payment =>
    text("Payment", "கட்டணம்", "भुगतान");

static String get noPaymentRecordsFound =>
    text("No payment records found", "கட்டண பதிவுகள் இல்லை", "कोई भुगतान रिकॉर्ड नहीं मिला");

static String get paymentRecordsAppearHere =>
    text("Payment records will appear here", "கட்டண பதிவுகள் இங்கே தோன்றும்", "भुगतान रिकॉर्ड यहां दिखाई देंगे");

static String get paymentStatusList =>
    text("PAYMENT STATUS LIST", "கட்டண நிலை பட்டியல்", "भुगतान स्थिति सूची");

static String get paymentStatusTitle =>
    text("PAYMENT STATUS", "கட்டண நிலை", "भुगतान स्थिति");

static String get paidPendingFeeTracking =>
    text("Paid and pending fee tracking", "செலுத்திய மற்றும் நிலுவை கட்டண கண்காணிப்பு", "भुगतान और लंबित शुल्क ट्रैकिंग");

static String get trackPaidPendingStudentFeeStatus =>
    text("Track paid and pending student fee status.", "மாணவர்களின் செலுத்திய மற்றும் நிலுவை கட்டண நிலையை கண்காணிக்கவும்.", "छात्रों की भुगतान और लंबित शुल्क स्थिति ट्रैक करें।");

static String get paidAmountLabel =>
    text("Paid ₹", "செலுத்தியது ₹", "भुगतान ₹");

static String get pendingAmountLabel =>
    text("Pending ₹", "நிலுவை ₹", "लंबित ₹");

static String get noPaymentStatusFound =>
    text("No Payment Status Found", "கட்டண நிலை பதிவுகள் இல்லை", "कोई भुगतान स्थिति नहीं मिली");

static String get noFeeRecordsForFilter =>
    text("No fee records available for this filter.", "இந்த வடிகட்டிக்கு கட்டண பதிவுகள் இல்லை.", "इस फ़िल्टर के लिए कोई शुल्क रिकॉर्ड उपलब्ध नहीं है।");

static String get feeReceipt =>
    text("Fee Receipt", "கட்டண ரசீது", "शुल्क रसीद");


static String get pendingAmount =>
    text("Pending Amount", "நிலுவை தொகை", "लंबित राशि");

static String get receiptPrintDownloadLater =>
    text("Receipt print/download can be added later.", "ரசீது அச்சிடுதல்/பதிவிறக்கம் பின்னர் சேர்க்கலாம்.", "रसीद प्रिंट/डाउनलोड बाद में जोड़ा जा सकता है।");

static String get feeReceiptsList =>
    text("FEE RECEIPTS LIST", "கட்டண ரசீது பட்டியல்", "शुल्क रसीद सूची");

static String get feeReceiptsTitle =>
    text("FEE RECEIPTS", "கட்டண ரசீதுகள்", "शुल्क रसीदें");


static String get receiptCenter =>
    text("Receipt Center", "ரசீது மையம்", "रसीद केंद्र");

static String get receipts =>
    text("receipts", "ரசீதுகள்", "रसीदें");

static String get searchStudentReceiptBatch =>
    text("Search by student, receipt no or batch", "மாணவர், ரசீது எண் அல்லது பேட்ச் மூலம் தேடவும்", "छात्र, रसीद नंबर या बैच से खोजें");

static String get noReceiptsFound =>
    text("No Receipts Found", "ரசீதுகள் இல்லை", "कोई रसीद नहीं मिली");

static String get noFeeReceiptRecordsAvailable =>
    text("No fee receipt records are available.", "கட்டண ரசீது பதிவுகள் இல்லை.", "कोई शुल्क रसीद रिकॉर्ड उपलब्ध नहीं है।");



  // ================= COACH SALARY =================
  static String get salaryMarkedAs => text("Salary marked as", "சம்பள நிலை மாற்றப்பட்டது:", "वेतन स्थिति बदली गई:");

  static String get salaryRecordDeleted => text("Salary record deleted", "சம்பள பதிவு நீக்கப்பட்டது", "वेतन रिकॉर्ड हटाया गया");

  static String get deleteSalaryRecord => text("Delete Salary Record", "சம்பள பதிவை நீக்கு", "वेतन रिकॉर्ड हटाएं");

  static String get deleteSalaryRecordConfirm => text("Are you sure you want to delete this salary record?", "இந்த சம்பள பதிவை நீக்க விரும்புகிறீர்களா?", "क्या आप यह वेतन रिकॉर्ड हटाना चाहते हैं?");

  static String get addCoachSalary => text("Add Coach Salary", "பயிற்சியாளர் சம்பளத்தை சேர்", "कोच वेतन जोड़ें");

  static String get noCoachUsersFoundEnterManually => text("No coach users found. You can enter manually.", "பயிற்சியாளர் பயனர்கள் இல்லை. கைமுறையாக உள்ளிடலாம்.", "कोई कोच उपयोगकर्ता नहीं मिला। आप मैन्युअल रूप से दर्ज कर सकते हैं।");

  static String get selectCoach => text("Select Coach", "பயிற்சியாளரை தேர்வு செய்க", "कोच चुनें");

  static String get coachName => text("Coach Name", "பயிற்சியாளர் பெயர்", "कोच का नाम");

  static String get role => text("Role", "பங்கு", "भूमिका");

  static String get salaryAmount => text("Salary Amount", "சம்பள தொகை", "वेतन राशि");

  static String get enterValidSalaryAmount => text("Please enter valid salary amount", "சரியான சம்பள தொகையை உள்ளிடவும்", "कृपया मान्य वेतन राशि दर्ज करें");

  static String get coachSalarySaved => text("Coach salary saved", "பயிற்சியாளர் சம்பளம் சேமிக்கப்பட்டது", "कोच वेतन सेव हुआ");

  static String get addSalary => text("Add Salary", "சம்பளம் சேர்", "वेतन जोड़ें");

  static String get salaryOverview => text("SALARY OVERVIEW", "சம்பள கண்ணோட்டம்", "वेतन अवलोकन");

  static String get budget => text("Budget", "பட்ஜெட்", "बजट");

  static String get remaining => text("Remaining", "மீதம்", "शेष");

  static String get entries => text("Entries", "பதிவுகள்", "प्रविष्टियाँ");

  static String get salaryRecords => text("SALARY RECORDS", "சம்பள பதிவுகள்", "वेतन रिकॉर्ड");

  static String get unknownCoach => text("Unknown Coach", "தெரியாத பயிற்சியாளர்", "अज्ञात कोच");

  static String get coachSalaryTitle => text("COACH SALARY", "பயிற்சியாளர் சம்பளம்", "कोच वेतन");

  static String get manageCoachMonthlySalary => text("Manage coach monthly salary", "பயிற்சியாளர் மாத சம்பளத்தை நிர்வகிக்கவும்", "कोच का मासिक वेतन प्रबंधित करें");

  static String get viewYourSalaryRecords => text("View your salary records", "உங்கள் சம்பள பதிவுகளை பாருங்கள்", "अपने वेतन रिकॉर्ड देखें");

  static String get salary => text("Salary", "சம்பளம்", "वेतन");

  static String get markPaid => text("Mark Paid", "செலுத்தியதாக குறி", "भुगतान चिह्नित करें");

  static String get markPending => text("Mark Pending", "நிலுவையாக குறி", "लंबित चिह्नित करें");

  static String get noSalaryRecordsFound => text("No Salary Records Found", "சம்பள பதிவுகள் இல்லை", "कोई वेतन रिकॉर्ड नहीं मिला");

  static String get clickAddSalaryCreateOne => text("Click Add Salary to create one", "புதிய பதிவு உருவாக்க Add Salary அழுத்தவும்", "नया रिकॉर्ड बनाने के लिए Add Salary दबाएं");

  static String get noSalaryRecordForAccount => text("No salary record available for your account", "உங்கள் கணக்கிற்கு சம்பள பதிவு இல்லை", "आपके खाते के लिए कोई वेतन रिकॉर्ड उपलब्ध नहीं है");



  // ================= FEE REPORT & MONTHLY COLLECTION =================
  static String get pdfReportGenerated =>
      text("PDF report generated", "PDF அறிக்கை உருவாக்கப்பட்டது", "PDF रिपोर्ट बनाई गई");

  static String get pdfFailed =>
      text("PDF failed", "PDF தோல்வியடைந்தது", "PDF विफल");

  static String get excelReportGenerated =>
      text("Excel report generated", "Excel அறிக்கை உருவாக்கப்பட்டது", "Excel रिपोर्ट बनाई गई");

  static String get excelFailed =>
      text("Excel failed", "Excel தோல்வியடைந்தது", "Excel विफल");

  static String get feeReportSummary =>
      text("FEE REPORT SUMMARY", "கட்டண அறிக்கை சுருக்கம்", "शुल्क रिपोर्ट सारांश");

  static String get paidRecords =>
      text("Paid Records", "செலுத்திய பதிவுகள்", "भुगतान रिकॉर्ड");

  static String get noFeeRecordForUser =>
      text("No fee record available for this user", "இந்த பயனருக்கு கட்டண பதிவு இல்லை", "इस उपयोगकर्ता के लिए कोई शुल्क रिकॉर्ड उपलब्ध नहीं है");

  static String get fullyPaid =>
      text("Fully Paid", "முழுமையாக செலுத்தப்பட்டது", "पूर्ण भुगतान");

  static String get pendingFeeRecords =>
      text("PENDING FEE RECORDS", "நிலுவை கட்டண பதிவுகள்", "लंबित शुल्क रिकॉर्ड");

  static String get noPendingFees =>
      text("No pending fees", "நிலுவை கட்டணங்கள் இல்லை", "कोई लंबित शुल्क नहीं");

  static String get allFeeRecordsCompleted =>
      text("All fee records are completed", "அனைத்து கட்டண பதிவுகளும் முடிந்தது", "सभी शुल्क रिकॉर्ड पूर्ण हैं");

  static String get feeReportsTitle =>
      text("FEE REPORTS", "கட்டண அறிக்கைகள்", "शुल्क रिपोर्ट");

  static String get collectionSummaryExports =>
      text("Collection summary and exports", "வசூல் சுருக்கம் மற்றும் ஏற்றுமதி", "संग्रह सारांश और निर्यात");

  static String get collectedFrom =>
      text("collected from", "வசூலிக்கப்பட்டது / மொத்தம்", "में से संग्रहित");

  static String get dayWiseCollection =>
      text("DAY WISE COLLECTION", "நாள் வாரியான வசூல்", "दिन-वार संग्रह");

  static String get monthlyTransactions =>
      text("MONTHLY TRANSACTIONS", "மாதாந்திர பரிவர்த்தனைகள்", "मासिक लेनदेन");

  static String get monthlyCollectionTitle =>
      text("MONTHLY COLLECTION", "மாதாந்திர வசூல்", "मासिक संग्रह");

  static String get monthlyFeeCollectionSummary =>
      text("Monthly fee collection summary", "மாதாந்திர கட்டண வசூல் சுருக்கம்", "मासिक शुल्क संग्रह सारांश");

  static String get tapArrowsChangeMonth =>
      text("Tap arrows to change month", "மாதத்தை மாற்ற அம்புகளை அழுத்தவும்", "माह बदलने के लिए तीर दबाएं");

  static String get monthlyFeeCollectionOverview =>
      text("Monthly fee collection, pending dues and transaction overview.", "மாதாந்திர கட்டண வசூல், நிலுவை மற்றும் பரிவர்த்தனை கண்ணோட்டம்.", "मासिक शुल्क संग्रह, लंबित बकाया और लेनदेन अवलोकन।");

  static String get paidPending =>
      text("Paid / Pending", "செலுத்தியது / நிலுவை", "भुगतान / लंबित");

  static String get noMonthlyCollectionFound =>
      text("No Monthly Collection Found", "மாதாந்திர வசூல் இல்லை", "कोई मासिक संग्रह नहीं मिला");

  static String get noFeeRecordsSelectedMonth =>
      text("No fee records are available for this selected month.", "தேர்ந்தெடுக்கப்பட்ட மாதத்திற்கு கட்டண பதிவுகள் இல்லை.", "चयनित माह के लिए कोई शुल्क रिकॉर्ड उपलब्ध नहीं है।");

static String get applyLeave =>
    text(
      "Apply Leave",
      "விடுப்பு விண்ணப்பம்",
      "छुट्टी के लिए आवेदन",
    );
static String get coachAttendanceTodaySubtitle => text(
  "Mark today attendance for weekly assigned sessions",
  "வாராந்திர ஒதுக்கப்பட்ட அமர்வுகளுக்கான இன்றைய வருகையை பதிவு செய்க",
  "साप्ताहिक असाइन सेशन के लिए आज की उपस्थिति दर्ज करें",
);

static String get coachAttendanceHistorySubtitle => text(
  "Review assigned student attendance history",
  "ஒதுக்கப்பட்ட மாணவர்களின் வருகை வரலாற்றைப் பாருங்கள்",
  "असाइन किए गए छात्रों का उपस्थिति इतिहास देखें",
);

static String get coachAttendanceCalendarSubtitle => text(
  "Track assigned student-wise attendance calendar",
  "ஒதுக்கப்பட்ட மாணவர் வாரியான வருகை காலண்டரை கண்காணிக்கவும்",
  "असाइन किए गए छात्र-वार उपस्थिति कैलेंडर देखें",
);

static String get markAttendanceTitleSingleLine => text(
  "Mark Attendance",
  "வருகையை பதிவு செய்க",
  "उपस्थिति दर्ज करें",
);

static String get takeTodayAttendanceCurrentWeek => text(
  "Take today attendance for current week sessions",
  "நடப்பு வார அமர்வுகளுக்கான இன்றைய வருகையை பதிவு செய்க",
  "वर्तमान सप्ताह के सेशन के लिए आज की उपस्थिति दर्ज करें",
);

static String get viewAssignedAttendanceHistory => text(
  "View previous attendance records of assigned students",
  "ஒதுக்கப்பட்ட மாணவர்களின் முந்தைய வருகை பதிவுகளைப் பாருங்கள்",
  "असाइन किए गए छात्रों के पिछले उपस्थिति रिकॉर्ड देखें",
);

static String get viewAssignedAttendanceCalendar => text(
  "View assigned student-wise attendance calendar",
  "ஒதுக்கப்பட்ட மாணவர் வாரியான வருகை காலண்டரைப் பாருங்கள்",
  "असाइन किए गए छात्र-वार उपस्थिति कैलेंडर देखें",
);

static String get coachAttendanceTitle => text(
  "COACH ATTENDANCE",
  "பயிற்சியாளர் வருகை",
  "कोच उपस्थिति",
);

static String get markReviewTrackAttendance => text(
  "Mark, review and track attendance",
  "வருகையை பதிவு செய்து, பார்த்து, கண்காணிக்கவும்",
  "उपस्थिति दर्ज करें, समीक्षा करें और ट्रैक करें",
);

static String get coachManageWeeklyAttendance => text(
  "Coach can manage attendance for current weekly assigned sessions",
  "பயிற்சியாளர் நடப்பு வாரம் ஒதுக்கப்பட்ட அமர்வுகளுக்கான வருகையை நிர்வகிக்கலாம்",
  "कोच वर्तमान सप्ताह के असाइन सेशन की उपस्थिति प्रबंधित कर सकता है",
);

static String get coachAttendanceFilteringInfo => text(
  "History and Calendar use weekly coach assignments for role-based filtering.",
  "வரலாறும் காலண்டரும் வாராந்திர பயிற்சியாளர் ஒதுக்கீடுகளைப் பயன்படுத்தி அணுகலை வடிகட்டுகின்றன.",
  "इतिहास और कैलेंडर भूमिका-आधारित फ़िल्टरिंग के लिए साप्ताहिक कोच असाइनमेंट का उपयोग करते हैं।",
);

static String get mark => text("Mark", "பதிவு", "दर्ज करें");
static String get roleLabel => text("Role", "பங்கு", "भूमिका");
static String get coachLabel => text("Coach", "பயிற்சியாளர்", "कोच");
static String get coachStudentsAssignedSubtitle => text("View students assigned to your batches", "உங்கள் பேட்ச்களுக்கு ஒதுக்கப்பட்ட மாணவர்களைப் பாருங்கள்", "अपने बैचों को असाइन किए गए छात्रों को देखें");
static String get coachStudentAttendanceSubtitle => text("Check student attendance records", "மாணவர் வருகை பதிவுகளைச் சரிபார்க்கவும்", "छात्र उपस्थिति रिकॉर्ड जांचें");
static String get coachStudentPerformanceSubtitle => text("Track student performance reports", "மாணவர் செயல்திறன் அறிக்கைகளை கண்காணிக்கவும்", "छात्र प्रदर्शन रिपोर्ट ट्रैक करें");
static String get assignedStudentsTitle => text("Assigned Students", "ஒதுக்கப்பட்ட மாணவர்கள்", "असाइन किए गए छात्र");
static String get viewYourBatchStudents => text("View your batch students", "உங்கள் பேட்ச் மாணவர்களைப் பாருங்கள்", "अपने बैच के छात्रों को देखें");
static String get studentAttendanceTitle => text("Student Attendance", "மாணவர் வருகை", "छात्र उपस्थिति");
static String get viewAssignedStudentsAttendance => text("View assigned students attendance", "ஒதுக்கப்பட்ட மாணவர்களின் வருகையைப் பாருங்கள்", "असाइन किए गए छात्रों की उपस्थिति देखें");
static String get studentPerformanceTitle => text("Student Performance", "மாணவர் செயல்திறன்", "छात्र प्रदर्शन");
static String get viewAssignedStudentsPerformance => text("View assigned students performance", "ஒதுக்கப்பட்ட மாணவர்களின் செயல்திறனைப் பாருங்கள்", "असाइन किए गए छात्रों का प्रदर्शन देखें");
static String get coachStudentsTitle => text("COACH STUDENTS", "பயிற்சியாளர் மாணவர்கள்", "कोच छात्र");
static String get studentModuleTitle => text("STUDENT MODULE", "மாணவர் மாட்யூல்", "छात्र मॉड्यूल");
static String get assignedStudentsAttendancePerformance => text("Assigned students, attendance and performance", "ஒதுக்கப்பட்ட மாணவர்கள், வருகை மற்றும் செயல்திறன்", "असाइन छात्र, उपस्थिति और प्रदर्शन");
static String get coachAssignedBatchStudentsOnly => text("Coach can view assigned batch students only", "பயிற்சியாளர் ஒதுக்கப்பட்ட பேட்ச் மாணவர்களை மட்டுமே பார்க்க முடியும்", "कोच केवल असाइन किए गए बैच के छात्रों को देख सकता है");
static String get coachStudentFilteringInfo => text("Student data is filtered using assigned batches. If the list is empty, check the coach assignment and student batch fields.", "மாணவர் தரவு ஒதுக்கப்பட்ட பேட்ச்களைப் பயன்படுத்தி வடிகட்டப்படுகிறது. பட்டியல் காலியாக இருந்தால், பயிற்சியாளர் ஒதுக்கீடு மற்றும் மாணவர் பேட்ச் புலங்களைச் சரிபார்க்கவும்.", "छात्र डेटा असाइन किए गए बैचों से फ़िल्टर होता है। सूची खाली होने पर कोच असाइनमेंट और छात्र बैच फ़ील्ड जांचें।");
static String get wise => text("Wise", "வாரியாக", "वार");
static String get only => text("Only", "மட்டும்", "केवल");
static String get feedback => text("Feedback", "கருத்து", "प्रतिक्रिया");

static String get noCoachLoggedIn => text("No Coach Logged In", "பயிற்சியாளர் உள்நுழையவில்லை", "कोई कोच लॉग इन नहीं है");
static String get loginAsCoachToViewStudents => text("Please login as coach to view assigned students.", "ஒதுக்கப்பட்ட மாணவர்களைப் பார்க்க பயிற்சியாளராக உள்நுழையவும்.", "असाइन किए गए छात्रों को देखने के लिए कोच के रूप में लॉग इन करें।");
static String get weeklyAssignmentError => text("Weekly Assignment Error", "வாராந்திர ஒதுக்கீட்டு பிழை", "साप्ताहिक असाइनमेंट त्रुटि");
static String get adminNotAssignedCurrentWeekSession => text("Admin has not assigned any session to this coach for the current week.", "நடப்பு வாரத்திற்கு இந்த பயிற்சியாளருக்கு அட்மின் எந்த அமர்வையும் ஒதுக்கவில்லை.", "एडमिन ने इस सप्ताह के लिए इस कोच को कोई सेशन असाइन नहीं किया है।");
static String get studentsLoadingError => text("Students Loading Error", "மாணவர்களை ஏற்றுவதில் பிழை", "छात्र लोड करने में त्रुटि");
static String get currentWeekSessionsTitle => text("CURRENT WEEK SESSIONS", "நடப்பு வார அமர்வுகள்", "वर्तमान सप्ताह के सेशन");
static String get currentWeekCoachStudentCenter => text("Current week coach student center", "நடப்பு வார பயிற்சியாளர் மாணவர் மையம்", "वर्तमान सप्ताह का कोच छात्र केंद्र");
static String get assignedStudentCenter => text("Assigned Student Center", "ஒதுக்கப்பட்ட மாணவர் மையம்", "असाइन छात्र केंद्र");
static String get noStudentsInCurrentWeekSessions => text("No students found in current week assigned sessions", "நடப்பு வாரம் ஒதுக்கப்பட்ட அமர்வுகளில் மாணவர்கள் இல்லை", "वर्तमान सप्ताह के असाइन सेशन में कोई छात्र नहीं मिला");
static String get loginAsCoachToViewAttendance => text(
  "Please login as coach to view student attendance.",
  "மாணவர் வருகையைப் பார்க்க பயிற்சியாளராக உள்நுழையவும்.",
  "छात्र उपस्थिति देखने के लिए कोच के रूप में लॉग इन करें।",
);

static String get currentWeekAssignedSessionOverview => text(
  "Current week assigned session overview",
  "நடப்பு வார ஒதுக்கப்பட்ட அமர்வு சுருக்கம்",
  "वर्तमान सप्ताह के असाइन सेशन का अवलोकन",
);

static String get currentWeekAttendance => text(
  "Current Week Attendance",
  "நடப்பு வார வருகை",
  "वर्तमान सप्ताह की उपस्थिति",
);

static String get presentShort => text(
  "P",
  "வ",
  "उ",
);

static String get absentShort => text(
  "A",
  "வரா",
  "अनु",
);

static String get leaveShort => text(
  "L",
  "வி",
  "छु",
);

static String get noAttendanceDataFound => text(
  "No Attendance Data Found",
  "வருகை தரவு இல்லை",
  "कोई उपस्थिति डेटा नहीं मिला",
);

static String get noStudentsForCoachCurrentWeek => text(
  "No students are available in this coach current week assigned sessions.",
  "இந்த பயிற்சியாளரின் நடப்பு வார ஒதுக்கப்பட்ட அமர்வுகளில் மாணவர்கள் இல்லை.",
  "इस कोच के वर्तमान सप्ताह के असाइन सेशन में कोई छात्र उपलब्ध नहीं है।",
);


static String get loginAsCoachToViewPerformance => text(
  "Please login as coach to view student performance.",
  "மாணவர் செயல்திறனைப் பார்க்க பயிற்சியாளராக உள்நுழையவும்.",
  "छात्र प्रदर्शन देखने के लिए कोच के रूप में लॉग इन करें।",
);

static String get noCurrentWeekSessionAssignedToCoach => text(
  "No current-week session is assigned to this coach yet.",
  "இந்த பயிற்சியாளருக்கு நடப்பு வார அமர்வு இன்னும் ஒதுக்கப்படவில்லை.",
  "इस कोच को वर्तमान सप्ताह का कोई सेशन अभी असाइन नहीं किया गया है।",
);

static String get assignedBatchPerformanceOverview => text(
  "Assigned session performance overview",
  "ஒதுக்கப்பட்ட அமர்வு செயல்திறன் சுருக்கம்",
  "असाइन सेशन प्रदर्शन का अवलोकन",
);

static String get assignedStudentPerformance => text(
  "Assigned Student Performance",
  "ஒதுக்கப்பட்ட மாணவர் செயல்திறன்",
  "असाइन छात्र प्रदर्शन",
);


static String get noPerformanceDataFound => text(
  "No Performance Data Found",
  "செயல்திறன் தரவு இல்லை",
  "कोई प्रदर्शन डेटा नहीं मिला",
);

static String get noStudentsForCoachAssignedSessions => text(
  "No students are available in this coach's assigned sessions.",
  "இந்த பயிற்சியாளரின் ஒதுக்கப்பட்ட அமர்வுகளில் மாணவர்கள் இல்லை.",
  "इस कोच के असाइन सेशन में कोई छात्र उपलब्ध नहीं है।",
);

static String get coachProfileUnavailable => text(
  "Coach profile is not available in the users collection.",
  "பயனர்கள் தொகுப்பில் பயிற்சியாளர் சுயவிவரம் கிடைக்கவில்லை.",
  "यूज़र्स कलेक्शन में कोच प्रोफ़ाइल उपलब्ध नहीं है।",
);
static String get coachPerfUpdateSkillsSubtitle => text(
  "Update player performance and skills",
  "வீரர் செயல்திறன் மற்றும் திறன்களை புதுப்பிக்கவும்",
  "खिलाड़ी का प्रदर्शन और कौशल अपडेट करें",
);

static String get coachPerfReportsSubtitle => text(
  "View student performance reports",
  "மாணவர் செயல்திறன் அறிக்கைகளைப் பாருங்கள்",
  "छात्र प्रदर्शन रिपोर्ट देखें",
);

static String get coachPerfFeedbackSubtitle => text(
  "Manage coach feedback and skill notes",
  "பயிற்சியாளர் கருத்து மற்றும் திறன் குறிப்புகளை நிர்வகிக்கவும்",
  "कोच प्रतिक्रिया और कौशल नोट्स प्रबंधित करें",
);

static String get coachPerfUpdatePerformance => text(
  "Update Performance",
  "செயல்திறனை புதுப்பிக்கவும்",
  "प्रदर्शन अपडेट करें",
);

static String get coachPerfTrackGrowthSkills => text(
  "Track player growth and skills",
  "வீரர் வளர்ச்சி மற்றும் திறன்களை கண்காணிக்கவும்",
  "खिलाड़ी की प्रगति और कौशल ट्रैक करें",
);

static String get coachPerfBattingUpdate => text(
  "Batting Update",
  "பேட்டிங் புதுப்பிப்பு",
  "बल्लेबाजी अपडेट",
);

static String get coachPerfUpdateBatting => text(
  "Update batting performance",
  "பேட்டிங் செயல்திறனை புதுப்பிக்கவும்",
  "बल्लेबाजी प्रदर्शन अपडेट करें",
);

static String get coachPerfBowlingUpdate => text(
  "Bowling Update",
  "பந்துவீச்சு புதுப்பிப்பு",
  "गेंदबाजी अपडेट",
);

static String get coachPerfUpdateBowling => text(
  "Update bowling performance",
  "பந்துவீச்சு செயல்திறனை புதுப்பிக்கவும்",
  "गेंदबाजी प्रदर्शन अपडेट करें",
);

static String get coachPerfStudentWiseReport => text(
  "View student-wise performance report",
  "மாணவர் வாரியான செயல்திறன் அறிக்கையைப் பாருங்கள்",
  "छात्र-वार प्रदर्शन रिपोर्ट देखें",
);

static String get coachPerfMonthlyReport => text(
  "Monthly Report",
  "மாதாந்திர அறிக்கை",
  "मासिक रिपोर्ट",
);

static String get coachPerfViewMonthlyProgress => text(
  "View monthly progress report",
  "மாதாந்திர முன்னேற்ற அறிக்கையைப் பாருங்கள்",
  "मासिक प्रगति रिपोर्ट देखें",
);

static String get coachPerfProgressAnalytics => text(
  "Progress Analytics",
  "முன்னேற்ற பகுப்பாய்வு",
  "प्रगति विश्लेषण",
);

static String get coachPerfAnalyzeGrowth => text(
  "Analyze growth and improvement",
  "வளர்ச்சி மற்றும் மேம்பாட்டை பகுப்பாய்வு செய்யவும்",
  "विकास और सुधार का विश्लेषण करें",
);

static String get coachPerfCoachFeedback => text(
  "Coach Feedback",
  "பயிற்சியாளர் கருத்து",
  "कोच प्रतिक्रिया",
);

static String get coachPerfAddFeedback => text(
  "Add coach feedback for students",
  "மாணவர்களுக்கு பயிற்சியாளர் கருத்தைச் சேர்க்கவும்",
  "छात्रों के लिए कोच प्रतिक्रिया जोड़ें",
);

static String get coachPerfSkillNotes => text(
  "Skill Notes",
  "திறன் குறிப்புகள்",
  "कौशल नोट्स",
);

static String get coachPerfAddSkillNotes => text(
  "Add skill improvement notes",
  "திறன் மேம்பாட்டு குறிப்புகளைச் சேர்க்கவும்",
  "कौशल सुधार नोट्स जोड़ें",
);

static String get coachPerfImprovementStatus => text(
  "Improvement Status",
  "மேம்பாட்டு நிலை",
  "सुधार स्थिति",
);

static String get coachPerfTrackImprovement => text(
  "Track student improvement status",
  "மாணவர் மேம்பாட்டு நிலையை கண்காணிக்கவும்",
  "छात्र सुधार स्थिति ट्रैक करें",
);

static String get coachPerfPageTitle => text(
  "COACH PERFORMANCE",
  "பயிற்சியாளர் செயல்திறன்",
  "कोच प्रदर्शन",
);

static String get coachPerfModuleTitle => text(
  "PERFORMANCE MODULE",
  "செயல்திறன் மாட்யூல்",
  "प्रदर्शन मॉड्यूल",
);

static String get coachPerfUpdateProgress => text(
  "Update player performance and progress",
  "வீரர் செயல்திறன் மற்றும் முன்னேற்றத்தை புதுப்பிக்கவும்",
  "खिलाड़ी का प्रदर्शन और प्रगति अपडेट करें",
);

static String get coachPerfAssignedStudentsOnly => text(
  "Coach can update reports for assigned students",
  "பயிற்சியாளர் ஒதுக்கப்பட்ட மாணவர்களின் அறிக்கைகளை புதுப்பிக்கலாம்",
  "कोच असाइन किए गए छात्रों की रिपोर्ट अपडेट कर सकता है",
);

static String get coachPerfInfoMessage => text(
  "All performance actions currently open the same performance report screen.",
  "அனைத்து செயல்திறன் செயல்களும் தற்போது ஒரே செயல்திறன் அறிக்கை திரையைத் திறக்கின்றன.",
  "सभी प्रदर्शन क्रियाएँ अभी एक ही प्रदर्शन रिपोर्ट स्क्रीन खोलती हैं।",
);

static String get now => text("Now", "இப்போது", "अभी");
static String get add => text("Add", "சேர்", "जोड़ें");
static String get noUserLoggedIn => text(
  "No user logged in",
  "பயனர் உள்நுழையவில்லை",
  "कोई उपयोगकर्ता लॉग इन नहीं है",
);

static String get coachDetailsNotFound =>
    text(
      "Coach details not found",
      "பயிற்சியாளர் விவரங்கள் கிடைக்கவில்லை",
      "कोच का विवरण नहीं मिला",
    );

static String get weeklySessions =>
    text(
      "weekly sessions",
      "வாராந்திர அமர்வுகள்",
      "साप्ताहिक सेशन",
    );
}
