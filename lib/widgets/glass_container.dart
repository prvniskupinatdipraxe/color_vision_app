import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final List<Color>? gradientColors;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;

    // Adjust based on Simplified UI
    final double blurX = themeProvider.isSimplifiedUI ? 0.0 : 10.0;
    final double blurY = themeProvider.isSimplifiedUI ? 0.0 : 10.0;

    // Adjust based on High Contrast
    final double opacityMultiplier = themeProvider.isHighContrast ? 2.0 : 1.0;
    final double borderWidth = themeProvider.isHighContrast ? 2.5 : 1.5;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: themeProvider.isSimplifiedUI
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: themeProvider.isSimplifiedUI 
                  ? (isDark ? Colors.black : Colors.white) 
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: baseColor.withOpacity(
                  (isDark ? 0.15 : 0.08) * opacityMultiplier,
                ),
                width: borderWidth,
              ),
              gradient: themeProvider.isSimplifiedUI
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors ??
                          [
                            baseColor.withOpacity(
                              (isDark ? 0.1 : 0.03) * opacityMultiplier,
                            ),
                            baseColor.withOpacity(
                              (isDark ? 0.05 : 0.01) * opacityMultiplier,
                            ),
                          ],
                    ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
