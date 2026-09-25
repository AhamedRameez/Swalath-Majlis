// lib/screens/super_admin/user_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMessagesScreen extends StatefulWidget {
  final bool adminView;
  const UserMessagesScreen({super.key, this.adminView = false});

  @override
  State<UserMessagesScreen> createState() => _UserMessagesScreenState();
}

class _UserMessagesScreenState extends State<UserMessagesScreen> {
  // Filter state
  String _filterStatus = 'all'; // all, unread, read

  // Your app's color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text(
          'User Messages',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Summary
          _buildStatsSummary(),
          // Messages List
          Expanded(child: _buildMessagesList()),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('user_messages')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final total = snapshot.data!.docs.length;
        final unread = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return !(data['isRead'] ?? false);
        }).length;
        final read = total - unread;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), Icons.inbox),
              _buildStatItem(
                  'Unread', unread.toString(), Icons.mark_email_unread,
                  color: accentColor),
              _buildStatItem('Read', read.toString(), Icons.done_all,
                  color: Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String count, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Colors.grey).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color ?? Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    Query query = FirebaseFirestore.instance
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('user_messages')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: primaryColor));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inbox_rounded,
                    size: 50,
                    color: primaryColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Messages from Users',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        }

        var docs = snapshot.data!.docs;

        // Apply filters
        if (_filterStatus != 'all') {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (_filterStatus == 'unread') {
              return !(data['isRead'] ?? false);
            } else if (_filterStatus == 'read') {
              return (data['isRead'] ?? false);
            }
            return true;
          }).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildMessageCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildMessageCard(String docId, Map<String, dynamic> data) {
    final isRead = data['isRead'] ?? false;
    final isAnonymous = data['isAnonymous'] ?? false;
    final timestamp = data['createdAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: !isRead ? accentColor.withValues(alpha: 0.5) : Colors.grey.shade200,
          width: !isRead ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // User Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isAnonymous
                        ? Colors.grey.withValues(alpha: 0.1)
                        : primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isAnonymous ? Icons.person_outline : Icons.person,
                    color: isAnonymous ? Colors.grey : primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['userName'] ?? 'Anonymous User',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color:
                              isAnonymous ? Colors.grey[700] : Colors.black87,
                        ),
                      ),
                      Text(
                        data['userEmail'] ?? 'No email',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Unread Badge
                if (!isRead)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Subject
            Text(
              data['subject'] ?? 'No Subject',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Message
            Text(
              data['message'] ?? '',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),

            const SizedBox(height: 16),

            // Footer
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                // Mark as Read button
                if (!isRead)
                  TextButton.icon(
                    onPressed: () => _markAsRead(docId),
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Mark Read'),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Read',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('user_messages')
          .doc(docId)
          .update({
        'isRead': true,
        'status': 'read',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(child: Text('Message marked as read')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              initialValue: _filterStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Messages')),
                DropdownMenuItem(value: 'unread', child: Text('Unread')),
                DropdownMenuItem(value: 'read', child: Text('Read')),
              ],
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
