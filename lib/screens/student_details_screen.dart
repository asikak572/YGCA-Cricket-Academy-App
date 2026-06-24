import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/theme_controller.dart';

import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';
import 'digital_id_card_screen.dart';

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
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool uploading = false;
  bool deleting = false;

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString().trim();
  }

  int _percent(String value) {
    return int.tryParse(value.replaceAll("%", "").trim()) ?? 0;
  }

  int _amount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString().replaceAll(',', '').trim()) ?? 0;
  }

  String _feeAmount(Map<String, dynamic> data) {
    final pendingAmount = data['pendingAmount'];
    final totalFee = data['totalFee'];
    final paidAmount = data['paidAmount'];

    if (pendingAmount != null) {
      return "₹${_amount(pendingAmount)}";
    }

    if (totalFee != null && paidAmount != null) {
      final total = _amount(totalFee);
      final paid = _amount(paidAmount);
      final pending = total - paid;
      return "₹${pending < 0 ? 0 : pending}";
    }

    return "₹0";
  }

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

  Future<void> _uploadPhoto() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedImage == null) return;

      setState(() => uploading = true);

      final file = File(pickedImage.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child('student_photos')
          .child('${widget.studentId}.jpg');

      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .set({
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(widget.studentId).set({
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student photo uploaded"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Photo upload failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> _deleteStudent() async {
    setState(() => deleting = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      batch.delete(firestore.collection('students').doc(widget.studentId));
      batch.delete(firestore.collection('users').doc(widget.studentId));

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Delete failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => deleting = false);
    }
  }

  Future<void> _updateStudent({
    required String name,
    required String age,
    required String batch,
    required String parentName,
    required String phone,
    required String rollNo,
    required String feeStatus,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final updateData = {
      'name': name.trim(),
      'age': age.trim(),
      'batch': batch.trim(),
      'parentName': parentName.trim(),
      'phone': phone.trim(),
      'rollNo': rollNo.trim(),
      'feeStatus': feeStatus.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await firestore.collection('students').doc(widget.studentId).set(
          updateData,
          SetOptions(merge: true),
        );

    await firestore.collection('users').doc(widget.studentId).set(
      {
        'name': name.trim(),
        'batch': batch.trim(),
        'rollNo': rollNo.trim(),
        'feeStatus': feeStatus.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Student updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDelete(String name, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Delete Student",
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "Are you sure you want to delete $name?",
          style: TextStyle(color: _secondaryText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: deleting ? null : () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: deleting
                ? null
                : () async {
                    Navigator.pop(context);
                    await _deleteStudent();
                  },
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(Map<String, dynamic> data, bool isDark) async {
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

    String feeStatus = data['feeStatus']?.toString() ?? 'Pending';
    if (!['Pending', 'Paid', 'Partial'].contains(feeStatus)) {
      feeStatus = 'Pending';
    }

    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: _card(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: red.withOpacity(0.16),
                    child: Icon(Icons.edit_rounded, color: isDark ? gold : maroon),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Edit Student",
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _editField(
                      isDark,
                      "Student Name",
                      nameController,
                      Icons.person_rounded,
                    ),
                    _editField(
                      isDark,
                      "Age",
                      ageController,
                      Icons.cake_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    _editField(
                      isDark,
                      "Batch",
                      batchController,
                      Icons.groups_rounded,
                    ),
                    _editField(
                      isDark,
                      "Parent Name",
                      parentNameController,
                      Icons.family_restroom_rounded,
                    ),
                    _editField(
                      isDark,
                      "Phone Number",
                      phoneController,
                      Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    _editField(
                      isDark,
                      "Roll No",
                      rollNoController,
                      Icons.tag_rounded,
                    ),
                    DropdownButtonFormField<String>(
                      value: feeStatus,
                      dropdownColor: isDark ? const Color(0xFF111111) : Colors.white,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: "Fee Status",
                        labelStyle: TextStyle(color: _secondaryText(isDark)),
                        prefixIcon: Icon(Icons.payments_rounded, color: isDark ? gold : maroon),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
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
                          borderSide: BorderSide(color: isDark ? red : maroon),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Pending", child: Text("Pending")),
                        DropdownMenuItem(value: "Paid", child: Text("Paid")),
                        DropdownMenuItem(value: "Partial", child: Text("Partial")),
                      ],
                      onChanged: isSaving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setDialogState(() => feeStatus = value);
                            },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? red : maroon,
                    foregroundColor: isDark ? Colors.white : gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);

                          try {
                            await _updateStudent(
                              name: nameController.text,
                              age: ageController.text,
                              batch: batchController.text,
                              parentName: parentNameController.text,
                              phone: phoneController.text,
                              rollNo: rollNoController.text,
                              feeStatus: feeStatus,
                            );

                            if (mounted) Navigator.pop(dialogContext);
                          } catch (e) {
                            if (!mounted) return;

                            setDialogState(() => isSaving = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Update failed: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(isSaving ? "Saving..." : "Update"),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    ageController.dispose();
    batchController.dispose();
    parentNameController.dispose();
    phoneController.dispose();
    rollNoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .doc(widget.studentId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                backgroundColor: _bg(isDark),
                body: Center(
                  child: Text(
                    "Something went wrong",
                    style: TextStyle(color: _primaryText(isDark)),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: _bg(isDark),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Scaffold(
                backgroundColor: _bg(isDark),
                body: Center(
                  child: Text(
                    "Student not found",
                    style: TextStyle(color: _primaryText(isDark)),
                  ),
                ),
              );
            }

            final data = snapshot.data!.data() ?? {};

            final name = _text(data, 'name', widget.name);
            final age = _text(data, 'age', widget.age);
            final batch = _text(data, 'batch', widget.batch);
            final rollNo = _text(data, 'rollNo', widget.rollNo);
            final parentName = _text(data, 'parentName', widget.parentName);
            final phone = _text(data, 'phone', widget.phone);
            final attendance = _text(data, 'attendance', widget.attendance);
            final feeStatus = _text(data, 'feeStatus', widget.feeStatus);
            final photoUrl = _text(data, 'photoUrl', '');
            final feeAmount = _feeAmount(data);
            final attendanceValue = _percent(attendance);

            final initials = name
                .split(" ")
                .where((e) => e.isNotEmpty)
                .map((e) => e[0])
                .take(2)
                .join()
                .toUpperCase();

            return Scaffold(
              backgroundColor: _bg(isDark),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _topHeader(context, isDark),
                      _profileCard(
                        isDark: isDark,
                        initials: initials,
                        name: name,
                        batch: batch,
                        rollNo: rollNo,
                        photoUrl: photoUrl,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _summaryCard(
                          isDark: isDark,
                          attendance: "$attendanceValue%",
                          fee: feeStatus == "Paid" ? "Paid" : feeAmount,
                          batch: batch,
                          rollNo: rollNo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _infoCard(
                          isDark: isDark,
                          title: "STUDENT INFORMATION",
                          children: [
                            _infoRow(isDark, "Full Name", name),
                            _infoRow(isDark, "Age", "$age Years"),
                            _infoRow(isDark, "Parent", parentName),
                            _infoRow(
                              isDark,
                              "Phone",
                              phone.isEmpty ? "Not Added" : phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _infoCard(
                          isDark: isDark,
                          title: "QUICK ACTIONS",
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.05,
                              children: [
                                _actionCard(
                                  isDark,
                                  Icons.calendar_month_rounded,
                                  "Calendar",
                                  Colors.orange,
                                  () {
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
                                _actionCard(
                                  isDark,
                                  Icons.history_rounded,
                                  "History",
                                  Colors.red,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AttendanceHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _actionCard(
                                  isDark,
                                  Icons.edit_rounded,
                                  "Edit",
                                  Colors.blue,
                                  () => _showEditDialog(data, isDark),
                                ),
                                _actionCard(
                                  isDark,
                                  Icons.badge_rounded,
                                  "ID Card",
                                  Colors.green,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DigitalIdCardScreen(
                                          name: name,
                                          rollNo: rollNo,
                                          batch: batch,
                                          parentName: parentName,
                                          phone: phone,
                                          photoUrl: photoUrl,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _actionCard(
                                  isDark,
                                  Icons.upload_rounded,
                                  photoUrl.isEmpty ? "Photo" : "Change",
                                  Colors.purple,
                                  uploading ? null : _uploadPhoto,
                                ),
                                _actionCard(
                                  isDark,
                                  Icons.delete_rounded,
                                  "Delete",
                                  Colors.redAccent,
                                  deleting
                                      ? null
                                      : () => _confirmDelete(name, isDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _progressCard(
                        isDark: isDark,
                        attendanceValue: attendanceValue,
                        attendance: attendance,
                        feeStatus: feeStatus,
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.55),
                ]
              : [
                  maroon,
                  red.withOpacity(0.78),
                  darkMaroon,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? red.withOpacity(0.40) : gold.withOpacity(0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.18) : maroon.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _circleHeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 52,
            height: 52,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STUDENT DETAILS",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gold,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Profile • Attendance • ID Card",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleHeaderButton(
                icon: dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

  Widget _profileCard({
    required bool isDark,
    required String initials,
    required String name,
    required String batch,
    required String rollNo,
    required String photoUrl,
  }) {
    return Container(
      height: 190,
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.14) : maroon.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
                          Colors.black.withOpacity(0.90),
                          darkMaroon.withOpacity(0.82),
                          red.withOpacity(0.30),
                        ]
                      : [
                          maroon.withOpacity(0.92),
                          maroon.withOpacity(0.72),
                          Colors.black.withOpacity(0.25),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -24,
            bottom: -28,
            child: Icon(
              Icons.sports_cricket_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 130,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? Text(
                              initials.isEmpty ? "S" : initials,
                              style: const TextStyle(
                                color: maroon,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: uploading ? null : _uploadPhoto,
                        borderRadius: BorderRadius.circular(50),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: gold,
                          child: uploading
                              ? const SizedBox(
                                  height: 13,
                                  width: 13,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: maroon,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  color: maroon,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "YGCA STUDENT",
                            style: TextStyle(
                              color: gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _heroChip("Roll No: $rollNo"),
                          const SizedBox(height: 7),
                          _heroChip("Batch: $batch"),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: uploading ? null : _uploadPhoto,
                            child: Text(
                              photoUrl.isEmpty ? "Upload Photo" : "Change Photo",
                              style: TextStyle(
                                color: gold,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
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

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _summaryCard({
    required bool isDark,
    required String attendance,
    required String fee,
    required String batch,
    required String rollNo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : gold.withOpacity(0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.30) : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  isDark,
                  Icons.verified_rounded,
                  "Attendance",
                  attendance,
                  Colors.green,
                ),
              ),
              _verticalDivider(isDark),
              Expanded(
                child: _summaryItem(
                  isDark,
                  Icons.currency_rupee_rounded,
                  "Fee",
                  fee,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  isDark,
                  Icons.groups_rounded,
                  "Batch",
                  batch,
                  Colors.blue,
                ),
              ),
              _verticalDivider(isDark),
              Expanded(
                child: _summaryItem(
                  isDark,
                  Icons.tag_rounded,
                  "Roll No",
                  rollNo,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    bool isDark,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.14),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider(bool isDark) {
    return Container(
      height: 38,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: _border(isDark),
    );
  }

  Widget _infoCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: isDark ? gold : maroon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? gold : maroon,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(bool isDark, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.035) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    bool isDark,
    IconData icon,
    String title,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.035) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 7),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editField(
    bool isDark,
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: _primaryText(isDark)),
        cursorColor: isDark ? gold : maroon,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _secondaryText(isDark)),
          prefixIcon: Icon(icon, color: isDark ? gold : maroon),
          filled: true,
          fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
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
            borderSide: BorderSide(color: isDark ? red : maroon),
          ),
        ),
      ),
    );
  }

  Widget _progressCard({
    required bool isDark,
    required int attendanceValue,
    required String attendance,
    required String feeStatus,
  }) {
    final progress = (attendanceValue.clamp(0, 100)) / 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF180808),
                  const Color(0xFF0F0F0F),
                  red.withOpacity(0.18),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  gold.withOpacity(0.18),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: red.withOpacity(0.18),
            child: Icon(Icons.insights_rounded, color: gold, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Student Progress",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Attendance $attendance • Fee $feeStatus",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      attendanceValue >= 75 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            attendanceValue >= 75 ? "GOOD" : "FOCUS",
            style: TextStyle(
              color: attendanceValue >= 75 ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
