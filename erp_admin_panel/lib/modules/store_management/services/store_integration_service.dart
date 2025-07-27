import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/activity_tracker.dart';

/// Comprehensive Store Integration Service
/// Handles cross-module communication for Store Management
class StoreIntegrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ==================== CRM INTEGRATION ====================
  
  /// Get customer data for store-specific analytics
  static Future<List<Map<String, dynamic>>> getStoreCustomers(String storeId) async {
    try {
      // Track CRM integration activity
      ActivityTracker().trackInteraction(
        action: 'store_crm_integration',
        element: 'customer_data_fetch',
        data: {
          'store_id': storeId,
          'integration_type': 'crm_customers',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final querySnapshot = await _firestore
          .collection('customers')
          .where('preferredStore', isEqualTo: storeId)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
        'lastVisitDate': (doc.data()['lastVisitDate'] as Timestamp?)?.toDate(),
        'registrationDate': (doc.data()['registrationDate'] as Timestamp?)?.toDate(),
      }).toList();
    } catch (e) {
      print('Error fetching store customers: $e');
      return [];
    }
  }
  
  /// Get customer order history for store
  static Future<List<Map<String, dynamic>>> getStoreCustomerOrders(String storeId) async {
    try {
      // Track customer order integration activity
      ActivityTracker().trackInteraction(
        action: 'store_order_integration',
        element: 'customer_orders_fetch',
        data: {
          'store_id': storeId,
          'integration_type': 'customer_orders',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final querySnapshot = await _firestore
          .collection('customer_orders')
          .where('storeId', isEqualTo: storeId)
          .orderBy('orderDate', descending: true)
          .limit(100)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
        'orderDate': (doc.data()['orderDate'] as Timestamp?)?.toDate(),
        'expectedDeliveryDate': (doc.data()['expectedDeliveryDate'] as Timestamp?)?.toDate(),
      }).toList();
    } catch (e) {
      print('Error fetching store customer orders: $e');
      return [];
    }
  }
  
  // ==================== SUPPLIER INTEGRATION ====================
  
  /// Get suppliers for store
  static Future<List<Map<String, dynamic>>> getStoreSuppliers(String storeId) async {
    try {
      // Track supplier integration activity
      ActivityTracker().trackInteraction(
        action: 'store_supplier_integration',
        element: 'supplier_data_fetch',
        data: {
          'store_id': storeId,
          'integration_type': 'suppliers',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final querySnapshot = await _firestore
          .collection('suppliers')
          .where('servicesStores', arrayContains: storeId)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
        'registrationDate': (doc.data()['registrationDate'] as Timestamp?)?.toDate(),
        'lastOrderDate': (doc.data()['lastOrderDate'] as Timestamp?)?.toDate(),
      }).toList();
    } catch (e) {
      print('Error fetching store suppliers: $e');
      return [];
    }
  }
  
  /// Get purchase orders for store
  static Future<List<Map<String, dynamic>>> getStorePurchaseOrders(String storeId) async {
    try {
      // Track purchase order integration activity
      ActivityTracker().trackInteraction(
        action: 'store_po_integration',
        element: 'purchase_orders_fetch',
        data: {
          'store_id': storeId,
          'integration_type': 'purchase_orders',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final querySnapshot = await _firestore
          .collection('purchase_orders')
          .where('storeId', isEqualTo: storeId)
          .orderBy('orderDate', descending: true)
          .limit(50)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
        'orderDate': (doc.data()['orderDate'] as Timestamp?)?.toDate(),
        'expectedDeliveryDate': (doc.data()['expectedDeliveryDate'] as Timestamp?)?.toDate(),
        'deliveryDate': (doc.data()['deliveryDate'] as Timestamp?)?.toDate(),
      }).toList();
    } catch (e) {
      print('Error fetching store purchase orders: $e');
      return [];
    }
  }
  
  // ==================== INVENTORY INTEGRATION ====================
  
  /// Get real-time inventory for store
  static Future<List<Map<String, dynamic>>> getStoreInventory(String storeId) async {
    try {
      // Track inventory integration activity
      ActivityTracker().trackInteraction(
        action: 'store_inventory_integration',
        element: 'inventory_data_fetch',
        data: {
          'store_id': storeId,
          'integration_type': 'inventory',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final querySnapshot = await _firestore
          .collection('inventory')
          .where('storeId', isEqualTo: storeId)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
        'lastUpdated': (doc.data()['lastUpdated'] as Timestamp?)?.toDate(),
        'lastRestockDate': (doc.data()['lastRestockDate'] as Timestamp?)?.toDate(),
      }).toList();
    } catch (e) {
      print('Error fetching store inventory: $e');
      return [];
    }
  }
  
  /// Get products available in store
  static Future<List<Map<String, dynamic>>> getStoreProducts(String storeId) async {
    try {
      // Track product integration activity
      ActivityTracker().trackInteraction(
        action: 'store_product_integration',
        element: 'products_data_fetch',
        data: {
          'store_id': storeId,
          'integration_type': 'products',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      // Get inventory items for this store
      final inventorySnapshot = await _firestore
          .collection('inventory')
          .where('storeId', isEqualTo: storeId)
          .get();
      
      List<String> productIds = inventorySnapshot.docs
          .map((doc) => doc.data()['productId'] as String)
          .toList();
      
      if (productIds.isEmpty) return [];
      
      // Get product details for these product IDs
      List<Map<String, dynamic>> products = [];
      
      // Firestore 'in' query supports max 10 items, so batch the requests
      for (int i = 0; i < productIds.length; i += 10) {
        int end = (i + 10 < productIds.length) ? i + 10 : productIds.length;
        List<String> batch = productIds.sublist(i, end);
        
        final productSnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        products.addAll(productSnapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
          'createdAt': (doc.data()['createdAt'] as Timestamp?)?.toDate(),
          'updatedAt': (doc.data()['updatedAt'] as Timestamp?)?.toDate(),
        }));
      }
      
      return products;
    } catch (e) {
      print('Error fetching store products: $e');
      return [];
    }
  }
  
  // ==================== POS INTEGRATION ====================
  
  /// Get POS transactions for store
  static Future<List<Map<String, dynamic>>> getStorePOSTransactions(String storeId) async {
    try {
      // Track POS integration activity
      ActivityTracker().trackInteraction(
        action: 'store_pos_integration',
        element: 'pos_transactions_fetch',
        data: {
          'store_id': storeId,
          'integration_type': 'pos_transactions',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final querySnapshot = await _firestore
          .collection('pos_transactions')
          .where('storeId', isEqualTo: storeId)
          .orderBy('transactionDate', descending: true)
          .limit(100)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
        'transactionDate': (doc.data()['transactionDate'] as Timestamp?)?.toDate(),
      }).toList();
    } catch (e) {
      print('Error fetching store POS transactions: $e');
      return [];
    }
  }
  
  // ==================== COMPREHENSIVE STORE ANALYTICS ====================
  
  /// Get comprehensive store analytics with all module data
  static Future<Map<String, dynamic>> getComprehensiveStoreAnalytics(String storeId) async {
    try {
      // Track comprehensive analytics activity
      ActivityTracker().trackInteraction(
        action: 'store_comprehensive_analytics',
        element: 'full_analytics_fetch',
        data: {
          'store_id': storeId,
          'integration_type': 'comprehensive_analytics',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      // Fetch all data in parallel for better performance
      final futures = await Future.wait([
        getStoreCustomers(storeId),
        getStoreCustomerOrders(storeId),
        getStoreSuppliers(storeId),
        getStorePurchaseOrders(storeId),
        getStoreInventory(storeId),
        getStoreProducts(storeId),
        getStorePOSTransactions(storeId),
      ]);
      
      final customers = futures[0] as List<Map<String, dynamic>>;
      final customerOrders = futures[1] as List<Map<String, dynamic>>;
      final suppliers = futures[2] as List<Map<String, dynamic>>;
      final purchaseOrders = futures[3] as List<Map<String, dynamic>>;
      final inventory = futures[4] as List<Map<String, dynamic>>;
      final products = futures[5] as List<Map<String, dynamic>>;
      final posTransactions = futures[6] as List<Map<String, dynamic>>;
      
      // Calculate analytics
      double totalRevenue = posTransactions.fold(0.0, (sum, transaction) => 
          sum + (transaction['totalAmount'] as num? ?? 0).toDouble());
      
      double totalPurchaseCost = purchaseOrders.fold(0.0, (sum, order) => 
          sum + (order['totalAmount'] as num? ?? 0).toDouble());
      
      int totalInventoryItems = inventory.fold(0, (sum, item) => 
          sum + (item['currentStock'] as int? ?? 0));
      
      int lowStockItems = inventory.where((item) => 
          (item['currentStock'] as int? ?? 0) < (item['minStockLevel'] as int? ?? 10)).length;
      
      // Recent activity (last 7 days)
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final recentOrders = customerOrders.where((order) => 
          (order['orderDate'] as DateTime?)?.isAfter(lastWeek) ?? false).length;
      final recentTransactions = posTransactions.where((transaction) => 
          (transaction['transactionDate'] as DateTime?)?.isAfter(lastWeek) ?? false).length;
      
      return {
        'storeId': storeId,
        'timestamp': DateTime.now().toIso8601String(),
        'summary': {
          'totalCustomers': customers.length,
          'totalSuppliers': suppliers.length,
          'totalProducts': products.length,
          'totalInventoryItems': totalInventoryItems,
          'lowStockItems': lowStockItems,
          'totalRevenue': totalRevenue,
          'totalPurchaseCost': totalPurchaseCost,
          'profitMargin': totalRevenue > 0 ? ((totalRevenue - totalPurchaseCost) / totalRevenue * 100) : 0,
        },
        'recentActivity': {
          'ordersLastWeek': recentOrders,
          'transactionsLastWeek': recentTransactions,
          'lastOrderDate': customerOrders.isNotEmpty 
              ? customerOrders.first['orderDate']?.toIso8601String() 
              : null,
          'lastTransactionDate': posTransactions.isNotEmpty 
              ? posTransactions.first['transactionDate']?.toIso8601String() 
              : null,
        },
        'moduleData': {
          'customers': customers,
          'customerOrders': customerOrders,
          'suppliers': suppliers,
          'purchaseOrders': purchaseOrders,
          'inventory': inventory,
          'products': products,
          'posTransactions': posTransactions,
        },
        'integrationStatus': {
          'crmConnected': customers.isNotEmpty,
          'supplierConnected': suppliers.isNotEmpty,
          'inventoryConnected': inventory.isNotEmpty,
          'posConnected': posTransactions.isNotEmpty,
          'ordersConnected': customerOrders.isNotEmpty,
          'productsConnected': products.isNotEmpty,
        },
      };
    } catch (e) {
      print('Error getting comprehensive store analytics: $e');
      return {
        'error': e.toString(),
        'storeId': storeId,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  // ==================== COMMUNICATION TESTING ====================
  
  /// Test cross-module communication
  static Future<Map<String, bool>> testModuleCommunication(String storeId) async {
    try {
      // Track communication test
      ActivityTracker().trackInteraction(
        action: 'store_communication_test',
        element: 'module_communication_test',
        data: {
          'store_id': storeId,
          'test_type': 'cross_module_communication',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      // Test each module connection
      final results = <String, bool>{};
      
      try {
        await getStoreCustomers(storeId);
        results['crm'] = true;
      } catch (e) {
        results['crm'] = false;
      }
      
      try {
        await getStoreSuppliers(storeId);
        results['suppliers'] = true;
      } catch (e) {
        results['suppliers'] = false;
      }
      
      try {
        await getStoreInventory(storeId);
        results['inventory'] = true;
      } catch (e) {
        results['inventory'] = false;
      }
      
      try {
        await getStorePOSTransactions(storeId);
        results['pos'] = true;
      } catch (e) {
        results['pos'] = false;
      }
      
      try {
        await getStoreCustomerOrders(storeId);
        results['orders'] = true;
      } catch (e) {
        results['orders'] = false;
      }
      
      try {
        await getStoreProducts(storeId);
        results['products'] = true;
      } catch (e) {
        results['products'] = false;
      }
      
      return results;
    } catch (e) {
      print('Error testing module communication: $e');
      return {};
    }
  }
}
