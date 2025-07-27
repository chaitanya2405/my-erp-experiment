// Supplier Authentication Service
// Handles supplier login, registration, and authentication

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/original_models.dart';

class SupplierAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'suppliers';

  // Sign in supplier with email and password
  static Future<Map<String, dynamic>?> signInSupplier({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting to sign in supplier: $email');
      
      // Firebase Auth sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        debugPrint('✅ Firebase Auth successful for: $email');
        
        // Get supplier profile from Firestore
        final supplier = await getSupplierByEmail(email);
        
        if (supplier != null) {
          debugPrint('✅ Supplier profile found: ${supplier.supplierName} (${supplier.supplierId})');
          return {
            'success': true,
            'supplier': supplier,
            'user': userCredential.user,
          };
        } else {
          debugPrint('❌ Supplier profile not found in Firestore for: $email');
          return {
            'success': false,
            'error': 'Supplier profile not found. Please contact administrator.',
          };
        }
      }
      
      return {
        'success': false,
        'error': 'Authentication failed',
      };
    } catch (e) {
      debugPrint('❌ Supplier sign in error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Register new supplier
  static Future<Map<String, dynamic>?> registerSupplier({
    required String email,
    required String password,
    required String supplierName,
    required String contactPersonName,
    required String contactPersonMobile,
    required String supplierType,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? gstin,
  }) async {
    try {
      debugPrint('📝 Registering new supplier: $email');
      
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Generate supplier ID
        final supplierId = 'SUPP-${DateTime.now().millisecondsSinceEpoch}';
        
        // Create supplier profile
        final supplier = Supplier(
          supplierId: supplierId,
          supplierName: supplierName,
          contactPerson: contactPersonName,
          email: email,
          phone: contactPersonMobile,
          address: address,
          city: city,
          state: state,
          country: 'India',
          pincode: pincode,
          gstNumber: gstin ?? '',
          panNumber: '',
          bankDetails: '',
          supplierType: supplierType,
          supplierStatus: 'active',
          creditLimit: 100000,
          paymentTerms: 30,
          productCategories: [],
          supplierRating: 5.0,
          notes: null,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        // Save to Firestore
        await _firestore.collection(_collection).doc(supplierId).set(supplier.toMap());
        
        debugPrint('✅ Supplier registered successfully: $supplierId');
        return {
          'success': true,
          'supplier': supplier,
          'user': userCredential.user,
        };
      }
      
      return {
        'success': false,
        'error': 'Registration failed',
      };
    } catch (e) {
      debugPrint('❌ Supplier registration error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get supplier by email
  static Future<Supplier?> getSupplierByEmail(String email) async {
    try {
      debugPrint('🔍 Searching for supplier with email: $email');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      debugPrint('📊 Query returned ${snapshot.docs.length} documents');
      
      if (snapshot.docs.isNotEmpty) {
        final supplier = Supplier.fromFirestore(snapshot.docs.first);
        debugPrint('✅ Found supplier document: ${supplier.supplierId}');
        return supplier;
      }
      
      debugPrint('❌ No supplier documents found for email: $email');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting supplier by email: $e');
      return null;
    }
  }

  // Get supplier by ID
  static Future<Supplier?> getSupplierById(String supplierId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(supplierId).get();
      
      if (doc.exists) {
        return Supplier.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error getting supplier by ID: $e');
      return null;
    }
  }

  // Update supplier profile
  static Future<bool> updateSupplierProfile(String supplierId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = Timestamp.now();
      
      await _firestore.collection(_collection).doc(supplierId).update(updates);
      
      debugPrint('✅ Supplier profile updated: $supplierId');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating supplier profile: $e');
      return false;
    }
  }

  // Sign out supplier
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ Supplier signed out');
    } catch (e) {
      debugPrint('❌ Error signing out supplier: $e');
    }
  }

  // Get current authenticated user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if supplier is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }
}
