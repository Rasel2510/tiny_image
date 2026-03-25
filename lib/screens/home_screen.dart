import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../models/image_item.dart';
import '../widgets/drop_zone.dart';
import '../widgets/image_card.dart';
import '../widgets/settings_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<ImageItem> _images = [];
  int _quality = 75;
  String _format = 'JPEG';
  bool _isProcessingAll = false;

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;

    final newItems = <ImageItem>[];
    for (final f in files) {
      final file = File(f.path);
      final stat = await file.stat();
      newItems.add(ImageItem(
        id: DateTime.now().microsecondsSinceEpoch.toString() + f.name,
        originalFile: file,
        originalName: f.name,
        originalSize: stat.size,
      ));
    }

    setState(() => _images.insertAll(0, newItems));
    _compressAll(newItems);
  }

  Future<void> _compressAll(List<ImageItem> items) async {
    setState(() => _isProcessingAll = true);

    for (final item in items) {
      await _compressOne(item);
    }

    setState(() => _isProcessingAll = false);
  }

  Future<void> _compressOne(ImageItem item) async {
    final idx = _images.indexWhere((i) => i.id == item.id);
    if (idx == -1) return;

    setState(() {
      _images[idx] = _images[idx].copyWith(
        status: CompressionStatus.compressing,
        progress: 0,
      );
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final ext =
          _format.toLowerCase() == 'jpeg' ? 'jpg' : _format.toLowerCase();
      final outPath =
          '${tempDir.path}/tinyimg_${DateTime.now().millisecondsSinceEpoch}.$ext';

      CompressFormat fmt;
      switch (_format) {
        case 'WebP':
          fmt = CompressFormat.webp;
          break;
        case 'PNG':
          fmt = CompressFormat.png;
          break;
        default:
          fmt = CompressFormat.jpeg;
      }

      final result = await FlutterImageCompress.compressAndGetFile(
        item.originalFile.absolute.path,
        outPath,
        quality: _quality,
        format: fmt,
        keepExif: false,
      );

      if (result == null) throw Exception('Compression failed');
      final outFile = File(result.path);
      final stat = await outFile.stat();

      setState(() {
        _images[idx] = _images[idx].copyWith(
          compressedFile: outFile,
          compressedSize: stat.size,
          status: CompressionStatus.done,
          progress: 1,
        );
      });
    } catch (e) {
      setState(() {
        _images[idx] = _images[idx].copyWith(
          status: CompressionStatus.error,
          errorMessage: e.toString(),
        );
      });
    }
  }

  Future<void> _recompressAll() async {
    final items = List<ImageItem>.from(_images);
    await _compressAll(items);
  }

  Future<void> _shareFile(ImageItem item) async {
    if (item.compressedFile == null) return;
    await Share.shareXFiles([XFile(item.compressedFile!.path)],
        text: 'Compressed with TinyImg');
  }

  void _removeImage(String id) {
    setState(() => _images.removeWhere((i) => i.id == id));
  }

  void _clearAll() {
    setState(() => _images.clear());
  }

  int get _totalSaved {
    int saved = 0;
    for (final img in _images) {
      if (img.compressedSize != null) {
        saved +=
            (img.originalSize - img.compressedSize!).clamp(0, img.originalSize);
      }
    }
    return saved;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            FadeTransition(
              opacity: _headerFade,
              child: _buildHeader(),
            ),

            // Settings bar
            SettingsBar(
              quality: _quality,
              format: _format,
              onQualityChanged: (v) => setState(() => _quality = v),
              onFormatChanged: (v) => setState(() => _format = v),
              onRecompress: _images.isNotEmpty ? _recompressAll : null,
            ),

            // Stats bar
            if (_images.isNotEmpty) _buildStatsBar(),

            // Content
            Expanded(
              child: _images.isEmpty
                  ? DropZone(onTap: _pickImages)
                  : _buildImageList(),
            ),

            // Bottom action bar
            if (_images.isNotEmpty) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accent2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.accent, AppColors.accent2],
            ).createShader(bounds),
            child: const Text(
              'TinyImg',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Spacer(),
          if (_images.isNotEmpty)
            GestureDetector(
              onTap: _clearAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final done =
        _images.where((i) => i.status == CompressionStatus.done).length;
    final total = _images.length;
    final saved = _totalSaved;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _statChip('Files', '$done/$total'),
          _divider(),
          _statChip('Saved', _formatBytes(saved), highlight: saved > 0),
          _divider(),
          _statChip(
            'Avg',
            done > 0
                ? '-${(_images.where((i) => i.status == CompressionStatus.done).map((i) => i.savedPercent).fold(0.0, (a, b) => a + b) / done).toStringAsFixed(0)}%'
                : '--',
            highlight: done > 0,
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, {bool highlight = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.green : AppColors.text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildImageList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      itemCount: _images.length,
      itemBuilder: (ctx, i) {
        final item = _images[i];
        return ImageCard(
          key: ValueKey(item.id),
          item: item,
          onShare: () => _shareFile(item),
          onRemove: () => _removeImage(item.id),
          onRetry: () => _compressOne(item),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accent2],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Add More',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final done = _images
                  .where((i) => i.status == CompressionStatus.done)
                  .toList();
              if (done.isEmpty) return;
              final paths =
                  done.map((i) => XFile(i.compressedFile!.path)).toList();
              await Share.shareXFiles(paths, text: 'Compressed with TinyImg');
            },
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.ios_share_rounded,
                color: AppColors.text,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
