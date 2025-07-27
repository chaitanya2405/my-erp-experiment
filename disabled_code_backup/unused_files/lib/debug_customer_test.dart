// Debug script to test customer authentication directly
// Run this in isolation to debug the "customer not found" issue

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'services/customer_auth_service.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('🔍 Starting customer authentication debug test...');

  await testDirectFirestoreQuery();
  await testCustomerAuthService();
  await testFirebaseAuth();
}

Future<void> testDirectFirestoreQuery() async {
  debugPrint('\n📊 === DIRECT FIRESTORE TEST ===');
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Check if customers collection exists
    final allCustomers = await firestore.collection('customers').limit(10).get();
    debugPrint('📋 Total customers found: ${allCustomers.docs.length}');
    
    for (var doc in allCustomers.docs) {
      final data = doc.data();
      debugPrint('👤 Customer ${doc.id}: ${data['customer_name']} - ${data['email']}');
    }
    
    // Search for demo customer specifically
    final demoQuery = await firestore
        .collection('customers')
        .where('email', isEqualTo: 'john@example.com')
        .get();
    
    debugPrint('\n🎯 Demo customer query results: ${demoQuery.docs.length}');
    
    if (demoQuery.docs.isNotEmpty) {
      final doc = demoQuery.docs.first;
      debugPrint('✅ Found demo customer: ${doc.id}');
      debugPrint('📄 Full data: ${doc.data()}');
    } else {
      debugPrint('❌ Demo customer NOT found');
    }
    
  } catch (e) {
    debugPrint('❌ Error in direct Firestore test: $e');
  }
}

Future<void> testCustomerAuthService() async {
  debugPrint('\n🔧 === CUSTOMER AUTH SERVICE TEST ===');
  
  try {
    // Test the service method
    final customer = await CustomerAuthService.getCustomerByEmail('john@example.com');
    
    if (customer != null) {
      debugPrint('✅ CustomerAuthService found customer: ${customer.customerName}');
      debugPrint('🆔 Customer ID: ${customer.customerId}');
      debugPrint('📧 Email: ${customer.email}');
    } else {
      debugPrint('❌ CustomerAuthService did NOT find customer');
    }
    
  } catch (e) {
    debugPrint('❌ Error in CustomerAuthService test: $e');
  }
}

Future<void> testFirebaseAuth() async {
  debugPrint('\n🔐 === FIREBASE AUTH TEST ===');
  
  try {
    // Check if user exists in Firebase Auth
    final auth = FirebaseAuth.instance;
    
    // Try to sign in with demo credentials
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: 'john@example.com',
        password: 'password123',
      );
      
      if (result.user != null) {
        debugPrint('✅ Firebase Auth successful');
        debugPrint('🆔 UID: ${result.user!.uid}');
        debugPrint('📧 Email: ${result.user!.email}');
        debugPrint('👤 Display Name: ${result.user!.displayName}');
        
        // Sign out after test
        await auth.signOut();
      }
    } catch (e) {
      debugPrint('❌ Firebase Auth failed: $e');
    }
    
  } catch (e) {
    debugPrint('❌ Error in Firebase Auth test: $e');
  }
}
