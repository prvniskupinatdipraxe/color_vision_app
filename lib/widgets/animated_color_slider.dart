import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

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
        SizedBox(
          height: 32, // Increased height for better accessibility
          child: SliderTheme(
            data: Theme.of(context).sliderTheme.copyWith(
                  activeTrackColor: activeColor,
                  inactiveTrackColor: isDark 
                      ? (isHighContrast ? Colors.white38 : Colors.white10) 
                      : (isHighContrast ? Colors.black38 : Colors.black12),
                  thumbColor: isDark && isHighContrast ? Colors.white : activeColor,
                  overlayColor: activeColor.withOpacity(0.2),
                  trackHeight: isHighContrast ? 4.0 : 2.0,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isHighContrast ? 10 : 8, 
                    elevation: isHighContrast ? 12 : 8
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
