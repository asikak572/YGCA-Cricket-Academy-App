import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_padding.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingPhoto = false;

  String role = "";
  String photoUrl = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  Future<DocumentReference<Map<String, dynamic>>?> _studentDocRef(
    String uid,
  ) async {
    final directRef = FirebaseFirestore.instance.collection('students').doc(uid);
    final directDoc = await directRef.get();

    if (directDoc.exists) return directRef;

    final query = await FirebaseFirestore.instance
        .collection('students')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return query.docs.first.reference;
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() ?? {};

      nameController.text = data['name']?.toString() ?? '';
      phoneController.text = data['phone']?.toString() ?? '';
      emailController.text = data['email']?.toString() ?? user.email ?? '';
      addressController.text = data['address']?.toString() ?? '';
      role = data['role']?.toString() ?? '';
      photoUrl = data['photoUrl']?.toString() ?? '';
    } else {
      emailController.text = user.email ?? '';
    }

    DocumentSnapshot<Map<String, dynamic>>? studentDoc;

    try {
      final studentRef = await _studentDocRef(user.uid);
      studentDoc = await studentRef?.get();
    } catch (_) {
      studentDoc = null;
    }

    if (studentDoc != null && studentDoc.exists) {
      final data = studentDoc.data() ?? {};

      nameController.text = nameController.text.isNotEmpty
          ? nameController.text
          : data['name']?.toString() ?? '';

      phoneController.text = phoneController.text.isNotEmpty
          ? phoneController.text
          : data['phone']?.toString() ?? '';

      addressController.text = addressController.text.isNotEmpty
          ? addressController.text
          : data['address']?.toString() ?? '';

      photoUrl = photoUrl.isNotEmpty
          ? photoUrl
          : data['photoUrl']?.toString() ?? '';
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedImage == null) return;

      final file = File(pickedImage.path);

      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      if (fileSizeMB > 2) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.editProfileImageTooLarge),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        isUploadingPhoto = true;
      });

      final storageRef = FirebaseStorage.instance.ref().child(
            'student_photos/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

      final uploadTask = await storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'photoUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (role == "Student") {
        final studentRef = await _studentDocRef(user.uid);

        if (studentRef != null) {
          await studentRef.set(
            {
              'name': nameController.text.trim(),
              'phone': phoneController.text.trim(),
              'address': addressController.text.trim(),
              'photoUrl': downloadUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        photoUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.editProfilePhotoUploaded),
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
      if (mounted) {
        setState(() {
          isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.editProfileNamePhoneRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'address': addressController.text.trim(),
          'role': role,
          'photoUrl': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (role == "Student") {
        final studentRef = await _studentDocRef(user.uid);

        if (studentRef != null) {
          await studentRef.set(
            {
              'name': nameController.text.trim(),
              'phone': phoneController.text.trim(),
              'address': addressController.text.trim(),
              'photoUrl': photoUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.editProfileUpdatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.error}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
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

            if (isLoading) {
          return Scaffold(
            backgroundColor: _bg(isDark),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _topHeader(context, isDark),
                ),
                SliverToBoxAdapter(
                  child: _profileHeader(isDark),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 18),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsivePadding.horizontal(context),
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _inputField(
                          isDark: isDark,
                          label: AppStrings.fullName,
                          controller: nameController,
                          icon: Icons.person_rounded,
                        ),
                        _inputField(
                          isDark: isDark,
                          label: AppStrings.phoneNumber,
                          controller: phoneController,
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        _inputField(
                          isDark: isDark,
                          label: AppStrings.email,
                          controller: emailController,
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _inputField(
                          isDark: isDark,
                          label: AppStrings.address,
                          controller: addressController,
                          icon: Icons.location_on_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? red : maroon,
                              foregroundColor: isDark ? Colors.white : gold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor:
                                  isDark ? Colors.white12 : Colors.grey.shade300,
                            ),
                            onPressed: isSaving ? null : _saveProfile,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              isSaving ? AppStrings.saving.toUpperCase() : AppStrings.editProfileSaveChanges.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _noteCard(isDark),
                        const SizedBox(height: 26),
                      ],
                    ),
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

  Widget _topHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context),
        12,
        ResponsivePadding.horizontal(context),
        14,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : maroon,
        border: Border(
          bottom: BorderSide(
            color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.editProfileTitle.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleButton(
                isDark: isDark,
                icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF111111) : Colors.white.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? red.withOpacity(0.28) : gold.withOpacity(0.55),
          ),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : gold,
          size: 22,
        ),
      ),
    );
  }

  Widget _profileHeader(bool isDark) {
    final initial = nameController.text.isNotEmpty
        ? nameController.text[0].toUpperCase()
        : "U";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.42),
                ]
              : [
                  maroon,
                  darkMaroon,
                  Colors.black.withOpacity(0.86),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.18) : maroon.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            bottom: -28,
            child: Icon(
              Icons.person_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 130,
            ),
          ),
          Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? Text(
                            initial,
                            style: const TextStyle(
                              color: maroon,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: isUploadingPhoto ? null : _uploadPhoto,
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: gold,
                        child: isUploadingPhoto
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: maroon,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: maroon,
                                size: 17,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: isUploadingPhoto ? null : _uploadPhoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gold.withOpacity(0.85)),
                  ),
                  child: Text(
                    isUploadingPhoto
                        ? AppStrings.editProfileUploading
                        : photoUrl.isEmpty
                            ? AppStrings.uploadPhoto
                            : AppStrings.changePhoto,
                    style: const TextStyle(
                      color: gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                nameController.text.isEmpty
                    ? AppStrings.editProfileUserProfile
                    : nameController.text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role.isEmpty ? AppStrings.editProfileYgcaMember.toUpperCase() : role.toUpperCase(),
                style: const TextStyle(
                  color: gold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _secondaryText(isDark)),
          prefixIcon: Icon(icon, color: isDark ? gold : maroon),
          filled: true,
          fillColor: _card(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: isDark ? red : maroon,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF180808) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.35) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? gold : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.editProfileInfoNote,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF374151),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
