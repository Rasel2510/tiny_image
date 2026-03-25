import 'package:flutter/material.dart';
import '../main.dart';
import '../models/image_item.dart';

class ImageCard extends StatefulWidget {
  final ImageItem item;
  final VoidCallback onShare;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  const ImageCard({
    super.key,
    required this.item,
    required this.onShare,
    required this.onRemove,
    required this.onRetry,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              _buildThumbnail(),
              const SizedBox(width: 14),

              // Info
              Expanded(child: _buildInfo()),
              const SizedBox(width: 12),

              // Actions
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Color get _borderColor {
    switch (widget.item.status) {
      case CompressionStatus.done:
        return AppColors.green.withOpacity(0.3);
      case CompressionStatus.error:
        return AppColors.red.withOpacity(0.3);
      case CompressionStatus.compressing:
        return AppColors.accent.withOpacity(0.3);
      default:
        return AppColors.border;
    }
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Image.file(
            widget.item.originalFile,
            width: 56, height: 56,
            fit: BoxFit.cover,
          ),
          if (widget.item.status == CompressionStatus.compressing)
            Container(
              width: 56, height: 56,
              color: Colors.black54,
              child: const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          if (widget.item.status == CompressionStatus.done)
            Positioned(
              bottom: 4, right: 4,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.originalName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Size row
        Row(
          children: [
            Text(
              item.originalSizeLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
              ),
            ),
            if (item.status == CompressionStatus.done) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(Icons.arrow_forward,
                    size: 10, color: AppColors.muted),
              ),
              Text(
                item.compressedSizeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // Progress bar or status
        if (item.status == CompressionStatus.compressing)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          )
        else if (item.status == CompressionStatus.done)
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1 - (item.savedPercent / 100),
                    minHeight: 3,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.green),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.savedPercentLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        else if (item.status == CompressionStatus.error)
          const Text(
            'Compression failed',
            style: TextStyle(fontSize: 11, color: AppColors.red),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        if (widget.item.status == CompressionStatus.done)
          _iconBtn(Icons.ios_share_rounded, AppColors.accent, widget.onShare),
        if (widget.item.status == CompressionStatus.error)
          _iconBtn(Icons.refresh_rounded, AppColors.accent, widget.onRetry),
        const SizedBox(height: 6),
        _iconBtn(Icons.close_rounded, AppColors.muted, widget.onRemove),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
