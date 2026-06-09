import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;
  final String name;
  final String age;
  final String batch;
  final String rollNo;
  final String parentName;
  final String phone;
  final String attendance;
  final String feeStatus;

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
    required this.name,
    required this.age,
    required this.batch,
    required this.rollNo,
    required this.parentName,
    required this.phone,
    required this.attendance,
    required this.feeStatus,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  Future<void> deleteStudent() async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student deleted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  Future<void> updateStudent({
    required String name,
    required String age,
    required String batch,
    required String parentName,
    required String phone,
    required String rollNo,
    required String feeStatus,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .update({
        'name': name.trim(),
        'age': age.trim(),
        'batch': batch.trim(),
        'parentName': parentName.trim(),
        'phone': phone.trim(),
        'rollNo': rollNo.trim(),
        'feeStatus': feeStatus.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student updated successfully")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  void confirmDelete(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await deleteStudent();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void showEditDialog(Map<String, dynamic> data) {
    final nameController =
        TextEditingController(text: data['name']?.toString() ?? '');
    final ageController =
        TextEditingController(text: data['age']?.toString() ?? '');
    final batchController =
        TextEditingController(text: data['batch']?.toString() ?? '');
    final parentNameController =
        TextEditingController(text: data['parentName']?.toString() ?? '');
    final phoneController =
        TextEditingController(text: data['phone']?.toString() ?? '');
    final rollNoController =
        TextEditingController(text: data['rollNo']?.toString() ?? '');
    final feeStatusController =
        TextEditingController(text: data['feeStatus']?.toString() ?? 'Pending');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Student"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _editField("Student Name", nameController),
              _editField(
                "Age",
                ageController,
                keyboardType: TextInputType.number,
              ),
              _editField("Batch", batchController),
              _editField("Parent Name", parentNameController),
              _editField(
                "Phone Number",
                phoneController,
                keyboardType: TextInputType.phone,
              ),
              _editField("Roll No", rollNoController),
              _editField("Fee Status", feeStatusController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroon,
              foregroundColor: gold,
            ),
            onPressed: () async {
              await updateStudent(
                name: nameController.text,
                age: ageController.text,
                batch: batchController.text,
                parentName: parentNameController.text,
                phone: phoneController.text,
                rollNo: rollNoController.text,
                feeStatus: feeStatusController.text,
              );

              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null) return fallback;

    final text = value.toString().trim();
    if (text.isEmpty) return fallback;

    return text;
  }

  int _numberFromPercent(String value) {
    final cleaned = value.replaceAll("%", "").trim();
    return int.tryParse(cleaned) ?? 0;
  }

  String _feeAmountFromData(Map<String, dynamic> data) {
    final pendingAmount = data['pendingAmount'];
    final totalFee = data['totalFee'];
    final paidAmount = data['paidAmount'];

    if (pendingAmount != null) return "₹$pendingAmount";
    if (totalFee != null && paidAmount != null) {
      final total = int.tryParse(totalFee.toString()) ?? 0;
      final paid = int.tryParse(paidAmount.toString()) ?? 0;
      return "₹${total - paid}";
    }
    return "₹0";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Student not found")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final name = _text(data, 'name', 'No Name');
        final age = _text(data, 'age', '0');
        final batch = _text(data, 'batch', 'No Batch');
        final rollNo = _text(data, 'rollNo', '#YGCA');
        final parentName = _text(data, 'parentName', 'Not Added');
        final phone = _text(data, 'phone', '');
        final attendance = _text(data, 'attendance', '0%');
        final feeStatus = _text(data, 'feeStatus', 'Pending');
        final feeAmount = _feeAmountFromData(data);

        final initials = name
            .split(" ")
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        final attendanceValue = _numberFromPercent(attendance);

        return Scaffold(
          backgroundColor: bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _profileHero(
                  initials: initials,
                  name: name,
                  age: age,
                  batch: batch,
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.22,
                    children: [
                      _statCard(
                        icon: Icons.verified,
                        title: "ATTENDANCE",
                        value: "$attendanceValue%",
                        subtitle: attendanceValue >= 75 ? "Good" : "Needs Focus",
                        color: Colors.green,
                      ),
                      _statCard(
                        icon: Icons.currency_rupee,
                        title: "FEE STATUS",
                        value: feeStatus == "Paid" ? "Paid" : feeAmount,
                        subtitle: feeStatus,
                        color: Colors.orange,
                      ),
                      _statCard(
                        icon: Icons.groups,
                        title: "BATCH",
                        value: batch,
                        subtitle: "Assigned Batch",
                        color: Colors.blue,
                      ),
                      _statCard(
                        icon: Icons.tag,
                        title: "ROLL NO.",
                        value: rollNo,
                        subtitle: "YGCA Student",
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
                                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _infoCard(
                          title: "PERSONAL INFORMATION",
                          children: [
                            _infoRow("Full Name", name),
                            _infoRow("Age", "$age Years"),
                            _infoRow("Batch", batch),
                            _infoRow("Roll Number", rollNo),
                            _infoRow("Status", "Active"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoCard(
                    title: "PARENT / GUARDIAN",
                    children: [
                      _infoRow("Parent Name", parentName),
                      _infoRow("Phone Number", phone),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoCard(
                    title: "QUICK ACTIONS",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              icon: Icons.calendar_month,
                              title: "Attendance\nCalendar",
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AttendanceCalendarScreen(
                                      studentId: widget.studentId,
                                      name: name,
                                      batch: batch,
                                      rollNo: rollNo,
                                      attendance: attendance,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionCard(
                              icon: Icons.history,
                              title: "Attendance\nHistory",
                              color: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AttendanceHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              icon: Icons.edit,
                              title: "Edit\nStudent",
                              color: Colors.blue,
                              onTap: () => showEditDialog(data),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionCard(
                              icon: Icons.delete,
                              title: "Delete\nStudent",
                              color: Colors.red,
                              onTap: () => confirmDelete(name),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroon,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(55),
                          ),
                          onPressed: () => showEditDialog(data),
                          icon: const Icon(Icons.edit),
                          label: const Text("EDIT STUDENT"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            minimumSize: const Size.fromHeight(55),
                          ),
                          onPressed: () => confirmDelete(name),
                          icon: const Icon(Icons.delete),
                          label: const Text("DELETE STUDENT"),
                        ),
                      ),
                    ],
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
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 60,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "STUDENT DETAILS",
              style: TextStyle(
                color: gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  Widget _profileHero({
    required String initials,
    required String name,
    required String age,
    required String batch,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/home_hero_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black.withOpacity(0.45),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: maroon,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Age $age Years | $batch",
                      style: TextStyle(color: gold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Discipline today, Champion tomorrow.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(subtitle),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}