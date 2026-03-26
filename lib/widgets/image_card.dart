import 'package:flutter/material.dart';
import '../main.dart';
import '../models/image_item.dart';

class ImageCard extends StatefulWidget {
  final ImageItem    item;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  const ImageCard({
    super.key,
    required this.item,
    required this.onShare,
    required this.onSave,
    required this.onRemove,
    required this.onRetry,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end  : Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Color get _borderColor {
    switch (widget.item.status) {
      case CompressionStatus.done       : return AppColors.green.withAlpha(77);
      case CompressionStatus.error      : return AppColors.red.withAlpha(77);
      case CompressionStatus.compressing: return AppColors.accent.withAlpha(77);
      default                           : return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin     : const EdgeInsets.only(bottom: 10),
          padding    : const EdgeInsets.all(14),
          decoration : BoxDecoration(
            color        : AppColors.surface,
            borderRadius : BorderRadius.circular(16),
            border       : Border.all(color: _borderColor),
          ),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
              const SizedBox(width: 10),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56, height: 56,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              widget.item.originalFile,
              fit         : BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surface2,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.muted, size: 24),
              ),
            ),
            if (widget.item.status == CompressionStatus.compressing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color      : AppColors.accent,
                    ),
                  ),
                ),
              ),
            if (widget.item.status == CompressionStatus.done)
              Positioned(
                bottom: 3, right: 3,
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
      ),
    );
  }

  Widget _buildInfo() {
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File name
        Text(
          item.originalName,
          style: const TextStyle(
            fontSize     : 13,
            fontWeight   : FontWeight.w600,
            color        : AppColors.text,
            letterSpacing: -0.2,
          ),
          maxLines : 1,
          overflow : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Size row
        Row(
          children: [
            Text(item.originalSizeLabel,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            if (item.status == CompressionStatus.done) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 10, color: AppColors.muted),
              ),
              Text(
                item.compressedSizeLabel,
                style: TextStyle(
                  fontSize  : 12,
                  color     : item.isLarger ? AppColors.red : AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // Progress / status
        if (item.status == CompressionStatus.compressing)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              minHeight        : 3,
              backgroundColor  : AppColors.border,
              valueColor       : AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          )
        else if (item.status == CompressionStatus.done)
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value           : 1 - (item.savedPercent / 100),
                    minHeight       : 3,
                    backgroundColor : AppColors.border,
                    valueColor      : AlwaysStoppedAnimation<Color>(
                        item.isLarger ? AppColors.red : AppColors.green),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.isLarger ? '+larger' : item.savedPercentLabel,
                style: TextStyle(
                  fontSize  : 11,
                  color     : item.isLarger ? AppColors.red : AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        else if (item.status == CompressionStatus.error)
          Text(
            item.errorMessage ?? 'Compression failed',
            style: const TextStyle(fontSize: 11, color: AppColors.red),
            maxLines : 1,
            overflow : TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildActions() {
    final item = widget.item;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.status == CompressionStatus.done) ...[
          _iconBtn(Icons.save_alt_rounded,    AppColors.green,  widget.onSave),
          const SizedBox(height: 5),
          _iconBtn(Icons.ios_share_rounded,   AppColors.accent, widget.onShare),
        ],
        if (item.status == CompressionStatus.error)
          _iconBtn(Icons.refresh_rounded, AppColors.accent, widget.onRetry),
        const SizedBox(height: 5),
        _iconBtn(Icons.close_rounded, AppColors.muted, widget.onRemove),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color        : color.withAlpha(26),
          borderRadius : BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}
