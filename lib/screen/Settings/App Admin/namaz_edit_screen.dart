// lib/screen/admin/namaz_edit_screen.dart
import 'package:flutter/material.dart';
import 'namaz_enter_screen.dart';

class NamazEditScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const NamazEditScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<NamazEditScreen> createState() => _NamazEditScreenState();
}

class _NamazEditScreenState extends State<NamazEditScreen> {
  // ==================== COLOR SCHEME ====================
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);

  bool _isLoading = true;
  Map<String, dynamic>? _currentData;
  String? _docId;

  @override
  void initState() {
    super.initState();
    _docId = widget.docId;
    _currentData = widget.data;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
        ),
      );
    }

    // If data is not available, try to fetch from Firestore
    if (_currentData == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Edit Namaz Guide',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red[400],
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error loading Namaz data',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use the existing NamazEnterScreen with edit mode
    return NamazEnterScreen(
      isEditMode: true,
      namazData: _currentData,
      docId: _docId,
    );
  }
}
