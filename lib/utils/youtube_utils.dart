// lib/utils/youtube_utils.dart

class YouTubeUtils {
  // Extract video ID from any YouTube URL
  static String extractVideoId(String url) {
    try {
      if (url.isEmpty) return '';

      // Handle youtube.com/watch?v= format
      if (url.contains('youtube.com/watch?v=')) {
        final parts = url.split('v=');
        if (parts.length > 1) {
          return parts[1].split('&')[0];
        }
      }

      // Handle youtube.com/live/ format
      if (url.contains('youtube.com/live/')) {
        final parts = url.split('youtube.com/live/');
        if (parts.length > 1) {
          return parts[1].split('?')[0].split('&')[0];
        }
      }

      // Handle youtu.be/ format
      if (url.contains('youtu.be/')) {
        final parts = url.split('youtu.be/');
        if (parts.length > 1) {
          return parts[1].split('?')[0];
        }
      }

      // Handle youtube.com/embed/ format
      if (url.contains('youtube.com/embed/')) {
        final parts = url.split('youtube.com/embed/');
        if (parts.length > 1) {
          return parts[1].split('?')[0];
        }
      }

      // Handle youtube.com/shorts/ format
      if (url.contains('youtube.com/shorts/')) {
        final parts = url.split('youtube.com/shorts/');
        if (parts.length > 1) {
          return parts[1].split('?')[0];
        }
      }

      // Handle m.youtube.com format
      if (url.contains('m.youtube.com/watch?v=')) {
        final parts = url.split('v=');
        if (parts.length > 1) {
          return parts[1].split('&')[0];
        }
      }

      // Handle youtu.be with timestamp
      if (url.contains('youtu.be/')) {
        final parts = url.split('youtu.be/');
        if (parts.length > 1) {
          return parts[1].split('?')[0].split('&')[0];
        }
      }
    } catch (e) {
      print('❌ Error extracting video ID: $e');
    }

    print('⚠️ Could not extract video ID from: $url');
    return '';
  }

  // Convert any YouTube URL to embed URL
  static String convertToEmbedUrl(String url) {
    try {
      final videoId = extractVideoId(url);
      if (videoId.isEmpty) {
        print('⚠️ No video ID found, returning original URL');
        return url;
      }

      final embedUrl =
          'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1&controls=1&showinfo=0&enablejsapi=1';
      print('✅ Converted to embed URL: $embedUrl');
      return embedUrl;
    } catch (e) {
      print('❌ Error converting to embed URL: $e');
      return url;
    }
  }

  // Convert to youtube-nocookie.com embed (better for embedding)
  static String convertToNoCookieEmbedUrl(String url) {
    try {
      final videoId = extractVideoId(url);
      if (videoId.isEmpty) {
        print('⚠️ No video ID found, returning original URL');
        return url;
      }

      final embedUrl =
          'https://www.youtube-nocookie.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1&controls=1&showinfo=0&enablejsapi=1';
      print('✅ Converted to no-cookie embed URL: $embedUrl');
      return embedUrl;
    } catch (e) {
      print('❌ Error converting to no-cookie embed URL: $e');
      return url;
    }
  }

  // Validate YouTube URL
  static bool isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;

    final patterns = [
      'youtube.com/watch',
      'youtube.com/live',
      'youtube.com/embed',
      'youtube.com/shorts',
      'youtu.be',
      'm.youtube.com',
    ];

    for (String pattern in patterns) {
      if (url.contains(pattern)) {
        print('✅ URL validation passed: $url');
        return true;
      }
    }

    print('⚠️ URL validation failed: $url');
    return false;
  }

  // Get YouTube direct watch URL
  static String getDirectWatchUrl(String url) {
    final videoId = extractVideoId(url);
    if (videoId.isNotEmpty) {
      return 'https://www.youtube.com/watch?v=$videoId';
    }
    return url;
  }

  // Get YouTube thumbnail URL
  static String getThumbnailUrl(String url, {String quality = 'hqdefault'}) {
    final videoId = extractVideoId(url);
    if (videoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
    }
    return '';
  }

  // JavaScript to hide YouTube UI elements
  static String getHideYoutubeUIScript() {
    return '''
      var style = document.createElement('style');
      style.innerHTML = `
        .ytp-chrome-top,
        .ytp-title,
        .ytp-watermark,
        .ytp-ce-element,
        .ytp-pause-overlay,
        .ytp-endscreen-content {
          display: none !important;
        }
        body { 
          margin: 0; 
          padding: 0; 
          background: #000; 
        }
        #player { 
          width: 100% !important; 
          height: 100% !important; 
        }
      `;
      document.head.appendChild(style);
    ''';
  }

  // Check if URL is a live stream
  static bool isLiveStreamUrl(String url) {
    return url.contains('youtube.com/live/');
  }

  // Extract channel name from URL (if available)
  static String extractChannelName(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        final channel = uri.pathSegments.first;
        if (channel.startsWith('@')) {
          return channel;
        }
      }
    } catch (e) {
      print('Error extracting channel name: $e');
    }
    return '';
  }
}
