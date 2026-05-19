import 'package:flutter/material.dart';
import '../widgets/animated_color_slider.dart';
import '../widgets/camera_preview_placeholder.dart';
import '../widgets/glass_container.dart';
import '../services/color_vision_simulator.dart';

class SimulateScreen extends StatefulWidget {
  const SimulateScreen({super.key});

  @override
  State<SimulateScreen> createState() => _SimulateScreenState();
}

class _SimulateScreenState extends State<SimulateScreen> {
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

  @override
  Widget build(BuildContext context) {
    final matrix = ColorVisionSimulator.calculateSimulationMatrix(
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
              Text(
                'Simulate',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Experience vision deficiencies',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
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
                      'Deficiency Intensity',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPresetButton('Mild', 0.8),
                        _buildPresetButton('Medium', 0.5),
                        _buildPresetButton('Severe', 0.1),
                        _buildPresetButton('None', 1.0, isReset: true),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AnimatedColorSlider(
                      label: 'Red Cones (Protan)',
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
                      label: 'Green Cones (Deutan)',
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
                      label: 'Blue Cones (Tritan)',
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
              const SizedBox(height: 100),
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
                ? Colors.greenAccent.withOpacity(0.1) 
                : Colors.white.withOpacity(0.05),
            foregroundColor: isReset ? Colors.greenAccent : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isReset 
                    ? Colors.greenAccent.withOpacity(0.3) 
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
