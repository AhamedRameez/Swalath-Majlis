// lib/screen/App Admin/admin_prayer_time_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPrayerTimeScreen extends StatefulWidget {
  const AdminPrayerTimeScreen({super.key});

  @override
  State<AdminPrayerTimeScreen> createState() => _AdminPrayerTimeScreenState();
}

class _AdminPrayerTimeScreenState extends State<AdminPrayerTimeScreen> {
  // 🎨 Your app theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // City selection
  String _selectedCity = 'Kasaragod';
  final List<String> _cities = [
    'Kasaragod',
    'Kannur',
    'Kozhikode',
    'Malappuram',
    'Thrissur',
    'Ernakulam',
    'Kottayam',
    'Alappuzha',
    'Pathanamthitta',
    'Kollam',
    'Thiruvananthapuram',
    'Wayanad',
    'Idukki',
    'Palakkad',
  ];

  // Controllers for form fields
  final _formKey = GlobalKey<FormState>();

  // Date selection
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');

  // Prayer time controllers
  final TextEditingController _fajrController = TextEditingController();
  final TextEditingController _dhuhrController = TextEditingController();
  final TextEditingController _asrController = TextEditingController();
  final TextEditingController _maghribController = TextEditingController();
  final TextEditingController _ishaController = TextEditingController();
  final TextEditingController _sunriseController = TextEditingController();

  // Notes
  final TextEditingController _notesController = TextEditingController();

  // Loading state
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingDocId;

  // Selected month for filtering
  DateTime? _selectedMonth;

  // Time picker with default PM for afternoon prayers
  Future<void> _selectTime(
      TextEditingController controller, String prayerName) async {
    // Set default hour based on prayer
    TimeOfDay initialTime;

    if (prayerName == 'Fajr' || prayerName == 'Sunrise') {
      initialTime = const TimeOfDay(hour: 5, minute: 30); // Default AM
    } else if (prayerName == 'Dhuhr') {
      initialTime = const TimeOfDay(hour: 12, minute: 30); // Default PM
    } else if (prayerName == 'Asr') {
      initialTime = const TimeOfDay(hour: 15, minute: 30); // Default PM
    } else if (prayerName == 'Maghrib') {
      initialTime = const TimeOfDay(hour: 18, minute: 30); // Default PM
    } else if (prayerName == 'Isha') {
      initialTime = const TimeOfDay(hour: 19, minute: 45); // Default PM
    } else {
      initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              secondary: accentColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  // Date picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              secondary: accentColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Load prayer time for editing
  Future<void> _loadPrayerTimeForEdit(String docId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('prayer_times')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _selectedCity = data['city'] ?? 'Kasaragod';
          _selectedDate = (data['date'] as Timestamp).toDate();
          _fajrController.text = data['fajr'] ?? '';
          _dhuhrController.text = data['dhuhr'] ?? '';
          _asrController.text = data['asr'] ?? '';
          _maghribController.text = data['maghrib'] ?? '';
          _ishaController.text = data['isha'] ?? '';
          _sunriseController.text = data['sunrise'] ?? '';
          _notesController.text = data['notes'] ?? '';
          _isEditing = true;
          _editingDocId = docId;
        });
      }
    } catch (e) {
      _showSnackbar('Error loading prayer time: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save prayer time to Firestore
  Future<void> _savePrayerTime() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Validate time fields
    if (_fajrController.text.isEmpty ||
        _dhuhrController.text.isEmpty ||
        _asrController.text.isEmpty ||
        _maghribController.text.isEmpty ||
        _ishaController.text.isEmpty) {
      _showSnackbar('Please enter all prayer times', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prayerData = {
        'city': _selectedCity,
        'date': Timestamp.fromDate(_selectedDate),
        'fajr': _fajrController.text.trim(),
        'dhuhr': _dhuhrController.text.trim(),
        'asr': _asrController.text.trim(),
        'maghrib': _maghribController.text.trim(),
        'isha': _ishaController.text.trim(),
        'sunrise': _sunriseController.text.trim(),
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing && _editingDocId != null) {
        // Update existing
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('prayer_times')
            .doc(_editingDocId)
            .update(prayerData);
        _showSnackbar('Prayer time updated successfully!');
      } else {
        // Create new
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('prayer_times')
            .add(prayerData);
        _showSnackbar('Prayer time added successfully!');
      }

      // Clear form
      _clearForm();
    } catch (e) {
      _showSnackbar('Error saving: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Clear form
  void _clearForm() {
    setState(() {
      _selectedCity = 'Kasaragod';
      _selectedDate = DateTime.now();
      _fajrController.clear();
      _dhuhrController.clear();
      _asrController.clear();
      _maghribController.clear();
      _ishaController.clear();
      _sunriseController.clear();
      _notesController.clear();
      _isEditing = false;
      _editingDocId = null;
    });
  }

  // Show snackbar
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Delete confirmation
  Future<void> _confirmDelete(String docId, String date) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Prayer Time',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete prayer time for $date?',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('prayer_times')
          .doc(docId)
          .delete();
      _showSnackbar('Prayer time deleted successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Prayer Times Management',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: accentColor,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Add/Edit', icon: Icon(Icons.edit_rounded)),
              Tab(text: 'View All', icon: Icon(Icons.list_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Add/Edit Form
            _buildFormTab(),
            // Tab 2: View All (Fixed)
            _buildViewAllTab(),
          ],
        ),
      ),
    );
  }

  // Form Tab
  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City Selection Dropdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select City',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCity,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down_rounded,
                            color: primaryColor),
                        items: _cities.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city,
                              style: const TextStyle(color: textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCity = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Date Selection Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dividerColor),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                                Text(
                                  _dateFormat.format(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down_rounded,
                              color: primaryColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Prayer Times Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dividerColor),
              ),
              child: Column(
                children: [
                  _buildTimeField(
                      'Fajr', _fajrController, Icons.wb_sunny_rounded),
                  const SizedBox(height: 12),
                  _buildTimeField(
                      'Sunrise', _sunriseController, Icons.wb_twilight_rounded),
                  const SizedBox(height: 12),
                  _buildTimeField(
                      'Dhuhr', _dhuhrController, Icons.wb_sunny_rounded),
                  const SizedBox(height: 12),
                  _buildTimeField('Asr', _asrController, Icons.cloud_rounded),
                  const SizedBox(height: 12),
                  _buildTimeField(
                      'Maghrib', _maghribController, Icons.nights_stay_rounded),
                  const SizedBox(height: 12),
                  _buildTimeField(
                      'Isha', _ishaController, Icons.nightlight_round),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notes Field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dividerColor),
              ),
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note_rounded, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePrayerTime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isEditing ? 'Update' : 'Save'),
                  ),
                ),
                const SizedBox(width: 12),
                if (_isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Time field builder with prayer-specific defaults
  Widget _buildTimeField(
      String label, TextEditingController controller, IconData icon) {
    return InkWell(
      onTap: () => _selectTime(controller, label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  Text(
                    controller.text.isEmpty ? 'Select time' : controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: controller.text.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w600,
                      color:
                          controller.text.isEmpty ? textTertiary : textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.access_time_rounded, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  // FIXED: View All Tab - Shows all prayer times for selected city
  Widget _buildViewAllTab() {
    return Column(
      children: [
        // City Filter Dropdown
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dividerColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down_rounded, color: primaryColor),
                items: _cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child:
                        Text(city, style: const TextStyle(color: textPrimary)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCity = newValue!;
                  });
                },
              ),
            ),
          ),
        ),

        // Prayer Times List - FIXED QUERY
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('swalathmajlis')
                .doc('iM6QRMlgUuWNbUdgQ0')
                .collection('prayer_times')
                .where('city', isEqualTo: _selectedCity)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // Debug: Print snapshot info
              print('🔥 Connection state: ${snapshot.connectionState}');
              print('📊 Has data: ${snapshot.hasData}');
              print('📦 Docs count: ${snapshot.data?.docs.length}');

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print('❌ Error: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading data: ${snapshot.error}',
                          style: const TextStyle(color: textSecondary)),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 60, color: textTertiary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No prayer times for $_selectedCity',
                          style: const TextStyle(color: textSecondary)),
                      const SizedBox(height: 8),
                      Text('Add prayer times using the Add/Edit tab',
                          style: TextStyle(color: textTertiary, fontSize: 12)),
                    ],
                  ),
                );
              }

              // If we have data, display it
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['date'] as Timestamp).toDate();
                  final formattedDate = DateFormat('dd MMMM yyyy').format(date);
                  final dayOfWeek = DateFormat('EEEE').format(date);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, Color(0xFF2A8A83)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('d').format(date),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('MMM').format(date),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dayOfWeek,
                              style: TextStyle(
                                fontSize: 10,
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (data['notes'] != null &&
                              data['notes'].toString().isNotEmpty)
                            Expanded(
                              child: Text(
                                data['notes'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textTertiary,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_rounded,
                                color: primaryColor, size: 20),
                            onPressed: () => _loadPrayerTimeForEdit(doc.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded,
                                color: Colors.red, size: 20),
                            onPressed: () =>
                                _confirmDelete(doc.id, formattedDate),
                          ),
                        ],
                      ),
                      children: [
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDetailRow('Fajr', data['fajr'] ?? '-',
                                  Icons.wb_sunny_rounded),
                              const SizedBox(height: 8),
                              _buildDetailRow('Sunrise', data['sunrise'] ?? '-',
                                  Icons.wb_twilight_rounded),
                              const SizedBox(height: 8),
                              _buildDetailRow('Dhuhr', data['dhuhr'] ?? '-',
                                  Icons.wb_sunny_rounded),
                              const SizedBox(height: 8),
                              _buildDetailRow('Asr', data['asr'] ?? '-',
                                  Icons.cloud_rounded),
                              const SizedBox(height: 8),
                              _buildDetailRow('Maghrib', data['maghrib'] ?? '-',
                                  Icons.nights_stay_rounded),
                              const SizedBox(height: 8),
                              _buildDetailRow('Isha', data['isha'] ?? '-',
                                  Icons.nightlight_round),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Icon(icon, size: 16, color: primaryColor),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(color: textSecondary, fontSize: 14),
          ),
        ),
        const Text(':', style: TextStyle(color: textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
