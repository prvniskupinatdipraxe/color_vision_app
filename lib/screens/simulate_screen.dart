import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_color_slider.dart';
import '../widgets/camera_preview_placeholder.dart';
import '../widgets/glass_container.dart';
import '../services/color_vision_simulator.dart';
import '../services/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DeficiencyType { protan, deutan, tritan }

class SimulateScreen extends StatefulWidget {
  const SimulateScreen({super.key});

  @override
  State<SimulateScreen> createState() => _SimulateScreenState();
}

class _SimulateScreenState extends State<SimulateScreen> {
  DeficiencyType _selectedType = DeficiencyType.protan;
  double _intensity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _intensity = prefs.getDouble('simulate_intensity') ?? 0.0;
      final typeIndex = prefs.getInt('simulate_type') ?? 0;
      if (typeIndex >= 0 && typeIndex < DeficiencyType.values.length) {
        _selectedType = DeficiencyType.values[typeIndex];
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('simulate_intensity', _intensity);
    await prefs.setInt('simulate_type', _selectedType.index);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getAccentColor(DeficiencyType type) {
    switch (type) {
      case DeficiencyType.protan:
        return const Color(0xFFE57373); // Soft red
      case DeficiencyType.deutan:
        return const Color(0xFF81C784); // Soft green
      case DeficiencyType.tritan:
        return const Color(0xFF64B5F6); // Soft blue
    }
  }

  void _showInfoSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  elevation: 0,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    icon: Icon(
                      Icons.info_outline, 
                      color: isDark ? Colors.white54 : Colors.black45, 
                      size: 24
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CameraPreviewPlaceholder(
                matrix: matrix,
                accentColor: _getAccentColor(_selectedType),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Deficiency Type',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildTypeCard(
                    context,
                    DeficiencyType.protan,
                    'Protanopia',
                    'Red-Blind',
                    Icons.lens_blur_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildTypeCard(
                    context,
                    DeficiencyType.deutan,
                    'Deuteranopia',
                    'Green-Blind',
                    Icons.lens_blur_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildTypeCard(
                    context,
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
                    if (!themeProvider.isSimplifiedUI) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIntensityPreset(context, 'Mild', 0.2, _getAccentColor(_selectedType)),
                          _buildIntensityPreset(context, 'Medium', 0.5, _getAccentColor(_selectedType)),
                          _buildIntensityPreset(context, 'Severe', 1.0, _getAccentColor(_selectedType)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    AnimatedColorSlider(
                      label: 'Simulation Strength',
                      value: _intensity,
                      activeColor: _getAccentColor(_selectedType),
                      onChanged: (val) {
                        setState(() {
                          _intensity = val;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Current Settings'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _getAccentColor(_selectedType).withOpacity(0.15),
                          foregroundColor: _getAccentColor(_selectedType),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _getAccentColor(_selectedType).withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildTypeCard(BuildContext context, DeficiencyType type, String title, String subtitle, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _getAccentColor(type);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: isSelected ? Border.all(color: typeColor.withOpacity(0.5), width: 1.5) : null,
            boxShadow: isSelected && !themeProvider.isSimplifiedUI
                ? [
                    BoxShadow(
                      color: typeColor.withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            gradientColors: isSelected && !themeProvider.isSimplifiedUI
                ? [
                    typeColor.withOpacity(0.25),
                    typeColor.withOpacity(0.05),
                  ]
                : null,
            child: Column(
              children: [
                Icon(
                  icon,
                  color: typeColor.withOpacity(isSelected ? 1.0 : 0.6),
                  size: 28,
                  shadows: isSelected ? [
                    Shadow(color: typeColor.withOpacity(0.5), blurRadius: 10)
                  ] : null,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (!themeProvider.isSimplifiedUI)
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntensityPreset(BuildContext context, String label, double value, Color accentColor) {
    final isSelected = (_intensity - value).abs() < 0.05;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => setState(() => _intensity = value),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected 
                ? accentColor.withOpacity(0.2) 
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            foregroundColor: isSelected ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white54 : Colors.black54),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected 
                    ? accentColor.withOpacity(0.5) 
                    : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
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
