// Simple script to check what modules exist in Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> main() async {
  try {
    // Initialize Firebase (check if already initialized)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    
    print('🔥 Firebase initialized');
    
    final firestore = FirebaseFirestore.instance;
    
    // List all modules
    print('📋 Current modules in database:');
    final snapshot = await firestore.collection('modules').get();
    
    if (snapshot.docs.isEmpty) {
      print('❌ No modules found in Firestore!');
    } else {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('  ${data['icon'] ?? '📄'} ${data['title'] ?? 'Unknown'} (ID: ${doc.id})');
      }
    }
    
    // Check if Supplier Portal specifically exists
    final supplierPortalDoc = await firestore.collection('modules').doc('supplier_portal').get();
    
    if (supplierPortalDoc.exists) {
      print('\n✅ Supplier Portal module EXISTS in Firestore');
      print('📊 Data: ${supplierPortalDoc.data()}');
    } else {
      print('\n❌ Supplier Portal module NOT FOUND in Firestore');
      
      // Add it now
      print('🔧 Adding Supplier Portal module...');
      await firestore.collection('modules').doc('supplier_portal').set({
        'title': 'Supplier Portal',
        'icon': '🏭',
        'description': 'Supplier portal for managing purchase orders, inventory, and deliveries',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Supplier Portal module added successfully!');
    }
    
    print('\n🎉 Check completed! Refresh your browser to see the Supplier Portal module.');
    
  } catch (e) {
    print('❌ Error: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
