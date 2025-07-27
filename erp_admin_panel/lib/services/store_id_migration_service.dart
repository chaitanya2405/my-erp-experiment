// 🔧 MIGRATION SCRIPT - Update Store IDs
// This script updates existing POS transactions and orders to use the correct store ID

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StoreIdMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Update all POS transactions from 'default_store' to 'STORE_001'
  static Future<void> migrateStoreIds() async {
    try {
      print('🔧 Starting store ID migration from admin app...');
      print('   • Target store ID: STORE_001');
      print('   • Source store ID: default_store');
      
      // Update POS transactions
      await _migratePosTransactions();
      
      // Update customer orders
      await _migrateCustomerOrders();
      
      print('✅ Store ID migration completed successfully!');
    } catch (e) {
      print('❌ Error during migration: $e');
      rethrow;
    }
  }
  
  static Future<void> _migratePosTransactions() async {
    print('📄 Migrating POS transactions...');
    
    // Query all POS transactions with old store ID
    final snapshot = await _firestore
        .collection('pos_transactions')
        .where('store_id', isEqualTo: 'default_store')
        .get();
    
    print('📄 Found ${snapshot.docs.length} POS transactions to migrate');
    
    // Update each transaction
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'store_id': 'STORE_001',
        'updated_at': FieldValue.serverTimestamp(),
        'migrated_by': 'admin_app',
      });
    }
    
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
      print('   ✅ Updated ${snapshot.docs.length} POS transactions');
    } else {
      print('   ℹ️ No POS transactions found with old store ID');
    }
  }
  
  static Future<void> _migrateCustomerOrders() async {
    print('📋 Migrating customer orders...');
    
    // Query all customer orders with old store ID
    final snapshot = await _firestore
        .collection('customer_orders')
        .where('store_id', isEqualTo: 'default_store')
        .get();
    
    print('📋 Found ${snapshot.docs.length} customer orders to migrate');
    
    // Update each order
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'store_id': 'STORE_001',
        'updated_at': FieldValue.serverTimestamp(),
        'migrated_by': 'admin_app',
      });
    }
    
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
      print('   ✅ Updated ${snapshot.docs.length} customer orders');
    } else {
      print('   ℹ️ No customer orders found with old store ID');
    }
  }
  
  // Get migration status
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      // Count transactions with old store ID
      final oldPosSnapshot = await _firestore
          .collection('pos_transactions')
          .where('store_id', isEqualTo: 'default_store')
          .get();
      
      final oldOrdersSnapshot = await _firestore
          .collection('customer_orders')
          .where('store_id', isEqualTo: 'default_store')
          .get();
      
      // Count transactions with new store ID
      final newPosSnapshot = await _firestore
          .collection('pos_transactions')
          .where('store_id', isEqualTo: 'STORE_001')
          .get();
      
      final newOrdersSnapshot = await _firestore
          .collection('customer_orders')
          .where('store_id', isEqualTo: 'STORE_001')
          .get();
      
      return {
        'pending_pos_transactions': oldPosSnapshot.docs.length,
        'pending_customer_orders': oldOrdersSnapshot.docs.length,
        'migrated_pos_transactions': newPosSnapshot.docs.length,
        'migrated_customer_orders': newOrdersSnapshot.docs.length,
        'migration_needed': oldPosSnapshot.docs.isNotEmpty || oldOrdersSnapshot.docs.isNotEmpty,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'migration_needed': false,
      };
    }
  }
  
  // Auto-migrate on app startup if needed
  static Future<void> autoMigrateIfNeeded() async {
    try {
      final status = await getMigrationStatus();
      final migrationNeeded = status['migration_needed'] as bool? ?? false;
      
      if (migrationNeeded) {
        print('Auto-migration triggered - found data with old store IDs');
        await migrateStoreIds();
      } else {
        print('No migration needed - all data uses correct store ID');
      }
    } catch (e) {
      print('⚠️ Auto-migration check failed: $e');
    }
  }
}
