import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:universal_platform/universal_platform.dart';

class QuranViewScreen extends StatefulWidget {
  final String title;
  final String pdfPath;

  // Updated constructor with default value
  const QuranViewScreen({
    super.key,
    required this.title,
    this.pdfPath = 'assets/pdfs/quran.pdf', // Default value
  });

  @override
  State<QuranViewScreen> createState() => _QuranViewScreenState();
}

class _QuranViewScreenState extends State<QuranViewScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // For mobile PDF viewing
  String? _localFilePath;
  int? _totalPages;
  int _currentPage = 0;
  bool _isPdfReady = false;
  bool _isFromCache = false;

  @override
  void initState() {
    super.initState();
    _loadPdfFromAssets();
  }

  Future<void> _loadPdfFromAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For web, we can't use assets directly
      if (UniversalPlatform.isWeb) {
        setState(() {
          _errorMessage =
              'PDF viewing is not supported on web. Please use the mobile app.';
          _isLoading = false;
        });
        return;
      }

      // Get the local file path
      final directory = await getApplicationDocumentsDirectory();
      const fileName = 'quran.pdf';
      final file = File('${directory.path}/$fileName');

      // Check if PDF already exists in local storage
      if (await file.exists()) {
        print('✅ Quran PDF found in local storage: ${file.path}');
        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
          _isPdfReady = true;
          _isFromCache = true;
        });
        return;
      }

      // Copy PDF from assets to local storage
      print('📚 Copying Quran PDF from assets to local storage...');
      print('📚 Asset path: ${widget.pdfPath}');

      // Load the PDF from assets
      final byteData = await rootBundle.load(widget.pdfPath);
      final bytes = byteData.buffer.asUint8List();

      // Write to local storage
      await file.writeAsBytes(bytes);

      print('✅ Quran PDF saved to local storage: ${file.path}');
      print('✅ File size: ${bytes.length} bytes');

      setState(() {
        _localFilePath = file.path;
        _isLoading = false;
        _isPdfReady = true;
        _isFromCache = true;
      });
    } catch (e) {
      print('❌ Error loading PDF from assets: $e');
      setState(() {
        _errorMessage =
            'Failed to load PDF: $e\n\nAsset path: ${widget.pdfPath}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3D2A5B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3D2A5B), strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              'Loading Quran...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF7E22CE),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPdfFromAssets,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D2A5B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Web: Show message
    if (UniversalPlatform.isWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D2A5B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  size: 80,
                  color: Color(0xFF3D2A5B),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D2A5B),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'PDF viewing is available on mobile devices.\nPlease use the mobile app to read the Quran.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF7E22CE),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D2A5B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile: Show PDF inside the app
    if (_localFilePath != null && _isPdfReady) {
      return Stack(
        children: [
          PDFView(
            filePath: _localFilePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            onRender: (pages) {
              setState(() {
                _totalPages = pages;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = 'PDF Error: $error';
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page ?? 0;
              });
            },
          ),
          // Show cache indicator badge
          if (_isFromCache)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
