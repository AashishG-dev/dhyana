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

/// Manages interactions with Cloudinary for uploading and managing media files
/// (audio, images, videos/GIFs for exercise demos).
///
/// This service primarily focuses on direct upload using HTTP POST requests
/// to Cloudinary's upload API, which is suitable for client-side uploads.
/// For highly secure or complex scenarios, server-side signed uploads are recommended.
class CloudinaryService {
  final String _cloudName = AppConstants.cloudinaryCloudName;
  final String _apiKey = AppConstants.cloudinaryApiKey;
  // Note: API Secret should ideally NOT be exposed on the client-side for security.
  // For signed uploads, this secret is used on a backend server to generate signatures.
  // For simplicity in this client-side example, we'll use unsigned uploads with an upload preset.
  final String _uploadPreset = AppConstants.cloudinaryUploadPreset;

  /// Uploads a file to Cloudinary.
  ///
  /// [filePath]: The local path of the file to upload.
  /// [resourceType]: The type of resource being uploaded (image, video, raw).
  /// [folder]: Optional folder name in Cloudinary to organize uploads.
  ///
  /// Returns the secure URL of the uploaded asset, or null if upload fails.
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
        ..fields['upload_preset'] = _uploadPreset // Use unsigned upload preset
        ..files.add(await http.MultipartFile.fromPath(
          'file', // Field name for the file
          file.path,
          filename: file.path.split('/').last, // Use original filename
        ));

      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Cloudinary upload status: ${response.statusCode}');
      debugPrint('Cloudinary upload response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? secureUrl = responseData['secure_url'];
        if (secureUrl != null) {
          debugPrint('File uploaded successfully: $secureUrl');
          return secureUrl;
        } else {
          debugPrint('Upload successful but secure_url not found in response.');
          return null;
        }
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
  /// This operation typically requires authentication (API Key and Secret)
  /// and should ideally be done from a secure backend for production apps,
  /// as exposing API Secret on client-side is a security risk.
  /// For this client-side example, we'll provide a basic structure,
  /// but note the security implications.
  Future<bool> deleteFile({
    required String publicId,
    required CloudinaryResourceType resourceType,
  }) async {
    // WARNING: Deleting assets requires API Key and API Secret, which should
    // NOT be exposed on the client-side in a production application.
    // This method is provided for completeness but should be implemented
    // via a secure backend API call for actual deletion in production.
    if (_cloudName.isEmpty || _apiKey.isEmpty || AppConstants.cloudinaryApiSecret.isEmpty) {
      debugPrint('Cloudinary credentials (cloudName, apiKey, or apiSecret) are not set for deletion.');
      return false;
    }

    final Uri uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/${resourceType.name}/destroy');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Authentication header for signed requests (requires API Secret)
          // This part is simplified and for demonstration.
          // In real-world, you'd generate a signature on your backend.
          // For direct client-side deletion, you'd typically use a signed URL.
        },
        body: jsonEncode({
          'public_id': publicId,
          'api_key': _apiKey,
          'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          // 'signature': 'GENERATED_SIGNATURE_ON_BACKEND', // Crucial for secure deletion
          'invalidate': true, // Invalidate CDN cache
        }),
      );

      debugPrint('Cloudinary delete status: ${response.statusCode}');
      debugPrint('Cloudinary delete response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['result'] == 'ok') {
          debugPrint('File deleted successfully: $publicId');
          return true;
        } else {
          debugPrint('Deletion failed for $publicId: ${responseData['result']}');
          return false;
        }
      } else {
        debugPrint('Cloudinary deletion failed with status ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting file from Cloudinary: $e');
      return false;
    }
  }

  /// Extracts the public ID from a Cloudinary URL.
  /// This is useful when you need to reference an asset by its public ID
  /// for operations like deletion or specific transformations.
  ///
  /// Example:
  /// Input: "https://res.cloudinary.com/your_cloud_name/image/upload/v1678901234/folder/my_image.jpg"
  /// Output: "folder/my_image"
  static String? getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find the "upload" or "fetch" segment and get the path after it.
      // The public ID is typically the part after /upload/v<version>/
      int uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) {
        uploadIndex = pathSegments.indexOf('fetch'); // Also check for fetch
      }

      if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
        // The public ID starts after the version number (v<timestamp>)
        // Example: pathSegments = [..., 'upload', 'v1234567890', 'folder', 'my_image.jpg']
        // We want 'folder/my_image'
        final String fullPublicId = pathSegments.sublist(uploadIndex + 2).join('/');
        // Remove file extension if present
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

  /// Constructs a Cloudinary URL for an asset given its public ID.
  /// This can be used to generate URLs with transformations.
  ///
  /// [publicId]: The public ID of the asset (e.g., 'folder/my_image').
  /// [resourceType]: The type of resource (image, video, raw).
  /// [transformations]: Optional string for Cloudinary transformations (e.g., 'w_200,h_200,c_fill').
  static String buildCloudinaryUrl({
    required String publicId,
    required CloudinaryResourceType resourceType,
    String? transformations,
  }) {
    final String baseUrl = 'https://res.cloudinary.com/${AppConstants.cloudinaryCloudName}/${resourceType.name}/upload/';
    final String transformPart = transformations != null && transformations.isNotEmpty ? '$transformations/' : '';
    return '$baseUrl$transformPart$publicId';
  }
}
