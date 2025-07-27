import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/purchase_order.dart';
import '../core/bridge/bridge_helper.dart';
import 'inventory_service.dart';
import 'supplier_service.dart';

class PurchaseOrderService {
  final CollectionReference poCollection =
      FirebaseFirestore.instance.collection('purchase_orders');

  Future<List<PurchaseOrder>> fetchPurchaseOrders() async {
    final snapshot = await poCollection.get();
    return snapshot.docs.map((doc) => PurchaseOrder.fromFirestore(doc)).toList();
  }

  Future<void> createPurchaseOrder(PurchaseOrder po) async {
    await poCollection.add(po.toMap());
  }

  Future<void> updatePurchaseOrder(String id, Map<String, dynamic> data) async {
    await poCollection.doc(id).update(data);
  }

  Future<void> deletePurchaseOrder(String id) async {
    await poCollection.doc(id).delete();
  }

  // 🌉 Bridge Integration - Initialize purchase order module
  static Future<void> initializeBridgeConnection() async {
    await BridgeHelper.connectModule(
      moduleName: 'purchase_order_service',
      capabilities: ['create_po', 'get_pos', 'update_po_status', 'auto_reorder'],
      schema: {
        'purchase_orders': {
          'fields': ['po_id', 'supplier_id', 'product_id', 'quantity', 'status'],
          'filters': ['supplier_id', 'status', 'product_id'],
        },
      },
      dataProvider: (dataType, filters) async {
        switch (dataType) {
          case 'purchase_orders':
            return await getAllPurchaseOrders(filters);
          default:
            return [];
        }
      },
      eventHandler: (event) async {
        switch (event.type) {
          case 'inventory_low_stock':
            await _handleLowStockEvent(event.data);
            break;
          case 'restock_required':
            await _handleRestockRequired(event.data);
            break;
        }
      },
    );
    
    if (kDebugMode) {
      print('✅ Purchase Order Service connected to Universal Bridge');
    }
  }

  // 🔔 Auto-create purchase order for low stock items
  static Future<void> _handleLowStockEvent(Map<String, dynamic> stockData) async {
    try {
      final productId = stockData['product_id'];
      final currentStock = stockData['current_quantity'] ?? 0;
      final minStock = stockData['minimum_quantity'] ?? 10;
      
      if (kDebugMode) {
        print('📋 Auto-creating purchase order for low stock product: $productId');
        print('  • Current stock: $currentStock');
        print('  • Minimum stock: $minStock');
      }

      // Calculate reorder quantity (double the minimum + buffer)
      final reorderQuantity = (minStock * 2) + 20;

      // Get best supplier for this product
      final supplier = await _getBestSupplierForProduct(productId);
      
      if (supplier != null) {
        final purchaseOrder = PurchaseOrder(
          poId: 'PO_${DateTime.now().millisecondsSinceEpoch}',
          poNumber: 'PO-${DateTime.now().millisecondsSinceEpoch}',
          supplierId: supplier['id'],
          storeId: 'STORE_001', // Default store
          orderDate: DateTime.now(),
          expectedDelivery: DateTime.now().add(const Duration(days: 7)),
          status: 'pending',
          totalItems: 1,
          totalValue: 0, // Calculate based on supplier pricing
          createdBy: 'auto_system',
          lineItems: [], // Will be populated with actual POItem objects
          deliveryStatus: 'pending',
          documentsAttached: [],
          billingAddress: 'Default Billing Address',
          shippingAddress: 'Default Shipping Address',
          remarks: 'Auto-generated for low stock alert',
        );

        // Create the purchase order
        await _createAutoPurchaseOrder(purchaseOrder);

        // Notify other modules
        await BridgeHelper.sendEvent(
          'purchase_order_created',
          {
            'po_id': purchaseOrder.poId,
            'product_id': productId,
            'supplier_id': supplier['id'],
            'quantity': reorderQuantity,
            'auto_generated': true,
          },
          fromModule: 'purchase_order_service',
        );

        if (kDebugMode) {
          print('✅ Purchase order created: ${purchaseOrder.poId}');
          print('  • Supplier: ${supplier['name']}');
          print('  • Quantity: $reorderQuantity');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ No supplier found for product: $productId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating auto purchase order: $e');
      }
    }
  }

  // Handle explicit restock requests
  static Future<void> _handleRestockRequired(Map<String, dynamic> restockData) async {
    await _handleLowStockEvent(restockData);
  }

  // Get best supplier for a product based on performance metrics
  static Future<Map<String, dynamic>?> _getBestSupplierForProduct(String productId) async {
    try {
      // Get all suppliers that can supply this product
      final suppliersData = await SupplierService.getAllSuppliers();
      final suppliers = suppliersData['suppliers'] as List;

      if (suppliers.isEmpty) return null;

      // For now, return first supplier (can be enhanced with scoring algorithm)
      // TODO: Implement supplier scoring based on:
      // - Delivery time
      // - Price
      // - Quality rating
      // - Past performance
      
      return suppliers.first;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting supplier for product $productId: $e');
      }
      return null;
    }
  }

  // Create auto-generated purchase order
  static Future<void> _createAutoPurchaseOrder(PurchaseOrder purchaseOrder) async {
    try {
      final poService = PurchaseOrderService();
      await poService.createPurchaseOrder(purchaseOrder);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating auto purchase order: $e');
      }
      rethrow;
    }
  }

  // Get all purchase orders with filters
  static Future<List<Map<String, dynamic>>> getAllPurchaseOrders(Map<String, dynamic>? filters) async {
    try {
      final poService = PurchaseOrderService();
      final orders = await poService.fetchPurchaseOrders();
      return orders.map((po) => po.toMap()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching purchase orders: $e');
      }
      return [];
    }
  }
}
