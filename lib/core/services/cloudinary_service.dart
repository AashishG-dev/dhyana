// lib/core/services/cloudinary_service.dart
import 'dart:io'; // For File
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:dhyana/core/constants/app_constants.dart'; // For Cloudinary credentials

/// Enum to define common Cloudinary resource types.
enum CloudinaryResourceType {
  image,
  video,
  raw,
  auto, // Let Cloudinary determine
}

/// Manages interactions with Cloudinary for uploading and managing media files.
class CloudinaryService {
  final String _cloudName = AppConstants.cloudinaryCloudName;
  final String _apiKey = AppConstants.cloudinaryApiKey;
  final String _uploadPreset = AppConstants.cloudinaryUploadPreset;

  // --- (uploadFile and deleteFile methods remain the same) ---

  /// Uploads a file to Cloudinary.
  Future<String?> uploadFile({
    required String filePath,
    required CloudinaryResourceType resourceType,
    String? folder,
  }) async {
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      debugPrint('Cloudinary credentials (cloudName or uploadPreset) are not set.');
      return null;
    }

    final Uri uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/${resourceType.name}/upload');

    final File file = File(filePath);
    if (!await file.exists()) {
      debugPrint('File does not exist at path: $filePath');
      return null;
    }

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ));

      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? secureUrl = responseData['secure_url'];
        if (secureUrl != null) {
          return secureUrl;
        }
        return null;
      } else {
        debugPrint('Cloudinary upload failed with status ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading file to Cloudinary: $e');
      return null;
    }
  }

  /// Deletes a file from Cloudinary using its public ID.
  Future<bool> deleteFile({
    required String publicId,
    required CloudinaryResourceType resourceType,
  }) async {
    // This is a placeholder for a secure, backend-driven deletion.
    // Avoid client-side deletion in production apps.
    debugPrint('Deletion should be handled by a secure backend.');
    return false;
  }

  /// Extracts the public ID from a Cloudinary URL.
  static String? getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      int uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
        final String fullPublicId = pathSegments.sublist(uploadIndex + 2).join('/');
        final int lastDotIndex = fullPublicId.lastIndexOf('.');
        if (lastDotIndex != -1) {
          return fullPublicId.substring(0, lastDotIndex);
        }
        return fullPublicId;
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing public ID from URL ($url): $e');
      return null;
    }
  }

  /// ✅ FINAL CORRECTED LOGIC
  /// Constructs a Cloudinary URL for an asset given its public ID.
  static String buildCloudinaryUrl({
    required String publicId,
    required CloudinaryResourceType resourceType,
    String? transformations,
  }) {
    debugPrint('Cloudinary Service received Public ID: "$publicId"');

    // The base URL for all Cloudinary assets.
    final String baseUrl = 'https://res.cloudinary.com/${AppConstants.cloudinaryCloudName}';

    // The transformation string, if any (e.g., for resizing images).
    final String transformPart = transformations != null && transformations.isNotEmpty ? '$transformations/' : '';

    // ✅ FIX: Add the version number 'v1/' to the URL path.
    // This is a standard practice and resolves issues with some asset delivery configurations.
    final String finalUrl = '$baseUrl/${resourceType.name}/upload/${transformPart}v1/$publicId';

    debugPrint('Constructed Final URL: "$finalUrl"');

    return finalUrl;
  }
}
