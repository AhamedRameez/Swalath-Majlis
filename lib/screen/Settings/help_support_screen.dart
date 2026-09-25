// lib/screen/Settings/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // 🎨 Your app theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Contact URLs - UPDATE THESE WITH YOUR ACTUAL LINKS
  final String _websiteUrl = 'https://www.saktechnosolution.com';
  final String _supportEmail = 'mailto:support@saktechnosolution.com';
  final String _faqUrl = 'https://www.saktechnosolution.com/faq';
  final String _whatsAppUrl =
      'https://wa.me/+919995258618'; // Replace with your number
  final String _telegramUrl = 'https://t.me/saktechnosolution';
  final String _instagramUrl = 'https://instagram.com/saktechnosolution';
  final String _youtubeUrl = 'https://youtube.com/@saktechnosolution';
  final String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.saktechnosolution.swalathmajlis';

  // App version
  final String _appVersion = '1.0.1';

  // FAQ data
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I set prayer time alarms?',
      'answer':
          'Go to Prayer Times screen, tap on the alarm icon next to any prayer, and select when you want to be notified. You can choose from 30 min before to 5 min after prayer time.',
    },
    {
      'question': 'Why is my location not accurate?',
      'answer':
          'Make sure location permissions are enabled for the app. Go to your phone Settings → Apps → Swalath Majlis → Permissions → Location and allow it. Then refresh the Prayer Times screen.',
    },
    {
      'question': 'How do I save Tasbeeh counts?',
      'answer':
          'After completing your Tasbeeh, tap the "Save" button, enter a name for your count (e.g., "Morning Dhikr"), and it will be saved to history. You can continue it later from the history screen.',
    },
    {
      'question': 'Can I use the app offline?',
      'answer':
          'Yes! Duas, Quran, and previously loaded content are cached and available offline. Prayer times require internet connection for initial calculation, but can be updated manually when offline.',
    },
    {
      'question': 'How do I share duas with others?',
      'answer':
          'When viewing any dua, tap the share icon in the app bar. This will create a beautifully formatted message with the dua text and download link that you can share on any platform.',
    },
    {
      'question': 'Why aren\'t notifications working?',
      'answer':
          'Check if notifications are enabled in your phone Settings. Also ensure that "Notifications" is toggled ON in App Settings. For Android 13+, you need to grant notification permission when prompted.',
    },
  ];

  bool _showAllFaqs = false;

  // Launch URL function
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      _showErrorSnackbar('Could not open link');
    }
  }

  // Show error message
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Share app
  void _shareApp() {
    Share.share(
      '📱 Swalath Majlis - Your Complete Islamic Companion\n\n'
      'Download now: $_playStoreUrl',
      subject: 'Swalath Majlis App',
    );
  }

  // Rate app
  void _rateApp() {
    _launchUrl(_playStoreUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareApp,
            tooltip: 'Share App',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Help Header
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How can we help you?',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Version $_appVersion',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 📞 CONTACT SUPPORT SECTION
            _buildSection(
              icon: Icons.headset_mic_rounded,
              title: 'Contact Support',
              color: primaryColor,
              children: [
                _buildContactCard(
                  icon: Icons.email_rounded,
                  title: 'Email Support',
                  subtitle: 'support@saktechnosolution.com',
                  color: Colors.red,
                  onTap: () => _launchUrl(_supportEmail),
                ),
                const SizedBox(height: 8),
                _buildContactCard(
                  icon: Icons.message_rounded,
                  title: 'WhatsApp',
                  subtitle: 'Chat with support team',
                  color: Colors.green,
                  onTap: () => _launchUrl(_whatsAppUrl),
                ),
                const SizedBox(height: 8),
                // _buildContactCard(
                //   icon: Icons.telegram_rounded,
                //   title: 'Telegram',
                //   subtitle: '@saktechnosolution',
                //   color: Colors.blue,
                //   onTap: () => _launchUrl(_telegramUrl),
                // ),
              ],
            ),

            const SizedBox(height: 20),

            // ❓ FAQ SECTION
            _buildSection(
              icon: Icons.help_rounded,
              title: 'Frequently Asked Questions',
              color: accentColor,
              children: [
                ..._faqs
                    .take(_showAllFaqs ? _faqs.length : 3)
                    .map(
                      (faq) => _buildFaqItem(faq['question']!, faq['answer']!),
                    ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAllFaqs = !_showAllFaqs;
                      });
                    },
                    icon: Icon(
                      _showAllFaqs
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: primaryColor,
                    ),
                    label: Text(
                      _showAllFaqs
                          ? 'Show Less'
                          : 'View All FAQs (${_faqs.length})',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🌐 COMMUNITY & SOCIAL SECTION
            _buildSection(
              icon: Icons.people_rounded,
              title: 'Community & Social',
              color: Colors.purple,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSocialChip(
                      icon: Icons.language_rounded,
                      label: 'Website',
                      color: Colors.blue,
                      onTap: () => _launchUrl(_websiteUrl),
                    ),
                    _buildSocialChip(
                      icon: Icons.camera_alt_rounded,
                      label: 'Instagram',
                      color: Colors.purple,
                      onTap: () => _launchUrl(_instagramUrl),
                    ),
                    _buildSocialChip(
                      icon: Icons.play_circle_fill_rounded,
                      label: 'YouTube',
                      color: Colors.red,
                      onTap: () => _launchUrl(_youtubeUrl),
                    ),
                    // _buildSocialChip(
                    //   icon: Icons.telegram_rounded,
                    //   label: 'Telegram',
                    //   color: Colors.blue,
                    //   onTap: () => _launchUrl(_telegramUrl),
                    // ),
                    _buildSocialChip(
                      icon: Icons.message_rounded,
                      label: 'WhatsApp',
                      color: Colors.green,
                      onTap: () => _launchUrl(_whatsAppUrl),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📋 QUICK ACTIONS SECTION
            _buildSection(
              icon: Icons.flash_on_rounded,
              title: 'Quick Actions',
              color: Colors.orange,
              children: [
                _buildActionCard(
                  icon: Icons.star_rounded,
                  title: 'Rate this App',
                  subtitle: 'Love our app? Rate us on Play Store',
                  color: Colors.amber,
                  onTap: _rateApp,
                ),
                const SizedBox(height: 8),
                _buildActionCard(
                  icon: Icons.share_rounded,
                  title: 'Share with Friends',
                  subtitle: 'Tell others about Swalath Majlis',
                  color: Colors.green,
                  onTap: _shareApp,
                ),
                const SizedBox(height: 8),
                _buildActionCard(
                  icon: Icons.feedback_rounded,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  color: Colors.blue,
                  onTap: () =>
                      _launchUrl('mailto:feedback@saktechnosolution.com'),
                ),
                const SizedBox(height: 8),
                _buildActionCard(
                  icon: Icons.report_problem_rounded,
                  title: 'Report a Bug',
                  subtitle: 'Found an issue? Let us know',
                  color: Colors.red,
                  onTap: () => _launchUrl('mailto:bugs@saktechnosolution.com'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // // ⏰ SUPPORT HOURS CARD
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: cardColor,
            //     borderRadius: BorderRadius.circular(16),
            //     border: Border.all(color: dividerColor),
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         padding: const EdgeInsets.all(10),
            //         decoration: BoxDecoration(
            //           color: primaryColor.withOpacity(0.1),
            //           shape: BoxShape.circle,
            //         ),
            //         child: Icon(
            //           Icons.access_time_rounded,
            //           color: primaryColor,
            //           size: 24,
            //         ),
            //       ),
            //       const SizedBox(width: 16),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             const Text(
            //               'Support Hours',
            //               style: TextStyle(
            //                 fontFamily: 'Poppins',
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w600,
            //                 color: textPrimary,
            //               ),
            //             ),
            //             const SizedBox(height: 4),
            //             Text(
            //               'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 2:00 PM\nSunday: Closed',
            //               style: TextStyle(
            //                 fontFamily: 'Poppins',
            //                 fontSize: 13,
            //                 color: textSecondary,
            //                 height: 1.5,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 20),

            // // Response Time Note
            // Center(
            //   child: Text(
            //     'We typically respond within 24 hours',
            //     style: TextStyle(
            //       fontFamily: 'Poppins',
            //       fontSize: 12,
            //       color: textTertiary,
            //       fontStyle: FontStyle.italic,
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section Builder
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Contact Card
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  // FAQ Item
  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: dividerColor),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: dividerColor),
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              answer,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Social Chip
  Widget _buildSocialChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Card
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
