// 🔧 MIGRATION SCRIPT - Update Store IDs
// This script updates existing POS transactions and orders to use the correct store ID

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StoreIdMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Update all POS transactions from 'default_store' to 'STORE_001'
  static Future<void> migrateStoreIds() async {
    try {
      if (kDebugMode) {
        print('🔧 Starting store ID migration...');
      }
      
      // Update POS transactions
      await _migratePosTransactions();
      
      // Update customer orders
      await _migrateCustomerOrders();
      
      if (kDebugMode) {
        print('✅ Store ID migration completed successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during migration: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> _migratePosTransactions() async {
    if (kDebugMode) {
      print('📄 Migrating POS transactions...');
    }
    
    // Query all POS transactions with old store ID
    final snapshot = await _firestore
        .collection('pos_transactions')
        .where('store_id', isEqualTo: 'default_store')
        .get();
    
    if (kDebugMode) {
      print('📄 Found ${snapshot.docs.length} POS transactions to migrate');
    }
    
    // Update each transaction
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'store_id': 'STORE_001',
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
    
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
      if (kDebugMode) {
        print('✅ Updated ${snapshot.docs.length} POS transactions');
      }
    }
  }
  
  static Future<void> _migrateCustomerOrders() async {
    if (kDebugMode) {
      print('📋 Migrating customer orders...');
    }
    
    // Query all customer orders with old store ID
    final snapshot = await _firestore
        .collection('customer_orders')
        .where('store_id', isEqualTo: 'default_store')
        .get();
    
    if (kDebugMode) {
      print('📋 Found ${snapshot.docs.length} customer orders to migrate');
    }
    
    // Update each order
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'store_id': 'STORE_001',
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
    
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
      if (kDebugMode) {
        print('✅ Updated ${snapshot.docs.length} customer orders');
      }
    }
  }
  
  // Get migration status
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      // Count transactions with old store ID
      final oldPosTransactions = await _firestore
          .collection('pos_transactions')
          .where('store_id', isEqualTo: 'default_store')
          .get();
      
      final oldCustomerOrders = await _firestore
          .collection('customer_orders')
          .where('store_id', isEqualTo: 'default_store')
          .get();
      
      // Count transactions with new store ID
      final newPosTransactions = await _firestore
          .collection('pos_transactions')
          .where('store_id', isEqualTo: 'STORE_001')
          .get();
      
      final newCustomerOrders = await _firestore
          .collection('customer_orders')
          .where('store_id', isEqualTo: 'STORE_001')
          .get();
      
      return {
        'old_pos_transactions': oldPosTransactions.docs.length,
        'old_customer_orders': oldCustomerOrders.docs.length,
        'new_pos_transactions': newPosTransactions.docs.length,
        'new_customer_orders': newCustomerOrders.docs.length,
        'migration_needed': oldPosTransactions.docs.isNotEmpty || oldCustomerOrders.docs.isNotEmpty,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
