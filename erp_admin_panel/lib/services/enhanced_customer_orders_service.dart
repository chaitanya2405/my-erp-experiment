// Enhanced Customer Orders Service with Auto POS Integration
// Orders placed here automatically trigger POS invoice generation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/original_models.dart';
import 'enhanced_services.dart';
import 'customer_auth_service.dart';

class EnhancedCustomerOrdersService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'customer_orders';

  // Generate unique order number
  static String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD${timestamp.toString().substring(8)}';
  }

  // Place order from customer app with auto POS integration
  static Future<Map<String, dynamic>?> placeCustomerOrder({
    required String customerId,
    required List<Map<String, dynamic>> items, // [{product_id, quantity, price}]
    required String paymentMode,
    required String deliveryMode,
    Map<String, dynamic>? deliveryAddress,
    String? deliverySlot,
    double discount = 0.0,
    double deliveryCharges = 0.0,
    String? remarks,
  }) async {
    try {
      debugPrint('🛒 Placing order for customer: $customerId');
      
      // 1. Validate customer exists using the correct service
      debugPrint('🔍 Looking up customer with ID: $customerId');
      final customer = await CustomerAuthService.getCustomerById(customerId);
      if (customer == null) {
        debugPrint('❌ Customer not found in CustomerAuthService: $customerId');
        // Try the other service as fallback
        final fallbackCustomer = await EnhancedCustomerService.getCustomerById(customerId);
        if (fallbackCustomer == null) {
          debugPrint('❌ Customer not found in EnhancedCustomerService either: $customerId');
          return {'success': false, 'error': 'Customer not found'};
        } else {
          debugPrint('✅ Customer found via fallback service: ${fallbackCustomer.customerName}');
        }
      } else {
        debugPrint('✅ Customer found: ${customer.customerName}');
      }

      // 2. Validate inventory availability
      for (final item in items) {
        final productId = item['product_id'] as String;
        final quantity = item['quantity'] as int;
        
        final hasStock = await EnhancedInventoryService.checkStockAvailability(productId, quantity);
        if (!hasStock) {
          final product = await EnhancedProductService.getProductById(productId);
          return {
            'success': false, 
            'error': 'Insufficient stock for ${product?.productName ?? productId}'
          };
        }
      }

      // 3. Calculate totals
      double subtotal = 0.0;
      double taxAmount = 0.0;
      final processedItems = <Map<String, dynamic>>[];

      for (final item in items) {
        final productId = item['product_id'] as String;
        final quantity = item['quantity'] as int;
        final product = await EnhancedProductService.getProductById(productId);
        
        if (product == null) {
          return {'success': false, 'error': 'Product not found: $productId'};
        }

        final itemPrice = product.sellingPrice;
        final itemTotal = itemPrice * quantity;
        final itemTax = itemTotal * (product.taxPercent / 100);
        
        subtotal += itemTotal;
        taxAmount += itemTax;

        processedItems.add({
          'product_id': productId,
          'product_name': product.productName,
          'quantity': quantity,
          'price': itemPrice,
          'total': itemTotal,
          'tax': itemTax,
          'unit': product.unit,
        });
      }

      final grandTotal = subtotal + taxAmount + deliveryCharges - discount;

      // 4. Create customer order
      final orderNumber = _generateOrderNumber();
      final now = Timestamp.now();

      final customerOrder = CustomerOrder(
        orderId: '', // Will be set by Firestore
        orderNumber: orderNumber,
        customerId: customerId,
        storeId: 'default_store',
        orderDate: now,
        orderStatus: 'confirmed', // Start as confirmed for customer orders
        paymentStatus: paymentMode == 'COD' ? 'pending' : 'paid',
        paymentMode: paymentMode,
        deliveryMode: deliveryMode,
        deliveryAddress: deliveryAddress,
        productsOrdered: processedItems,
        totalAmount: subtotal,
        discount: discount,
        taxAmount: taxAmount,
        deliveryCharges: deliveryCharges,
        grandTotal: grandTotal,
        subscriptionFlag: false,
        subscriptionPlan: null,
        walletUsed: 0.0,
        deliverySlot: deliverySlot,
        deliveryPersonId: null,
        invoiceId: null, // Will be set after POS invoice creation
        remarks: remarks,
        createdAt: now,
        updatedAt: now,
      );

      // 5. Save customer order
      final orderDocRef = await _firestore.collection(_collection).add(customerOrder.toMap());
      final orderId = orderDocRef.id;

      // 6. Reserve inventory for the order
      for (final item in processedItems) {
        await EnhancedInventoryService.reserveStock(
          item['product_id'] as String,
          item['quantity'] as int,
        );
      }

      // 7. AUTO-TRIGGER POS INVOICE GENERATION
      final posResult = await _createPosInvoiceFromOrder(customerOrder.copyWith(orderId: orderId), processedItems);
      
      if (posResult['success']) {
        // Update order with invoice ID
        await _firestore.collection(_collection).doc(orderId).update({
          'invoice_id': posResult['transactionId'],
          'payment_status': 'paid', // Mark as paid since invoice is generated
          'updated_at': Timestamp.now(),
        });

        // Add loyalty points for the customer
        final loyaltyPoints = (grandTotal * 0.01).round(); // 1% as loyalty points
        await CustomerAuthService.addLoyaltyPoints(
          customerId, 
          loyaltyPoints, 
          'Order placed - $orderNumber'
        );

        debugPrint('✅ Customer order placed successfully: $orderNumber');
        debugPrint('✅ POS invoice auto-generated: ${posResult['transactionId']}');
        
        return {
          'success': true,
          'orderId': orderId,
          'orderNumber': orderNumber,
          'invoiceId': posResult['transactionId'],
          'totalAmount': grandTotal,
          'loyaltyPointsEarned': loyaltyPoints,
        };
      } else {
        // If POS invoice creation failed, we should handle this gracefully
        debugPrint('⚠️ Order created but POS invoice failed: ${posResult['error']}');
        return {
          'success': true,
          'orderId': orderId,
          'orderNumber': orderNumber,
          'invoiceId': null,
          'totalAmount': grandTotal,
          'warning': 'Order created but invoice generation failed',
        };
      }

    } catch (e) {
      debugPrint('❌ Error placing customer order: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Helper: Create POS invoice from customer order
  static Future<Map<String, dynamic>> _createPosInvoiceFromOrder(
    CustomerOrder order, 
    List<Map<String, dynamic>> processedItems
  ) async {
    try {
      final transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create POS transaction
      final posTransaction = PosTransaction(
        transactionId: transactionId,
        storeId: order.storeId,
        customerId: order.customerId,
        cashierId: 'system_auto', // Auto-generated from customer order
        transactionDate: order.orderDate,
        items: processedItems,
        subtotal: order.totalAmount,
        discountAmount: order.discount,
        taxAmount: order.taxAmount,
        totalAmount: order.grandTotal,
        paymentMethod: order.paymentMode,
        transactionStatus: 'completed',
        receiptNumber: transactionId,
        customerInfo: {
          'order_number': order.orderNumber,
          'delivery_mode': order.deliveryMode,
          'delivery_slot': order.deliverySlot,
        },
        notes: 'Auto-generated from customer order: ${order.orderNumber}',
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      );

      // Use enhanced POS service to create transaction (this will handle inventory updates)
      final result = await EnhancedPosService.addTransactionFromOrder(posTransaction);
      
      if (result != null) {
        return {'success': true, 'transactionId': result};
      } else {
        return {'success': false, 'error': 'Failed to create POS transaction'};
      }

    } catch (e) {
      debugPrint('Error creating POS invoice from order: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get customer orders by customer ID
  static Future<List<CustomerOrder>> getOrdersByCustomerId(String customerId) async {
    try {
      debugPrint('🔍 Getting orders for customer: $customerId');
      
      // Simple query without orderBy to avoid composite index requirement
      final snapshot = await _firestore
          .collection(_collection)
          .where('customer_id', isEqualTo: customerId)
          .get();
      
      // Convert to CustomerOrder objects
      final orders = snapshot.docs
          .map((doc) => CustomerOrder.fromFirestore(doc))
          .toList();
      
      // Sort in memory by order date (newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      debugPrint('✅ Found ${orders.length} orders for customer $customerId');
      return orders;
    } catch (e) {
      debugPrint('❌ Error getting customer orders: $e');
      
      // If the above query still fails, try even simpler query
      try {
        debugPrint('🔄 Trying simplified query...');
        final snapshot = await _firestore
            .collection(_collection)
            .limit(50) // Get recent orders
            .get();
        
        // Filter in memory for this customer
        final orders = snapshot.docs
            .map((doc) => CustomerOrder.fromFirestore(doc))
            .where((order) => order.customerId == customerId)
            .toList();
        
        // Sort by date
        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        
        debugPrint('✅ Fallback query found ${orders.length} orders');
        return orders;
      } catch (fallbackError) {
        debugPrint('❌ Fallback query also failed: $fallbackError');
        return [];
      }
    }
  }

  // Update order status (for delivery tracking)
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'order_status': status,
        'updated_at': Timestamp.now(),
      });

      // If order is completed, release reserved stock and reduce actual stock
      if (status == 'completed') {
        final order = await getOrderById(orderId);
        if (order != null) {
          for (final item in order.productsOrdered) {
            final productId = item['product_id'] as String;
            final quantity = item['quantity'] as int;
            
            // Release reserved stock and reduce actual stock
            await EnhancedInventoryService.releaseReservedStock(productId, quantity);
            // Note: Actual stock reduction is handled by POS transaction
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
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
      debugPrint('Error getting order by ID: $e');
      return null;
    }
  }

  // Cancel order
  static Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return false;

      // Release reserved inventory
      for (final item in order.productsOrdered) {
        await EnhancedInventoryService.releaseReservedStock(
          item['product_id'] as String,
          item['quantity'] as int,
        );
      }

      // Update order status
      await _firestore.collection(_collection).doc(orderId).update({
        'order_status': 'cancelled',
        'remarks': '${order.remarks ?? ''}\nCancelled: $reason',
        'updated_at': Timestamp.now(),
      });

      return true;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }
}
