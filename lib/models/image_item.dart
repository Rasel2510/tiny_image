import 'dart:io';

enum CompressionStatus { idle, compressing, done, error }

class ImageItem {
  final String id;
  final File originalFile;
  final String originalName;
  final int originalSize;

  File? compressedFile;
  int? compressedSize;
  CompressionStatus status;
  double progress;
  String? errorMessage;

  ImageItem({
    required this.id,
    required this.originalFile,
    required this.originalName,
    required this.originalSize,
    this.compressedFile,
    this.compressedSize,
    this.status = CompressionStatus.idle,
    this.progress = 0,
    this.errorMessage,
  });

  double get savedPercent {
    if (originalSize == 0 || compressedSize == null) return 0;
    return ((originalSize - compressedSize!) / originalSize * 100);
  }

  String get savedPercentLabel {
    final p = savedPercent;
    if (p <= 0) return '0%';
    return '-${p.toStringAsFixed(0)}%';
  }

  String get originalSizeLabel => _formatBytes(originalSize);
  String get compressedSizeLabel =>
      compressedSize != null ? _formatBytes(compressedSize!) : '--';

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  ImageItem copyWith({
    File? compressedFile,
    int? compressedSize,
    CompressionStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return ImageItem(
      id: id,
      originalFile: originalFile,
      originalName: originalName,
      originalSize: originalSize,
      compressedFile: compressedFile ?? this.compressedFile,
      compressedSize: compressedSize ?? this.compressedSize,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
