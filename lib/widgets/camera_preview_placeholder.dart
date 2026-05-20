import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'glass_container.dart';
import '../services/color_vision_simulator.dart';
import '../screens/fullscreen_camera_screen.dart';
import '../services/camera_manager.dart';
import '../services/theme_provider.dart';

class CameraPreviewPlaceholder extends StatefulWidget {
  final List<double>? matrix;
  final Color? accentColor;

  const CameraPreviewPlaceholder({super.key, this.matrix, this.accentColor});

  @override
  State<CameraPreviewPlaceholder> createState() => _CameraPreviewPlaceholderState();
}

class _CameraPreviewPlaceholderState extends State<CameraPreviewPlaceholder> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _isCameraInitialized = CameraManager().isInitialized;
    _checkCamera();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkCamera() async {
    final cameraManager = CameraManager();
    if (!cameraManager.isInitialized) {
      await cameraManager.initialize();
    }
    if (mounted && _isCameraInitialized != cameraManager.isInitialized) {
      setState(() {
        _isCameraInitialized = cameraManager.isInitialized;
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraManager = CameraManager();
    final controller = cameraManager.controller;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget cameraContent;
    Widget content;

    if (_isCameraInitialized && controller != null && controller.value.isInitialized) {
      final double aspectRatio = 1 / controller.value.aspectRatio;

      cameraContent = Stack(
        key: const ValueKey('camera_preview'),
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28.0),
              boxShadow: themeProvider.isSimplifiedUI ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.0),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
          
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (widget.accentColor ?? Colors.redAccent).withOpacity(0.85),
                borderRadius: BorderRadius.circular(10),
                boxShadow: themeProvider.isSimplifiedUI ? null : [
                  BoxShadow(
                    color: (widget.accentColor ?? Colors.redAccent).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.fullscreen, color: Colors.white, size: 24),
            ),
          ),
        ],
      );
    } else {
      // Use a standard portrait aspect ratio for the placeholder (3:4) to avoid layout jumps
      cameraContent = AspectRatio(
        key: const ValueKey('camera_placeholder'),
        aspectRatio: 3 / 4,
        child: GlassContainer(
          width: double.infinity,
          borderRadius: 28,
          gradientColors: themeProvider.isSimplifiedUI ? [
            isDark ? Colors.black : Colors.grey.shade200,
            isDark ? Colors.black : Colors.grey.shade200,
          ] : [
            isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            isDark ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.02),
          ],
          child: Center(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _glowAnimation.value * 0.8, // 0.16 to 0.48 opacity
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: cameraContent,
    );

    if (widget.matrix != null) {
      content = TweenAnimationBuilder<List<double>>(
        tween: ColorMatrixTween(
          begin: ColorVisionSimulator.identity,
          end: widget.matrix!,
        ),
        duration: themeProvider.isSimplifiedUI ? Duration.zero : const Duration(milliseconds: 300),
        builder: (context, currentMatrix, child) {
          return ColorFiltered(
            colorFilter: ColorFilter.matrix(currentMatrix),
            child: child,
          );
        },
        child: content,
      );
    }

    if (_isCameraInitialized && controller != null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: themeProvider.isSimplifiedUI ? Duration.zero : const Duration(milliseconds: 400),
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(
                  opacity: animation,
                  child: FullscreenCameraScreen(
                    controller: controller,
                    baseMatrix: widget.matrix,
                  ),
                );
              },
            ),
          );
        },
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.0),
                boxShadow: themeProvider.isSimplifiedUI ? null : [
                  BoxShadow(
                    color: (widget.accentColor ?? Theme.of(context).colorScheme.primary).withOpacity(_glowAnimation.value * 0.5),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Hero(
                tag: 'camera_preview_${widget.hashCode}',
                child: content,
              ),
            );
          },
        ),
      );
    }

    return content;
  }
}

class ColorMatrixTween extends Tween<List<double>> {
  ColorMatrixTween({required super.begin, required super.end});

  @override
  List<double> lerp(double t) {
    return ColorVisionSimulator.interpolateMatrix(begin!, end!, t);
  }
}
