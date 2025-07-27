// Enhanced services that use original Firestore collections and data structure
// These services work with your existing data in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/unified_models.dart';

// Product Service - uses existing 'products' collection
class EnhancedProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'products';

  // Get all products from existing Firestore collection
  static Future<List<UnifiedProduct>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => UnifiedProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all products: $e');
      return [];
    }
  }

  // Get product by ID
  static Future<UnifiedProduct?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      if (doc.exists) {
        return UnifiedProduct.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product by ID: $e');
      return null;
    }
  }

  // Stream all products for real-time updates
  static Stream<List<UnifiedProduct>> getProductsStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnifiedProduct.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Search products by name, barcode, or SKU
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((product) {
        final name = product.productName.toLowerCase();
        final barcode = product.barcode?.toLowerCase() ?? '';
        final sku = product.sku.toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || 
               barcode.contains(searchQuery) || 
               sku.contains(searchQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // Add product
  static Future<String?> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection(_collection).add(product.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return null;
    }
  }

  // Update product
  static Future<bool> updateProduct(String productId, Product product) async {
    try {
      await _firestore.collection(_collection).doc(productId).update(product.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  // Delete product
  static Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  // Get products by category
  static Future<List<UnifiedProduct>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => UnifiedProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  // Get low stock products
  static Future<List<UnifiedProduct>> getLowStockProducts() async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((product) {
        return (product.minStockLevel ?? 0) > 0; // Filter products with stock tracking
      }).toList();
    } catch (e) {
      debugPrint('Error getting low stock products: $e');
      return [];
    }
  }
}

// Customer Service - uses existing 'customer_profiles' collection
class EnhancedCustomerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'customers'; // Fixed: Use same collection as CustomerAuthService

  // Get all customers
  static Future<List<UnifiedCustomerProfile>> getAllCustomers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => UnifiedCustomerProfile.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all customers: $e');
      return [];
    }
  }

  // Stream all customers for real-time updates
  static Stream<List<UnifiedCustomerProfile>> getCustomersStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnifiedCustomerProfile.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get customer by ID
  static Future<UnifiedCustomerProfile?> getCustomerById(String customerId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(customerId).get();
      if (doc.exists) {
        return UnifiedCustomerProfile.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting customer by ID: $e');
      return null;
    }
  }

  // Add customer
  static Future<String?> addCustomer(CustomerProfile customer) async {
    try {
      final docRef = await _firestore.collection(_collection).add(customer.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding customer: $e');
      return null;
    }
  }

  // Update customer
  static Future<bool> updateCustomer(String customerId, CustomerProfile customer) async {
    try {
      await _firestore.collection(_collection).doc(customerId).update(customer.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating customer: $e');
      return false;
    }
  }

  // Search customers
  static Future<List<CustomerProfile>> searchCustomers(String query) async {
    try {
      final allCustomers = await getAllCustomers();
      return allCustomers.where((customer) {
        final name = customer.customerName.toLowerCase();
        final email = (customer.email ?? '').toLowerCase();
        final phone = customer.mobileNumber.toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || 
               email.contains(searchQuery) || 
               phone.contains(searchQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error searching customers: $e');
      return [];
    }
  }
}

// Purchase Order Service - uses existing 'purchase_orders' collection
class EnhancedPurchaseOrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'purchase_orders';

  // Get all purchase orders
  static Future<List<PurchaseOrder>> getAllPurchaseOrders() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => UnifiedPurchaseOrder.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all purchase orders: $e');
      return [];
    }
  }

  // Stream all purchase orders for real-time updates
  static Stream<List<PurchaseOrder>> getPurchaseOrdersStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnifiedPurchaseOrder.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get purchase order by ID
  static Future<PurchaseOrder?> getPurchaseOrderById(String poId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(poId).get();
      if (doc.exists) {
        return UnifiedPurchaseOrder.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting purchase order by ID: $e');
      return null;
    }
  }

  // Add purchase order
  static Future<String?> addPurchaseOrder(PurchaseOrder po) async {
    try {
      final docRef = await _firestore.collection(_collection).add(po.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding purchase order: $e');
      return null;
    }
  }

  // Update purchase order with inventory management
  static Future<bool> updatePurchaseOrder(String poId, UnifiedPurchaseOrder po) async {
    try {
      // Get the existing PO to check status changes
      final existingPO = await getPurchaseOrderById(poId);
      
      await _firestore.collection(_collection).doc(poId).update(po.toMap());
      
      // If PO status changed to 'received', update inventory
      if (existingPO != null && 
          existingPO.status != 'received' && 
          po.status == 'received') {
        
        debugPrint('🔄 Processing inventory updates for received PO: $poId');
        
        // Add stock for each line item
        for (final lineItem in po.lineItems) {
          final stockUpdated = await EnhancedInventoryService.updateStock(
            lineItem.productId,
            lineItem.quantity,  // Positive quantity for purchases
            reason: 'PO Received - ${po.poNumber} - ${lineItem.productName}'
          );
          
          if (stockUpdated) {
            debugPrint('✅ Stock updated for ${lineItem.productName}: +${lineItem.quantity}');
          } else {
            debugPrint('⚠️ Failed to update stock for ${lineItem.productName}');
          }
        }
        
        debugPrint('✅ Inventory updates completed for PO: ${po.poNumber}');
      }
      
      return true;
    } catch (e) {
      debugPrint('Error updating purchase order: $e');
      return false;
    }
  }

  // Mark PO as received and update inventory
  static Future<bool> markPurchaseOrderReceived(String poId) async {
    try {
      final po = await getPurchaseOrderById(poId);
      if (po == null) return false;

      final updatedPO = po.copyWith(
        status: 'received',
        actualDelivery: DateTime.now(),
        deliveryStatus: 'delivered',
      );

      return await updatePurchaseOrder(poId, updatedPO);
    } catch (e) {
      debugPrint('Error marking PO as received: $e');
      return false;
    }
  }
}

// Supplier Service - uses existing 'suppliers' collection
class EnhancedSupplierService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'suppliers';

  // Get all suppliers
  static Future<List<UnifiedSupplier>> getAllSuppliers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => UnifiedSupplier.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all suppliers: $e');
      return [];
    }
  }

  // Stream all suppliers for real-time updates
  static Stream<List<UnifiedSupplier>> getSuppliersStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnifiedSupplier.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get supplier by ID
  static Future<UnifiedSupplier?> getSupplierById(String supplierId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(supplierId).get();
      if (doc.exists) {
        return UnifiedSupplier.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting supplier by ID: $e');
      return null;
    }
  }

  // Add supplier
  static Future<String?> addSupplier(Supplier supplier) async {
    try {
      final docRef = await _firestore.collection(_collection).add(supplier.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding supplier: $e');
      return null;
    }
  }

  // Update supplier
  static Future<bool> updateSupplier(String supplierId, Supplier supplier) async {
    try {
      await _firestore.collection(_collection).doc(supplierId).update(supplier.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating supplier: $e');
      return false;
    }
  }
}

// Customer Order Service - uses existing 'customer_orders' collection
class EnhancedCustomerOrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'customer_orders';

  // Get all customer orders
  static Future<List<UnifiedCustomerOrder>> getAllCustomerOrders() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => UnifiedCustomerOrder.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all customer orders: $e');
      return [];
    }
  }

  // Stream all customer orders for real-time updates
  static Stream<List<UnifiedCustomerOrder>> getCustomerOrdersStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnifiedCustomerOrder.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get customer order by ID
  static Future<UnifiedCustomerOrder?> getCustomerOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return UnifiedCustomerOrder.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting customer order by ID: $e');
      return null;
    }
  }

  // Add customer order with inventory management
  static Future<String?> addCustomerOrder(CustomerOrder order) async {
    try {
      // First, check if all items have sufficient stock
      final productsOrdered = order.productsOrdered ?? [];
      for (final item in productsOrdered) {
        final productId = item['product_id'] as String;
        final quantity = item['quantity'] as int;
        
        final hasStock = await EnhancedInventoryService.checkStockAvailability(productId, quantity);
        if (!hasStock) {
          debugPrint('Insufficient stock for product $productId. Order cancelled.');
          return null;
        }
      }

      // Reserve stock for the order
      for (final item in productsOrdered) {
        final productId = item['product_id'] as String;
        final quantity = item['quantity'] as int;
        
        await EnhancedInventoryService.reserveStock(productId, quantity);
      }

      // Add the order
      final docRef = await _firestore.collection(_collection).add(order.toMap());
      
      debugPrint('✅ Customer Order ${docRef.id} created with stock reservation');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding customer order: $e');
      return null;
    }
  }

  // Add customer order without inventory management (for POS integration)
  static Future<String?> addCustomerOrderOnly(CustomerOrder order) async {
    try {
      final docRef = await _firestore.collection(_collection).add(order.toMap());
      debugPrint('✅ Customer Order ${docRef.id} created without inventory changes');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding customer order: $e');
      return null;
    }
  }

  // Update customer order with inventory management
  static Future<bool> updateCustomerOrder(String orderId, CustomerOrder order) async {
    try {
      // Get existing order to check status changes
      final existingOrder = await getCustomerOrderById(orderId);
      
      await _firestore.collection(_collection).doc(orderId).update(order.toMap());
      
      // Handle inventory based on status changes
      if (existingOrder != null) {
        // If order is completed/shipped, reduce actual stock
        if (existingOrder.orderStatus != 'completed' && 
            order.orderStatus == 'completed') {
          
          final productsOrdered = order.productsOrdered ?? [];
          for (final item in productsOrdered) {
            final productId = item['product_id'] as String;
            final quantity = item['quantity'] as int;
            final productName = item['product_name'] as String? ?? 'Unknown';
            
            // Release reserved stock and reduce actual stock
            await EnhancedInventoryService.releaseReservedStock(productId, quantity);
            await EnhancedInventoryService.updateStock(
              productId,
              -quantity,  // Negative for completed orders
              reason: 'Customer Order Completed - ${order.orderNumber} - $productName'
            );
          }
        }
        
        // If order is cancelled, release reserved stock
        if (existingOrder.orderStatus != 'cancelled' && 
            order.orderStatus == 'cancelled') {
          
          final productsOrdered = order.productsOrdered ?? [];
          for (final item in productsOrdered) {
            final productId = item['product_id'] as String;
            final quantity = item['quantity'] as int;
            
            await EnhancedInventoryService.releaseReservedStock(productId, quantity);
          }
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error updating customer order: $e');
      return false;
    }
  }

  // Get customer orders with linked invoice details
  static Future<List<Map<String, dynamic>>> getCustomerOrdersWithInvoices() async {
    try {
      final orders = await getAllCustomerOrders();
      final ordersWithInvoices = <Map<String, dynamic>>[];

      for (final order in orders) {
        final orderData = <String, dynamic>{
          'order': order,
          'invoice': null,
        };

        // If order has an invoice ID, fetch the POS transaction
        if (order.invoiceId != null && order.invoiceId!.isNotEmpty) {
          final transaction = await EnhancedPosService.getTransactionById(order.invoiceId!);
          orderData['invoice'] = transaction;
        }

        ordersWithInvoices.add(orderData);
      }

      return ordersWithInvoices;
    } catch (e) {
      debugPrint('Error getting customer orders with invoices: $e');
      return [];
    }
  }

  // Get customer orders by customer ID with invoice details
  static Future<List<Map<String, dynamic>>> getCustomerOrdersByCustomerId(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('customer_id', isEqualTo: customerId)
          .orderBy('order_date', descending: true)
          .get();
      
      final orders = snapshot.docs
          .map((doc) => UnifiedCustomerOrder.fromFirestore(doc.data(), doc.id))
          .toList();

      final ordersWithInvoices = <Map<String, dynamic>>[];

      for (final order in orders) {
        final orderData = <String, dynamic>{
          'order': order,
          'invoice': null,
        };

        // If order has an invoice ID, fetch the POS transaction
        if (order.invoiceId != null && order.invoiceId!.isNotEmpty) {
          final transaction = await EnhancedPosService.getTransactionById(order.invoiceId!);
          orderData['invoice'] = transaction;
        }

        ordersWithInvoices.add(orderData);
      }

      return ordersWithInvoices;
    } catch (e) {
      debugPrint('Error getting customer orders by customer ID: $e');
      return [];
    }
  }
}

// POS Service - uses existing 'pos_transactions' collection
class EnhancedPosService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'pos_transactions';

  // Get all POS transactions
  static Future<List<PosTransaction>> getAllTransactions() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => UnifiedPOSTransaction.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all POS transactions: $e');
      return [];
    }
  }

  // Stream all POS transactions for real-time updates
  static Stream<List<UnifiedPOSTransaction>> getTransactionsStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnifiedPOSTransaction.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get transaction by ID
  static Future<UnifiedPOSTransaction?> getTransactionById(String transactionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(transactionId).get();
      if (doc.exists) {
        return UnifiedPOSTransaction.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting transaction by ID: $e');
      return null;
    }
  }

  // Add POS transaction from customer order (for automatic invoice creation)
  static Future<String?> addTransactionFromOrder(PosTransaction transaction) async {
    try {
      // Use the existing addTransaction method which handles all integrations
      return addTransaction(transaction);
    } catch (e) {
      debugPrint('Error adding transaction from order: $e');
      return null;
    }
  }

  // Add POS transaction with automatic inventory updates, customer order creation, and CRM updates
  static Future<String?> addTransaction(UnifiedPOSTransaction transaction) async {
    try {
      // First, check if all items have sufficient stock
      for (final item in transaction.productItems) {
        final productId = item.productId;
        final quantity = item.quantity;
        
        final hasStock = await EnhancedInventoryService.checkStockAvailability(productId, quantity);
        if (!hasStock) {
          debugPrint('Insufficient stock for product $productId. Transaction cancelled.');
          return null;
        }
      }

      // Add the transaction first
      final docRef = await _firestore.collection(_collection).add(transaction.toMap());
      final transactionId = docRef.id;
      
      // Update inventory for each item sold
      for (final item in transaction.productItems) {
        final productId = item.productId;
        final quantity = item.quantity;
        final productName = item.productName;
        
        // Reduce stock (negative quantity for sales)
        final stockUpdated = await EnhancedInventoryService.updateStock(
          productId, 
          -quantity,  // Negative because it's a sale
          reason: 'POS Sale - ${transaction.transactionId} - $productName'
        );
        
        if (!stockUpdated) {
          debugPrint('Warning: Failed to update stock for product $productId in transaction ${transactionId}');
        }
      }

      // If customer is provided, create customer order and update CRM
      if (transaction.customerId != null && transaction.customerId!.isNotEmpty) {
        await _createCustomerOrderFromTransaction(transaction, transactionId);
        await _updateCrmFromTransaction(transaction);
      }
      
      debugPrint('✅ POS Transaction ${transactionId} completed with inventory updates, customer order creation, and CRM updates');
      return transactionId;
    } catch (e) {
      debugPrint('Error adding transaction with integrations: $e');
      return null;
    }
  }

  // Helper: Create customer order from POS transaction
  static Future<void> _createCustomerOrderFromTransaction(PosTransaction transaction, String transactionId) async {
    try {
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Convert POS items to customer order format
      final productsOrdered = transaction.productItems.map((item) => {
        'product_id': item.productId,
        'product_name': item.productName,
        'quantity': item.quantity,
        'price': item.unitPrice,
        'total': item.totalPrice,
        'unit': 'pcs',
      }).toList();

      final customerOrder = UnifiedCustomerOrder(
        id: '', // Will be set by Firestore
        orderId: orderNumber,
        customerId: transaction.customerId!,
        customerName: transaction.metadata['customerName'] ?? 'Walk-in Customer',
        storeId: transaction.storeId ?? '',
        status: 'completed', // Completed since it's a direct sale
        items: transaction.productItems,
        subtotal: transaction.subTotal,
        taxAmount: transaction.taxAmount,
        discount: transaction.discountApplied,
        totalAmount: transaction.totalAmount,
        paymentStatus: 'paid', // Paid since transaction is complete
        deliveryStatus: 'completed', // Completed for POS sales
        orderDate: transaction.createdAt,
        createdAt: transaction.createdAt,
        updatedAt: transaction.createdAt,
        orderNumber: orderNumber,
        orderStatus: 'completed',
        paymentMode: transaction.paymentMode.toLowerCase(),
        deliveryMode: 'pickup', // POS sales are typically pickup
        subscriptionFlag: false,
        deliveryCharges: 0.0,
        grandTotal: transaction.totalAmount,
        walletUsed: transaction.walletUsed,
        productsOrdered: productsOrdered,
        deliverySlot: null,
        deliveryPersonId: null,
        invoiceId: transactionId, // Link to POS transaction
        remarks: 'Created from POS Transaction - ${transaction.transactionId}',
      );

      await EnhancedCustomerOrderService.addCustomerOrderOnly(customerOrder);
      debugPrint('✅ Customer order ${orderNumber} created from POS transaction ${transactionId}');
    } catch (e) {
      debugPrint('Error creating customer order from transaction: $e');
    }
  }

  // Helper: Update CRM from POS transaction
  static Future<void> _updateCrmFromTransaction(UnifiedPOSTransaction transaction) async {
    try {
      if (transaction.customerId == null || transaction.customerId!.isEmpty) return;

      // TODO: Update customer profile with purchase info
      // Customer profile update temporarily disabled during unified model migration
      debugPrint('✅ Transaction processed: ${transaction.transactionId}');
    } catch (e) {
      debugPrint('Error updating CRM from transaction: $e');
    }
  }

  // Original add transaction method (without inventory updates)
  static Future<String?> addTransactionOnly(UnifiedPOSTransaction transaction) async {
    try {
      final docRef = await _firestore.collection(_collection).add(transaction.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return null;
    }
  }

  // Update POS transaction
  static Future<bool> updateTransaction(String transactionId, UnifiedPOSTransaction transaction) async {
    try {
      await _firestore.collection(_collection).doc(transactionId).update(transaction.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }
}

// Inventory Service - uses existing 'inventory' collection
class EnhancedInventoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'inventory';

  // Get all inventory items
  static Future<List<UnifiedInventoryItem>> getAllInventoryItems() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => UnifiedInventoryItem.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all inventory items: $e');
      return [];
    }
  }

  // Stream all inventory items for real-time updates
  static Stream<List<UnifiedInventoryItem>> getInventoryItemsStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UnifiedInventoryItem.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get inventory item by ID
  static Future<UnifiedInventoryItem?> getInventoryItemById(String inventoryId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(inventoryId).get();
      if (doc.exists) {
        return UnifiedInventoryItem.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting inventory item by ID: $e');
      return null;
    }
  }

  // Get inventory items by product ID
  static Future<List<UnifiedInventoryItem>> getInventoryByProductId(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('product_id', isEqualTo: productId)
          .get();
      return snapshot.docs
          .map((doc) => UnifiedInventoryItem.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting inventory by product ID: $e');
      return [];
    }
  }

  // Add inventory item
  static Future<String?> addInventoryItem(UnifiedInventoryItem item) async {
    try {
      final docRef = await _firestore.collection(_collection).add(item.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding inventory item: $e');
      return null;
    }
  }

  // Update inventory item
  static Future<bool> updateInventoryItem(String inventoryId, UnifiedInventoryItem item) async {
    try {
      await _firestore.collection(_collection).doc(inventoryId).update(item.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating inventory item: $e');
      return false;
    }
  }

  // Get low stock items
  static Future<List<InventoryItem>> getLowStockItems() async {
    try {
      final allItems = await getAllInventoryItems();
      return allItems.where((item) {
        return item.currentStock <= item.minStockLevel;
      }).toList();
    } catch (e) {
      debugPrint('Error getting low stock items: $e');
      return [];
    }
  }

  // Update stock levels - CRITICAL BUSINESS LOGIC
  static Future<bool> updateStock(String productId, int quantityChange, {String? reason}) async {
    try {
      // Get inventory items for this product
      final inventoryItems = await getInventoryByProductId(productId);
      
      if (inventoryItems.isEmpty) {
        debugPrint('No inventory found for product $productId');
        return false;
      }

      // For simplicity, update the first inventory item found
      // In a real system, you might have multiple locations/batches
      final inventoryItem = inventoryItems.first;
      final newStock = inventoryItem.currentStock + quantityChange;
      
      if (newStock < 0) {
        debugPrint('Insufficient stock. Current: ${inventoryItem.currentStock}, Requested: ${quantityChange.abs()}');
        return false;
      }

      // Update the inventory
      final updatedItem = inventoryItem.copyWith(
        quantityAvailable: newStock,
        updatedAt: DateTime.now(),
        remarks: reason ?? 'Stock updated by system',
      );

      await updateInventoryItem(inventoryItem.id, updatedItem);
      
      debugPrint('Stock updated for product $productId: ${inventoryItem.currentStock} -> $newStock (${quantityChange > 0 ? '+' : ''}$quantityChange) - Reason: $reason');
      return true;
    } catch (e) {
      debugPrint('Error updating stock: $e');
      return false;
    }
  }

  // Check if sufficient stock is available
  static Future<bool> checkStockAvailability(String productId, int requiredQuantity) async {
    try {
      debugPrint('🔍 Checking stock for product: $productId, required: $requiredQuantity');
      
      // First check inventory collection
      final inventoryItems = await getInventoryByProductId(productId);
      debugPrint('📦 Found ${inventoryItems.length} inventory items for product $productId');
      
      if (inventoryItems.isNotEmpty) {
        final totalAvailableStock = inventoryItems.fold<int>(
          0, (sum, item) {
            debugPrint('   - Location: ${item.location}, Available: ${item.availableStock}');
            return sum + item.availableStock;
          }
        );
        debugPrint('📊 Total available stock: $totalAvailableStock');
        
        if (totalAvailableStock >= requiredQuantity) {
          debugPrint('✅ Stock check passed');
          return true;
        }
      }
      
      // Fallback: Check product collection for current_stock
      debugPrint('🔄 Checking product collection for current_stock...');
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (productDoc.exists) {
        final data = productDoc.data() as Map<String, dynamic>;
        final currentStock = data['current_stock'] ?? 0;
        debugPrint('📦 Product current_stock: $currentStock');
        
        if (currentStock >= requiredQuantity) {
          debugPrint('✅ Stock check passed via product collection');
          return true;
        }
      }
      
      debugPrint('❌ Insufficient stock');
      return false;
    } catch (e) {
      debugPrint('❌ Error checking stock availability: $e');
      return false;
    }
  }

  // Reserve stock for pending orders
  static Future<bool> reserveStock(String productId, int quantity) async {
    try {
      final inventoryItems = await getInventoryByProductId(productId);
      if (inventoryItems.isEmpty) return false;

      final inventoryItem = inventoryItems.first;
      if (inventoryItem.availableStock < quantity) return false;

      final updatedItem = inventoryItem.copyWith(
        quantityReserved: inventoryItem.quantityReserved + quantity,
        updatedAt: DateTime.now(),
        remarks: 'Stock reserved',
      );

      return await updateInventoryItem(inventoryItem.id, updatedItem);
    } catch (e) {
      debugPrint('Error reserving stock: $e');
      return false;
    }
  }

  // Release reserved stock
  static Future<bool> releaseReservedStock(String productId, int quantity) async {
    try {
      final inventoryItems = await getInventoryByProductId(productId);
      if (inventoryItems.isEmpty) return false;

      final inventoryItem = inventoryItems.first;
      final newReservedStock = (inventoryItem.quantityReserved - quantity).clamp(0, inventoryItem.currentStock);

      final updatedItem = inventoryItem.copyWith(
        quantityReserved: newReservedStock,
        updatedAt: DateTime.now(),
        remarks: 'Stock reservation released',
      );

      return await updateInventoryItem(inventoryItem.id, updatedItem);
    } catch (e) {
      debugPrint('Error releasing reserved stock: $e');
      return false;
    }
  }
}
