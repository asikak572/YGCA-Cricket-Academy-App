import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

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
    if (user == null) return;

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

    final studentRef = await _studentDocRef(user.uid);
    final studentDoc = await studentRef?.get();

    if (studentDoc != null && studentDoc.exists) {
      final data = studentDoc.data() ?? {};

      nameController.text =
          nameController.text.isNotEmpty ? nameController.text : data['name']?.toString() ?? '';
      phoneController.text =
          phoneController.text.isNotEmpty ? phoneController.text : data['phone']?.toString() ?? '';
      addressController.text =
          addressController.text.isNotEmpty ? addressController.text : data['address']?.toString() ?? '';
      photoUrl = photoUrl.isNotEmpty ? photoUrl : data['photoUrl']?.toString() ?? '';
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
        const SnackBar(
          content: Text("Image size must be less than 2 MB"),
        ),
      );
      return;
    }

    setState(() {
      isUploadingPhoto = true;
    });

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(
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

    final studentRef = await _studentDocRef(user.uid);

    if (studentRef != null) {
      await studentRef.set(
        {
          'photoUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    if (!mounted) return;

    setState(() {
      photoUrl = downloadUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile photo uploaded successfully"),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Photo upload failed: $e"),
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
        const SnackBar(content: Text("Name and phone number are required")),
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

      final studentRef = await _studentDocRef(user.uid);

      if (studentRef != null) {
        await studentRef.update({
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'photoUrl': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _inputField(
                    label: "Full Name",
                    controller: nameController,
                    icon: Icons.person,
                  ),
                  _inputField(
                    label: "Phone Number",
                    controller: phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  _inputField(
                    label: "Email",
                    controller: emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _inputField(
                    label: "Address",
                    controller: addressController,
                    icon: Icons.location_on,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isSaving ? null : _saveProfile,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        isSaving ? "SAVING..." : "SAVE CHANGES",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _noteCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final initial =
        nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : "U";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? Text(
                        initial,
                        style: TextStyle(
                          color: maroon,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: isUploadingPhoto ? null : _uploadPhoto,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: gold,
                    child: isUploadingPhoto
                        ? SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: maroon,
                            ),
                          )
                        : Icon(Icons.camera_alt, color: maroon, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: isUploadingPhoto ? null : _uploadPhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gold),
              ),
              child: Text(
                photoUrl.isEmpty ? "Upload Photo" : "Change Photo",
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nameController.text.isEmpty ? "User Profile" : nameController.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role.isEmpty ? "YGCA Member" : role.toUpperCase(),
            style: TextStyle(
              color: gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
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
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: maroon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: border),
          ),
        ),
      ),
    );
  }

  Widget _noteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "You can update only your own profile details. Academy data like batch, roll number, attendance and fees are controlled by Admin.",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}