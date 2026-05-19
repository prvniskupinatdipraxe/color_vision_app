import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: May 2024',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing or using Vision Assist Pro, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you may not use the application.',
            ),
            _buildSection(
              context,
              '2. Educational and Assistive Use',
              'Vision Assist Pro is designed as an assistive tool for individuals with color vision deficiencies and an educational tool for simulating those conditions. It is intended for personal use only.',
            ),
            _buildSection(
              context,
              '3. No Medical Certification',
              'IMPORTANT: This application is NOT a medical device. It has not been certified by any medical or health authority. It should not be used to diagnose color blindness or any other medical condition. Always consult with a qualified eye care professional for medical advice and diagnosis.',
            ),
            _buildSection(
              context,
              '4. Limitation of Liability',
              'The application is provided "as is" without warranties of any kind. The developers shall not be liable for any damages arising from the use or inability to use the application, including but not limited to reliance on the color corrections or simulations provided.',
            ),
            _buildSection(
              context,
              '5. Updates to the Service',
              'We reserve the right to modify or discontinue the service at any time without notice. We may also update these terms periodically to reflect changes in our service or legal requirements.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2024 Vision Assist Pro. All rights reserved.',
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
