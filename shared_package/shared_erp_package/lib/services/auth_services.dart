// 🔐 SHARED AUTHENTICATION SERVICES
// Preserves all existing authentication logic for customers and suppliers
// Ensures zero functional change during restructuring

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/shared_models.dart';

// ============================================================================
// 🏪 SUPPLIER AUTHENTICATION SERVICE
// ============================================================================

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

// ============================================================================
// 👤 CUSTOMER AUTHENTICATION SERVICE
// ============================================================================

class CustomerAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'customers';

  // Sign in customer with email and password
  static Future<Map<String, dynamic>?> signInCustomer({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting to sign in customer: $email');
      
      // Firebase Auth sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        debugPrint('✅ Firebase Auth successful for: $email');
        
        // Get customer profile from Firestore
        final customer = await getCustomerByEmail(email);
        
        if (customer != null) {
          debugPrint('✅ Customer profile found: ${customer.customerName} (${customer.customerId})');
          return {
            'success': true,
            'customer': customer,
            'user': userCredential.user,
          };
        } else {
          debugPrint('❌ Customer profile not found in Firestore for: $email');
          return {
            'success': false,
            'error': 'Customer profile not found. Please contact administrator.',
          };
        }
      }
      
      return {
        'success': false,
        'error': 'Authentication failed',
      };
    } catch (e) {
      debugPrint('❌ Customer sign in error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Register new customer
  static Future<Map<String, dynamic>?> registerCustomer({
    required String email,
    required String password,
    required String customerName,
    required String phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    try {
      debugPrint('📝 Registering new customer: $email');
      
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Generate customer ID
        final customerId = 'CUST-${DateTime.now().millisecondsSinceEpoch}';
        
        // Create customer profile
        final customer = CustomerProfile(
          customerId: customerId,
          customerName: customerName,
          email: email,
          phone: phone,
          address: address,
          city: city,
          state: state,
          pincode: pincode,
          customerType: 'regular',
          customerStatus: 'active',
          creditLimit: 50000,
          walletBalance: 0,
          loyaltyPoints: 0,
          dateOfBirth: Timestamp.now(),
          gender: 'other',
          preferredCategories: [],
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        // Save to Firestore
        await _firestore.collection(_collection).doc(customerId).set(customer.toMap());
        
        debugPrint('✅ Customer registered successfully: $customerId');
        return {
          'success': true,
          'customer': customer,
          'user': userCredential.user,
        };
      }
      
      return {
        'success': false,
        'error': 'Registration failed',
      };
    } catch (e) {
      debugPrint('❌ Customer registration error: $e');
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
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      debugPrint('📊 Query returned ${snapshot.docs.length} documents');
      
      if (snapshot.docs.isNotEmpty) {
        final customer = CustomerProfile.fromFirestore(snapshot.docs.first);
        debugPrint('✅ Found customer document: ${customer.customerId}');
        return customer;
      }
      
      debugPrint('❌ No customer documents found for email: $email');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting customer by email: $e');
      return null;
    }
  }

  // Get customer by ID
  static Future<CustomerProfile?> getCustomerById(String customerId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(customerId).get();
      
      if (doc.exists) {
        return CustomerProfile.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error getting customer by ID: $e');
      return null;
    }
  }

  // Update customer profile
  static Future<bool> updateCustomerProfile(String customerId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = Timestamp.now();
      
      await _firestore.collection(_collection).doc(customerId).update(updates);
      
      debugPrint('✅ Customer profile updated: $customerId');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating customer profile: $e');
      return false;
    }
  }

  // Sign out customer
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ Customer signed out');
    } catch (e) {
      debugPrint('❌ Error signing out customer: $e');
    }
  }

  // Get current authenticated user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if customer is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }
}

// ============================================================================
// 🔐 GENERAL AUTHENTICATION SERVICE (for customer app compatibility)
// ============================================================================

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}

// ============================================================================
// 🗃️ FIRESTORE SERVICE (for data access)
// ============================================================================

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create document
  Future<void> createDoc(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  // Additional method for compatibility
  Future<void> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).add(data);
  }

  // Get documents (collection query) - returns data maps for easy use
  Future<List<Map<String, dynamic>>> getDocuments(
    String collection, {
    Map<String, dynamic>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _firestore.collection(collection);
    
    // Apply where filters
    if (where != null) {
      where.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });
    }
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Query collection with filters - returns data maps
  Future<List<Map<String, dynamic>>> queryCollection(
    String collection, {
    List<Map<String, dynamic>>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _firestore.collection(collection);
    
    if (where != null) {
      for (final filter in where) {
        query = query.where(
          filter['field'], 
          isEqualTo: filter['isEqualTo'],
          isGreaterThan: filter['isGreaterThan'],
          isLessThan: filter['isLessThan'],
          arrayContains: filter['arrayContains'],
        );
      }
    }
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Get document - returns data map for easy use
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.exists ? doc.data() as Map<String, dynamic>? : null;
  }

  // Update document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Get collection
  Future<QuerySnapshot> getCollection(String collection) async {
    return await _firestore.collection(collection).get();
  }

  // Get collection with where clause
  Future<QuerySnapshot> getCollectionWhere(
    String collection,
    String field,
    dynamic value,
  ) async {
    return await _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .get();
  }

  // Listen to document changes
  Stream<DocumentSnapshot> listenToDocument(
    String collection,
    String docId,
  ) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // Listen to collection changes
  Stream<QuerySnapshot> listenToCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Customer authentication methods (instance methods)
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
