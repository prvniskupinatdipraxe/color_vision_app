import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_container.dart';
import '../services/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle(context, 'Appearance'),
              const SizedBox(height: 16),
              const ThemeSelector(),
              
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Accessibility'),
              const SizedBox(height: 16),
              const AccessibilitySettings(),
              


              const SizedBox(height: 32),
              _buildSectionTitle(context, 'System'),
              const SizedBox(height: 16),
              GlassContainer(
                padding: const EdgeInsets.all(4),
                child: ListTile(
                  leading: const Icon(Icons.restart_alt, color: Colors.redAccent),
                  title: const Text('Reset to Defaults', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () {
                    themeProvider.triggerHaptic();
                    themeProvider.resetToDefaults();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings reset to defaults')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ThemeOption(
            mode: ThemeMode.light,
            icon: Icons.light_mode_rounded,
            label: 'Light',
            isSelected: themeProvider.themeMode == ThemeMode.light,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
          ),
          _ThemeOption(
            mode: ThemeMode.dark,
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            isSelected: themeProvider.themeMode == ThemeMode.dark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
          ),
          _ThemeOption(
            mode: ThemeMode.system,
            icon: Icons.brightness_auto_rounded,
            label: 'System',
            isSelected: themeProvider.themeMode == ThemeMode.system,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final ThemeMode mode;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary.withOpacity(0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : (isDark ? Colors.white54 : Colors.black45),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.primary : (isDark ? Colors.white54 : Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccessibilitySettings extends StatelessWidget {
  const AccessibilitySettings({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            'High Contrast Mode',
            'Increase global UI contrast',
            Icons.contrast,
            themeProvider.isHighContrast,
            (val) => themeProvider.setHighContrast(val),
          ),
          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
          _buildSwitchTile(
            context,
            'Large Text Mode',
            'Increase application font size',
            Icons.format_size,
            themeProvider.isLargeText,
            (val) => themeProvider.setLargeText(val),
          ),
          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
          _buildSwitchTile(
            context,
            'Simplified UI',
            'Reduce clutter and animations',
            Icons.dashboard_customize,
            themeProvider.isSimplifiedUI,
            (val) => themeProvider.setSimplifiedUI(val),
          ),
          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
          _buildSwitchTile(
            context,
            'Haptic Feedback',
            'Enable subtle vibration feedback',
            Icons.vibration,
            themeProvider.isHapticEnabled,
            (val) {
              themeProvider.setHapticFeedback(val);
              if (val) themeProvider.triggerHaptic();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return SwitchListTile(
      secondary: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: themeProvider.isSimplifiedUI ? null : Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
