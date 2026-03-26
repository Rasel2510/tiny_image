import 'package:flutter/material.dart';
import '../main.dart';

class DropZone extends StatefulWidget {
  final VoidCallback onTap;
  const DropZone({super.key, required this.onTap});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync   : this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.975, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin : const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
            decoration: BoxDecoration(
              color        : AppColors.surface,
              borderRadius : BorderRadius.circular(24),
              border       : Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withAlpha(38),
                        AppColors.accent2.withAlpha(38),
                      ],
                      begin: Alignment.topLeft,
                      end  : Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size : 32,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.accent, AppColors.accent2],
                  ).createShader(b),
                  child: const Text(
                    'Add Images',
                    style: TextStyle(
                      fontSize  : 22,
                      fontWeight: FontWeight.w700,
                      color     : Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap to pick from gallery\nJPEG · PNG · WebP supported',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color   : AppColors.muted,
                    height  : 1.7,
                  ),
                ),
                const SizedBox(height: 28),

                Wrap(
                  spacing         : 8,
                  runSpacing       : 8,
                  alignment       : WrapAlignment.center,
                  children: ['⚡ Fast', '🔒 Offline', '🗜 Up to 90% smaller']
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color       : AppColors.surface2,
                              borderRadius: BorderRadius.circular(20),
                              border      : Border.all(color: AppColors.border),
                            ),
                            child: Text(s,
                                style: const TextStyle(
                                  fontSize  : 12,
                                  color     : AppColors.muted,
                                  fontWeight: FontWeight.w500,
                                )),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
