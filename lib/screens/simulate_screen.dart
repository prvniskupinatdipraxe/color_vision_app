import 'package:flutter/material.dart';
import '../widgets/animated_color_slider.dart';
import '../widgets/camera_preview_placeholder.dart';
import '../widgets/glass_container.dart';
import '../services/color_vision_simulator.dart';

enum DeficiencyType { protan, deutan, tritan }

class SimulateScreen extends StatefulWidget {
  const SimulateScreen({super.key});

  @override
  State<SimulateScreen> createState() => _SimulateScreenState();
}

class _SimulateScreenState extends State<SimulateScreen> {
  DeficiencyType _selectedType = DeficiencyType.protan;
  double _intensity = 0.5;

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
                  'Simulate Mode',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Simulate mode recreates how different color blindness types affect real-world vision.',
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
    // Map single intensity to specific channel sensitivity
    double red = 1.0;
    double green = 1.0;
    double blue = 1.0;
    
    final sensitivity = 1.0 - _intensity;
    
    switch (_selectedType) {
      case DeficiencyType.protan:
        red = sensitivity;
        break;
      case DeficiencyType.deutan:
        green = sensitivity;
        break;
      case DeficiencyType.tritan:
        blue = sensitivity;
        break;
    }

    final matrix = ColorVisionSimulator.calculateSimulationMatrix(
      redSensitivity: red,
      greenSensitivity: green,
      blueSensitivity: blue,
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
                    'Simulate',
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
              
              Text(
                'Deficiency Type',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildTypeCard(
                    DeficiencyType.protan,
                    'Protanopia',
                    'Red-Blind',
                    Icons.lens_blur_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildTypeCard(
                    DeficiencyType.deutan,
                    'Deuteranopia',
                    'Green-Blind',
                    Icons.lens_blur_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildTypeCard(
                    DeficiencyType.tritan,
                    'Tritanopia',
                    'Blue-Blind',
                    Icons.lens_blur_rounded,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intensity Control',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIntensityPreset('Mild', 0.2),
                        _buildIntensityPreset('Medium', 0.5),
                        _buildIntensityPreset('Severe', 1.0),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AnimatedColorSlider(
                      label: 'Simulation Strength',
                      value: _intensity,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _intensity = val;
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

  Widget _buildTypeCard(DeficiencyType type, String title, String subtitle, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          gradientColors: isSelected
              ? [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ]
              : null,
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white38,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white54,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntensityPreset(String label, double value) {
    final isSelected = (_intensity - value).abs() < 0.05;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => setState(() => _intensity = value),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2) 
                : Colors.white.withOpacity(0.05),
            foregroundColor: isSelected ? Colors.white : Colors.white54,
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5) 
                    : Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
