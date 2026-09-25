// lib/screens/app_admin/login_screen.dart (User App)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './appAdmin_dashboard.dart'; // We'll create this next

class AppAdminLoginScreen extends StatefulWidget {
  const AppAdminLoginScreen({super.key});

  @override
  State<AppAdminLoginScreen> createState() => _AppAdminLoginScreenState();
}

class _AppAdminLoginScreenState extends State<AppAdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // 🌈 Use User App Theme Colors (Green-Gold)
  final Color _primaryColor = const Color.fromARGB(
    255,
    42,
    172,
    131,
  ); // Deep Teal Green
  final Color _accentColor = const Color(0xFFD4AF37); // Warm Gold
  final Color _backgroundColor = const Color(0xFFFAF9F6);

  get legacyAdminDoc => null; // Warm White

  Future<void> _loginAppAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Authenticate with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // 2. Check if user exists in appAdmins collection
      final firestore = FirebaseFirestore.instance;

      // Check in root collection first
      final adminDoc = await firestore
          .collection('appAdmins')
          .doc(userCredential.user!.uid)
          .get();

      if (!adminDoc.exists) {
        // Check in legacy collection (backward compatibility)
        final legacyAdminDoc = await firestore
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('appAdmins')
            .doc(userCredential.user!.uid)
            .get();

        if (!legacyAdminDoc.exists) {
          // Not an app admin - sign out and show error
          await FirebaseAuth.instance.signOut();
          throw Exception('Access denied. Not authorized as App Admin.');
        }
      }

      // 3. Get admin data and permissions
      final adminData = adminDoc.exists
          ? adminDoc.data()
          : legacyAdminDoc.data();
      final permissions = adminData?['permissions'] ?? [];
      final isActive = adminData?['isActive'] ?? true;

      if (!isActive) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account is deactivated. Contact super admin.');
      }

      // 4. Save login state to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAppAdminLoggedIn', true);
      await prefs.setString('appAdminEmail', _emailController.text.trim());
      await prefs.setString('appAdminUid', userCredential.user!.uid);
      await prefs.setStringList(
        'appAdminPermissions',
        List<String>.from(permissions),
      );
      await prefs.setString('appAdminName', adminData?['name'] ?? 'App Admin');

      // Store login time for session management
      await prefs.setString('loginTime', DateTime.now().toIso8601String());

      // 5. Navigate to App Admin Dashboard
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AppAdminDashboard()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'Account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      setState(() => _errorMessage = errorMessage);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Header
              Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: _primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'App Admin Portal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  //
                ],
              ),

              const SizedBox(height: 40),

              // Login Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Admin Email',
                          prefixIcon: Icon(Icons.email, color: _primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: _primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      // Error Message
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginAppAdmin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Login as App Admin',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Back to User App Button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Back to user dashboard
                        },
                        child: Text(
                          '← Back to User App',
                          style: TextStyle(color: _primaryColor, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              //
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
