// 🌐 WEB AUTH STUB
// Minimal Firebase Auth stub for web builds to avoid compilation issues

import 'package:flutter/foundation.dart';

// Stub for web authentication when Firebase Auth Web has issues
class WebAuthStub {
  static bool get isSupported => kIsWeb;
  
  static Future<bool> signInAnonymously() async {
    if (kIsWeb) {
      // Return a successful anonymous sign-in for demo purposes
      return true;
    }
    return false;
  }
  
  static Future<Map<String, dynamic>?> signInWithEmailAndPassword(String email, String password) async {
    if (kIsWeb) {
      // Return demo user credentials
      return {
        'uid': 'web_demo_user_$email',
        'email': email,
        'displayName': 'Demo User',
      };
    }
    return null;
  }
  
  static Future<Map<String, dynamic>?> createUserWithEmailAndPassword(String email, String password) async {
    if (kIsWeb) {
      // Return demo user credentials
      return {
        'uid': 'web_demo_user_$email',
        'email': email,
        'displayName': 'Demo User',
      };
    }
    return null;
  }
  
  static Future<bool> signOut() async {
    if (kIsWeb) {
      return true;
    }
    return false;
  }
  
  static String? get currentUserId {
    if (kIsWeb) {
      return 'web_demo_user';
    }
    return null;
  }
  
  static bool get isSignedIn {
    if (kIsWeb) {
      return true; // Always signed in for demo
    }
    return false;
  }
}
