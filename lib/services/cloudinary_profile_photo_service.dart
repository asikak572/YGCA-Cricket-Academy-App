import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryPhotoResult {
  final String url;
  final String publicId;
  final String assetId;

  const CloudinaryPhotoResult({
    required this.url,
    required this.publicId,
    required this.assetId,
  });
}

class CloudinaryProfilePhotoService {
  static const String _cloudName = 'nvzfopj6';
  static const String _uploadPreset = 'ygca_profile_photos';
  static const int _maxBytes = 250 * 1024;

  static Future<CloudinaryPhotoResult?> pickAndUpload() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedImage == null) return null;

    final compressedBytes = await _compressUnder250Kb(pickedImage.path);

    if (compressedBytes == null) {
      throw Exception(
        'Unable to reduce this photo below 250 KB. Please choose another photo.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      ),
    )
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          compressedBytes,
          filename: 'profile.jpg',
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Cloudinary upload failed (${response.statusCode})';

      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = errorData['error'];
        if (error is Map && error['message'] != null) {
          message = error['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;
    final url = responseData['secure_url']?.toString().trim() ?? '';

    if (url.isEmpty) {
      throw Exception('Cloudinary did not return a photo URL.');
    }

    return CloudinaryPhotoResult(
      url: url,
      publicId: responseData['public_id']?.toString().trim() ?? '',
      assetId: responseData['asset_id']?.toString().trim() ?? '',
    );
  }

  static Future<Uint8List?> _compressUnder250Kb(
    String sourcePath,
  ) async {
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

      if (smallestResult == null ||
          result.lengthInBytes < smallestResult.lengthInBytes) {
        smallestResult = result;
      }

      if (result.lengthInBytes <= _maxBytes) return result;
    }

    return smallestResult != null &&
            smallestResult.lengthInBytes <= _maxBytes
        ? smallestResult
        : null;
  }
}
