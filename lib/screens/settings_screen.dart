import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    // Reset logic would go here
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

class AccessibilitySettings extends StatefulWidget {
  const AccessibilitySettings({super.key});

  @override
  State<AccessibilitySettings> createState() => _AccessibilitySettingsState();
}

class _AccessibilitySettingsState extends State<AccessibilitySettings> {
  bool _highContrast = false;
  bool _largeText = false;
  bool _simplifiedUI = false;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildSwitchTile(
            'High Contrast Mode',
            'Increase global UI contrast',
            Icons.contrast,
            _highContrast,
            (val) => setState(() => _highContrast = val),
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildSwitchTile(
            'Large Text Mode',
            'Increase application font size',
            Icons.format_size,
            _largeText,
            (val) => setState(() => _largeText = val),
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildSwitchTile(
            'Simplified UI',
            'Reduce clutter and animations',
            Icons.dashboard_customize,
            _simplifiedUI,
            (val) => setState(() => _simplifiedUI = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
