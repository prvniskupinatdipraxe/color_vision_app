import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'glass_container.dart';
import '../services/color_vision_simulator.dart';
import '../screens/fullscreen_camera_screen.dart';
import '../services/camera_manager.dart';

class CameraPreviewPlaceholder extends StatefulWidget {
  final List<double>? matrix;

  const CameraPreviewPlaceholder({super.key, this.matrix});

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
    
    Widget content;

    if (_isCameraInitialized && controller != null && controller.value.isInitialized) {
      content = Stack(
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: CameraPreview(controller),
            ),
          ),
          
          // LIVE Badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Fullscreen Hint
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fullscreen, color: Colors.white.withOpacity(0.8), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to enter fullscreen',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      content = GlassContainer(
        height: 240,
        width: double.infinity,
        gradientColors: [
          Colors.black.withOpacity(0.3),
          Colors.black.withOpacity(0.1),
        ],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
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
        duration: const Duration(milliseconds: 300),
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
              transitionDuration: const Duration(milliseconds: 400),
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
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(_glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Hero(
                tag: 'camera_preview_\${widget.hashCode}',
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
