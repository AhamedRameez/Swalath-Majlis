// lib/screen/Settings/App Admin/youtube_video_add_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeVideoAddScreen extends StatefulWidget {
  const YoutubeVideoAddScreen({super.key});

  @override
  State<YoutubeVideoAddScreen> createState() => _YoutubeVideoAddScreenState();
}

class _YoutubeVideoAddScreenState extends State<YoutubeVideoAddScreen> {
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentVideoId;
  String? _currentTitle;
  bool _isEnabled = true;
  String _errorMessage = '';

  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);

  @override
  void initState() {
    super.initState();
    _loadCurrentVideoSettings();
  }

  @override
  void dispose() {
    _videoUrlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ✅ FIXED: Load from video_stream_settings
  Future<void> _loadCurrentVideoSettings() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('video_stream_settings') // ← CHANGED!
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final videoId = data['videoId']?.toString() ?? '';
        final videoUrl = data['videoUrl']?.toString() ?? '';
        final title = data['title']?.toString() ?? 'Thursday Live Stream';

        setState(() {
          _currentVideoId = videoId;
          _currentTitle = title;
          _isEnabled = data['isEnabled'] ?? true;
          _videoUrlController.text = videoUrl.isNotEmpty
              ? videoUrl
              : 'https://www.youtube.com/watch?v=$videoId';
          _titleController.text = title;
        });
      } else {
        // Set default values
        const defaultVideoId = '4iKp91iLzwo';
        const defaultUrl = 'https://www.youtube.com/watch?v=4iKp91iLzwo';
        setState(() {
          _currentVideoId = defaultVideoId;
          _currentTitle = 'Thursday Live Stream';
          _videoUrlController.text = defaultUrl;
          _titleController.text = 'Thursday Live Stream';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading settings: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _extractVideoId(String url) {
    final patterns = [
      r'(?:youtube\.com\/watch\?v=)([\w-]+)', // Standard watch URL
      r'(?:youtu\.be\/)([\w-]+)', // Short URL
      r'(?:youtube\.com\/embed\/)([\w-]+)', // Embed URL
      r'(?:youtube\.com\/shorts\/)([\w-]+)', // Shorts URL
      r'(?:youtube\.com\/v\/)([\w-]+)', // Old embed URL
      r'(?:youtube\.com\/live\/)([\w-]+)', // ✅ ADD THIS: Live URL
      r'(?:youtube\.com\/live\/)([\w-]+)\?', // Live URL with query params
    ];

    for (final pattern in patterns) {
      final match = RegExp(pattern).firstMatch(url);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    // Also handle: youtube.com/live/VIDEO_ID?si=...
    final liveMatch = RegExp(r'youtube\.com\/live\/([\w-]+)').firstMatch(url);
    if (liveMatch != null && liveMatch.group(1) != null) {
      return liveMatch.group(1)!;
    }

    if (RegExp(r'^[\w-]{11}$').hasMatch(url)) {
      return url;
    }

    return '';
  }

  bool _isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;
    final videoId = _extractVideoId(url);
    return videoId.isNotEmpty && videoId.length == 11;
  }

  // ✅ FIXED: Save to video_stream_settings
  Future<void> _saveVideoSettings() async {
    final url = _videoUrlController.text.trim();
    final title = _titleController.text.trim();

    if (url.isEmpty) {
      _showSnackBar('Please enter a YouTube URL', Colors.red);
      return;
    }

    if (title.isEmpty) {
      _showSnackBar('Please enter a title', Colors.red);
      return;
    }

    final videoId = _extractVideoId(url);
    if (videoId.isEmpty || videoId.length != 11) {
      _showSnackBar('Invalid YouTube URL. Please check the link.', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('video_stream_settings') // ← CHANGED!
          .set({
        'videoId': videoId,
        'videoUrl': url,
        'title': title,
        'isEnabled': _isEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _currentVideoId = videoId;
        _currentTitle = title;
      });

      _showSnackBar('✅ YouTube video updated successfully!', Colors.green);
      await _loadCurrentVideoSettings();
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _previewVideo() {
    final url = _videoUrlController.text.trim();
    final videoId = _extractVideoId(url);

    if (videoId.isNotEmpty) {
      _launchUrl('https://www.youtube.com/watch?v=$videoId');
    } else {
      _showSnackBar('Please enter a valid YouTube URL first', Colors.orange);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open URL', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Live Video Settings',
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
            icon: const Icon(Icons.preview_rounded),
            onPressed: _previewVideo,
            tooltip: 'Preview Video',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCurrentStatusCard(),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEnabled ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isEnabled ? Icons.check_circle_rounded : Icons.block_rounded,
                color: _isEnabled ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _isEnabled ? 'Video is ACTIVE' : 'Video is DISABLED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isEnabled ? Colors.green : Colors.red,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Text(
                'Current Video: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  fontFamily: 'Poppins',
                ),
              ),
              Expanded(
                child: Text(
                  _currentVideoId?.isNotEmpty == true
                      ? _currentVideoId!
                      : 'None',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Title: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  fontFamily: 'Poppins',
                ),
              ),
              Expanded(
                child: Text(
                  _currentTitle ?? 'No title',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateTime.now().toString().substring(0, 16)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YouTube Video URL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _videoUrlController,
              decoration: InputDecoration(
                hintText: 'https://www.youtube.com/watch?v=...',
                prefixIcon: Icon(Icons.link_rounded, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Supported: YouTube URL, Shorts URL, or Video ID',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Stream Title',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g., Thursday Live Stream',
                prefixIcon: Icon(Icons.title_rounded, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enable Video',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Color(0xFF333333),
                ),
              ),
              Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
                activeThumbColor: primaryColor,
                activeTrackColor: primaryColor.withValues(alpha: 0.3),
              ),
            ],
          ),
          Text(
            _isEnabled
                ? 'Video will be shown to users'
                : 'Video is hidden from users',
            style: TextStyle(
              fontSize: 12,
              color: _isEnabled ? Colors.green : Colors.red,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveVideoSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
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
                  Text('Saving...'),
                ],
              )
            : const Text(
                'Save Video Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }
}
