import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/camera_preview_placeholder.dart';
import '../services/color_vision_simulator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FullscreenCameraScreen extends StatefulWidget {
  final CameraController controller;
  final List<double>? baseMatrix;

  const FullscreenCameraScreen({
    super.key,
    required this.controller,
    this.baseMatrix,
  });

  @override
  State<FullscreenCameraScreen> createState() => _FullscreenCameraScreenState();
}

class _FullscreenCameraScreenState extends State<FullscreenCameraScreen> {
  bool _showOriginal = false;
  double _intensity = 1.0;
  
  bool _isFrozen = false;
  
  File? _importedImage;

  @override
  void dispose() {
    if (_isFrozen) {
      widget.controller.resumePreview();
    }
    super.dispose();
  }

  void _toggleFreeze() {
    setState(() {
      _isFrozen = !_isFrozen;
    });
    if (_isFrozen) {
      widget.controller.pausePreview();
    } else {
      widget.controller.resumePreview();
    }
  }

  Future<void> _importImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _importedImage = File(pickedFile.path);
        _isFrozen = true; // freeze camera so imported image is shown statically
      });
      widget.controller.pausePreview();
    }
  }

  Future<void> _captureComparison() async {
    // Show success animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent),
            SizedBox(width: 12),
            Text('Capture saved to Gallery'),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<double>? activeMatrix;
    
    if (widget.baseMatrix != null) {
      if (_showOriginal || _intensity == 0.0) {
        activeMatrix = ColorVisionSimulator.identity;
      } else if (_intensity == 1.0) {
        activeMatrix = widget.baseMatrix;
      } else {
        activeMatrix = ColorVisionSimulator.interpolateMatrix(
          ColorVisionSimulator.identity,
          widget.baseMatrix!,
          _intensity,
        );
      }
    }

    Widget baseContent = _importedImage != null
        ? Image.file(_importedImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
        : CameraPreview(widget.controller);

    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: baseContent,
    );

    if (activeMatrix != null) {
      content = TweenAnimationBuilder<List<double>>(
        tween: ColorMatrixTween(
          begin: ColorVisionSimulator.identity,
          end: activeMatrix,
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

    if (_isFrozen) {
      content = InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'camera_preview',
            child: content,
          ),
          
          // Top Bar Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingButton(Icons.close, () => Navigator.pop(context)),
                Row(
                  children: [
                    _buildFloatingButton(Icons.image_outlined, _importImage),
                    const SizedBox(width: 12),
                    _buildFloatingButton(Icons.camera_alt, _captureComparison),
                    const SizedBox(width: 12),
                    _buildFloatingButton(
                      _isFrozen ? Icons.play_arrow : Icons.pause,
                      _toggleFreeze,
                      isActive: _isFrozen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Controls Panel (Bottom)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode Toggles
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModeChip('Original', _showOriginal, () {
                          setState(() {
                            _showOriginal = true;
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildModeChip('Assisted', !_showOriginal, () {
                          setState(() {
                            _showOriginal = false;
                          });
                        }),
                      ],
                    ),
                  ),
                  
                  // Compact Intensity Slider
                  if (!_showOriginal) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.opacity, color: Colors.white54, size: 20),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Theme.of(context).colorScheme.primary,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                              overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              trackHeight: 4.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            ),
                            child: Slider(
                              value: _intensity,
                              onChanged: (val) {
                                setState(() {
                                  _intensity = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Text(
                          '${(_intensity * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.8) : Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildModeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.8) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
