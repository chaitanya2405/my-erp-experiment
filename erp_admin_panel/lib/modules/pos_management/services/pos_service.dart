import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../models/pos_transaction.dart' hide PosTransaction;
import '../../../models/product.dart' hide Product;
import '../../../core/models/unified_models.dart';
import '../../../models/customer_profile.dart' hide CustomerProfile;
import '../../../services/product_service.dart';
import '../../../services/inventory_service.dart';
import '../../../services/customer_order_service.dart';
import '../../../services/customer_profile_service.dart';

class PosService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'pos_transactions';

  // Create a new POS transaction (now uses integrated approach)
  static Future<String> createTransaction(PosTransaction transaction) async {
    return await createIntegratedTransaction(transaction);
  }

  // Update an existing transaction
  static Future<void> updateTransaction(String transactionId, PosTransaction transaction) async {
    try {
      await _firestore.collection(_collection).doc(transactionId).update(transaction.toFirestore());
    } catch (e) {
      debugPrint('Error updating POS transaction: $e');
      rethrow;
    }
  }

  // Get transaction by ID
  static Future<UnifiedPOSTransaction?> getTransaction(String transactionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(transactionId).get();
      if (doc.exists) {
        return UnifiedPOSTransaction.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting POS transaction: $e');
      return null;
    }
  }

  // Get transactions for a specific store
  static Stream<List<UnifiedPOSTransaction>> getTransactionsByStore(String storeId) {
    return _firestore
        .collection(_collection)
        .where('store_id', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) => UnifiedPOSTransaction.fromFirestore(doc.data(), doc.id))
              .toList();
          
          // Sort by transaction time in memory
          transactions.sort((a, b) => b.transactionTime.compareTo(a.transactionTime));
          return transactions;
        });
  }

  // Get transactions for a specific cashier
  static Stream<List<UnifiedPOSTransaction>> getTransactionsByCashier(String cashierId) {
    return _firestore
        .collection(_collection)
        .where('cashier_id', isEqualTo: cashierId)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) => UnifiedPOSTransaction.fromFirestore(doc.data(), doc.id))
              .toList();
          
          // Sort by transaction time in memory
          transactions.sort((a, b) => b.transactionTime.compareTo(a.transactionTime));
          return transactions;
        });
  }

  // Get transactions by date range
  static Future<List<UnifiedPOSTransaction>> getTransactionsByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Use a simpler query to avoid composite index requirement
      // Filter by store_id first, then filter by date in memory
      final query = await _firestore
          .collection(_collection)
          .where('store_id', isEqualTo: storeId)
          .get();

      // Filter by date range in memory and sort
      final filteredTransactions = query.docs
          .map((doc) => UnifiedPOSTransaction.fromFirestore(doc.data(), doc.id))
          .where((transaction) {
            final transactionDate = transaction.transactionTime;
            return transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   transactionDate.isBefore(endDate.add(const Duration(days: 1)));
          })
          .toList();

      // Sort by transaction time descending
      filteredTransactions.sort((a, b) => b.transactionTime.compareTo(a.transactionTime));

      return filteredTransactions;
    } catch (e) {
      debugPrint('Error getting transactions by date range: $e');
      return [];
    }
  }

  // Search transactions by invoice number
  static Future<UnifiedPOSTransaction?> getTransactionByInvoiceNumber(String invoiceNumber) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('invoice_number', isEqualTo: invoiceNumber)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UnifiedPOSTransaction.fromFirestore(query.docs.first.data(), query.docs.first.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error searching transaction by invoice: $e');
      return null;
    }
  }

  // Get sales analytics for a store
  static Future<Map<String, dynamic>> getSalesAnalytics(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions = await getTransactionsByDateRange(storeId, startDate, endDate);
      
      double totalSales = 0;
      double totalTax = 0;
      double totalDiscount = 0;
      int totalTransactions = transactions.length;
      Map<String, int> paymentModes = {};
      
      for (final transaction in transactions) {
        totalSales += transaction.totalAmount;
        totalDiscount += transaction.discountApplied;
        
        // Calculate total tax from tax breakup
        if (transaction.taxBreakup != null) {
          final taxData = transaction.taxBreakup as Map<String, dynamic>;
          for (final value in taxData.values) {
            if (value is num) {
              totalTax += value.toDouble();
            }
          }
        }
        
        // Count payment modes
        paymentModes[transaction.paymentMode] = 
            (paymentModes[transaction.paymentMode] ?? 0) + 1;
      }
      
      return {
        'total_sales': totalSales,
        'total_tax': totalTax,
        'total_discount': totalDiscount,
        'total_transactions': totalTransactions,
        'average_bill_value': totalTransactions > 0 ? totalSales / totalTransactions : 0,
        'payment_modes': paymentModes,
      };
    } catch (e) {
      debugPrint('Error getting sales analytics: $e');
      return {};
    }
  }

  // Process refund
  static Future<void> processRefund(String transactionId, double refundAmount, String reason) async {
    try {
      await _firestore.collection(_collection).doc(transactionId).update({
        'refund_status': 'Partially Refunded',
        'remarks': reason,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Create refund audit log entry
      await _firestore.collection('pos_audit_logs').add({
        'transaction_id': transactionId,
        'action': 'refund',
        'amount': refundAmount,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error processing refund: $e');
      rethrow;
    }
  }

  // Sync offline transactions
  static Future<void> syncOfflineTransactions(List<PosTransaction> offlineTransactions) async {
    try {
      final batch = _firestore.batch();
      
      for (final transaction in offlineTransactions) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, {
          ...transaction.toFirestore(),
          'synced_to_server': true,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error syncing offline transactions: $e');
      rethrow;
    }
  }

  // Generate next invoice number
  static Future<String> generateInvoiceNumber(String storeId) async {
    try {
      final counterDoc = await _firestore.collection('invoice_counters').doc(storeId).get();
      
      int nextNumber = 1;
      if (counterDoc.exists) {
        nextNumber = (counterDoc.data()?['counter'] ?? 0) + 1;
      }
      
      // Update counter
      await _firestore.collection('invoice_counters').doc(storeId).set({
        'counter': nextNumber,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Format: POS-STORE-00001
      return 'POS-${storeId.toUpperCase()}-${nextNumber.toString().padLeft(5, '0')}';
    } catch (e) {
      debugPrint('Error generating invoice number: $e');
      // Fallback to timestamp-based number
      return 'POS-${storeId.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // ======================== MODULE INTEGRATION METHODS ========================

  // Create integrated POS transaction with all module updates
  static Future<String> createIntegratedTransaction(PosTransaction transaction) async {
    try {
      if (kDebugMode) {
        print('🧾 Creating POS transaction with FULL business logic integration');
        print('  • Store: ${transaction.storeId}');
        print('  • Customer: ${transaction.customerId ?? 'Walk-in customer'}');
        print('  • Total amount: \$${transaction.totalAmount.toStringAsFixed(2)}');
        print('  • Products: ${transaction.productItems.length} items');
      }
      
      // Start a batch write for atomicity
      final batch = _firestore.batch();
      
      // 1. Create POS transaction
      final posRef = _firestore.collection(_collection).doc();
      batch.set(posRef, transaction.toFirestore());
      
      if (kDebugMode) {
        print('📦 Updating inventory for ${transaction.productItems.length} products...');
      }
      
      // 2. Update inventory levels for all products
      for (final item in transaction.productItems) {
        await _updateInventoryFromSale(item);
      }
      
      // 3. Create/Update customer profile if customer ID exists
      if (transaction.customerId != null && transaction.customerId!.isNotEmpty) {
        if (kDebugMode) {
          print('🎯 Updating customer loyalty (CRM integration):');
          print('  • Customer ID: ${transaction.customerId}');
          print('  • Amount spent: \$${transaction.totalAmount.toStringAsFixed(2)}');
        }
        await _updateCustomerProfile(transaction);
      }
      
      // 4. Create customer order record
      await _createCustomerOrderFromPOS(transaction, posRef.id);
      
      // 5. Update product sales statistics
      await _updateProductSalesStats(transaction.productItems);
      
      // Commit the batch
      await batch.commit();
      
      if (kDebugMode) {
        print('✅ POS transaction created with FULL business logic: ${posRef.id}');
        print('✅ Invoice number: ${transaction.invoiceNumber}');
        print('✅ Inventory updates: COMPLETED');
        print('✅ Loyalty updates: COMPLETED');
      }
      
      return posRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating integrated POS transaction: $e');
      }
      rethrow;
    }
  }

  // Get products from Product Management module for POS
  static Future<List<UnifiedProduct>> getAvailableProducts() async {
    try {
      final legacyProducts = await ProductService.getAllProducts();
      return legacyProducts.map((product) => _convertToUnifiedProduct(product)).toList();
    } catch (e) {
      debugPrint('Error getting products for POS: $e');
      return [];
    }
  }

  // Search products by name, barcode, or SKU
  static Future<List<UnifiedProduct>> searchProducts(String query) async {
    try {
      final legacyProducts = await ProductService.searchProducts(query);
      return legacyProducts.map((product) => _convertToUnifiedProduct(product)).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // Get product by barcode for scanning
  static Future<UnifiedProduct?> getProductByBarcode(String barcode) async {
    try {
      final legacyProduct = await ProductService.getProductByBarcode(barcode);
      return legacyProduct != null ? _convertToUnifiedProduct(legacyProduct) : null;
    } catch (e) {
      debugPrint('Error getting product by barcode: $e');
      return null;
    }
  }

  // Check inventory availability before sale
  static Future<bool> checkInventoryAvailability(String productId, int quantity) async {
    try {
      final inventory = await InventoryService.getInventoryByProductId(productId);
      if (inventory != null) {
        return inventory.currentQuantity >= quantity;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking inventory availability: $e');
      return false;
    }
  }

  // Get customer details for POS
  static Future<UnifiedCustomerProfile?> getCustomerProfile(String customerId) async {
    try {
      final legacyProfile = await CustomerProfileService.getProfile(customerId);
      return legacyProfile != null ? _convertToUnifiedCustomerProfile(legacyProfile) : null;
    } catch (e) {
      debugPrint('Error getting customer profile: $e');
      return null;
    }
  }

  // Search customers by phone, email, or name
  static Future<List<UnifiedCustomerProfile>> searchCustomers(String query) async {
    try {
      final legacyCustomers = await CustomerProfileService.searchCustomers(query);
      return legacyCustomers.map((customer) => _convertToUnifiedCustomerProfile(customer)).toList();
    } catch (e) {
      debugPrint('Error searching customers: $e');
      return [];
    }
  }

  // ======================== PRIVATE INTEGRATION HELPERS ========================

  // Update inventory levels after sale
  static Future<void> _updateInventoryFromSale(UnifiedPOSTransactionItem item) async {
    try {
      final productId = item.productId;
      final quantitySold = item.quantity;
      
      if (kDebugMode) {
        print('📦 Inventory Update: ${item.productName} (${productId})');
        print('  • Quantity sold: $quantitySold');
      }
      
      // Get current inventory
      final inventory = await InventoryService.getInventoryByProductId(productId);
      if (inventory != null) {
        final oldQuantity = inventory.currentQuantity;
        final newQuantity = oldQuantity - quantitySold;
        
        if (kDebugMode) {
          print('✅ Inventory updated for Product ${productId}: $oldQuantity → $newQuantity');
        }
        
        // Update inventory quantity
        final updatedInventory = inventory.copyWith(
          quantityAvailable: newQuantity,
          lastUpdated: Timestamp.fromDate(DateTime.now()),
        );
        await InventoryService.updateInventory(inventory.inventoryId, updatedInventory);
        
        // Check for low stock alert
        if (newQuantity <= updatedInventory.minimumQuantity) {
          if (kDebugMode) {
            print('⚠️ LOW STOCK ALERT: ${item.productName}');
            print('  • Current: $newQuantity');
            print('  • Minimum: ${updatedInventory.minimumQuantity}');
          }
          await _triggerLowStockAlert(productId, newQuantity.toInt());
        }
      } else {
        if (kDebugMode) {
          print('⚠️ No inventory record found for product: $productId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating inventory from sale: $e');
      }
    }
  }

  // Update customer profile with purchase history
  static Future<void> _updateCustomerProfile(PosTransaction transaction) async {
    try {
      if (transaction.customerId == null) return;
      
      final customer = await CustomerProfileService.getProfile(transaction.customerId!);
      if (customer != null) {
        // Update customer purchase statistics
        final currentTotalPurchases = customer.totalPurchases;
        final newTotalPurchases = currentTotalPurchases + transaction.totalAmount;
        final newTotalOrders = customer.totalOrders + 1;
        final newAverageOrderValue = newTotalPurchases / newTotalOrders;
        
        if (kDebugMode) {
          print('  • Points to award: ${transaction.totalAmount.round()}');
          print('  ✅ CRM record updated:');
          print('    • Points: ${customer.loyaltyPoints} → ${customer.loyaltyPoints + transaction.totalAmount.round()} (+${transaction.totalAmount.round()})');
          print('    • Total orders: ${customer.totalOrders} → $newTotalOrders');
          print('    • Total purchases: \$${currentTotalPurchases.toStringAsFixed(2)} → \$${newTotalPurchases.toStringAsFixed(2)}');
        }
        
        final updatedCustomer = customer.copyWith(
          totalOrders: newTotalOrders,
          totalPurchases: newTotalPurchases,
          averageOrderValue: newAverageOrderValue,
          lastOrderDate: Timestamp.fromDate(transaction.transactionTime),
          loyaltyPoints: customer.loyaltyPoints + transaction.totalAmount.round().toInt(),
        );
        await CustomerProfileService.updateProfile(customer.customerId, updatedCustomer);
        
        // Update loyalty points if applicable
        await _updateCustomerLoyaltyPoints(transaction);
      } else {
        if (kDebugMode) {
          print('  ❌ Customer not found in CRM: ${transaction.customerId}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating customer profile: $e');
      }
    }
  }

  // Create customer order from POS transaction
  static Future<void> _createCustomerOrderFromPOS(PosTransaction transaction, String posTransactionId) async {
    try {
      if (kDebugMode) {
        print('📋 Creating customer order record from POS transaction');
        print('  • POS Transaction ID: $posTransactionId');
        print('  • Customer: ${transaction.customerId ?? 'Walk-in'}');
      }
      
      // Convert POS transaction to Customer Order
      final customerOrder = UnifiedCustomerOrder(
        id: '',
        orderId: UnifiedCustomerOrder.generateOrderId(),
        customerId: transaction.customerId ?? 'walk-in-customer',
        customerName: transaction.customerName ?? 'Walk-in Customer',
        storeId: transaction.storeId ?? 'default-store',
        status: 'completed', // POS transactions are immediately completed
        items: transaction.productItems,
        subtotal: transaction.subTotal,
        taxAmount: transaction.taxAmount,
        discount: transaction.discountApplied,
        totalAmount: transaction.totalAmount,
        paymentStatus: 'paid',
        deliveryStatus: 'completed',
        orderDate: transaction.createdAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        orderNumber: 'POS-${transaction.invoiceNumber}',
        paymentMode: transaction.paymentMode,
        deliveryMode: 'in-store-pickup',
        deliveryAddress: null,
        productsOrdered: transaction.productItems.map((item) => {
          'product_id': item.productId,
          'product_name': item.productName,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
          'discount': item.discount,
          'tax_amount': item.taxAmount,
          'sku': item.sku,
          'category': item.category,
        }).toList(),
        deliveryCharges: 0.0,
        grandTotal: transaction.totalAmount,
        subscriptionFlag: false,
        subscriptionPlan: null,
        walletUsed: 0.0,
        deliverySlot: null,
        deliveryPersonId: null,
        invoiceId: posTransactionId,
        remarks: transaction.metadata['remarks'] ?? '',
      );
      
      await CustomerOrderService.createOrder(customerOrder);
      
      if (kDebugMode) {
        print('✅ Customer order record created: ${customerOrder.orderId}');
        print('  • Order number: ${customerOrder.orderNumber}');
        print('  • Status: ${customerOrder.orderStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating customer order from POS: $e');
      }
    }
  }

  // Update product sales statistics
  static Future<void> _updateProductSalesStats(List<UnifiedPOSTransactionItem> items) async {
    try {
      for (final item in items) {
        final productId = item.productId;
        final quantitySold = item.quantity;
        final revenue = item.totalPrice;
        
        // Update product sales data
        await ProductService.updateSalesStats(productId, quantitySold, revenue);
      }
    } catch (e) {
      debugPrint('Error updating product sales stats: $e');
    }
  }

  // Update customer loyalty points
  static Future<void> _updateCustomerLoyaltyPoints(PosTransaction transaction) async {
    try {
      if (transaction.customerId == null) return;
      
      // Simple loyalty calculation: 1 point per ₹10 spent
      final pointsEarned = (transaction.totalAmount / 10).floor();
      
      if (pointsEarned > 0) {
        await CustomerProfileService.addLoyaltyPoints(transaction.customerId!, pointsEarned);
      }
    } catch (e) {
      debugPrint('Error updating loyalty points: $e');
    }
  }

  // Trigger low stock alert
  static Future<void> _triggerLowStockAlert(String productId, int currentQuantity) async {
    try {
      // Create notification for inventory management
      await _firestore.collection('notifications').add({
        'type': 'low_stock_alert',
        'product_id': productId,
        'current_quantity': currentQuantity,
        'message': 'Product is running low on stock',
        'created_at': FieldValue.serverTimestamp(),
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Error triggering low stock alert: $e');
    }
  }

  // Get integrated sales analytics across all modules
  static Future<Map<String, dynamic>> getIntegratedAnalytics(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final analytics = await getSalesAnalytics(storeId, startDate, endDate);
      
      // Add inventory insights
      final lowStockProducts = await InventoryService.getLowStockProducts();
      analytics['low_stock_count'] = lowStockProducts.length;
      
      // Add customer insights
      final customerStats = await CustomerProfileService.getCustomerStats(startDate, endDate);
      analytics['new_customers'] = customerStats['new_customers'];
      analytics['returning_customers'] = customerStats['returning_customers'];
      
      // Add top performing products
      final topProducts = await ProductService.getTopSellingProducts(10, startDate, endDate);
      analytics['top_products'] = topProducts;
      
      return analytics;
    } catch (e) {
      debugPrint('Error getting integrated analytics: $e');
      return {};
    }
  }

  // Sync POS data with all modules
  static Future<void> syncWithAllModules() async {
    try {
      debugPrint('Starting sync with all modules...');
      
      // Sync inventory levels
      await InventoryService.syncInventoryLevels();
      
      // Sync customer data
      await CustomerProfileService.syncCustomerData();
      
      // Sync product information
      await ProductService.syncProductData();
      
      debugPrint('Module sync completed successfully');
    } catch (e) {
      debugPrint('Error syncing with modules: $e');
    }
  }

  // ======================== FIRESTORE INDEX REQUIREMENTS ========================
  
  /*
   * Required Firestore Composite Indexes:
   * 
   * 1. Collection: pos_transactions
   *    Fields: store_id (Ascending), transaction_time (Descending)
   *    
   * 2. Collection: pos_transactions  
   *    Fields: cashier_id (Ascending), transaction_time (Descending)
   *    
   * 3. Collection: pos_transactions
   *    Fields: store_id (Ascending), transaction_time (Ascending), transaction_time (Descending)
   *    
   * To create these indexes:
   * 1. Go to Firebase Console > Firestore Database > Indexes
   * 2. Click "Create Index"
   * 3. Add the fields as specified above
   * 
   * OR use the auto-generated links when Firestore errors occur
   */

  // ======================== CONVERSION HELPER METHODS ========================

  static UnifiedProduct _convertToUnifiedProduct(dynamic legacyProduct) {
    return UnifiedProduct(
      id: legacyProduct.productId ?? legacyProduct.id ?? '',
      name: legacyProduct.productName ?? legacyProduct.name ?? '',
      code: legacyProduct.sku ?? legacyProduct.code ?? '',
      description: legacyProduct.description,
      category: legacyProduct.category,
      brand: legacyProduct.brand,
      costPrice: legacyProduct.costPrice?.toDouble() ?? 0.0,
      salePrice: legacyProduct.sellingPrice?.toDouble() ?? legacyProduct.salePrice?.toDouble() ?? 0.0,
      mrp: legacyProduct.mrp?.toDouble(),
      unit: legacyProduct.unit,
      isActive: legacyProduct.isActive ?? true,
      createdAt: legacyProduct.createdAt ?? DateTime.now(),
      updatedAt: legacyProduct.updatedAt ?? DateTime.now(),
      taxRate: legacyProduct.taxPercent?.toDouble() ?? 0.0,
      metadata: {
        'barcode': legacyProduct.barcode,
        'batch_number': legacyProduct.batchNumber,
        'tax_slab': legacyProduct.taxSlab,
      },
    );
  }

  static UnifiedCustomerProfile _convertToUnifiedCustomerProfile(dynamic legacyCustomer) {
    return UnifiedCustomerProfile(
      id: legacyCustomer.id ?? '',
      customerId: legacyCustomer.customerId ?? legacyCustomer.id ?? '',
      fullName: legacyCustomer.customerName ?? legacyCustomer.fullName ?? '',
      mobileNumber: legacyCustomer.mobileNumber ?? '',
      email: legacyCustomer.email,
      addressLine1: legacyCustomer.addressLine1 ?? '',
      addressLine2: legacyCustomer.addressLine2 ?? '',
      city: legacyCustomer.city ?? '',
      state: legacyCustomer.state ?? '',
      postalCode: legacyCustomer.postalCode ?? '',
      dateOfBirth: legacyCustomer.dateOfBirth,
      gender: legacyCustomer.gender ?? '',
      loyaltyTier: legacyCustomer.loyaltyTier ?? 'Bronze',
      totalSpent: legacyCustomer.totalSpent?.toDouble() ?? 0.0,
      totalOrders: legacyCustomer.totalOrders ?? 0,
      averageOrderValue: legacyCustomer.averageOrderValue?.toDouble() ?? 0.0,
      lastVisit: legacyCustomer.lastVisit,
      isActive: legacyCustomer.isActive ?? true,
      customerSegment: legacyCustomer.customerSegment ?? 'Regular',
      preferredContactMode: legacyCustomer.preferredContactMode ?? 'SMS',
      preferredStoreId: legacyCustomer.preferredStoreId,
      marketingOptIn: legacyCustomer.marketingOptIn ?? false,
      referralCode: legacyCustomer.referralCode,
      referredBy: legacyCustomer.referredBy,
      supportTickets: legacyCustomer.supportTickets ?? [],
      feedbackNotes: legacyCustomer.feedbackNotes ?? [],
      createdAt: legacyCustomer.createdAt ?? DateTime.now(),
      updatedAt: legacyCustomer.updatedAt ?? DateTime.now(),
      metadata: legacyCustomer.metadata ?? {},
    );
  }
}
