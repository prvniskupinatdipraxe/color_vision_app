import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraManager {
  static final CameraManager _instance = CameraManager._internal();
  factory CameraManager() => _instance;
  CameraManager._internal();

  CameraController? _controller;
  bool _isInitialized = false;
  Future<void>? _initFuture;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized && _controller != null) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _initializeInternal();
    return _initFuture;
  }

  Future<void> _initializeInternal() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        
        await _controller!.initialize();
        
        // Wait a short duration to ensure the first frame is pushed to the SurfaceTexture
        // This prevents the black flash when the Texture widget first mounts
        await Future.delayed(const Duration(milliseconds: 300));
        
        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('Error initializing camera in CameraManager: $e');
      _initFuture = null; // Allow retry
      rethrow;
    }
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _initFuture = null;
  }
}
