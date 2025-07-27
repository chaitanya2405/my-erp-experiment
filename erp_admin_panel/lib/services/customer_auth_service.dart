// Customer Authentication and ID Generation Service
// This handles customer signup, authentication, and automatic CRM entry

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/original_models.dart';

class CustomerAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _customersCollection = 'customers';

  // Generate unique customer ID
  static String _generateCustomerId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000; // Last 4 digits for uniqueness
    return 'CUST${timestamp.toString().substring(8)}$random';
  }

  // Alias for signUpCustomer to match the usage in customer_app_screen.dart
  static Future<Map<String, dynamic>?> createCustomer({
    required String email,
    required String password,
    required String customerName,
    required String mobileNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    return signUpCustomer(
      email: email,
      password: password,
      customerName: customerName,
      mobileNumber: mobileNumber,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
  }

  // Customer signup with automatic CRM entry
  static Future<Map<String, dynamic>?> signUpCustomer({
    required String email,
    required String password,
    required String customerName,
    required String mobileNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      // Create Firebase Auth account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return null;
      }

      // Generate unique customer ID
      final customerId = _generateCustomerId();
      final now = Timestamp.now();

      // Create customer profile in CRM
      final customerProfile = CustomerProfile(
        customerId: customerId,
        customerName: customerName,
        email: email,
        phone: mobileNumber,
        altPhone: null,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        customerType: 'regular',
        customerStatus: 'active',
        creditLimit: 0.0,
        walletBalance: 0.0,
        loyaltyPoints: 100, // Welcome bonus
        gstNumber: null,
        companyName: null,
        dateOfBirth: dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : now,
        gender: gender ?? 'other',
        preferredCategories: [],
        preferences: {
          'notifications': true,
          'email_marketing': true,
          'sms_marketing': true,
          'created_via': 'customer_app',
        },
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore with custom document ID
      await _firestore.collection(_customersCollection).doc(customerId).set(customerProfile.toMap());

      // Update Firebase Auth profile
      await userCredential.user!.updateDisplayName(customerName);

      debugPrint('✅ Customer created successfully: $customerId');

      return {
        'success': true,
        'customerId': customerId,
        'uid': userCredential.user!.uid,
        'customerProfile': customerProfile,
      };

    } catch (e) {
      debugPrint('❌ Error creating customer: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Customer login
  static Future<Map<String, dynamic>?> signInCustomer({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting to sign in customer: $email');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        debugPrint('❌ Firebase Auth returned null user');
        return {
          'success': false,
          'error': 'Authentication failed - no user returned',
        };
      }

      debugPrint('✅ Firebase Auth successful for: ${userCredential.user!.email}');

      // Get customer profile from CRM
      final customerProfile = await getCustomerByEmail(email);

      if (customerProfile == null) {
        debugPrint('❌ Customer profile not found in Firestore for: $email');
        return {
          'success': false,
          'error': 'Customer profile not found. Please contact support.',
        };
      }

      debugPrint('✅ Customer profile found: ${customerProfile.customerName} (${customerProfile.customerId})');

      return {
        'success': true,
        'uid': userCredential.user!.uid,
        'customerProfile': customerProfile,
      };

    } catch (e) {
      debugPrint('❌ Error signing in customer: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get customer by email
  static Future<CustomerProfile?> getCustomerByEmail(String email) async {
    try {
      debugPrint('🔍 Searching for customer with email: $email');
      
      final snapshot = await _firestore
          .collection(_customersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      debugPrint('📊 Query returned ${snapshot.docs.length} documents');

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        debugPrint('✅ Found customer document: ${doc.id}');
        debugPrint('📄 Customer data: ${doc.data()}');
        return CustomerProfile.fromFirestore(doc);
      } else {
        debugPrint('❌ No customer documents found for email: $email');
        
        // Let's also check what customers exist in the collection
        final allCustomersSnapshot = await _firestore
            .collection(_customersCollection)
            .limit(5)
            .get();
        debugPrint('📋 Total customers in collection: ${allCustomersSnapshot.docs.length}');
        for (var doc in allCustomersSnapshot.docs) {
          debugPrint('👤 Customer: ${doc.id} - ${doc.data()['email']} - ${doc.data()['customer_name']}');
        }
        
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting customer by email: $e');
      return null;
    }
  }

  // Get customer by ID
  static Future<CustomerProfile?> getCustomerById(String customerId) async {
    try {
      final doc = await _firestore.collection(_customersCollection).doc(customerId).get();
      if (doc.exists) {
        return CustomerProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting customer by ID: $e');
      return null;
    }
  }

  // Update customer profile
  static Future<bool> updateCustomerProfile(String customerId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = Timestamp.now();
      await _firestore.collection(_customersCollection).doc(customerId).update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating customer profile: $e');
      return false;
    }
  }

  // Add loyalty points
  static Future<bool> addLoyaltyPoints(String customerId, int points, String reason) async {
    try {
      final customer = await getCustomerById(customerId);
      if (customer == null) return false;

      final newPoints = customer.loyaltyPoints + points;
      
      await updateCustomerProfile(customerId, {
        'loyalty_points': newPoints,
      });

      // Log loyalty transaction
      await _firestore.collection('loyalty_transactions').add({
        'customer_id': customerId,
        'points': points,
        'reason': reason,
        'balance_after': newPoints,
        'created_at': Timestamp.now(),
      });

      debugPrint('✅ Added $points loyalty points to $customerId. Reason: $reason');
      return true;
    } catch (e) {
      debugPrint('Error adding loyalty points: $e');
      return false;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if customer exists
  static Future<bool> customerExists(String email) async {
    try {
      final customer = await getCustomerByEmail(email);
      return customer != null;
    } catch (e) {
      return false;
    }
  }
}
