import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_spacing.dart';
import '../core/responsive/responsive_grid.dart';
import '../core/responsive/responsive_radius.dart';
import '../core/responsive/responsive_text.dart';

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

  static const String _cloudinaryCloudName = 'nvzfopj6';
  static const String _cloudinaryUploadPreset = 'ygca_profile_photos';

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

  String _localizedFeeStatus(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized == 'paid') return AppStrings.paid;
    if (normalized == 'pending') return AppStrings.pending;
    if (normalized == 'unpaid') return AppStrings.unpaid;
    if (normalized == 'partial' || normalized == 'partially paid') {
      return AppStrings.partiallyPaid;
    }

    return value;
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

  Future<Uint8List?> _compressPhotoUnder250Kb(String sourcePath) async {
    const maxBytes = 250 * 1024;

    final settings = <({int size, int quality})>[
      (size: 1000, quality: 70),
      (size: 900, quality: 60),
      (size: 800, quality: 50),
      (size: 700, quality: 40),
      (size: 600, quality: 35),
      (size: 500, quality: 30),
      (size: 450, quality: 25),
      (size: 400, quality: 22),
    ];

    Uint8List? smallestResult;

    for (final setting in settings) {
      final result = await FlutterImageCompress.compressWithFile(
        sourcePath,
        minWidth: setting.size,
        minHeight: setting.size,
        quality: setting.quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (result == null || result.isEmpty) continue;

      if (smallestResult == null || result.lengthInBytes < smallestResult.lengthInBytes) {
        smallestResult = result;
      }

      if (result.lengthInBytes <= maxBytes) {
        return result;
      }
    }

    return smallestResult != null && smallestResult.lengthInBytes <= maxBytes
        ? smallestResult
        : null;
  }

  Future<void> _uploadPhoto() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1400,
        maxHeight: 1400,
      );

      if (pickedImage == null) return;

      if (!mounted) return;
      setState(() => uploading = true);

      final compressedPhoto =
          await _compressPhotoUnder250Kb(pickedImage.path);

      if (compressedPhoto == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to reduce this photo below 250 KB. Please choose another photo.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final uploadUri = Uri.parse(
        'https://api.cloudinary.com/v1_1/'
        '$_cloudinaryCloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uploadUri)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..fields['public_id'] = 'student_${widget.studentId}'
        ..fields['tags'] = 'ygca_profile_photo,student_profile'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            compressedPhoto,
            filename: 'profile.jpg',
          ),
        );

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      final responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorData = responseData['error'];
        final errorMessage = errorData is Map<String, dynamic>
            ? errorData['message']?.toString()
            : null;

        throw Exception(
          errorMessage ?? 'Cloudinary photo upload failed.',
        );
      }

      final url = responseData['secure_url']?.toString().trim() ?? '';
      final publicId = responseData['public_id']?.toString().trim() ?? '';
      final assetId = responseData['asset_id']?.toString().trim() ?? '';

      if (url.isEmpty) {
        throw Exception('Cloudinary did not return a secure photo URL.');
      }

      final studentRef = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId);

      await studentRef.set({
        'photoUrl': url,
        'photoProvider': 'cloudinary',
        'photoPublicId': publicId,
        'photoAssetId': assetId,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Sync the Authentication user only when an existing user document can
      // be resolved. Never create users/{studentId} accidentally.
      final studentSnapshot = await studentRef.get();
      final studentData = studentSnapshot.data() ?? <String, dynamic>{};
      final possibleUserIds = <String>{
        studentData['authUid']?.toString().trim() ?? '',
        studentData['userId']?.toString().trim() ?? '',
        studentData['uid']?.toString().trim() ?? '',
      }..removeWhere((value) => value.isEmpty);

      for (final userId in possibleUserIds) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);
        final userSnapshot = await userRef.get();

        if (userSnapshot.exists) {
          await userRef.update({
            'photoUrl': url,
            'photoProvider': 'cloudinary',
            'photoPublicId': publicId,
            'photoAssetId': assetId,
            'photoUpdatedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          break;
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.studentPhotoUploaded),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.photoUploadFailed}: $e"),
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
        SnackBar(
          content: Text(AppStrings.studentDeletedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.deleteFailed}: $e"),
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
      SnackBar(
        content: Text(AppStrings.studentUpdatedSuccessfully),
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
          AppStrings.deleteStudent,
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "${AppStrings.deleteStudentConfirm} $name?",
          style: TextStyle(color: _secondaryText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: deleting ? null : () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
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
            label: Text(AppStrings.delete),
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
              insetPadding: EdgeInsets.symmetric(horizontal: ResponsivePadding.horizontal(context)),
              backgroundColor: _card(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
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
                      AppStrings.editStudent,
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
                      AppStrings.studentName,
                      nameController,
                      Icons.person_rounded,
                    ),
                    _editField(
                      isDark,
                      AppStrings.age,
                      ageController,
                      Icons.cake_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    _editField(
                      isDark,
                      AppStrings.batch,
                      batchController,
                      Icons.groups_rounded,
                    ),
                    _editField(
                      isDark,
                      AppStrings.parentName,
                      parentNameController,
                      Icons.family_restroom_rounded,
                    ),
                    _editField(
                      isDark,
                      AppStrings.phoneNumber,
                      phoneController,
                      Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    _editField(
                      isDark,
                      AppStrings.rollNo,
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
                        labelText: AppStrings.feeStatus.replaceAll('\n', ' '),
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
                      items: [
                        DropdownMenuItem(
                          value: "Pending",
                          child: Text(AppStrings.pending),
                        ),
                        DropdownMenuItem(
                          value: "Paid",
                          child: Text(AppStrings.paid),
                        ),
                        DropdownMenuItem(
                          value: "Partial",
                          child: Text(AppStrings.partiallyPaid),
                        ),
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
                  child: Text(AppStrings.cancel),
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
                                content: Text("${AppStrings.updateFailed}: $e"),
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
                  label: Text(isSaving ? AppStrings.saving : AppStrings.update),
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
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
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
                    AppStrings.somethingWentWrong,
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
                    AppStrings.studentNotFound,
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
                        padding: EdgeInsets.symmetric(horizontal: ResponsivePadding.horizontal(context)),
                        child: _summaryCard(
                          isDark: isDark,
                          attendance: "$attendanceValue%",
                          fee: feeStatus == "Paid" ? AppStrings.paid : feeAmount,
                          batch: batch,
                          rollNo: rollNo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ResponsivePadding.horizontal(context)),
                        child: _infoCard(
                          isDark: isDark,
                          title: AppStrings.studentInformation,
                          children: [
                            _infoRow(isDark, AppStrings.fullName, name),
                            _infoRow(isDark, AppStrings.age, "$age ${AppStrings.years}"),
                            _infoRow(isDark, AppStrings.parent, parentName),
                            _infoRow(
                              isDark,
                              AppStrings.phone,
                              phone.isEmpty ? AppStrings.notAdded : phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ResponsivePadding.horizontal(context)),
                        child: _infoCard(
                          isDark: isDark,
                          title: AppStrings.quickActions,
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: ResponsiveHelper.isMobile(context) ? 3 : 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.05 : 1.20,
                              children: [
                                _actionCard(
                                  isDark,
                                  Icons.calendar_month_rounded,
                                  AppStrings.calendar,
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
                                  AppStrings.history,
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
                                  AppStrings.edit,
                                  Colors.blue,
                                  () => _showEditDialog(data, isDark),
                                ),
                                _actionCard(
                                  isDark,
                                  Icons.badge_rounded,
                                  AppStrings.idCard,
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
                                  photoUrl.isEmpty ? AppStrings.photo : AppStrings.change,
                                  Colors.purple,
                                  uploading ? null : _uploadPhoto,
                                ),
                                _actionCard(
                                  isDark,
                                  Icons.delete_rounded,
                                  AppStrings.delete,
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
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(ResponsivePadding.horizontal(context) - 2, 12, ResponsivePadding.horizontal(context) - 2, 10),
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
        borderRadius: BorderRadius.circular(ResponsiveRadius.large(context)),
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
            width: ResponsiveHelper.isMobile(context) ? 52 : 58,
            height: ResponsiveHelper.isMobile(context) ? 52 : 58,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.studentDetailsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gold,
                    fontSize: ResponsiveText.body(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  AppStrings.profileAttendanceIdCard,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: ResponsiveText.small(context),
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
        width: ResponsiveHelper.isMobile(context) ? 42 : 46,
        height: ResponsiveHelper.isMobile(context) ? 42 : 46,
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
      height: ResponsiveHelper.isMobile(context) ? 190 : 220,
      margin: EdgeInsets.fromLTRB(ResponsivePadding.horizontal(context), 2, ResponsivePadding.horizontal(context), 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveRadius.large(context)),
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
                      radius: ResponsiveHelper.isMobile(context) ? 45 : 55,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: SizedBox.expand(
                          child: photoUrl.isEmpty
                              ? Center(
                                  child: Text(
                                    initials.isEmpty ? "S" : initials,
                                    style: TextStyle(
                                      color: maroon,
                                      fontSize:
                                          ResponsiveHelper.isMobile(context)
                                              ? 28
                                              : 34,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )
                              : Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        initials.isEmpty ? "S" : initials,
                                        style: TextStyle(
                                          color: maroon,
                                          fontSize:
                                              ResponsiveHelper.isMobile(context)
                                                  ? 28
                                                  : 34,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
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
                      width: ResponsiveHelper.isMobile(context) ? 230 : 330,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.ygcaStudent,
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.isMobile(context) ? 27 : 36,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _heroChip("${AppStrings.rollNo}: $rollNo"),
                          const SizedBox(height: 7),
                          _heroChip("${AppStrings.batch}: $batch"),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: uploading ? null : _uploadPhoto,
                            child: Text(
                              photoUrl.isEmpty ? AppStrings.uploadPhoto : AppStrings.changePhoto,
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
        borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
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
        borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
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
                  AppStrings.attendance,
                  attendance,
                  Colors.green,
                ),
              ),
              _verticalDivider(isDark),
              Expanded(
                child: _summaryItem(
                  isDark,
                  Icons.currency_rupee_rounded,
                  AppStrings.fee,
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
                  AppStrings.batch,
                  batch,
                  Colors.blue,
                ),
              ),
              _verticalDivider(isDark),
              Expanded(
                child: _summaryItem(
                  isDark,
                  Icons.tag_rounded,
                  AppStrings.rollNo,
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
        borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: ResponsiveText.small(context),
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
      margin: EdgeInsets.symmetric(horizontal: ResponsivePadding.horizontal(context)),
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
        borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
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
                  AppStrings.studentProgress,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${AppStrings.attendance} $attendance • ${AppStrings.fee} ${_localizedFeeStatus(feeStatus)}",
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
                  borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
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
            attendanceValue >= 75 ? AppStrings.good : AppStrings.focus,
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

