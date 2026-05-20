import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vision Assist Pro',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.13.0',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'This application assists individuals with color vision deficiencies by simulating and correcting color profiles in real-time through the device camera.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GlassContainer(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.policy_outlined, color: isDark ? Colors.white70 : Colors.black54),
                      title: const Text('Privacy Policy'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white38 : Colors.black38),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                      ),
                    ),
                    Divider(color: isDark ? Colors.white24 : Colors.black12),
                    ListTile(
                      leading: Icon(Icons.description_outlined, color: isDark ? Colors.white70 : Colors.black54),
                      title: const Text('Terms of Service'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white38 : Colors.black38),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsScreen()),
                      ),
                    ),
                  ],
                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
