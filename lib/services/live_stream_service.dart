import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveStreamService {
  // YOUR CORRECT ORGANIZATION ID FROM FIREBASE
  static const String organizationId = 'iM6QRMlgUuWNbUdgQ0';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reference to the current stream document
  DocumentReference get _currentStreamRef => _firestore
      .collection('swalathmajlis')
      .doc(organizationId)
      .collection('live_streams')
      .doc('current_stream');

  // Reference to comments subcollection
  CollectionReference get _commentsRef =>
      _currentStreamRef.collection('comments');

  // --- FOR ALL USERS ---

  // Check if stream is live
  Future<bool> isStreamLive() async {
    try {
      final snapshot = await _currentStreamRef.get();
      return snapshot.exists && snapshot['isLive'] == true;
    } catch (e) {
      print('Error checking stream status: $e');
      return false;
    }
  }

  // Get current stream data
  Future<Map<String, dynamic>?> getCurrentStream() async {
    try {
      final snapshot = await _currentStreamRef.get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Error getting stream data: $e');
      return null;
    }
  }

  // Stream for real-time updates
  Stream<DocumentSnapshot> get liveStreamUpdates {
    return _currentStreamRef.snapshots();
  }

  // Add comment
  Future<void> addComment(String message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Check if user is admin
      final isAdmin = await _isUserAdmin(user.uid);

      await _commentsRef.add({
        'userId': user.uid,
        'userName': user.displayName ?? user.email?.split('@').first ?? 'User',
        'userEmail': user.email ?? '',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'isAdmin': isAdmin,
      });

      // Increment viewer count when someone comments (simple engagement tracking)
      await _incrementViewerCount();

      print('✅ Comment added successfully');
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Get comments stream
  Stream<QuerySnapshot> getCommentsStream() {
    return _commentsRef
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }

  // --- FOR APP ADMINS ONLY ---

  // Start live stream
  Future<void> startStream({
    required String title,
    required String description,
    required String youtubeUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      print('🚀 Starting stream with URL: $youtubeUrl');

      // First check if document exists, if not create it
      final docSnapshot = await _currentStreamRef.get();

      if (!docSnapshot.exists) {
        // Create the document first with default values
        await _currentStreamRef.set({
          'isLive': false,
          'title': '',
          'description': '',
          'youtubeUrl': '',
          'viewerCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Now update it with stream data
      await _currentStreamRef.update({
        'isLive': true,
        'title': title.trim(),
        'description': description.trim(),
        'youtubeUrl': youtubeUrl.trim(),
        'startedAt': FieldValue.serverTimestamp(),
        'adminId': user.uid,
        'adminName': user.displayName ?? 'Admin',
        'adminEmail': user.email,
        'viewerCount': 0,
        'status': 'live',
        'platform': 'youtube',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Save last stream info for easy restart
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_stream_title', title);
      await prefs.setString('last_stream_description', description);

      print('✅ Stream started successfully');

      // Debug: Verify the update
      await debugStreamStatus();
    } catch (e) {
      print('Error starting stream: $e');
      rethrow;
    }
  }

  // End stream
  Future<void> endStream() async {
    try {
      await _currentStreamRef.update({
        'isLive': false,
        'endedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'ended',
      });
      print('✅ Stream ended successfully');
    } catch (e) {
      print('Error ending stream: $e');
      rethrow;
    }
  }

  // Update viewer count
  Future<void> updateViewerCount(int count) async {
    try {
      await _currentStreamRef.update({
        'viewerCount': count,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating viewer count: $e');
    }
  }

  // Increment viewer count
  Future<void> _incrementViewerCount() async {
    try {
      await _currentStreamRef.update({'viewerCount': FieldValue.increment(1)});
    } catch (e) {
      print('Error incrementing viewer count: $e');
    }
  }

  // Decrement viewer count
  Future<void> decrementViewerCount() async {
    try {
      await _currentStreamRef.update({'viewerCount': FieldValue.increment(-1)});
    } catch (e) {
      print('Error decrementing viewer count: $e');
    }
  }

  // Delete comment (admin only)
  Future<void> deleteComment(String commentId) async {
    try {
      await _commentsRef.doc(commentId).delete();
      print('✅ Comment deleted');
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  // Get last stream info for easy restart
  Future<Map<String, String>> getLastStreamInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'title': prefs.getString('last_stream_title') ?? '',
      'description': prefs.getString('last_stream_description') ?? '',
    };
  }

  // Helper: Check if user is admin
  Future<bool> _isUserAdmin(String uid) async {
    try {
      final adminDoc = await _firestore
          .collection('swalathmajlis')
          .doc(organizationId)
          .collection('appAdmins')
          .doc(uid)
          .get();
      return adminDoc.exists;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Debug method to check stream status
  Future<void> debugStreamStatus() async {
    print('🔍 ===== STREAM STATUS DEBUG =====');
    try {
      final doc = await _currentStreamRef.get();
      print('Document exists: ${doc.exists}');

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('isLive: ${data['isLive']}');
        print('youtubeUrl: ${data['youtubeUrl']}');
        print('title: ${data['title']}');
        print('viewerCount: ${data['viewerCount']}');

        // Check if comments subcollection exists
        final commentsSnapshot = await _commentsRef.limit(1).get();
        print(
          'Comments collection exists: ${commentsSnapshot.docs.isNotEmpty}',
        );
        if (commentsSnapshot.docs.isNotEmpty) {
          print('Sample comment: ${commentsSnapshot.docs.first.data()}');
        }
      }
    } catch (e) {
      print('Error debugging stream: $e');
    }
    print('🔍 ===============================');
  }
}
