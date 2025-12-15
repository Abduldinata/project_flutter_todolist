import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme_tokens.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  static const String gitbookUrl = 'https://syahrul.gitbook.io/todolist/';

  Future<void> _openPrivacyPolicy({bool inApp = true}) async {
    try {
      final uri = Uri.parse(gitbookUrl);

      // Coba langsung launch, tanpa pengecekan canLaunchUrl yang bisa false positive
      if (inApp) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );

        if (!launched && mounted) {
          // Jika inApp gagal, coba external browser
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on Exception catch (e) {
      if (mounted) {
        // Tampilkan error yang lebih informatif
        final errorMessage = e.toString().contains('No Activity found')
            ? 'No browser app found. Please install a web browser.'
            : 'Failed to open Privacy Policy: ${e.toString()}';

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to open Privacy Policy. Please try again or use external browser.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    color: isDark ? Colors.white : AppColors.text,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Privacy Policy',
                        style: AppStyle.title.copyWith(
                          fontSize: 20,
                          color: isDark ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: FlatStyle.card(isDark: isDark),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: AppColors.blue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Our Privacy Policy explains how we collect, use, and protect your personal information.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    _buildActionButton(
                      icon: Icons.open_in_browser,
                      title: 'Open in App Browser',
                      subtitle: 'View Privacy Policy in app',
                      isDark: isDark,
                      onTap: () => _openPrivacyPolicy(inApp: true),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.launch,
                      title: 'Open in External Browser',
                      subtitle: 'View in your default browser',
                      isDark: isDark,
                      onTap: () => _openPrivacyPolicy(inApp: false),
                    ),
                    const SizedBox(height: 32),

                    // Additional Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: FlatStyle.button(isDark: isDark),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Privacy Policy is hosted on GitBook. Make sure you have an active internet connection.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: isDark ? NeuDark.concave : Neu.concave,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
