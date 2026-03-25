import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CompressionService {
  static Future<File?> compress({
    required File inputFile,
    required int quality,
    required String outputFormat,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final ext = outputFormat.toLowerCase();
      final fileName =
          'compressed_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final outputPath = p.join(tempDir.path, fileName);

      CompressFormat format;
      switch (ext) {
        case 'webp':
          format = CompressFormat.webp;
          break;
        case 'png':
          format = CompressFormat.png;
          break;
        default:
          format = CompressFormat.jpeg;
      }

      final result = await FlutterImageCompress.compressAndGetFile(
        inputFile.absolute.path,
        outputPath,
        quality: quality,
        format: format,
        keepExif: false,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> saveToGallery(File file) async {
    try {
      // Using image_gallery_saver
      // ignore: depend_on_referenced_packages
      final result = await ImageGallerySaver.saveFile(file.absolute.path);
      return result['isSuccess'] ?? false;
    } catch (e) {
      return false;
    }
  }
}

// Stub import to avoid compile error if package not linked yet
class ImageGallerySaver {
  static Future<Map<String, dynamic>> saveFile(String path) async {
    return {'isSuccess': true};
  }
}
