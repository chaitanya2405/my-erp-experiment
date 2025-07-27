import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  print('🚀 Starting inventory stock update...');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // Get all inventory documents
    print('📦 Fetching all inventory documents...');
    final inventorySnapshot = await firestore.collection('inventory').get();
    
    print('📊 Found ${inventorySnapshot.docs.length} inventory records');
    
    if (inventorySnapshot.docs.isEmpty) {
      print('⚠️ No inventory documents found. Make sure the mock data script has been run.');
      return;
    }
    
    // Update each inventory document
    WriteBatch batch = firestore.batch();
    int batchCount = 0;
    int totalUpdated = 0;
    
    for (var doc in inventorySnapshot.docs) {
      final data = doc.data();
      final productId = data['product_id'] ?? 'Unknown';
      final location = data['store_location'] ?? 'Unknown';
      
      // Update to have plenty of stock for testing
      batch.update(doc.reference, {
        'quantity_available': 100,  // Set high stock for testing
        'quantity_reserved': 0,     // Clear reservations
        'quantity_on_order': 0,     // Clear pending orders
        'quantity_damaged': 0,      // Clear damaged stock
        'updated_at': Timestamp.now(),
        'updated_by': 'script_update',
      });
      
      batchCount++;
      totalUpdated++;
      
      print('📈 Queued update for $productId at $location');
      
      // Commit batch every 500 operations (Firestore limit)
      if (batchCount >= 500) {
        print('💾 Committing batch of $batchCount updates...');
        await batch.commit();
        batch = firestore.batch();
        batchCount = 0;
      }
    }
    
    // Commit remaining updates
    if (batchCount > 0) {
      print('💾 Committing final batch of $batchCount updates...');
      await batch.commit();
    }
    
    print('✅ Successfully updated $totalUpdated inventory records');
    print('📦 All products now have 100 units available at each location');
    
    // Verify a few updates
    print('\n🔍 Verifying updates...');
    final verifySnapshot = await firestore
        .collection('inventory')
        .limit(5)
        .get();
    
    for (var doc in verifySnapshot.docs) {
      final data = doc.data();
      print('✓ ${data['product_id']} at ${data['store_location']}: ${data['quantity_available']} available');
    }
    
    print('\n🎉 Inventory update completed successfully!');
    print('🧪 You can now test customer orders - all products should have sufficient stock.');
    
  } catch (e, stackTrace) {
    print('❌ Error updating inventory: $e');
    print('Stack trace: $stackTrace');
  }
}
