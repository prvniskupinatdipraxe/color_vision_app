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
    if (mounted) {
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
    
    Widget content;

    if (_isCameraInitialized && controller != null && controller.value.isInitialized) {
      final double aspectRatio = 1 / controller.value.aspectRatio;

      content = Stack(
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
      content = GlassContainer(
        height: 300,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 56,
                color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.5),
                      fontSize: 18,
                    ),
              ),
            ],
          ),
        ),
      );
    }

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
