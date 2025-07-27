import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/inventory_models.dart';
import '../core/bridge/bridge_helper.dart';
import '../core/activity_tracker.dart';

class InventoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _inventoryCollection = 'inventory';
  static const String _movementCollection = 'inventory_movements';

  // Stream inventory records
  static Stream<List<InventoryRecord>> getInventoryStream() {
    return _firestore.collection(_inventoryCollection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => InventoryRecord.fromFirestore(doc)).toList());
  }

  // Add inventory record
  static Future<void> addInventory(InventoryRecord record) async {
    try {
      await _firestore.collection(_inventoryCollection).doc(record.inventoryId).set(record.toFirestore());
    } catch (e) {
      debugPrint('Error adding inventory: $e');
      rethrow;
    }
  }

  // Update inventory record
  static Future<void> updateInventory(String inventoryId, InventoryRecord record) async {
    try {
      await _firestore.collection(_inventoryCollection).doc(inventoryId).update(record.toFirestore());
    } catch (e) {
      debugPrint('Error updating inventory: $e');
      rethrow;
    }
  }

  // Delete inventory record
  static Future<void> deleteInventory(String inventoryId) async {
    try {
      await _firestore.collection(_inventoryCollection).doc(inventoryId).delete();
    } catch (e) {
      debugPrint('Error deleting inventory: $e');
      rethrow;
    }
  }

  // Log inventory movement
  static Future<void> logMovement(InventoryMovementLog log) async {
    try {
      await _firestore.collection(_movementCollection).doc(log.movementId).set(log.toFirestore());
    } catch (e) {
      debugPrint('Error logging inventory movement: $e');
    }
  }

  // Get movements for product
  static Stream<List<InventoryMovementLog>> getMovementsForProduct(String productId) {
    return _firestore
        .collection(_movementCollection)
        .where('product_id', isEqualTo: productId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryMovementLog.fromFirestore(doc))
            .toList());
  }

  // ======================== POS INTEGRATION METHODS ========================

  // Get inventory by product ID
  static Future<InventoryRecord?> getInventoryByProductId(String productId) async {
    try {
      if (kDebugMode) {
        print('📦 Inventory Service: Looking up product: $productId');
      }
      
      final snapshot = await _firestore
          .collection(_inventoryCollection)
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final inventory = InventoryRecord.fromFirestore(snapshot.docs.first);
        if (kDebugMode) {
          print('✅ Inventory found: ${inventory.productName ?? 'Unknown Product'} - Stock: ${inventory.quantityAvailable}');
        }
        return inventory;
      }
      
      if (kDebugMode) {
        print('⚠️ No inventory record found for product: $productId');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Inventory Service error getting product $productId: $e');
      }
      return null;
    }
  }

  // Get low stock products
  static Future<List<InventoryRecord>> getLowStockProducts() async {
    try {
      final snapshot = await _firestore.collection(_inventoryCollection).get();
      final allInventory = snapshot.docs
          .map((doc) => InventoryRecord.fromFirestore(doc))
          .toList();
      
      return allInventory.where((inventory) {
        return inventory.quantityAvailable <= inventory.reorderPoint;
      }).toList();
    } catch (e) {
      debugPrint('Error getting low stock products: $e');
      return [];
    }
  }

  // Check if product is available for sale
  static Future<bool> isProductAvailable(String productId, int requestedQuantity) async {
    try {
      final inventory = await getInventoryByProductId(productId);
      if (inventory != null) {
        return inventory.quantityAvailable >= requestedQuantity;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking product availability: $e');
      return false;
    }
  }

  // Get inventory levels for multiple products
  static Future<Map<String, int>> getInventoryLevels(List<String> productIds) async {
    try {
      Map<String, int> levels = {};
      
      for (final productId in productIds) {
        final inventory = await getInventoryByProductId(productId);
        levels[productId] = inventory?.quantityAvailable.toInt() ?? 0;
      }
      
      return levels;
    } catch (e) {
      debugPrint('Error getting inventory levels: $e');
      return {};
    }
  }

  // Sync inventory levels
  static Future<void> syncInventoryLevels() async {
    try {
      debugPrint('Syncing inventory levels...');
      // Implementation for syncing inventory across modules
      // This could include updating cached values, reconciling with external systems, etc.
    } catch (e) {
      debugPrint('Error syncing inventory levels: $e');
    }
  }

  // Get inventory analytics
  static Future<Map<String, dynamic>> getInventoryAnalytics() async {
    try {
      final allInventory = await _firestore.collection(_inventoryCollection).get();
      final inventoryList = allInventory.docs
          .map((doc) => InventoryRecord.fromFirestore(doc))
          .toList();
      
      final totalProducts = inventoryList.length;
      final lowStockCount = inventoryList.where((inv) => 
          inv.quantityAvailable <= inv.reorderPoint).length;
      final outOfStockCount = inventoryList.where((inv) => 
          inv.quantityAvailable == 0).length;
      
      final totalValue = inventoryList.fold<double>(0, (sum, inv) => 
          sum + (inv.quantityAvailable * (inv.unitCost ?? 0)));
      
      return {
        'total_products': totalProducts,
        'low_stock_count': lowStockCount,
        'out_of_stock_count': outOfStockCount,
        'total_inventory_value': totalValue,
      };
    } catch (e) {
      debugPrint('Error getting inventory analytics: $e');
      return {};
    }
  }

  // Update inventory levels after a sale
  static Future<void> updateInventoryAfterSale(String productId, int quantitySold, String storeId) async {
    try {
      if (kDebugMode) {
        print('📦 Inventory Update: Processing sale for product $productId');
        print('  • Quantity sold: $quantitySold');
        print('  • Store: $storeId');
      }

      final inventory = await getInventoryByProductId(productId);
      if (inventory == null) {
        if (kDebugMode) {
          print('⚠️ Cannot update inventory - product not found: $productId');
        }
        return;
      }

      final newQuantity = inventory.quantityAvailable - quantitySold;
      
      if (kDebugMode) {
        print('  • Previous stock: ${inventory.quantityAvailable}');
        print('  • New stock level: $newQuantity');
      }

      // Update the inventory record
      final updatedInventory = inventory.copyWith(
        quantityAvailable: newQuantity,
        lastUpdated: Timestamp.now(),
      );

      await updateInventory(inventory.inventoryId, updatedInventory);

      // Log the movement
      final movement = InventoryMovementLog(
        movementId: 'mov_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        fromLocation: 'store',
        toLocation: 'sold',
        quantity: -quantitySold,
        movementType: 'SALE',
        initiatedBy: 'pos_system',
        timestamp: Timestamp.now(),
      );

      await logMovement(movement);

      if (kDebugMode) {
        print('✅ Inventory updated successfully');
        
        // Check for low stock
        if (newQuantity <= inventory.reorderPoint) {
          print('⚠️ LOW STOCK ALERT: ${inventory.productName ?? 'Unknown Product'}');
          print('  • Current: $newQuantity');
          print('  • Minimum: ${inventory.reorderPoint}');
          print('  • Action: Consider reordering');
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Inventory update failed for product $productId: $e');
      }
      rethrow;
    }
  }

  // 🌉 Bridge Integration - Enhanced with supplier and purchase order tracking
  static Future<void> initializeBridgeConnection() async {
    await BridgeHelper.connectModule(
      moduleName: 'inventory_service',
      capabilities: [
        'get_inventory', 'update_stock', 'get_low_stock', 'search_products',
        'supplier_tracking', 'purchase_order_integration', 'supplier_analytics'
      ],
      schema: {
        'inventory': {
          'fields': ['product_id', 'store_id', 'quantity', 'min_stock', 'supplier_id', 'purchase_order_id'],
          'filters': ['store_id', 'product_id', 'low_stock', 'supplier_id', 'purchase_order_id'],
        },
      },
      dataProvider: (dataType, filters) async {
        switch (dataType) {
          case 'inventory':
            if (filters.containsKey('store_id')) {
              return await getInventoryByStore(filters['store_id']);
            } else if (filters.containsKey('supplier_id')) {
              return await getInventoryBySupplier(filters['supplier_id']);
            } else if (filters.containsKey('purchase_order_id')) {
              return await getInventoryByPurchaseOrder(filters['purchase_order_id']);
            } else if (filters.containsKey('low_stock') && filters['low_stock'] == true) {
              return await getLowStockItems();
            }
            return await getAllInventory();
          default:
            return [];
        }
      },
      eventHandler: (event) async {
        switch (event.type) {
          case 'pos_sale_completed':
            await _handlePOSSaleEvent(event.data);
            break;
          case 'restock_required':
            await _handleRestockEvent(event.data);
            break;
          case 'supplier_delivery':
            await _handleSupplierDelivery(event.data);
            break;
          case 'purchase_order_delivered':
            await processPurchaseOrderDelivery(event.data);
            break;
        }
      },
    );
    
    if (kDebugMode) {
      print('✅ Enhanced Inventory Service connected to Universal Bridge');
      print('   📦 Core inventory management enabled');
      print('   🏭 Supplier tracking integrated');
      print('   📋 Purchase order management enabled');
    }
  }

  // 🌉 Bridge Event Handlers
  static Future<void> _handlePOSSaleEvent(Map<String, dynamic> saleData) async {
    // Automatically decrease inventory when POS sale happens
    final items = saleData['items'] as List;
    for (final item in items) {
      // TODO: Implement stock update functionality
      // await updateStock(item['product_id'], -item['quantity']);
      
      // Broadcast inventory update event
      await BridgeHelper.sendEvent(
        'inventory_updated',
        {
          'product_id': item['product_id'],
          'quantity_change': -item['quantity'],
          'store_id': saleData['store_id'],
        },
        fromModule: 'inventory_service',
      );
    }
  }

  static Future<void> _handleRestockEvent(Map<String, dynamic> restockData) async {
    // Handle restock requests
    if (kDebugMode) {
      print('📦 Restock requested for product: ${restockData['product_id']}');
    }

    // Trigger automatic purchase order creation
    await BridgeHelper.sendEvent(
      'inventory_low_stock',
      restockData,
      fromModule: 'inventory_service',
    );
  }

  // Enhanced low stock detection with automatic purchase order triggering
  static Future<void> checkLowStockAndTriggerReorders() async {
    try {
      final lowStockProducts = await getLowStockProducts();
      
      if (kDebugMode) {
        print('🔍 Checking ${lowStockProducts.length} low stock products for reorders');
      }

      for (final product in lowStockProducts) {
        // Send low stock event to trigger purchase order creation
        await BridgeHelper.sendEvent(
          'inventory_low_stock',
          {
            'product_id': product.productId,
            'current_quantity': product.quantityAvailable,
            'minimum_quantity': product.reorderPoint,
            'reorder_level': product.reorderPoint,
            'product_name': product.productName ?? 'Unknown Product',
            'sku': product.sku ?? product.productId, // Using SKU or productId as fallback
          },
          fromModule: 'inventory_service',
        );

        if (kDebugMode) {
          print('📤 Low stock alert sent for: ${product.productName ?? 'Unknown Product'}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking low stock: $e');
      }
    }
  }

  // Process purchase order delivery and update inventory
  static Future<void> processPurchaseOrderDelivery(Map<String, dynamic> deliveryData) async {
    try {
      final productId = deliveryData['product_id'];
      final quantityReceived = deliveryData['quantity_received'];
      final poId = deliveryData['po_id'];

      if (kDebugMode) {
        print('📦 Processing delivery for PO: $poId');
        print('  • Product: $productId');
        print('  • Quantity: $quantityReceived');
      }

      // Get current inventory
      final inventory = await getInventoryByProductId(productId);
      if (inventory != null) {
        // Update inventory with received stock
        final newQuantity = inventory.quantityAvailable + quantityReceived;
        
        final updatedInventory = inventory.copyWith(
          quantityAvailable: newQuantity,
          lastUpdated: Timestamp.now(),
        );

        await updateInventory(inventory.inventoryId, updatedInventory);

        // Log the movement
        final movement = InventoryMovementLog(
          movementId: 'mov_${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          fromLocation: 'supplier',
          toLocation: 'warehouse',
          quantity: quantityReceived,
          movementType: 'PURCHASE_DELIVERY',
          initiatedBy: 'purchase_order_system',
          timestamp: Timestamp.now(),
        );

        await logMovement(movement);

        // Notify other modules
        await BridgeHelper.sendEvent(
          'inventory_restocked',
          {
            'product_id': productId,
            'quantity_added': quantityReceived,
            'new_total_quantity': newQuantity,
            'po_id': poId,
          },
          fromModule: 'inventory_service',
        );

        if (kDebugMode) {
          print('✅ Inventory updated successfully');
          print('  • Previous stock: ${inventory.quantityAvailable}');
          print('  • New stock: $newQuantity');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing delivery: $e');
      }
      rethrow;
    }
  }

  // 🌉 Bridge Helper Methods - Any module can call these through the bridge
  static Future<List<Map<String, dynamic>>> getInventoryByStore(String storeId) async {
    final snapshot = await _firestore
        .collection(_inventoryCollection)
        .where('store_id', isEqualTo: storeId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<List<Map<String, dynamic>>> getAllInventory() async {
    final snapshot = await _firestore.collection(_inventoryCollection).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<List<Map<String, dynamic>>> getLowStockItems() async {
    // This would need to be implemented based on your business logic
    // For now, return empty list
    return [];
  }

  // 🏭 Supplier-specific inventory methods
  static Future<List<Map<String, dynamic>>> getInventoryBySupplier(String supplierId) async {
    try {
      final snapshot = await _firestore
          .collection(_inventoryCollection)
          .where('supplier_id', isEqualTo: supplierId)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting inventory by supplier: $e');
      }
      return [];
    }
  }

  // 📋 Purchase order-specific inventory methods
  static Future<List<Map<String, dynamic>>> getInventoryByPurchaseOrder(String purchaseOrderId) async {
    try {
      final snapshot = await _firestore
          .collection(_inventoryCollection)
          .where('purchase_order_id', isEqualTo: purchaseOrderId)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting inventory by purchase order: $e');
      }
      return [];
    }
  }

  // 🚚 Handle supplier delivery events
  static Future<void> _handleSupplierDelivery(Map<String, dynamic> deliveryData) async {
    try {
      if (kDebugMode) {
        print('📦 Processing supplier delivery');
        print('   Supplier: ${deliveryData['supplier_id']}');
        print('   Products: ${deliveryData['products']}');
      }

      final products = deliveryData['products'] as List;
      for (final product in products) {
        final productId = product['product_id'];
        final quantityDelivered = product['quantity'];
        final supplierId = deliveryData['supplier_id'];

        // Update inventory
        final inventory = await getInventoryByProductId(productId);
        if (inventory != null) {
          final newQuantity = inventory.quantityAvailable + quantityDelivered;
          
          final updatedInventory = inventory.copyWith(
            quantityAvailable: newQuantity,
            supplierId: supplierId,
            lastUpdated: Timestamp.now(),
          );

          await updateInventory(inventory.inventoryId, updatedInventory);

          // Broadcast supplier delivery event
          await BridgeHelper.sendEvent(
            'supplier_delivery_processed',
            {
              'product_id': productId,
              'supplier_id': supplierId,
              'quantity_delivered': quantityDelivered,
              'new_stock_level': newQuantity,
            },
            fromModule: 'inventory_service',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing supplier delivery: $e');
      }
    }
  }
}
