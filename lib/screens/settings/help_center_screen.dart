import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final Map<String, bool> _expandedSections = {};

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
                        'Help Center',
                        style: AppStyle.title.copyWith(
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeCard(isDark),
                    const SizedBox(height: 32),

                    // Getting Started Section
                    _buildSectionTitle('GETTING STARTED', isDark),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'How do I create a new task?',
                      'To create a new task, tap the floating action button (blue circle with + icon) on any screen. Fill in the task details including title, description, due date, and priority, then tap "Add Task".',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'How do I organize my tasks?',
                      'You can organize tasks by:\n• Using the Inbox, Today, and Upcoming views\n• Setting priorities (High, Medium, Low)\n• Adding due dates\n• Using search to find specific tasks',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'What are the different views?',
                      '• Inbox: All your tasks in one place\n• Today: Tasks due today\n• Upcoming: Tasks scheduled for future dates\n• Completed: Finished tasks',
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // Task Management Section
                    _buildSectionTitle('TASK MANAGEMENT', isDark),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'How do I edit a task?',
                      'Tap on any task to open its details. Then tap the edit icon to modify the task information. You can change the title, description, due date, priority, and more.',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'How do I mark a task as complete?',
                      'Tap on a task to open its details, then tap the checkmark button. You can also swipe on a task in the list to quickly mark it as complete.',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'Can I delete a task?',
                      'Yes, you can delete a task by opening its details and tapping the delete icon. This action cannot be undone, so make sure you want to delete it.',
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // Settings & Preferences Section
                    _buildSectionTitle('SETTINGS & PREFERENCES', isDark),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'How do I change the app theme?',
                      'Go to Settings > Personalization > App Theme. You can choose between Light, Dark, or System (follows your device theme).',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'How do I change the start of week?',
                      'Go to Settings > Preferences > Start of Week. Select your preferred day (Monday through Sunday).',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'Can I customize notifications?',
                      'Yes! Go to Settings > Preferences > Notifications. Toggle notifications on or off according to your preference.',
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // Account & Sync Section
                    _buildSectionTitle('ACCOUNT & SYNC', isDark),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'How do I change my password?',
                      'Go to Settings > Profile > Account > Change Password. Enter your current password and your new password twice.',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'Are my tasks synced across devices?',
                      'Yes! All your tasks are automatically synced to the cloud. Sign in with the same account on any device to access your tasks.',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'How do I update my profile?',
                      'Go to Settings and tap on your profile card at the top. You can edit your username, bio, phone number, and upload a profile picture.',
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // Troubleshooting Section
                    _buildSectionTitle('TROUBLESHOOTING', isDark),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'My tasks are not syncing',
                      'Make sure you have an active internet connection. Try logging out and logging back in. If the problem persists, check your account status in Settings.',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'I forgot my password',
                      'On the login screen, tap "Forgot Password?" and enter your email address. You\'ll receive instructions to reset your password.',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFAQCard(
                      'The app is running slowly',
                      'Try clearing the app cache or restarting the app. Make sure you have a stable internet connection. If problems persist, contact support.',
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // Contact Support Section
                    _buildSectionTitle('NEED MORE HELP?', isDark),
                    const SizedBox(height: 12),
                    _buildContactCard(isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: isDark ? NeuDark.concave : Neu.concave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: AppColors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Help Center',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find answers to common questions',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(String question, String answer, bool isDark) {
    final isExpanded = _expandedSections[question] ?? false;

    return Container(
      decoration: isDark ? NeuDark.concave : Neu.concave,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[question] = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: isDark ? NeuDark.concave : Neu.concave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: AppColors.blue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Still need help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'If you couldn\'t find the answer you\'re looking for, please contact our support team.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildContactOption(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'sahtulbb@gmail.com',
            isDark: isDark,
            onTap: () {
              Get.snackbar(
                'Email Support',
                'Please send an email to sahtulbb@gmail.com',
                backgroundColor: AppColors.blue,
                colorText: Colors.white,
              );
            },
          ),
          const SizedBox(height: 12),
          _buildContactOption(
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Available 24/7',
            isDark: isDark,
            onTap: () {
              Get.snackbar(
                'Live Chat',
                'Live chat feature coming soon!',
                backgroundColor: AppColors.blue,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : Colors.grey[100]?.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
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
