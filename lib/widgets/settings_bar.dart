import 'package:flutter/material.dart';
import '../main.dart';

class SettingsBar extends StatelessWidget {
  final int                  quality;
  final String               format;
  final ValueChanged<int>    onQualityChanged;
  final ValueChanged<String> onFormatChanged;
  final VoidCallback?        onRecompress;

  const SettingsBar({
    super.key,
    required this.quality,
    required this.format,
    required this.onQualityChanged,
    required this.onFormatChanged,
    this.onRecompress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin : const EdgeInsets.fromLTRB(24, 14, 24, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color        : AppColors.surface,
        borderRadius : BorderRadius.circular(14),
        border       : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Quality ──────────────────────────────
          Row(
            children: [
              _label('QUALITY'),
              const Spacer(),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.accent, AppColors.accent2],
                ).createShader(b),
                child: Text(
                  '$quality%',
                  style: const TextStyle(
                    fontSize  : 14,
                    fontWeight: FontWeight.w700,
                    color     : Colors.white,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value   : quality.toDouble(),
            min     : 10,
            max     : 100,
            divisions: 18,
            onChanged: (v) => onQualityChanged(v.round()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hint('Smaller file'),
                _hint('Better quality'),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),

          // ── Format + Apply ───────────────────────
          Row(
            children: [
              _label('FORMAT'),
              const SizedBox(width: 10),
              ...['JPEG', 'PNG', 'WebP'].map(_fmtChip),
              const Spacer(),
              if (onRecompress != null)
                GestureDetector(
                  onTap: onRecompress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient    : const LinearGradient(
                          colors: [AppColors.accent, AppColors.accent2]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Apply',
                        style: TextStyle(
                          fontSize  : 12,
                          color     : Colors.white,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize  : 10,
          color     : AppColors.muted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _hint(String text) => Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppColors.muted),
      );

  Widget _fmtChip(String label) {
    final selected = format == label;
    return GestureDetector(
      onTap: () => onFormatChanged(label),
      child: Container(
        margin : const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color       : selected
              ? AppColors.accent.withAlpha(38)
              : AppColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border      : Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize  : 11,
            color     : selected ? AppColors.accent : AppColors.muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
