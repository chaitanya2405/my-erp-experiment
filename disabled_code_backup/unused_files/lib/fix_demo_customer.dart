// SOLUTION 1: Firestore Security Rules
// Make sure your Firestore security rules allow reading customer data

// In Firebase Console > Firestore Database > Rules, use:
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all documents (for development only)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}

// SOLUTION 2: Re-create Demo Customer
// If the customer data is corrupted, recreate it:

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/customer_auth_service.dart';

Future<void> fixDemoCustomer() async {
  try {
    // 1. Delete existing demo customer (if exists)
    await FirebaseFirestore.instance
        .collection('customers')
        .where('email', isEqualTo: 'john@example.com')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    
    // 2. Delete Firebase Auth user (if exists)
    // This needs to be done from Firebase Console manually
    
    // 3. Recreate demo customer
    final result = await CustomerAuthService.createCustomer(
      customerName: 'John Doe',
      email: 'john@example.com',
      password: 'password123',
      mobileNumber: '+91 9876543210',
      address: '123 Demo Street, Demo Colony',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400001',
      dateOfBirth: DateTime(1990, 5, 15),
    );
    
    if (result != null && result['success'] == true) {
      print('✅ Demo customer recreated successfully');
    } else {
      print('❌ Failed to recreate demo customer: ${result?['error']}');
    }
  } catch (e) {
    print('❌ Error fixing demo customer: $e');
  }
}
