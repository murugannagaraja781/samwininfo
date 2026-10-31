import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PickedImageData {
  final String base64Data;
  final String fileName;
  final int byteSize;

  const PickedImageData({
    required this.base64Data,
    required this.fileName,
    required this.byteSize,
  });

  Uint8List get bytes => base64Decode(base64Data);
}

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from device Gallery
  static Future<PickedImageData?> pickFromGallery({int maxWidth = 1280, int quality = 85}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        imageQuality: quality,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return PickedImageData(
        base64Data: base64Encode(bytes),
        fileName: file.name,
        byteSize: bytes.length,
      );
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Take a real photo using device Camera
  static Future<PickedImageData?> pickFromCamera({int maxWidth = 1280, int quality = 85}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        imageQuality: quality,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return PickedImageData(
        base64Data: base64Encode(bytes),
        fileName: file.name,
        byteSize: bytes.length,
      );
    } catch (e) {
      debugPrint('Error taking photo with camera: $e');
      return null;
    }
  }
}
