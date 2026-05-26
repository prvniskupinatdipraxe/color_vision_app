import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class GradientRectSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  final LinearGradient gradient;

  const GradientRectSliderTrackShape({
    required this.gradient,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) return;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeTrackRect = Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    final inactiveTrackRect = Rect.fromLTRB(thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);

    final Paint activePaint = Paint()..shader = gradient.createShader(trackRect);
    final Paint inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor!;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeTrackRect, Radius.circular(trackRect.height / 2)),
      activePaint,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveTrackRect, Radius.circular(trackRect.height / 2)),
      inactivePaint,
    );
  }
}

class AnimatedColorSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  const AnimatedColorSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighContrast = themeProvider.isHighContrast;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isHighContrast ? FontWeight.bold : FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(isHighContrast ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activeColor.withOpacity(isHighContrast ? 0.8 : 0.3),
                  width: isHighContrast ? 2.0 : 1.0,
                ),
              ),
              child: Text(
                '${(value * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark && isHighContrast ? Colors.white : activeColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 32, // Increased height for better accessibility
          decoration: BoxDecoration(
            boxShadow: [
              if (!themeProvider.isSimplifiedUI)
                BoxShadow(
                  color: activeColor.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: SliderTheme(
            data: Theme.of(context).sliderTheme.copyWith(
                  activeTrackColor: activeColor,
                  inactiveTrackColor: isDark 
                      ? (isHighContrast ? Colors.white38 : Colors.white10) 
                      : (isHighContrast ? Colors.black38 : Colors.black12),
                  thumbColor: isDark && isHighContrast ? Colors.white : activeColor,
                  overlayColor: activeColor.withOpacity(0.2),
                  trackHeight: isHighContrast ? 4.0 : 3.0,
                  trackShape: GradientRectSliderTrackShape(
                    gradient: LinearGradient(
                      colors: [
                        activeColor.withOpacity(0.3),
                        activeColor,
                      ],
                    ),
                  ),
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isHighContrast ? 10 : 8, 
                    elevation: isHighContrast ? 12 : 8
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              onChangeEnd: (val) {
                themeProvider.triggerHaptic();
              },
            ),
          ),
        ),
      ],
    );
  }
}
