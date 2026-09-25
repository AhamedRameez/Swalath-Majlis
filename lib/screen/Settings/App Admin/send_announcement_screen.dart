// lib/screens/send_announcement_screen.dart (admin)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SendAnnouncementScreen extends StatefulWidget {
  const SendAnnouncementScreen({super.key});

  @override
  State<SendAnnouncementScreen> createState() => _SendAnnouncementScreenState();
}

class _SendAnnouncementScreenState extends State<SendAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingDocId;
  bool _isVisible = true; // 🆕 Visibility toggle

  // 🌈 Color scheme matching the theme
  static const Color primaryColor = Color(0xFF3E63DD);
  static const Color accentColor = Color(0xFF6E8CFF);
  static const Color backgroundColor = Color(0xFFF4F6FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color borderColor = Color(0xFFE7EBFF);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendAnnouncement() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all required fields"),
          backgroundColor: warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing && _editingDocId != null) {
        // Update existing announcement
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('announcements')
            .doc(_editingDocId)
            .update({
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'isVisible': _isVisible, // 🆕 Save visibility
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isVisible
                  ? 'Announcement updated and visible'
                  : 'Announcement updated (hidden)',
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        // Create new announcement
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('announcements')
            .add({
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'isVisible': _isVisible, // 🆕 Save visibility
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isVisible
                  ? 'Announcement sent successfully'
                  : 'Announcement saved (hidden)',
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _messageController.clear();
    setState(() {
      _isEditing = false;
      _editingDocId = null;
      _isVisible = true; // 🆕 Reset to visible
    });
  }

  void _editAnnouncement(Map<String, dynamic> data, String docId) {
    setState(() {
      _titleController.text = data['title'] ?? '';
      _messageController.text = data['message'] ?? '';
      _isVisible = data['isVisible'] ?? true; // 🆕 Load visibility
      _isEditing = true;
      _editingDocId = docId;
    });

    // Scroll to top
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
    );
  }

  // 🆕 Toggle visibility directly from history
  Future<void> _toggleVisibility(String docId, bool currentValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('announcements')
          .doc(docId)
          .update({
        'isVisible': !currentValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentValue
                ? 'Announcement is now visible'
                : 'Announcement is now hidden',
          ),
          backgroundColor: successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _deleteAnnouncement(String docId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Announcement',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('announcements')
            .doc(docId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Announcement deleted successfully'),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        if (_editingDocId == docId) {
          _clearForm();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 2,
          backgroundColor: primaryColor,
          title: const Text(
            'Announcement Management',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Send', icon: Icon(Icons.send_rounded)),
              Tab(text: 'History', icon: Icon(Icons.history_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSendTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE9EEFF),
            Color(0xFFF4F7FF),
            Color(0xFFE8EDFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isEditing
                          ? Icons.edit_rounded
                          : Icons.announcement_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing
                              ? 'Edit Announcement'
                              : 'Broadcast Announcement',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditing
                              ? 'Update your announcement'
                              : 'Send important updates to all users',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: errorColor),
                      onPressed: _clearForm,
                      tooltip: 'Cancel editing',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title Field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
                color: cardColor,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: _titleController,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Announcement Title *',
                    hintText: 'Enter announcement title...',
                    hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
                    labelStyle: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.title_rounded,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Message Field Container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 12),
                    child: Text(
                      'Announcement Message *',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 8,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        fontFamily: 'Poppins',
                        color: textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: '',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: textSecondary.withValues(alpha: 0.6),
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: backgroundColor.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      border: Border(
                        top: BorderSide(color: borderColor, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Message',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '${_messageController.text.length} characters',
                          style: TextStyle(
                            color: _messageController.text.length > 100
                                ? Colors.green
                                : textSecondary,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🆕 Visibility Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isVisible
                      ? successColor.withValues(alpha: 0.3)
                      : warningColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isVisible
                          ? successColor.withValues(alpha: 0.1)
                          : warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: _isVisible ? successColor : warningColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isVisible ? 'Visible to Users' : 'Hidden from Users',
                          style: TextStyle(
                            color: _isVisible ? successColor : warningColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isVisible
                              ? 'Users can see this announcement'
                              : 'Users cannot see this announcement',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isVisible,
                    onChanged: (value) {
                      setState(() {
                        _isVisible = value;
                      });
                    },
                    activeThumbColor: successColor,
                    activeTrackColor: successColor.withValues(alpha: 0.3),
                    inactiveThumbColor: warningColor,
                    inactiveTrackColor: warningColor.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Send/Update Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEditing
                                ? Icons.update_rounded
                                : Icons.send_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing
                                ? 'Update Announcement'
                                : 'Send Announcement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Clear Button
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _clearForm,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],

            // Information Card
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This announcement will be visible to all users in the app.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
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

  Widget _buildHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 60, color: errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error loading announcements',
                  style: TextStyle(color: textSecondary),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.announcement_outlined,
                  size: 80,
                  color: textSecondary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No announcements yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your first announcement in the Send tab',
                  style: TextStyle(color: textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Untitled';
            final message = data['message'] ?? '';
            final createdAt = data['createdAt'] as Timestamp?;
            final updatedAt = data['updatedAt'] as Timestamp?;
            final isVisible = data['isVisible'] ?? true; // 🆕 Get visibility
            final dateStr = _formatDate(createdAt);
            final hasBeenUpdated = updatedAt != null &&
                (createdAt == null ||
                    updatedAt
                            .toDate()
                            .difference(createdAt.toDate())
                            .inSeconds >
                        5);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isVisible ? borderColor : warningColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.03),
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
                    // Header with title and actions
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.announcement_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSecondary,
                                    ),
                                  ),
                                  if (hasBeenUpdated) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Edited',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF6E8CFF),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                  // 🆕 Visibility badge
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isVisible
                                          ? successColor.withValues(alpha: 0.1)
                                          : warningColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isVisible
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          size: 10,
                                          color: isVisible
                                              ? successColor
                                              : warningColor,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          isVisible ? 'Visible' : 'Hidden',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isVisible
                                                ? successColor
                                                : warningColor,
                                            fontWeight: FontWeight.w600,
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
                        // Action buttons
                        Row(
                          children: [
                            // 🆕 Visibility toggle button
                            IconButton(
                              icon: Icon(
                                isVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: isVisible ? warningColor : successColor,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _toggleVisibility(doc.id, isVisible),
                              tooltip: isVisible ? 'Hide' : 'Show',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.edit_rounded,
                                color: primaryColor,
                                size: 20,
                              ),
                              onPressed: () => _editAnnouncement(data, doc.id),
                              tooltip: 'Edit',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Color(0xFFF44336),
                                size: 20,
                              ),
                              onPressed: () =>
                                  _deleteAnnouncement(doc.id, title),
                              tooltip: 'Delete',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
