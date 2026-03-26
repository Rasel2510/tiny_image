import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../models/image_item.dart';
import '../services/compression_service.dart';
import '../widgets/drop_zone.dart';
import '../widgets/image_card.dart';
import '../widgets/settings_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<ImageItem> _images = [];
  int _quality = 75;
  String _format = 'JPEG';

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  // ─── Pick ────────────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 100);
    if (files.isEmpty) return;

    final newItems = <ImageItem>[];
    for (final f in files) {
      final file = File(f.path);
      final stat = await file.stat();
      newItems.add(ImageItem(
        id: '${DateTime.now().microsecondsSinceEpoch}_${f.name}',
        originalFile: file,
        originalName: f.name,
        originalSize: stat.size,
      ));
    }

    if (!mounted) return;
    setState(() => _images.insertAll(0, newItems));

    for (final item in newItems) {
      await _compressOne(item);
    }
  }

  // ─── Compress ────────────────────────────────────────────────────────────

  Future<void> _compressOne(ImageItem item) async {
    final idx = _images.indexWhere((i) => i.id == item.id);
    if (idx == -1) return;

    // Reset state for retry
    setState(() {
      _images[idx] = _images[idx].copyWith(
        status: CompressionStatus.compressing,
        progress: 0,
        compressedFile: null,
        compressedSize: null,
        errorMessage: null,
      );
    });

    final result = await CompressionService.compress(
      inputFile: _images[idx].originalFile,
      quality: _quality,
      outputFormat: _format,
    );

    if (!mounted) return;
    final currentIdx = _images.indexWhere((i) => i.id == item.id);
    if (currentIdx == -1) return;

    if (result == null) {
      setState(() {
        _images[currentIdx] = _images[currentIdx].copyWith(
          status: CompressionStatus.error,
          errorMessage: 'Compression failed. Try a different format.',
        );
      });
      return;
    }

    final stat = await result.stat();
    if (!mounted) return;
    final finalIdx = _images.indexWhere((i) => i.id == item.id);
    if (finalIdx == -1) return;

    setState(() {
      _images[finalIdx] = _images[finalIdx].copyWith(
        compressedFile: result,
        compressedSize: stat.size,
        status: CompressionStatus.done,
        progress: 1,
      );
    });

    HapticFeedback.lightImpact();
  }

  Future<void> _recompressAll() async {
    final items = List<ImageItem>.from(_images);
    for (final item in items) {
      await _compressOne(item);
    }
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _shareOne(ImageItem item) async {
    if (item.compressedFile == null) return;
    await Share.shareXFiles(
      [XFile(item.compressedFile!.path)],
      subject: 'Compressed image',
    );
  }

  Future<void> _shareAll() async {
    final done =
        _images.where((i) => i.status == CompressionStatus.done).toList();
    if (done.isEmpty) return;
    await Share.shareXFiles(
      done.map((i) => XFile(i.compressedFile!.path)).toList(),
      subject: 'Compressed images',
    );
  }

  Future<void> _saveToGallery(ImageItem item) async {
    if (item.compressedFile == null) return;
    final ok = await CompressionService.saveToGallery(item.compressedFile!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Saved to gallery ✓' : 'Could not save to gallery'),
      backgroundColor:
          ok ? AppColors.green.withAlpha(200) : AppColors.red.withAlpha(200),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _removeImage(String id) =>
      setState(() => _images.removeWhere((i) => i.id == id));

  void _clearAll() => setState(() => _images.clear());

  // ─── Stats ───────────────────────────────────────────────────────────────

  int get _totalSaved {
    int saved = 0;
    for (final img in _images) {
      if (img.compressedSize != null && !img.isLarger) {
        saved += img.originalSize - img.compressedSize!;
      }
    }
    return saved;
  }

  String _fmtBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(opacity: _headerFade, child: _buildHeader()),
            SettingsBar(
              quality: _quality,
              format: _format,
              onQualityChanged: (v) => setState(() => _quality = v),
              onFormatChanged: (v) => setState(() => _format = v),
              onRecompress: _images.isNotEmpty ? _recompressAll : null,
            ),
            if (_images.isNotEmpty) _buildStatsBar(),
            Expanded(
              child: _images.isEmpty
                  ? DropZone(onTap: _pickImages)
                  : _buildImageList(),
            ),
            if (_images.isNotEmpty) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
            shaderCallback: (b) => const LinearGradient(
              colors: [AppColors.accent, AppColors.accent2],
            ).createShader(b),
            child: const Text(
              'TinyImg',
              style: TextStyle(
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
                child: const Text('Clear all',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
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

    double avgSaving = 0;
    if (done > 0) {
      avgSaving = _images
              .where((i) => i.status == CompressionStatus.done)
              .map((i) => i.savedPercent)
              .fold(0.0, (a, b) => a + b) /
          done;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _statChip('Files', '$done / $total'),
          _statDivider(),
          _statChip('Saved', _fmtBytes(saved), highlight: saved > 0),
          _statDivider(),
          _statChip(
            'Avg',
            done > 0 ? '-${avgSaving.toStringAsFixed(0)}%' : '--',
            highlight: done > 0,
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, {bool highlight = false}) =>
      Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.green : AppColors.text,
                  letterSpacing: -0.3,
                )),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      );

  Widget _statDivider() => Container(
        width: 1,
        height: 30,
        color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  Widget _buildImageList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
      itemCount: _images.length,
      itemBuilder: (_, i) {
        final item = _images[i];
        return ImageCard(
          key: ValueKey(item.id),
          item: item,
          onShare: () => _shareOne(item),
          onSave: () => _saveToGallery(item),
          onRemove: () => _removeImage(item.id),
          onRetry: () => _compressOne(item),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _gradientButton(
              label: 'Add More',
              icon: Icons.add_photo_alternate_outlined,
              onTap: _pickImages,
            ),
          ),
          const SizedBox(width: 12),
          _iconButton(
            icon: Icons.ios_share_rounded,
            onTap: _shareAll,
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.accent2],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                )),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.text, size: 20),
      ),
    );
  }
}
