// 📦 ORDER PROVIDER
// Order management and tracking

import 'package:flutter/foundation.dart';
import 'package:shared_erp_package/shared_erp_package.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  String? _customerId;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Order> get recentOrders => _orders.take(5).toList();
  List<Order> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<Order> get completedOrders => _orders.where((o) => o.status == OrderStatus.delivered).toList();

  // Initialize for customer
  void initializeOrders(String customerId) {
    _customerId = customerId;
    loadOrders();
  }

  // Load orders for customer
  Future<void> loadOrders() async {
    if (_customerId == null) return;

    _setLoading(true);
    try {
      final firestoreService = FirestoreService();
      final ordersData = await firestoreService.getDocuments(
        'orders',
        where: {'customerId': _customerId},
        orderBy: 'createdAt',
        descending: true,
      );

      _orders = ordersData.map((data) => Order.fromMap(data)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load orders: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load recent orders for customer
  Future<void> loadRecentOrders(String customerId) async {
    try {
      final firestoreService = FirestoreService();
      final ordersData = await firestoreService.getDocuments(
        'orders',
        where: {'customerId': customerId},
        orderBy: 'createdAt',
        descending: true,
        limit: 10,
      );
      
      _orders = ordersData
          .map((data) => Order.fromMap(data))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to load recent orders: $e');
    }
  }

  // Load customer orders
  Future<void> loadCustomerOrders(String customerId) async {
    try {
      final firestoreService = FirestoreService();
      final ordersData = await firestoreService.getDocuments(
        'orders',
        where: {'customerId': customerId},
        orderBy: 'createdAt',
        descending: true,
      );
      
      _orders = ordersData
          .map((data) => Order.fromMap(data))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to load customer orders: $e');
    }
  }

  // Place a new order
  Future<void> placeOrder(Order order) async {
    try {
      final firestoreService = FirestoreService();
      await firestoreService.addDocument('orders', order.toMap());
      
      _orders.insert(0, order);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to place order: $e');
      rethrow;
    }
  }

  // Get order by ID
  Future<void> loadOrderById(String orderId) async {
    _setLoading(true);
    try {
      final firestoreService = FirestoreService();
      final orderData = await firestoreService.getDocument('orders', orderId);
      
      if (orderData != null) {
        _selectedOrder = Order.fromMap(orderData);
        _error = null;
      } else {
        _error = 'Order not found';
      }
    } catch (e) {
      _error = 'Failed to load order: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    _setLoading(true);
    try {
      final firestoreService = FirestoreService();
      await firestoreService.updateDocument(
        'orders',
        orderId,
        {
          'status': 'cancelled',
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // Update local order
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex >= 0) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder!.copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to cancel order: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Reorder items
  Future<void> reorder(String orderId) async {
    final order = _orders.firstWhere((o) => o.id == orderId);
    
    // This would typically add items back to cart
    // Implementation depends on cart provider integration
    print('Reordering items from order: $orderId');
    print('Items: ${order.items.map((i) => i.productName).join(', ')}');
  }

  // Track order
  Future<List<OrderTrackingEvent>> getOrderTracking(String orderId) async {
    try {
      _setLoading(true);
      
      // Simulate tracking data
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        OrderTrackingEvent(
          status: 'Order Placed',
          description: 'Your order has been successfully placed',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          status: 'Processing',
          description: 'Your order is being prepared',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          status: 'Shipped',
          description: 'Your order has been shipped',
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          status: 'Out for Delivery',
          description: 'Your order is out for delivery',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isCompleted: false,
        ),
        OrderTrackingEvent(
          status: 'Delivered',
          description: 'Your order has been delivered',
          timestamp: null,
          isCompleted: false,
        ),
      ];
    } catch (e) {
      _error = 'Failed to load tracking: $e';
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// Order tracking event model
class OrderTrackingEvent {
  final String status;
  final String description;
  final DateTime? timestamp;
  final bool isCompleted;

  OrderTrackingEvent({
    required this.status,
    required this.description,
    this.timestamp,
    required this.isCompleted,
  });
}
