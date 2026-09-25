// lib/services/app_admin_auth_service.dart (User App)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppAdminAuthService {
  static const String _isLoggedInKey = 'isAppAdminLoggedIn';
  static const String _adminEmailKey = 'appAdminEmail';
  static const String _adminUidKey = 'appAdminUid';
  static const String _adminPermissionsKey = 'appAdminPermissions';
  static const String _adminNameKey = 'appAdminName';
  static const String _loginTimeKey = 'loginTime';
  static const String _lastAccessKey = 'lastAccess';

  // Session timeout (24 hours)
  static const int _sessionTimeoutHours = 24;

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return false;

    // Check session timeout
    final loginTimeStr = prefs.getString(_loginTimeKey);
    if (loginTimeStr == null) return false;

    try {
      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      final hoursSinceLogin = now.difference(loginTime).inHours;

      if (hoursSinceLogin >= _sessionTimeoutHours) {
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_adminEmailKey);
    await prefs.remove(_adminUidKey);
    await prefs.remove(_adminPermissionsKey);
    await prefs.remove(_adminNameKey);
    await prefs.remove(_loginTimeKey);
    await prefs.remove(_lastAccessKey);

    // Also sign out from Firebase Auth
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Ignore if already signed out
    }
  }

  static Future<List<String>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_adminPermissionsKey) ?? [];
  }

  static Future<bool> hasPermission(String permission) async {
    final permissions = await getPermissions();
    return permissions.contains(permission) || permissions.contains('all');
  }

  // Feature-specific permission checks (for dashboard)
  static Future<bool> canManageLiveStreams() async {
    return await hasPermission('manage_live_streams');
  }

  static Future<bool> canManageFeedback() async {
    return await hasPermission('manage_feedback');
  }

  static Future<bool> canViewComments() async {
    return await hasPermission('view_comments');
  }

  static Future<bool> canViewAnalytics() async {
    return await hasPermission('view_analytics');
  }

  static Future<bool> canSendAdminMessages() async {
    return await hasPermission('send_admin_messages');
  }

  static Future<String?> getAdminEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminEmailKey);
  }

  static Future<String?> getAdminUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminUidKey);
  }

  static Future<String?> getAdminName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminNameKey) ?? 'App Admin';
  }

  // Check if user is currently logged in as app admin
  static Future<bool> isCurrentUserAppAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString(_adminUidKey);

    return savedUid == user.uid && (prefs.getBool(_isLoggedInKey) ?? false);
  }

  // Extend session by updating login time (call when accessing dashboard)
  static Future<void> extendSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
  }

  // Update last access time (call on dashboard load)
  static Future<void> updateLastAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAccessKey, DateTime.now().toIso8601String());
  }

  // Check if session should stay active (for main app initialization)
  static Future<bool> shouldStayLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeStr = prefs.getString(_loginTimeKey);
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn || loginTimeStr == null) return false;

    try {
      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      final hoursSinceLogin = now.difference(loginTime).inHours;

      // Stay logged in for session timeout duration
      return hoursSinceLogin < _sessionTimeoutHours;
    } catch (e) {
      return false;
    }
  }

  // Save login data after successful authentication
  static Future<void> saveLoginData({
    required String email,
    required String uid,
    required List<String> permissions,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_adminEmailKey, email);
    await prefs.setString(_adminUidKey, uid);
    await prefs.setStringList(_adminPermissionsKey, permissions);
    await prefs.setString(_adminNameKey, name);
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
    await prefs.setString(_lastAccessKey, DateTime.now().toIso8601String());
  }

  // Clear cache only (without logging out)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adminPermissionsKey);
  }

  // Get session duration in hours
  static Future<double> getSessionDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeStr = prefs.getString(_loginTimeKey);

    if (loginTimeStr == null) return 0;

    try {
      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      return now.difference(loginTime).inHours.toDouble();
    } catch (e) {
      return 0;
    }
  }

  // Check if session is about to expire (within 1 hour)
  static Future<bool> isSessionAboutToExpire() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeStr = prefs.getString(_loginTimeKey);

    if (loginTimeStr == null) return false;

    try {
      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      final hoursSinceLogin = now.difference(loginTime).inHours;

      // Warn if less than 1 hour remaining
      return hoursSinceLogin >= (_sessionTimeoutHours - 1);
    } catch (e) {
      return false;
    }
  }

  // Get remaining session time in hours
  static Future<double> getRemainingSessionTime() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeStr = prefs.getString(_loginTimeKey);

    if (loginTimeStr == null) return 0;

    try {
      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      final hoursSinceLogin = now.difference(loginTime).inHours;

      final remaining = _sessionTimeoutHours - hoursSinceLogin;
      return remaining > 0 ? remaining.toDouble() : 0;
    } catch (e) {
      return 0;
    }
  }

  // Refresh permissions from Firestore
  static Future<void> refreshPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_adminUidKey);

    if (uid == null) return;

    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('appAdmins')
          .doc(uid)
          .get();

      if (adminDoc.exists) {
        final permissions = List<String>.from(adminDoc['permissions'] ?? []);
        await prefs.setStringList(_adminPermissionsKey, permissions);
      }
    } catch (e) {
      print('Error refreshing permissions: $e');
    }
  }
}
