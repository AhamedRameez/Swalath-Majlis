// lib/services/permission_checker.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionChecker {
  // Feature-specific permission checks
  static Future<bool> canManageLiveStreams() async {
    return await _hasPermission('manage_live_streams') ||
        await _hasPermission('all');
  }

  static Future<bool> canManageFeedback() async {
    return await _hasPermission('manage_feedback') ||
        await _hasPermission('all');
  }

  static Future<bool> canViewComments() async {
    return await _hasPermission('view_comments') || await _hasPermission('all');
  }

  static Future<bool> canModerateComments() async {
    return await _hasPermission('moderate_comments') ||
        await _hasPermission('all');
  }

  static Future<bool> canViewAnalytics() async {
    return await _hasPermission('view_analytics') ||
        await _hasPermission('all');
  }

  static Future<bool> canSendAdminMessages() async {
    return await _hasPermission('send_admin_messages') ||
        await _hasPermission('all');
  }

  static Future<bool> canViewAdminMessages() async {
    return await _hasPermission('view_admin_messages') ||
        await _hasPermission('all');
  }

  // Helper method
  static Future<bool> _hasPermission(String permission) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedPermissions = prefs.getStringList('appAdminPermissions') ?? [];

    if (cachedPermissions.contains('all') ||
        cachedPermissions.contains(permission)) {
      return true;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('appAdmins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        final permissions = List<String>.from(adminDoc['permissions'] ?? []);
        await prefs.setStringList('appAdminPermissions', permissions);
        return permissions.contains('all') || permissions.contains(permission);
      }
    } catch (e) {
      print('Permission check error: $e');
    }

    return false;
  }
}
