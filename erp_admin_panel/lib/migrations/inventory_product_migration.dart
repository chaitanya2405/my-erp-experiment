import 'package:cloud_firestore/cloud_firestore.dart';

/// Migration script to enhance existing inventory records with product information
/// This will update existing inventory records to include product_name, product_sku, etc.
class InventoryProductMigration {
  static Future<void> migrateExistingInventoryRecords() async {
    print('🔄 Starting inventory-product migration...');
    
    final firestore = FirebaseFirestore.instance;
    
    try {
      // Get all inventory records
      final inventorySnapshot = await firestore.collection('inventory').get();
      print('📦 Found ${inventorySnapshot.docs.length} inventory records to migrate');
      
      // Get all products for reference
      final productsSnapshot = await firestore.collection('products').get();
      final productsMap = <String, Map<String, dynamic>>{};
      
      for (final productDoc in productsSnapshot.docs) {
        productsMap[productDoc.id] = productDoc.data();
      }
      print('🏷️ Found ${productsMap.length} products for reference');
      
      int migrated = 0;
      int skipped = 0;
      
      // Update each inventory record with product information
      for (final inventoryDoc in inventorySnapshot.docs) {
        final inventoryData = inventoryDoc.data();
        final productId = inventoryData['product_id'] as String?;
        
        if (productId == null || !productsMap.containsKey(productId)) {
          print('⚠️ Skipping inventory ${inventoryDoc.id} - no product_id or product not found');
          skipped++;
          continue;
        }
        
        final productData = productsMap[productId]!;
        
        // Check if already migrated
        if (inventoryData.containsKey('product_name')) {
          print('✅ Inventory ${inventoryDoc.id} already has product info');
          skipped++;
          continue;
        }
        
        // Add product information to inventory record
        final updateData = {
          'product_name': productData['product_name'] ?? productData['name'] ?? 'Unknown Product',
          'product_sku': productData['sku'] ?? 'N/A',
          'product_category': productData['category'] ?? '',
          'product_brand': productData['brand'] ?? '',
          'migrated_at': Timestamp.now(),
        };
        
        await firestore.collection('inventory').doc(inventoryDoc.id).update(updateData);
        
        print('✅ Migrated inventory ${inventoryDoc.id} for product: ${updateData['product_name']}');
        migrated++;
      }
      
      print('🎉 Migration completed!');
      print('✅ Migrated: $migrated records');
      print('⏭️ Skipped: $skipped records');
      
    } catch (e) {
      print('❌ Migration failed: $e');
      throw e;
    }
  }
  
  /// Update store locations in inventory to use proper store codes
  static Future<void> migrateStoreLocations() async {
    print('🏪 Starting store location migration...');
    
    final firestore = FirebaseFirestore.instance;
    
    try {
      // Get all stores for reference
      final storesSnapshot = await firestore.collection('stores').get();
      final storesMap = <String, Map<String, dynamic>>{};
      
      for (final storeDoc in storesSnapshot.docs) {
        final storeData = storeDoc.data();
        storesMap[storeDoc.id] = storeData;
      }
      print('🏪 Found ${storesMap.length} stores for reference');
      
      // Get all inventory records
      final inventorySnapshot = await firestore.collection('inventory').get();
      
      int updated = 0;
      
      for (final inventoryDoc in inventorySnapshot.docs) {
        final inventoryData = inventoryDoc.data();
        final currentLocation = inventoryData['store_location'] as String?;
        
        // If store_location is already a store code, skip
        final hasStoreCode = storesMap.values.any((store) => 
          store['store_code'] == currentLocation);
        
        if (hasStoreCode) {
          continue;
        }
        
        // If it's "STORE_001", map it to the first store's code
        if (currentLocation == 'STORE_001' && storesMap.isNotEmpty) {
          final firstStore = storesMap.values.first;
          final storeCode = firstStore['store_code'] ?? firstStore['store_id'];
          
          await firestore.collection('inventory').doc(inventoryDoc.id).update({
            'store_location': storeCode,
            'store_location_migrated_at': Timestamp.now(),
          });
          
          print('✅ Updated inventory ${inventoryDoc.id} store location to: $storeCode');
          updated++;
        }
      }
      
      print('🎉 Store location migration completed!');
      print('✅ Updated: $updated records');
      
    } catch (e) {
      print('❌ Store location migration failed: $e');
      throw e;
    }
  }
}
