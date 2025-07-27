// Script to add Supplier Portal module to Firestore database
// This ensures the Supplier Portal appears as a clickable module in the main dashboard

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('🔥 Firebase initialized successfully');
    
    final firestore = FirebaseFirestore.instance;
    
    // Add Supplier Portal module
    await firestore.collection('modules').doc('supplier_portal').set({
      'title': 'Supplier Portal',
      'icon': '🏭',
      'description': 'Supplier portal for managing purchase orders, inventory, and deliveries',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ Supplier Portal module added successfully');
    
    // Verify by reading back
    final doc = await firestore.collection('modules').doc('supplier_portal').get();
    if (doc.exists) {
      print('✅ Verification: Supplier Portal module exists in Firestore');
      print('📊 Module data: ${doc.data()}');
    } else {
      print('❌ Verification failed: Module not found');
    }
    
    // List all modules
    print('\n📋 All modules in database:');
    final snapshot = await firestore.collection('modules').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      print('  ${data['icon']} ${data['title']} (${doc.id})');
    }
    
    print('\n🎉 Setup complete! You should now see the Supplier Portal in your main dashboard.');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
