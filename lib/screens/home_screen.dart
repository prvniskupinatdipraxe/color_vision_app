import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_color_slider.dart';
import '../widgets/camera_preview_placeholder.dart';
import '../widgets/glass_container.dart';
import '../services/color_vision_simulator.dart';
import '../services/theme_provider.dart';
import '../models/deficiency_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double redValue = 1.0;
  double greenValue = 1.0;
  double blueValue = 1.0;
  DeficiencyType _activeType = DeficiencyType.protan;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      redValue = prefs.getDouble('assist_red') ?? 1.0;
      greenValue = prefs.getDouble('assist_green') ?? 1.0;
      blueValue = prefs.getDouble('assist_blue') ?? 1.0;
      final typeIndex = prefs.getInt('assist_active_type') ?? 0;
      if (typeIndex >= 0 && typeIndex < DeficiencyType.values.length) {
        _activeType = DeficiencyType.values[typeIndex];
      }
    });
  }

  Future<void> _saveSettings() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.triggerHaptic();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('assist_red', redValue);
    await prefs.setDouble('assist_green', greenValue);
    await prefs.setDouble('assist_blue', blueValue);
    await prefs.setInt('assist_active_type', _activeType.index);
    
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

  void _applyPreset(double value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.triggerHaptic();

    setState(() {
      // Logic: Only update the channel matching the user's active handicap.
      // Other channels are reset to 1.0 (no correction) to ensure we only
      // assist the specific selected deficiency as requested.
      redValue = 1.0;
      greenValue = 1.0;
      blueValue = 1.0;

      switch (_activeType) {
        case DeficiencyType.protan:
          redValue = value;
          break;
        case DeficiencyType.deutan:
          greenValue = value;
          break;
        case DeficiencyType.tritan:
          blueValue = value;
          break;
      }
    });
  }

  void _showInfoSheet(BuildContext context) {
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
                  'Assist Mode',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Assist mode enhances difficult colors in real time to improve visibility for users with color vision deficiencies.',
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
              CameraPreviewPlaceholder(matrix: matrix),
              const SizedBox(height: 24),
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deficiency Focus',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Handicap Type Selector (Target specific color spectrum)
                    Row(
                      children: [
                        _buildTypeChip('Protan (Red)', DeficiencyType.protan),
                        const SizedBox(width: 8),
                        _buildTypeChip('Deutan (Green)', DeficiencyType.deutan),
                        const SizedBox(width: 8),
                        _buildTypeChip('Tritan (Blue)', DeficiencyType.tritan),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPresetButton(context, 'Mild', 0.8),
                        _buildPresetButton(context, 'Medium', 0.5),
                        _buildPresetButton(context, 'Strong', 0.1),
                        _buildPresetButton(context, 'Reset', 1.0, isReset: true),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Slider section - only the active one is highlighted through interaction
                    AnimatedColorSlider(
                      label: 'Red Sensitivity',
                      value: redValue,
                      activeColor: const Color(0xFFE57373),
                      onChanged: (val) {
                        setState(() {
                          redValue = val;
                          _activeType = DeficiencyType.protan;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    AnimatedColorSlider(
                      label: 'Green Sensitivity',
                      value: greenValue,
                      activeColor: const Color(0xFF81C784),
                      onChanged: (val) {
                        setState(() {
                          greenValue = val;
                          _activeType = DeficiencyType.deutan;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    AnimatedColorSlider(
                      label: 'Blue Sensitivity',
                      value: blueValue,
                      activeColor: const Color(0xFF64B5F6),
                      onChanged: (val) {
                        setState(() {
                          blueValue = val;
                          _activeType = DeficiencyType.tritan;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save My Configuration'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildTypeChip(String label, DeficiencyType type) {
    final isSelected = _activeType == type;
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          themeProvider.triggerHaptic();
          setState(() {
            _activeType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : (theme.brightness == Brightness.dark ? Colors.white54 : Colors.black45),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(BuildContext context, String label, double value, {bool isReset = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighContrast = themeProvider.isHighContrast;
    
    Color presetColor;
    switch (_activeType) {
      case DeficiencyType.protan: presetColor = const Color(0xFFE57373); break;
      case DeficiencyType.deutan: presetColor = const Color(0xFF81C784); break;
      case DeficiencyType.tritan: presetColor = const Color(0xFF64B5F6); break;
    }
    
    final bool active = isSelectedPreset(value);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => _applyPreset(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: isReset 
                ? (isHighContrast ? const Color(0xFFE57373).withOpacity(0.2) : const Color(0xFFE57373).withOpacity(0.1))
                : (active ? presetColor.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
            foregroundColor: isReset 
                ? (isDark && isHighContrast ? Colors.white : const Color(0xFFE57373)) 
                : (active ? presetColor : (isDark ? Colors.white : Colors.black87)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isReset 
                    ? (isHighContrast ? const Color(0xFFE57373) : const Color(0xFFE57373).withOpacity(0.3)) 
                    : (active ? presetColor.withOpacity(0.5) : (isHighContrast ? (isDark ? Colors.white38 : Colors.black38) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)))),
                width: (active || isReset) && isHighContrast ? 2.0 : 1.0,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: active || isReset ? FontWeight.bold : FontWeight.w600
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  bool isSelectedPreset(double value) {
    double currentVal;
    switch (_activeType) {
      case DeficiencyType.protan: currentVal = redValue; break;
      case DeficiencyType.deutan: currentVal = greenValue; break;
      case DeficiencyType.tritan: currentVal = blueValue; break;
    }
    return (currentVal - value).abs() < 0.01;
  }
}
