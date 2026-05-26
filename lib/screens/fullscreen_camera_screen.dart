import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/color_vision_simulator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:async';

class FullscreenCameraScreen extends StatefulWidget {
  final CameraController controller;
  final List<double>? baseMatrix;
  final bool isSimulation;

  const FullscreenCameraScreen({
    super.key,
    required this.controller,
    this.baseMatrix,
    this.isSimulation = false,
  });

  @override
  State<FullscreenCameraScreen> createState() => _FullscreenCameraScreenState();
}

class _FullscreenCameraScreenState extends State<FullscreenCameraScreen> {
  final GlobalKey _previewKey = GlobalKey();
  bool _showOriginal = false;
  double _intensity = 1.0;
  bool _isFrozen = false;
  File? _importedImage;
  bool _isCapturing = false;

  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  bool _isZooming = false;
  
  Timer? _hideControlsTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initZoomLevels();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isZooming && !_isCapturing) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  Future<void> _initZoomLevels() async {
    try {
      _minAvailableZoom = await widget.controller.getMinZoomLevel();
      _maxAvailableZoom = await widget.controller.getMaxZoomLevel();
      if (_maxAvailableZoom > 8.0) _maxAvailableZoom = 8.0; // clamp realistic max zoom
      _currentZoomLevel = _minAvailableZoom;
    } catch (e) {
      debugPrint('Error getting zoom levels: $e');
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _hideControlsTimer?.cancel();
    if (_isFrozen) {
      widget.controller.resumePreview();
    }
    super.dispose();
  }

  Future<bool> _requestSavePermission() async {
    bool hasPermission = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 28) {
        final status = await Permission.storage.request();
        hasPermission = status.isGranted;
      } else {
        // Android 10+ (API 29+): Scoped storage does not require explicit permission to save photos
        hasPermission = true;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      if (status.isGranted || status.isLimited) {
        hasPermission = true;
      } else {
        final fallback = await Permission.photos.request();
        hasPermission = fallback.isGranted || fallback.isLimited;
      }
    } else {
      hasPermission = true;
    }

    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission denied. Gallery access is needed to save photos.'),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Theme.of(context).colorScheme.primary,
            onPressed: () => openAppSettings(),
          ),
          backgroundColor: Colors.black.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
    return hasPermission;
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.triggerHaptic();
  }

  Future<void> _importImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _importedImage = File(pickedFile.path);
        _isFrozen = true;
      });
      widget.controller.pausePreview();
    }
  }

  Future<void> _captureComparison() async {
    if (_isCapturing) return;

    // Request dynamic saving permissions
    final hasPermission = await _requestSavePermission();
    if (!hasPermission) return;

    setState(() => _isCapturing = true);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.triggerHaptic();

    try {
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception("Could not find preview boundary");

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception("Failed to convert image to bytes");
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: "vision_assist_${DateTime.now().millisecondsSinceEpoch}",
      );
      
      if (mounted) {
        final bool isSuccess = result != null && result['isSuccess'] == true;
        
        // Show flash effect overlay if needed, but simple Snackbar for now
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                ),
                const SizedBox(width: 12),
                Text(isSuccess ? 'Photo saved to gallery' : 'Failed to save photo'),
              ],
            ),
            backgroundColor: Colors.black.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
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

    Widget baseContent;
    if (_importedImage != null) {
      baseContent = Image.file(
        _importedImage!,
        fit: BoxFit.contain,
      );
    } else {
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      double previewRatio = widget.controller.value.aspectRatio;
      if (isPortrait) {
        previewRatio = 1 / previewRatio;
      }
      
      baseContent = Center(
        child: AspectRatio(
          aspectRatio: previewRatio,
          child: CameraPreview(widget.controller),
        ),
      );

      if (!_isFrozen) {
        baseContent = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          onScaleStart: (details) {
            _baseZoomLevel = _currentZoomLevel;
            setState(() {
              _isZooming = true;
            });
            _startHideTimer();
          },
          onScaleUpdate: (details) {
            setState(() {
              _currentZoomLevel = (_baseZoomLevel * details.scale)
                  .clamp(_minAvailableZoom, _maxAvailableZoom);
            });
            widget.controller.setZoomLevel(_currentZoomLevel);
          },
          onScaleEnd: (details) {
            setState(() {
              _isZooming = false;
            });
            _startHideTimer();
          },
          child: baseContent,
        );
      } else {
        baseContent = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: baseContent,
        );
      }
    }

    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: baseContent,
    );

    if (activeMatrix != null) {
      content = ColorFiltered(
        colorFilter: ColorFilter.matrix(activeMatrix),
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
          RepaintBoundary(
            key: _previewKey,
            child: Hero(
              tag: 'camera_preview',
              child: content,
            ),
          ),
          
          // Zoom Indicator
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 20,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _isZooming ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentZoomLevel.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Flash effect during capture
          if (_isCapturing)
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.3)),
            ),

          // Top Bar Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Listener(
                  onPointerDown: (_) => _hideControlsTimer?.cancel(),
                  onPointerUp: (_) => _startHideTimer(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFloatingButton(Icons.close, () {
                        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                        themeProvider.triggerHaptic();
                        Navigator.pop(context);
                      }),
                      Row(
                        children: [
                          _buildFloatingButton(Icons.image_outlined, _importImage),
                          const SizedBox(width: 12),
                          _buildFloatingButton(
                            _isCapturing ? Icons.hourglass_empty : Icons.camera_alt,
                            _captureComparison,
                            isActive: _isCapturing,
                          ),
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
              ),
            ),
          ),

          // Controls Panel (Bottom)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Listener(
                  onPointerDown: (_) => _hideControlsTimer?.cancel(),
                  onPointerUp: (_) => _startHideTimer(),
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
                                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                                themeProvider.triggerHaptic();
                                setState(() {
                                  _showOriginal = true;
                                });
                              }),
                              const SizedBox(width: 8),
                              _buildModeChip(widget.isSimulation ? 'Simulated' : 'Assisted', !_showOriginal, () {
                                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                                themeProvider.triggerHaptic();
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
                                    onChangeEnd: (val) {
                                      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                                      themeProvider.triggerHaptic();
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

class ColorMatrixTween extends Tween<List<double>> {
  ColorMatrixTween({required super.begin, required super.end});

  @override
  List<double> lerp(double t) {
    return ColorVisionSimulator.interpolateMatrix(begin!, end!, t);
  }
}
