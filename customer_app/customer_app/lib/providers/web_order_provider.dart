// 📦 WEB-ONLY ORDER PROVIDER
// Order management for web builds using local models

import 'package:flutter/foundation.dart';
import '../models/web_models.dart';

class WebOrderProvider extends ChangeNotifier {
  List<WebOrder> _orders = [];
  WebOrder? _currentOrder;
  bool _isLoading = false;
  String? _error;
  String _filter = 'all'; // all, pending, processing, shipped, delivered

  // Getters
  List<WebOrder> get orders => _getFilteredOrders();
  List<WebOrder> get allOrders => _orders;
  WebOrder? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  List<WebOrder> get pendingOrders => _orders.where((o) => o.status == 'pending').toList();
  List<WebOrder> get processingOrders => _orders.where((o) => o.status == 'processing').toList();
  List<WebOrder> get shippedOrders => _orders.where((o) => o.status == 'shipped' || o.status == 'in_transit').toList();
  List<WebOrder> get deliveredOrders => _orders.where((o) => o.status == 'delivered').toList();

  // Initialize orders
  Future<void> initialize() async {
    await loadOrders();
  }

  // Load orders
  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      // For web demo, create sample orders
      _orders = _getSampleOrders();
      _clearError();
    } catch (e) {
      _setError('Failed to load orders: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new order
  Future<WebOrder?> createOrder({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required List<WebCartItem> cartItems,
    required String paymentMethod,
    String? shippingAddress,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      // Convert cart items to order items
      final orderItems = cartItems.map((cartItem) => WebOrderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: cartItem.productId,
        productName: cartItem.productName,
        productImage: cartItem.productImage,
        price: cartItem.price,
        quantity: cartItem.quantity,
        totalPrice: cartItem.totalPrice,
        selectedVariants: cartItem.selectedVariants,
      )).toList();

      final totalAmount = orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      final tax = totalAmount * 0.1; // 10% tax
      final shipping = totalAmount > 500 ? 0.0 : 50.0; // Free shipping over ₹500
      final finalAmount = totalAmount + tax + shipping;

      final order = WebOrder(
        id: 'order-${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        items: orderItems,
        subtotal: totalAmount,
        tax: tax,
        shipping: shipping,
        totalAmount: finalAmount,
        status: 'pending',
        paymentStatus: 'pending',
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        notes: notes,
        orderDate: DateTime.now(),
        expectedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
      );

      _orders.insert(0, order); // Add to beginning of list
      _currentOrder = order;
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      _clearError();
      notifyListeners();
      return order;
    } catch (e) {
      _setError('Failed to create order: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex >= 0) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(status: newStatus);
        
        // Update delivery date if delivered
        if (newStatus == 'delivered') {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            deliveryDate: DateTime.now(),
          );
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update order status: $e');
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex >= 0) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(paymentStatus: paymentStatus);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update payment status: $e');
    }
  }

  // Get order by ID
  WebOrder? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Get orders by customer
  List<WebOrder> getOrdersByCustomer(String customerId) {
    return _orders.where((order) => order.customerId == customerId).toList();
  }

  // Set current order
  void setCurrentOrder(WebOrder? order) {
    _currentOrder = order;
    notifyListeners();
  }

  // Set filter
  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  // Cancel order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex >= 0) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: 'cancelled',
          notes: '${_orders[orderIndex].notes ?? ''}\nCancelled: $reason',
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to cancel order: $e');
    }
  }

  // Track order
  Map<String, dynamic> trackOrder(String orderId) {
    final order = getOrderById(orderId);
    if (order == null) return {};

    return {
      'order_id': order.id,
      'status': order.status,
      'payment_status': order.paymentStatus,
      'order_date': order.orderDate,
      'expected_delivery': order.expectedDeliveryDate,
      'delivery_date': order.deliveryDate,
      'tracking_updates': _getTrackingUpdates(order),
    };
  }

  // Get tracking updates
  List<Map<String, dynamic>> _getTrackingUpdates(WebOrder order) {
    List<Map<String, dynamic>> updates = [
      {
        'status': 'Order Placed',
        'date': order.orderDate,
        'completed': true,
      },
    ];

    if (order.status == 'processing' || order.status == 'shipped' || 
        order.status == 'in_transit' || order.status == 'delivered') {
      updates.add({
        'status': 'Order Confirmed',
        'date': order.orderDate?.add(const Duration(hours: 2)),
        'completed': true,
      });
    }

    if (order.status == 'shipped' || order.status == 'in_transit' || order.status == 'delivered') {
      updates.add({
        'status': 'Order Shipped',
        'date': order.orderDate?.add(const Duration(days: 1)),
        'completed': true,
      });
    }

    if (order.status == 'in_transit' || order.status == 'delivered') {
      updates.add({
        'status': 'In Transit',
        'date': order.orderDate?.add(const Duration(days: 3)),
        'completed': true,
      });
    }

    if (order.status == 'delivered') {
      updates.add({
        'status': 'Delivered',
        'date': order.deliveryDate,
        'completed': true,
      });
    } else {
      updates.add({
        'status': 'Out for Delivery',
        'date': order.expectedDeliveryDate,
        'completed': false,
      });
    }

    return updates;
  }

  // Get filtered orders
  List<WebOrder> _getFilteredOrders() {
    switch (_filter) {
      case 'pending':
        return pendingOrders;
      case 'processing':
        return processingOrders;
      case 'shipped':
        return shippedOrders;
      case 'delivered':
        return deliveredOrders;
      default:
        return _orders;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get order stats
  Map<String, dynamic> getOrderStats() {
    return {
      'total_orders': _orders.length,
      'pending_orders': pendingOrders.length,
      'processing_orders': processingOrders.length,
      'shipped_orders': shippedOrders.length,
      'delivered_orders': deliveredOrders.length,
      'total_revenue': _orders.fold(0.0, (sum, order) => sum + order.totalAmount),
    };
  }

  // Sample data for web demo
  List<WebOrder> _getSampleOrders() {
    return [
      WebOrder(
        id: 'order-demo-1',
        customerId: 'demo-customer-1',
        customerName: 'Demo User',
        customerEmail: 'demo@example.com',
        customerPhone: '+91 9876543210',
        items: [],
        subtotal: 40000.0,
        tax: 4000.0,
        shipping: 0.0,
        totalAmount: 44000.0,
        status: 'delivered',
        paymentStatus: 'paid',
        paymentMethod: 'card',
        orderDate: DateTime.now().subtract(const Duration(days: 10)),
        deliveryDate: DateTime.now().subtract(const Duration(days: 5)),
        shippingAddress: '123 Demo Street, Demo City, Demo State 123456',
      ),
      WebOrder(
        id: 'order-demo-2',
        customerId: 'demo-customer-1',
        customerName: 'Demo User',
        customerEmail: 'demo@example.com',
        customerPhone: '+91 9876543210',
        items: [],
        subtotal: 25000.0,
        tax: 2500.0,
        shipping: 50.0,
        totalAmount: 27550.0,
        status: 'in_transit',
        paymentStatus: 'paid',
        paymentMethod: 'upi',
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        expectedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
        shippingAddress: '123 Demo Street, Demo City, Demo State 123456',
      ),
    ];
  }
}
