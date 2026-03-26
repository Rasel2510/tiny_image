import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class CompressionService {
  /// Compress [inputFile] and return the resulting [File].
  /// Returns null on failure.
  static Future<File?> compress({
    required File inputFile,
    required int quality,
    required String outputFormat,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final ext     = _ext(outputFormat);
      final outPath =
          '${tempDir.path}/tinyimg_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final result = await FlutterImageCompress.compressAndGetFile(
        inputFile.absolute.path,
        outPath,
        quality  : quality,
        format   : _format(outputFormat),
        keepExif : false,
        autoCorrectionAngle: true,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (_) {
      return null;
    }
  }

  /// Save [file] to the device photo gallery.
  static Future<bool> saveToGallery(File file) async {
    try {
      await Gal.putImage(file.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _ext(String format) {
    switch (format) {
      case 'PNG'  : return 'png';
      case 'WebP' : return 'webp';
      default     : return 'jpg';
    }
  }

  static CompressFormat _format(String format) {
    switch (format) {
      case 'PNG'  : return CompressFormat.png;
      case 'WebP' : return CompressFormat.webp;
      default     : return CompressFormat.jpeg;
    }
  }
}
