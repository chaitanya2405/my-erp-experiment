// 🏪 SHARED BUSINESS SERVICES
// Contains all business logic for orders, inventory, etc.
// Preserves exact functionality from original services

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/shared_models.dart';

// ============================================================================
// 📋 PURCHASE ORDERS SERVICE
// ============================================================================

class PurchaseOrdersService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'purchase_orders';

  // Get all purchase orders for a specific supplier
  static Future<List<PurchaseOrder>> getSupplierPurchaseOrders(String supplierId) async {
    try {
      debugPrint('📋 Getting purchase orders for supplier: $supplierId');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('supplier_id', isEqualTo: supplierId)
          .get();
      
      final orders = snapshot.docs
          .map((doc) => PurchaseOrder.fromFirestore(doc))
          .toList();
      
      // Sort by order date (newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      debugPrint('✅ Found ${orders.length} purchase orders for supplier $supplierId');
      return orders;
    } catch (e) {
      debugPrint('❌ Error getting supplier purchase orders: $e');
      return [];
    }
  }

  // Get pending purchase orders for supplier
  static Future<List<PurchaseOrder>> getPendingPurchaseOrders(String supplierId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('supplier_id', isEqualTo: supplierId)
          .where('status', whereIn: ['pending', 'confirmed', 'processing'])
          .get();
      
      final orders = snapshot.docs
          .map((doc) => PurchaseOrder.fromFirestore(doc))
          .toList();
      
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      debugPrint('✅ Found ${orders.length} pending purchase orders for supplier $supplierId');
      return orders;
    } catch (e) {
      debugPrint('❌ Error getting pending purchase orders: $e');
      return [];
    }
  }

  // Update purchase order status
  static Future<bool> updatePurchaseOrderStatus({
    required String orderId,
    required String newStatus,
    String? remarks,
    DateTime? expectedDeliveryDate,
  }) async {
    try {
      debugPrint('🔄 Updating PO status: $orderId -> $newStatus');
      
      final updates = {
        'status': newStatus,
        'updated_at': Timestamp.now(),
      };
      
      if (remarks != null) {
        updates['supplier_remarks'] = remarks;
      }
      
      if (expectedDeliveryDate != null) {
        updates['expected_delivery_date'] = Timestamp.fromDate(expectedDeliveryDate);
      }
      
      // Add status change to history
      final statusHistory = {
        'status': newStatus,
        'timestamp': Timestamp.now(),
        'remarks': remarks ?? '',
        'updated_by': 'supplier',
      };
      
      await _firestore.collection(_collection).doc(orderId).update({
        ...updates,
        'status_history': FieldValue.arrayUnion([statusHistory]),
      });
      
      debugPrint('✅ Purchase order status updated: $orderId -> $newStatus');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating purchase order status: $e');
      return false;
    }
  }

  // Create new purchase order
  static Future<String?> createPurchaseOrder(PurchaseOrder order) async {
    try {
      final docRef = await _firestore.collection(_collection).add(order.toMap());
      debugPrint('✅ Purchase order created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating purchase order: $e');
      return null;
    }
  }

  // Get purchase order by ID
  static Future<PurchaseOrder?> getPurchaseOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      
      if (doc.exists) {
        return PurchaseOrder.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error getting purchase order by ID: $e');
      return null;
    }
  }
}

// ============================================================================
// 🛒 CUSTOMER ORDERS SERVICE
// ============================================================================

class CustomerOrdersService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'customer_orders';

  // Get all orders for a specific customer
  static Future<List<CustomerOrder>> getCustomerOrders(String customerId) async {
    try {
      debugPrint('📋 Getting orders for customer: $customerId');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('customer_id', isEqualTo: customerId)
          .get();
      
      final orders = snapshot.docs
          .map((doc) => CustomerOrder.fromFirestore(doc))
          .toList();
      
      // Sort by order date (newest first)
      orders.sort((a, b) => b.orderDate.toDate().compareTo(a.orderDate.toDate()));
      
      debugPrint('✅ Found ${orders.length} orders for customer $customerId');
      return orders;
    } catch (e) {
      debugPrint('❌ Error getting customer orders: $e');
      return [];
    }
  }

  // Get pending orders for customer
  static Future<List<CustomerOrder>> getPendingOrders(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('customer_id', isEqualTo: customerId)
          .where('order_status', whereIn: ['pending', 'confirmed', 'processing'])
          .get();
      
      final orders = snapshot.docs
          .map((doc) => CustomerOrder.fromFirestore(doc))
          .toList();
      
      orders.sort((a, b) => b.orderDate.toDate().compareTo(a.orderDate.toDate()));
      
      debugPrint('✅ Found ${orders.length} pending orders for customer $customerId');
      return orders;
    } catch (e) {
      debugPrint('❌ Error getting pending orders: $e');
      return [];
    }
  }

  // Create new customer order
  static Future<String?> createCustomerOrder(CustomerOrder order) async {
    try {
      final docRef = await _firestore.collection(_collection).add(order.toMap());
      debugPrint('✅ Customer order created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating customer order: $e');
      return null;
    }
  }

  // Update order status
  static Future<bool> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? remarks,
  }) async {
    try {
      debugPrint('🔄 Updating order status: $orderId -> $newStatus');
      
      final updates = {
        'order_status': newStatus,
        'updated_at': Timestamp.now(),
      };
      
      if (remarks != null) {
        updates['remarks'] = remarks;
      }
      
      await _firestore.collection(_collection).doc(orderId).update(updates);
      
      debugPrint('✅ Order status updated: $orderId -> $newStatus');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
      return false;
    }
  }

  // Get order by ID
  static Future<CustomerOrder?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      
      if (doc.exists) {
        return CustomerOrder.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error getting order by ID: $e');
      return null;
    }
  }
}

// ============================================================================
// 📦 INVENTORY SERVICE
// ============================================================================

class InventoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'inventory';

  // Get all inventory items
  static Future<List<InventoryItem>> getAllInventoryItems() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      final items = snapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc))
          .toList();
      
      debugPrint('✅ Found ${items.length} inventory items');
      return items;
    } catch (e) {
      debugPrint('❌ Error getting inventory items: $e');
      return [];
    }
  }

  // Get inventory by product ID
  static Future<InventoryItem?> getInventoryByProductId(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return InventoryItem.fromFirestore(snapshot.docs.first);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error getting inventory by product ID: $e');
      return null;
    }
  }

  // Update inventory stock
  static Future<bool> updateStock({
    required String inventoryId,
    required int newStock,
    String? reason,
  }) async {
    try {
      final updates = {
        'current_stock': newStock,
        'available_stock': newStock, // Assuming no reserved stock for simplicity
        'last_updated': Timestamp.now(),
        'last_updated_by': 'system',
      };
      
      await _firestore.collection(_collection).doc(inventoryId).update(updates);
      
      debugPrint('✅ Inventory stock updated: $inventoryId -> $newStock');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating inventory stock: $e');
      return false;
    }
  }
}

// ============================================================================
// 📊 PRODUCTS SERVICE
// ============================================================================

class ProductsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'products';

  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
      
      debugPrint('✅ Found ${products.length} products');
      return products;
    } catch (e) {
      debugPrint('❌ Error getting products: $e');
      return [];
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
      
      debugPrint('✅ Found ${products.length} products in category: $category');
      return products;
    } catch (e) {
      debugPrint('❌ Error getting products by category: $e');
      return [];
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error getting product by ID: $e');
      return null;
    }
  }

  // Search products by name or SKU
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .where((product) => 
            product.productName.toLowerCase().contains(query.toLowerCase()) ||
            product.sku.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      debugPrint('✅ Found ${products.length} products matching: $query');
      return products;
    } catch (e) {
      debugPrint('❌ Error searching products: $e');
      return [];
    }
  }
}
