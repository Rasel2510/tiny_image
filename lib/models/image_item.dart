import 'dart:io';

enum CompressionStatus { idle, compressing, done, error }

class ImageItem {
  final String id;
  final File originalFile;
  final String originalName;
  final int originalSize;
  final File? compressedFile;
  final int? compressedSize;
  final CompressionStatus status;
  final double progress;
  final String? errorMessage;

  const ImageItem({
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
    final p = (originalSize - compressedSize!) / originalSize * 100;
    return p < 0 ? 0 : p;
  }

  String get savedPercentLabel {
    final p = savedPercent;
    return p <= 0 ? '0%' : '-${p.toStringAsFixed(0)}%';
  }

  bool get isLarger =>
      compressedSize != null && compressedSize! >= originalSize;

  String get originalSizeLabel  => _formatBytes(originalSize);
  String get compressedSizeLabel =>
      compressedSize != null ? _formatBytes(compressedSize!) : '--';

  static String _formatBytes(int bytes) {
    if (bytes < 1024)            return '${bytes} B';
    if (bytes < 1024 * 1024)     return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // Explicit sentinel so we can null-out compressedFile/Size on retry
  static const _keep = Object();

  ImageItem copyWith({
    Object? compressedFile  = _keep,
    Object? compressedSize  = _keep,
    CompressionStatus? status,
    double? progress,
    Object? errorMessage    = _keep,
  }) {
    return ImageItem(
      id             : id,
      originalFile   : originalFile,
      originalName   : originalName,
      originalSize   : originalSize,
      compressedFile : compressedFile  == _keep ? this.compressedFile  : compressedFile  as File?,
      compressedSize : compressedSize  == _keep ? this.compressedSize  : compressedSize  as int?,
      status         : status         ?? this.status,
      progress       : progress       ?? this.progress,
      errorMessage   : errorMessage   == _keep ? this.errorMessage   : errorMessage   as String?,
    );
  }
}
