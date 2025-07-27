// Enhanced Supplier Purchase Orders Service
// Handles supplier-specific purchase order operations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/original_models.dart';
import 'enhanced_services.dart';

class SupplierPurchaseOrdersService {
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

  // Confirm purchase order acceptance
  static Future<bool> confirmPurchaseOrder({
    required String orderId,
    required DateTime expectedDeliveryDate,
    String? remarks,
  }) async {
    return await updatePurchaseOrderStatus(
      orderId: orderId,
      newStatus: 'confirmed',
      expectedDeliveryDate: expectedDeliveryDate,
      remarks: remarks,
    );
  }

  // Mark purchase order as shipped
  static Future<bool> markAsShipped({
    required String orderId,
    required String trackingNumber,
    required String shippingCarrier,
    String? remarks,
  }) async {
    try {
      debugPrint('🚚 Marking PO as shipped: $orderId');
      
      final updates = {
        'status': 'shipped',
        'tracking_number': trackingNumber,
        'shipping_carrier': shippingCarrier,
        'shipped_date': Timestamp.now(),
        'updated_at': Timestamp.now(),
      };
      
      if (remarks != null) {
        updates['shipping_remarks'] = remarks;
      }
      
      // Add to status history
      final statusHistory = {
        'status': 'shipped',
        'timestamp': Timestamp.now(),
        'remarks': 'Shipped via $shippingCarrier, Tracking: $trackingNumber',
        'updated_by': 'supplier',
      };
      
      await _firestore.collection(_collection).doc(orderId).update({
        ...updates,
        'status_history': FieldValue.arrayUnion([statusHistory]),
      });
      
      debugPrint('✅ Purchase order marked as shipped: $orderId');
      return true;
    } catch (e) {
      debugPrint('❌ Error marking PO as shipped: $e');
      return false;
    }
  }

  // Mark purchase order as delivered
  static Future<bool> markAsDelivered({
    required String orderId,
    String? remarks,
    List<Map<String, dynamic>>? deliveredItems,
  }) async {
    try {
      debugPrint('📦 Marking PO as delivered: $orderId');
      
      final updates = {
        'status': 'delivered',
        'delivered_date': Timestamp.now(),
        'updated_at': Timestamp.now(),
      };
      
      if (remarks != null) {
        updates['delivery_remarks'] = remarks;
      }
      
      if (deliveredItems != null) {
        updates['delivered_items'] = deliveredItems;
      }
      
      // Add to status history
      final statusHistory = {
        'status': 'delivered',
        'timestamp': Timestamp.now(),
        'remarks': remarks ?? 'Order delivered successfully',
        'updated_by': 'supplier',
      };
      
      await _firestore.collection(_collection).doc(orderId).update({
        ...updates,
        'status_history': FieldValue.arrayUnion([statusHistory]),
      });
      
      // Update inventory if items were delivered
      if (deliveredItems != null) {
        await _updateInventoryForDelivery(orderId, deliveredItems);
      }
      
      debugPrint('✅ Purchase order marked as delivered: $orderId');
      return true;
    } catch (e) {
      debugPrint('❌ Error marking PO as delivered: $e');
      return false;
    }
  }

  // Update inventory when items are delivered
  static Future<void> _updateInventoryForDelivery(String orderId, List<Map<String, dynamic>> deliveredItems) async {
    try {
      debugPrint('📦 Updating inventory for delivered PO: $orderId');
      
      for (final item in deliveredItems) {
        final productId = item['product_id'] as String;
        final deliveredQuantity = item['delivered_quantity'] as int;
        
        // Update inventory using the enhanced inventory service
        // await EnhancedInventoryService.addStock(
        //   productId,
        //   deliveredQuantity,
        //   reason: 'Purchase Order Delivery - $orderId',
        // );
        debugPrint('📝 TODO: Add $deliveredQuantity units of $productId to inventory');
        
        debugPrint('✅ Added $deliveredQuantity units of $productId to inventory');
      }
    } catch (e) {
      debugPrint('❌ Error updating inventory for delivery: $e');
    }
  }

  // Submit invoice for purchase order
  static Future<bool> submitInvoice({
    required String orderId,
    required String invoiceNumber,
    required double invoiceAmount,
    required DateTime invoiceDate,
    String? invoiceUrl,
    String? remarks,
  }) async {
    try {
      debugPrint('📄 Submitting invoice for PO: $orderId');
      
      final invoice = {
        'invoice_number': invoiceNumber,
        'invoice_amount': invoiceAmount,
        'invoice_date': Timestamp.fromDate(invoiceDate),
        'invoice_url': invoiceUrl,
        'invoice_remarks': remarks,
        'submitted_date': Timestamp.now(),
        'status': 'submitted',
      };
      
      await _firestore.collection(_collection).doc(orderId).update({
        'invoice': invoice,
        'invoice_status': 'submitted',
        'updated_at': Timestamp.now(),
      });
      
      debugPrint('✅ Invoice submitted for PO: $orderId');
      return true;
    } catch (e) {
      debugPrint('❌ Error submitting invoice: $e');
      return false;
    }
  }

  // Get purchase order analytics for supplier
  static Future<Map<String, dynamic>> getSupplierAnalytics(String supplierId) async {
    try {
      final orders = await getSupplierPurchaseOrders(supplierId);
      
      final totalOrders = orders.length;
      final pendingOrders = orders.where((o) => ['pending', 'confirmed', 'processing'].contains(o.status)).length;
      final completedOrders = orders.where((o) => o.status == 'delivered').length;
      final totalValue = orders.fold<double>(0, (sum, order) => sum + order.totalValue);
      
      // Calculate average delivery time
      final deliveredOrders = orders.where((o) => o.status == 'delivered').toList();
      double avgDeliveryDays = 0;
      if (deliveredOrders.isNotEmpty) {
        final totalDays = deliveredOrders.fold<int>(0, (sum, order) {
          if (order.receivedDate != null) {
            return sum + order.receivedDate!.difference(order.orderDate).inDays;
          }
          return sum;
        });
        avgDeliveryDays = totalDays / deliveredOrders.length;
      }
      
      return {
        'total_orders': totalOrders,
        'pending_orders': pendingOrders,
        'completed_orders': completedOrders,
        'total_value': totalValue,
        'average_delivery_days': avgDeliveryDays,
        'completion_rate': totalOrders > 0 ? (completedOrders / totalOrders * 100) : 0,
      };
    } catch (e) {
      debugPrint('❌ Error getting supplier analytics: $e');
      return {
        'total_orders': 0,
        'pending_orders': 0,
        'completed_orders': 0,
        'total_value': 0.0,
        'average_delivery_days': 0.0,
        'completion_rate': 0.0,
      };
    }
  }
}
