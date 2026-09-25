// lib/screens/super_admin/live_stream_visibility_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveStreamVisibilityScreen extends StatefulWidget {
  const LiveStreamVisibilityScreen({super.key});

  @override
  State<LiveStreamVisibilityScreen> createState() =>
      _LiveStreamVisibilityScreenState();
}

class _LiveStreamVisibilityScreenState
    extends State<LiveStreamVisibilityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Visibility states
  bool _isThursdayVisible = true;
  bool _isSpecialDayDuasVisible = true;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVisibilityStatus();
  }

  Future<void> _loadVisibilityStatus() async {
    setState(() => _isLoading = true);

    try {
      final doc = await _firestore
          .collection('app_settings')
          .doc('live_stream_visibility')
          .get();

      if (doc.exists) {
        setState(() {
          _isThursdayVisible = doc['isVisible'] ?? true;
          _isSpecialDayDuasVisible = doc['isSpecialDayDuasVisible'] ?? true;
        });
      }
    } catch (e) {
      print('Error loading visibility status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleThursdayVisibility(bool newValue) async {
    setState(() => _isSaving = true);

    try {
      await _firestore
          .collection('app_settings')
          .doc('live_stream_visibility')
          .set({
        'isVisible': newValue,
        'isSpecialDayDuasVisible': _isSpecialDayDuasVisible,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': 'super_admin',
      });

      setState(() {
        _isThursdayVisible = newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Thursday Live Stream card is now VISIBLE'
                : 'Thursday Live Stream card is now HIDDEN',
          ),
          backgroundColor: newValue ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleSpecialDayDuasVisibility(bool newValue) async {
    setState(() => _isSaving = true);

    try {
      await _firestore
          .collection('app_settings')
          .doc('live_stream_visibility')
          .set({
        'isVisible': _isThursdayVisible,
        'isSpecialDayDuasVisible': newValue,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': 'super_admin',
      });

      setState(() {
        _isSpecialDayDuasVisible = newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Special Day Duas card is now VISIBLE'
                : 'Special Day Duas card is now HIDDEN',
          ),
          backgroundColor: newValue ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Visibility Control'),
        backgroundColor: const Color(0xFF3E63DD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Visibility Control',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Control which cards appear in the auto-sliding section',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Thursday Card Control
            _buildCardControl(
              title: 'Thursday Live Stream Card',
              description: 'Red card with live TV stream',
              isVisible: _isThursdayVisible,
              onToggle: _toggleThursdayVisibility,
              icon: Icons.live_tv_rounded,
              color: Colors.red,
              previewColor: Colors.red,
            ),

            const SizedBox(height: 20),

            // Special Day Duas Card Control
            _buildCardControl(
              title: 'Special Day Duas Card',
              description: 'Purple/Pink card for special occasion duas',
              isVisible: _isSpecialDayDuasVisible,
              onToggle: _toggleSpecialDayDuasVisibility,
              icon: Icons.event_available_rounded,
              color: Colors.purple,
              previewColor: Colors.purple,
            ),

            const SizedBox(height: 20),

            // Info Card - Quran is always visible
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'The 24/7 Quran Audio card is always visible and cannot be hidden.',
                      style: TextStyle(fontSize: 13, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How it works:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstruction(
                    Icons.visibility,
                    'ON - Visible',
                    'Card appears in the auto-sliding section',
                    Colors.green,
                  ),
                  _buildInstruction(
                    Icons.visibility_off,
                    'OFF - Hidden',
                    'Card is completely hidden from users',
                    Colors.red,
                  ),
                  _buildInstruction(
                    Icons.info_outline,
                    'Note',
                    'Changes take effect immediately. No app restart needed.',
                    Colors.blue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Loading/Saving Indicator
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Loading current status...'),
                  ],
                ),
              )
            else if (_isSaving)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Saving changes...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardControl({
    required String title,
    required String description,
    required bool isVisible,
    required Function(bool) onToggle,
    required IconData icon,
    required Color color,
    required Color previewColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isVisible,
                  onChanged: _isLoading || _isSaving ? null : onToggle,
                  activeThumbColor: color,
                  activeTrackColor: color.withValues(alpha: 0.5),
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isVisible
                    ? color.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isVisible
                      ? color.withValues(alpha: 0.2)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isVisible
                        ? Icons.check_circle_outline
                        : Icons.visibility_off,
                    size: 20,
                    color: isVisible ? color : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isVisible
                          ? 'This card is VISIBLE to users'
                          : 'This card is HIDDEN from users',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isVisible ? color : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isVisible
                          ? previewColor.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isVisible
                            ? previewColor.withValues(alpha: 0.3)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isVisible ? previewColor : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isVisible ? previewColor : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isVisible
                              ? 'Card appears in auto-sliding section'
                              : 'Card will not appear',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isVisible)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
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

  Widget _buildInstruction(
      IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
