import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/models/unified_models.dart';

class CustomerOrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'customer_orders';

  // Get orders by status
  static Future<List<UnifiedCustomerOrder>> getOrdersByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .get();
      
      return snapshot.docs
          .map((doc) => UnifiedCustomerOrder.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting orders by status: $e');
      rethrow;
    }
  }

  // Create new customer order
  static Future<String> createOrder(CustomerOrder order) async {
    try {
      final docRef = await _firestore.collection(_collection).add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating customer order: $e');
      rethrow;
    }
  }

  // Update customer order
  static Future<void> updateOrder(String orderId, CustomerOrder order) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update(order.toFirestore());
    } catch (e) {
      debugPrint('Error updating customer order: $e');
      rethrow;
    }
  }

  // Get order by ID
  static Future<UnifiedCustomerOrder?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return UnifiedCustomerOrder.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting customer order: $e');
      return null;
    }
  }

  // Get orders by status
  static Future<List<CustomerOrder>> getByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .get();
      
      return snapshot.docs
          .map((doc) => CustomerOrder.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting orders by status: $e');
      return [];
    }
  }

  // Get orders by customer
  static Future<List<UnifiedCustomerOrder>> getOrdersByCustomer(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('customer_id', isEqualTo: customerId)
          .orderBy('order_date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => UnifiedCustomerOrder.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting orders by customer: $e');
      return [];
    }
  }

  // Stream orders for real-time updates
  static Stream<List<UnifiedCustomerOrder>> streamOrders() {
    return _firestore
        .collection(_collection)
        .orderBy('order_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnifiedCustomerOrder.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get orders by date range
  static Future<List<UnifiedCustomerOrder>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('order_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('order_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('order_date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => UnifiedCustomerOrder.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting orders by date range: $e');
      return [];
    }
  }

  // Delete order
  static Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).delete();
    } catch (e) {
      debugPrint('Error deleting customer order: $e');
      rethrow;
    }
  }

  // Update order status
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  // Get order analytics
  static Future<Map<String, dynamic>> getOrderAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final orders = await getOrdersByDateRange(startDate, endDate);
      
      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.totalValue);
      final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
      
      final statusCounts = <String, int>{};
      for (final order in orders) {
        statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
      }
      
      return {
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'average_order_value': averageOrderValue,
        'status_breakdown': statusCounts,
      };
    } catch (e) {
      debugPrint('Error getting order analytics: $e');
      return {};
    }
  }

  // Get all customer orders (for bridge integration)
  static Future<Map<String, dynamic>> getAllCustomerOrders() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final orders = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
      return {
        'orders': orders,
        'total_count': orders.length,
        'status': 'success'
      };
    } catch (e) {
      return {
        'orders': [],
        'total_count': 0,
        'status': 'error',
        'error': e.toString()
      };
    }
  }

  // Get order by ID (for bridge integration)
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      
      if (doc.exists) {
        return {
          'order': {'id': doc.id, ...doc.data()!},
          'status': 'success'
        };
      } else {
        return {
          'order': null,
          'status': 'not_found',
          'error': 'Order not found'
        };
      }
    } catch (e) {
      return {
        'order': null,
        'status': 'error',
        'error': e.toString()
      };
    }
  }

  // Update order (bridge integration version)
  static Future<void> updateOrderForBridge(Map<String, dynamic> data) async {
    try {
      final orderId = data['id'] ?? data['order_id'];
      if (orderId != null) {
        final updateData = Map<String, dynamic>.from(data);
        updateData.remove('id');
        updateData['updated_at'] = FieldValue.serverTimestamp();
        
        await _firestore.collection(_collection).doc(orderId).update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }
}
