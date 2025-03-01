import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Service for handling file operations (images, documents, etc.)
class FileService extends GetxService {
  final ImagePicker _picker = ImagePicker();
  final uuid = const Uuid();
  
  /// Pick an image from the gallery
  Future<File?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }
  
  /// Take a photo using the camera
  Future<File?> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
    return null;
  }
  
  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }
  
  /// Pick a video from gallery
  Future<File?> pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
    return null;
  }
  
  /// Record a video using camera
  Future<File?> recordVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.camera,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error recording video: $e');
    }
    return null;
  }
  
  /// Save a file to the app's document directory
  Future<File?> saveFile(List<int> bytes, String fileName, {String? directory}) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String dirPath = directory != null 
          ? '${appDocDir.path}/$directory'
          : appDocDir.path;
      
      // Create directory if it doesn't exist
      final Directory dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final String filePath = '$dirPath/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }
  
  /// Generate a unique filename with appropriate extension
  String generateUniqueFileName(String extension) {
    return '${uuid.v4()}.$extension';
  }
  
  /// Download a file from URL
  Future<File?> downloadFile(String url, {String? fileName, String? directory}) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final String name = fileName ?? url.split('/').last;
        return await saveFile(response.bodyBytes, name, directory: directory);
      }
    } catch (e) {
      debugPrint('Error downloading file: $e');
    }
    return null;
  }
  
  /// Get file size in human-readable format
  String getFileSize(File file, {int decimals = 1}) {
    try {
      final int bytes = file.lengthSync();
      if (bytes <= 0) return '0 B';
      
      const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
      final i = (log(bytes) / log(1024)).floor();
      
      return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
    } catch (e) {
      return 'Unknown';
    }
  }
  
  /// Delete a file
  Future<bool> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
    return false;
  }
  
  /// Get file MIME type based on extension
  String getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream'; // Generic binary type
    }
  }
  
  /// Extension methods would be needed:
  /// import 'dart:math' for log and pow functions
}
