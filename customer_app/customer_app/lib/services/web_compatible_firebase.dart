// 🔥 WEB-COMPATIBLE FIREBASE SERVICE
// Conditional Firebase implementation for web builds

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/web_auth_stub.dart';

class WebCompatibleFirebaseService {
  static late FirebaseFirestore _firestore;
  
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Initialize Firestore only (avoid Firebase Auth for web)
        _firestore = FirebaseFirestore.instance;
        print('✅ Firebase Firestore initialized for web');
      } else {
        // For mobile, use full Firebase
        _firestore = FirebaseFirestore.instance;
        print('✅ Firebase Firestore initialized for mobile');
      }
    } catch (e) {
      print('⚠️ Firebase initialization warning: $e');
      // Continue without Firebase for demo purposes
    }
  }
  
  static FirebaseFirestore get firestore => _firestore;
  
  static bool get isInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Auth methods using stub for web
  static Future<String?> getCurrentUserId() async {
    if (kIsWeb) {
      return WebAuthStub.currentUserId;
    } else {
      // For mobile, implement actual Firebase Auth
      return 'mobile_user_placeholder';
    }
  }
  
  static Future<bool> signInAnonymously() async {
    if (kIsWeb) {
      return await WebAuthStub.signInAnonymously();
    } else {
      // For mobile, implement actual Firebase Auth
      return true;
    }
  }
  
  static Future<bool> signOut() async {
    if (kIsWeb) {
      return await WebAuthStub.signOut();
    } else {
      // For mobile, implement actual Firebase Auth
      return true;
    }
  }
  
  static bool get isSignedIn {
    if (kIsWeb) {
      return WebAuthStub.isSignedIn;
    } else {
      // For mobile, implement actual Firebase Auth
      return true;
    }
  }
}
