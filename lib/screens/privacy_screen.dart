import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: May 2026',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Camera Access',
              'Vision Assist Pro requires access to your device\'s camera to provide real-time color assistance and simulation. The camera feed is used solely for on-device processing and is never recorded or stored unless you explicitly use the capture feature.',
            ),
            _buildSection(
              context,
              '2. On-Device Processing',
              'All image processing, color transformations, and simulations are performed locally on your device. We do not transmit your camera feed or images to any external servers or cloud services.',
            ),
            _buildSection(
              context,
              '3. Data Collection',
              'We do not collect, store, or share any personal information. There is no account system, and the application does not track your location or usage patterns.',
            ),
            _buildSection(
              context,
              '4. Photo Storage',
              'When you use the capture feature, the resulting image is saved directly to your device\'s local gallery. We do not have access to these photos once they are saved.',
            ),
            _buildSection(
              context,
              '5. No Analytics or Tracking',
              'Vision Assist Pro does not use any third-party analytics or tracking pixels. Your usage of the app remains completely private and anonymous.',
            ),
            _buildSection(
              context,
              '6. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us through the official support channels.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2026 Vision Assist Pro. All rights reserved.',
                style: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
          ),
        ],
      ),
    );
  }
}
