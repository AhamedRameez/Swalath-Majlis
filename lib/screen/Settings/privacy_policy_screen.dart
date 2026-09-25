// lib/screen/Settings/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  // 🎨 Your app theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Last updated date
  final String _lastUpdated = 'March 01, 2026';

  // URLs for external links
  final String _contactEmail = 'mailto:privacy@saktechnosolution.com';
  final String _websiteUrl = 'https://www.saktechnosolution.com';

  Color? get textTertiary => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.update_rounded, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Last Updated: $_lastUpdated',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Introduction Card
            _buildPolicyCard(
              icon: Icons.privacy_tip_rounded,
              title: 'Our Commitment to Privacy',
              content:
                  'At Swalath Majlis, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our application.',
            ),

            const SizedBox(height: 16),

            // Information We Collect
            _buildPolicyCard(
              icon: Icons.info_rounded,
              title: 'Information We Collect',
              content:
                  '• Location data (for accurate prayer times calculation)\n'
                  '• Device information (for app functionality and improvements)\n'
                  '• Usage data (to enhance user experience)\n'
                  '• Tasbeeh history (stored locally on your device)\n'
                  '• Bookmarks and preferences (stored locally)',
            ),

            const SizedBox(height: 16),

            // How We Use Information
            _buildPolicyCard(
              icon: Icons.settings_applications_rounded,
              title: 'How We Use Your Information',
              content:
                  '• To calculate accurate prayer times based on your location\n'
                  '• To improve app performance and user experience\n'
                  '• To save your preferences and settings\n'
                  '• To send prayer time notifications (with your permission)\n'
                  '• To provide customer support',
            ),

            const SizedBox(height: 16),

            // Data Storage
            _buildPolicyCard(
              icon: Icons.storage_rounded,
              title: 'Data Storage & Security',
              content:
                  'Your personal data is stored locally on your device. We do not collect or store any personal information on our servers except for:\n\n'
                  '• Anonymous usage statistics (with your permission)\n'
                  'This app is 100% free of cost we never ask any kind of fees'
                  '• Crash reports (to improve app stability)\n\n'
                  'We implement industry-standard security measures to protect your information.',
            ),

            const SizedBox(height: 16),

            // Third-Party Services
            _buildPolicyCard(
              icon: Icons.share_rounded,
              title: 'Third-Party Services',
              content:
                  'Our app uses the following third-party services:\n\n'
                  '• Firebase (analytics and crash reporting)\n'
                  '• Google Maps (location services)\n'
                  '• Quran audio streaming services\n\n'
                  'These services have their own privacy policies and terms of use.',
            ),

            const SizedBox(height: 16),

            // Your Rights
            _buildPolicyCard(
              icon: Icons.gavel_rounded,
              title: 'Your Rights',
              content:
                  'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Delete your local data\n'
                  '• Opt-out of analytics\n'
                  '• Disable location services\n'
                  '• Disable notifications\n\n'
                  'You can exercise these rights through your device settings or by contacting us.',
            ),

            const SizedBox(height: 16),

            // Children's Privacy
            _buildPolicyCard(
              icon: Icons.family_restroom_rounded,
              title: 'Children\'s Privacy',
              content:
                  'Our app is suitable for all ages and does not knowingly collect personal information from children under 13. If you believe we have inadvertently collected such information, please contact us immediately.',
            ),

            const SizedBox(height: 16),

            // Changes to Policy
            _buildPolicyCard(
              icon: Icons.change_history_rounded,
              title: 'Changes to This Policy',
              content:
                  'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy in the app and updating the "Last Updated" date. You are advised to review this policy periodically for any changes.',
            ),

            const SizedBox(height: 24),

            // Contact Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.contact_mail_rounded,
                    size: 40,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you have any questions about this Privacy Policy, please contact us:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email Button
                  InkWell(
                    onTap: () => _launchUrl(_contactEmail),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email Us',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'saktechnosolution@gmail.com',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Website Button
                  InkWell(
                    onTap: () => _launchUrl(_websiteUrl),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Visit Website',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'sites.google.com/view/swalathmajlisprivacypolicy',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Accept/Decline Buttons (Optional)
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: () => Navigator.pop(context),
            //         style: OutlinedButton.styleFrom(
            //           foregroundColor: textSecondary,
            //           side: BorderSide(color: dividerColor),
            //           padding: const EdgeInsets.symmetric(vertical: 14),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         child: const Text(
            //           'Decline',
            //           style: TextStyle(
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () => Navigator.pop(context),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: primaryColor,
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(vertical: 14),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         child: const Text(
            //           'Accept',
            //           style: TextStyle(
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // Policy Card Builder
  Widget _buildPolicyCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: dividerColor),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // Launch URL function
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open link'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
