// lib/screens/user/user_send_message_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSendMessageScreen extends StatefulWidget {
  const UserSendMessageScreen({super.key});

  @override
  State<UserSendMessageScreen> createState() => _UserSendMessageScreenState();
}

class _UserSendMessageScreenState extends State<UserSendMessageScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;

  // // Categories for messages
  // String _selectedCategory = 'General';
  // final List<String> _categories = [
  //   'General',
  //   'Question',
  //   'Feedback',
  //   'Report Issue',
  //   'Suggestion',
  //   'Other',
  // ];

  // Your app's color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final name = _nameController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter subject and message'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final String userId =
          user?.uid ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
      final String userName =
          user?.displayName ?? (name.isEmpty ? 'App User' : name);

      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('user_messages')
          .add({
            // User Info
            'userId': userId,
            'userName': userName,
            'userPhotoUrl': user?.photoURL,

            // Message Content
            // 'category': _selectedCategory,
            'subject': subject,
            'message': message,

            // Status
            'status': 'unread', // unread, read, responded, closed
            'isRead': false,
            'replied': false,
            'priority': 'normal', // low, normal, high
            // Timestamps
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),

            // Reply Fields
            'reply': null,
            'replyMessage': null,
            'repliedAt': null,
            'repliedBy': null,

            // Metadata
            'isAnonymous': user == null,
            'platform': 'mobile',
            'appVersion': '1.0.0',
          });

      // Clear fields
      _nameController.clear();
      _subjectController.clear();
      _messageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user == null
                        ? '✅ Message sent!development team will check has soon has possible'
                        : '✅ Message sent successfully',
                  ),
                ),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.pop(context, true); // Return true to refresh inbox
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Contact Admin',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card - Enhanced
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Message to Super Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your message will be noted as soon has possble',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category Selection
            // const Text(
            //   'Category',
            //   style: TextStyle(
            //     fontWeight: FontWeight.w600,
            //     fontSize: 14,
            //     fontFamily: 'Poppins',
            //   ),
            // ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              // child: DropdownButtonHideUnderline(
              //   child: DropdownButton<String>(
              //     value: _selectedCategory,
              //     isExpanded: true,
              //     icon: const Icon(Icons.arrow_drop_down),
              //     items: _categories.map((category) {
              //       return DropdownMenuItem(
              //         value: category,
              //         child: Text(category),
              //       );
              //     }).toList(),
              //     onChanged: (value) {
              //       setState(() {
              //         _selectedCategory = value!;
              //       });
              //     },
              //   ),
              // ),
            ),

            const SizedBox(height: 20),

            // Name Field (Optional)
            const Text(
              'Your Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 20),

            // // Subject Field
            // const Text(
            //   'Subject *',
            //   style: TextStyle(
            //     fontWeight: FontWeight.w600,
            //     fontSize: 14,
            //     fontFamily: 'Poppins',
            //   ),
            // ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Enter which section has a mistake',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 20),

            // Message Field
            const Text(
              'Message *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Type your message here in detail...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 32),

            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSending
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Sending...'),
                        ],
                      )
                    : const Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Anonymous note
            if (FirebaseAuth.instance.currentUser == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'please provide the exact content or mistake with full details',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
