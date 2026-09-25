import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String organizationId = 'iM6QRMlgUuWNbUdgQ0';

  // Check if current user is app admin
  Future<bool> isCurrentUserAppAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check in both collections for compatibility
      final rootAdmin = await _firestore
          .collection('appAdmins')
          .doc(user.uid)
          .get();

      if (rootAdmin.exists && rootAdmin['isActive'] == true) {
        return true;
      }

      // Check legacy collection
      final legacyAdmin = await _firestore
          .collection('swalathmajlis')
          .doc(organizationId)
          .collection('appAdmins')
          .doc(user.uid)
          .get();

      return legacyAdmin.exists && legacyAdmin['isActive'] == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Get admin permissions
  Future<List<String>> getAdminPermissions() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Check root collection first
      final rootAdmin = await _firestore
          .collection('appAdmins')
          .doc(user.uid)
          .get();

      if (rootAdmin.exists) {
        final permissions = rootAdmin['permissions'] ?? [];
        return List<String>.from(permissions);
      }

      // Check legacy collection
      final legacyAdmin = await _firestore
          .collection('swalathmajlis')
          .doc(organizationId)
          .collection('appAdmins')
          .doc(user.uid)
          .get();

      if (legacyAdmin.exists) {
        final permissions = legacyAdmin['permissions'] ?? [];
        return List<String>.from(permissions);
      }

      return [];
    } catch (e) {
      print('Error getting permissions: $e');
      return [];
    }
  }

  // Check specific permission
  Future<bool> hasPermission(String permission) async {
    final permissions = await getAdminPermissions();
    return permissions.contains(permission);
  }
}
