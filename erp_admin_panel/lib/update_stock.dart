// Quick script to update all product stock to 100
// This will ensure we have sufficient inventory for testing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('🔧 Updating all product stock to 100...');
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Get all products
    final productsSnapshot = await firestore.collection('products').get();
    debugPrint('📦 Found ${productsSnapshot.docs.length} products to update');
    
    int updatedCount = 0;
    
    for (var doc in productsSnapshot.docs) {
      final data = doc.data();
      final productName = data['product_name'] ?? data['name'] ?? 'Unknown';
      
      // Update stock to 100
      await doc.reference.update({
        'current_stock': 100,
        'updated_at': Timestamp.now(),
      });
      
      updatedCount++;
      debugPrint('✅ Updated ${doc.id}: $productName -> Stock: 100');
    }
    
    debugPrint('🎉 Successfully updated $updatedCount products!');
    debugPrint('All products now have stock = 100');
    
  } catch (e) {
    debugPrint('❌ Error updating product stock: $e');
  }
}
