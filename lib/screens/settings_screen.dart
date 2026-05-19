import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _highContrast = false;
  bool _largeText = false;
  bool _simplifiedUI = false;

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
              
              _buildSectionTitle('Accessibility'),
              const SizedBox(height: 16),
              GlassContainer(
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
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('About'),
              const SizedBox(height: 16),
              GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.white70),
                      title: const Text('Vision Assist Pro'),
                      subtitle: const Text('Version 1.0.0'),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      leading: const Icon(Icons.policy_outlined, color: Colors.white70),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.white38),
                      onTap: () {},
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined, color: Colors.white70),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.white38),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              GlassContainer(
                padding: const EdgeInsets.all(4),
                child: ListTile(
                  leading: const Icon(Icons.restart_alt, color: Colors.redAccent),
                  title: const Text('Reset to Defaults', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () {
                    setState(() {
                      _highContrast = false;
                      _largeText = false;
                      _simplifiedUI = false;
                    });
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

  Widget _buildSectionTitle(String title) {
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
