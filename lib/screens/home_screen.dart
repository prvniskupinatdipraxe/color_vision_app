import 'package:flutter/material.dart';
import '../widgets/animated_color_slider.dart';
import '../widgets/camera_preview_placeholder.dart';
import '../widgets/glass_container.dart';
import '../services/color_vision_simulator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double redValue = 0.5;
  double greenValue = 0.5;
  double blueValue = 0.5;

  void _applyPreset(double value) {
    setState(() {
      redValue = value;
      greenValue = value;
      blueValue = value;
    });
  }

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Assist Mode',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Assist mode enhances difficult colors in real time to improve visibility for users with color vision deficiencies.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matrix = ColorVisionSimulator.calculateCorrectionMatrix(
      redSensitivity: redValue,
      greenSensitivity: greenValue,
      blueSensitivity: blueValue,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Vision Assist',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showInfoSheet(context),
                    icon: const Icon(Icons.info_outline, color: Colors.white54, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CameraPreviewPlaceholder(matrix: matrix),
              const SizedBox(height: 24),
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensitivity Adjustments',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPresetButton('Mild', 0.8),
                        _buildPresetButton('Medium', 0.5),
                        _buildPresetButton('Strong', 0.1),
                        _buildPresetButton('Reset', 1.0, isReset: true),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AnimatedColorSlider(
                      label: 'Red Sensitivity (Protan)',
                      value: redValue,
                      activeColor: Colors.redAccent,
                      onChanged: (val) {
                        setState(() {
                          redValue = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    AnimatedColorSlider(
                      label: 'Green Sensitivity (Deutan)',
                      value: greenValue,
                      activeColor: Colors.greenAccent,
                      onChanged: (val) {
                        setState(() {
                          greenValue = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    AnimatedColorSlider(
                      label: 'Blue Sensitivity (Tritan)',
                      value: blueValue,
                      activeColor: Colors.blueAccent,
                      onChanged: (val) {
                        setState(() {
                          blueValue = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, double value, {bool isReset = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => _applyPreset(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: isReset 
                ? Colors.redAccent.withOpacity(0.1) 
                : Colors.white.withOpacity(0.05),
            foregroundColor: isReset ? Colors.redAccent : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isReset 
                    ? Colors.redAccent.withOpacity(0.3) 
                    : Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
