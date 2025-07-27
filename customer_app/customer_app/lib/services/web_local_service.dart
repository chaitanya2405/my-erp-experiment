// 🔥 WEB-COMPATIBLE FIREBASE SERVICE
// Local demo service for web builds (no Firebase dependencies)

import 'package:flutter/foundation.dart';
import '../services/web_auth_stub.dart';

class WebCompatibleFirebaseService {
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // For web demo, just use local storage simulation
        print('✅ Web local demo service initialized');
      } else {
        // For mobile, would use full Firebase in production
        print('✅ Mobile demo service initialized');
      }
    } catch (e) {
      print('❌ Service initialization failed: $e');
      rethrow;
    }
  }

  // Authentication methods (using stubs for web)
  static Future<Map<String, dynamic>?> signInWithEmailAndPassword(String email, String password) async {
    if (kIsWeb) {
      return await WebAuthStub.signInWithEmailAndPassword(email, password);
    } else {
      // For mobile, implement actual Firebase Auth
      return {'uid': 'demo-user', 'email': email};
    }
  }

  static Future<Map<String, dynamic>?> createUserWithEmailAndPassword(String email, String password) async {
    if (kIsWeb) {
      return await WebAuthStub.createUserWithEmailAndPassword(email, password);
    } else {
      // For mobile, implement actual Firebase Auth
      return {'uid': 'demo-user', 'email': email};
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

  // Data methods (simulated for web demo)
  static Future<List<Map<String, dynamic>>> getCollection(String collectionName) async {
    if (kIsWeb) {
      // Return sample data for web demo
      switch (collectionName) {
        case 'products':
          return [
            {
              'id': '1',
              'name': 'Sample Product 1',
              'sku': 'SKU001',
              'price': 1000.0,
              'categoryId': 'electronics',
            },
            {
              'id': '2', 
              'name': 'Sample Product 2',
              'sku': 'SKU002',
              'price': 2000.0,
              'categoryId': 'furniture',
            },
          ];
        default:
          return [];
      }
    } else {
      // For mobile, implement actual Firestore
      return [];
    }
  }

  static Future<void> addDocument(String collectionName, Map<String, dynamic> data) async {
    if (kIsWeb) {
      // For web demo, just log the action
      print('📝 Added document to $collectionName: $data');
    } else {
      // For mobile, implement actual Firestore
    }
  }

  static Future<void> updateDocument(String collectionName, String docId, Map<String, dynamic> data) async {
    if (kIsWeb) {
      // For web demo, just log the action
      print('✏️ Updated document $docId in $collectionName: $data');
    } else {
      // For mobile, implement actual Firestore
    }
  }
}
