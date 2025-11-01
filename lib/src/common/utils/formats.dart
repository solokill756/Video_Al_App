import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Utility functions for filtering and formatting data
class Formats {
  /// Filters out null or empty values from a Map
  static Map<String, dynamic> filterNullOrEmpty(Map<String, dynamic> data) {
    return Map.fromEntries(
      data.entries.where((entry) {
        final value = entry.value;
        if (value == null) return false;
        if (value is String && value.isEmpty) return false;
        if (value is List && value.isEmpty) return false;
        if (value is Map && value.isEmpty) return false;
        return true;
      }),
    );
  }

  /// Filters out null or empty values from a List
  static List<T> filterNullOrEmptyList<T>(List<T?> list) {
    return list
        .where((item) {
          if (item == null) return false;
          if (item is String && item.isEmpty) return false;
          if (item is List && item.isEmpty) return false;
          if (item is Map && item.isEmpty) return false;
          return true;
        })
        .cast<T>()
        .toList();
  }

  /// Checks if a value is null or empty
  static bool isNullOrEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String && value.isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    if (value is Map && value.isEmpty) return true;
    return false;
  }

  static Future<String> imageEncodeToBase64(String imagePath) async {
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(imageBytes);
    return base64Image;
  }
}
