// Enhanced ERP System - Enhanced POS Service
// Provides event-driven POS operations with real-time integration and business intelligence

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// Legacy import removed - using unified models instead
import '../../services/pos_service.dart';
import '../../services/inventory_service.dart';
import '../../services/customer_profile_service.dart';
import '../events/erp_events.dart';
import '../events/erp_event_bus.dart';
import '../orchestration/transaction_orchestrator.dart';
import '../models/index.dart';
import 'enhanced_service_base.dart';

class EnhancedPOSService extends EnhancedERPService 
    with TransactionCapable, RealTimeSyncCapable, AnalyticsCapable {
  
  static EnhancedPOSService? _instance;
  
  EnhancedPOSService._(ERPEventBus eventBus, TransactionOrchestrator orchestrator)
      : super(eventBus, orchestrator);

  static EnhancedPOSService getInstance(ERPEventBus eventBus, TransactionOrchestrator orchestrator) {
    _instance ??= EnhancedPOSService._(eventBus, orchestrator);
    return _instance!;
  }

  @override
  Future<void> setupEventListeners() async {
    // Listen to inventory updates for real-time stock validation
    listenToEvent<InventoryUpdatedEvent>(_handleInventoryUpdate);
    
    // Listen to customer events for personalized offers
    listenToEvent<CustomerProfileUpdatedEvent>(_handleCustomerUpdate);
    
    // Listen to low stock alerts
    listenToEvent<LowStockAlertEvent>(_handleLowStockAlert);
    
    // Setup real-time sync
    setupRealTimeSync();
  }

  @override
  void listenToDataChanges() {
    // Listen to price changes, promotions, etc.
    listenToEvent<ProductUpdatedEvent>(_handleProductUpdate);
  }

  /// Enhanced transaction creation with full business logic integration
  Future<String> createEnhancedTransaction({
    required List<UnifiedCartItem> items,
    required String storeId,
    required String cashierId,
    String? customerId,
    double discountAmount = 0.0,
    String paymentMethod = 'cash',
    Map<String, dynamic> metadata = const {},
  }) async {
    return await executeInTransaction(
      'pos_transaction_${DateTime.now().millisecondsSinceEpoch}',
      () async {
        // 1. Validate inventory availability
        await _validateInventoryAvailability(items, storeId);

        // 2. Calculate totals and apply business rules
        final transactionData = await _calculateTransactionTotals(items, customerId, discountAmount);

        // 3. Create the POS transaction using unified model
        final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
        final now = DateTime.now();
        final unifiedTransaction = PosTransaction(
          id: transactionId,
          posTransactionId: transactionId,
          transactionId: transactionId,
          storeId: storeId,
          terminalId: 'terminal_001',
          cashierId: cashierId,
          customerId: customerId,
          productItems: items.map((item) => UnifiedPOSTransactionItem(
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            totalPrice: item.totalPrice,
            discount: item.discount ?? 0.0,
          )).toList(),
          subTotal: transactionData['subtotal'] ?? 0.0,
          taxAmount: 0.0,
          discountApplied: transactionData['discountAmount'] ?? 0.0,
          roundOffAmount: 0.0,
          totalAmount: transactionData['totalAmount'] ?? 0.0,
          paymentMode: paymentMethod,
          walletUsed: 0.0,
          changeReturned: 0.0,
          loyaltyPointsEarned: 0,
          loyaltyPointsUsed: 0,
          invoiceNumber: 'INV_${now.millisecondsSinceEpoch}',
          invoiceType: 'SALES',
          refundStatus: 'NONE',
          syncedToServer: true,
          syncedToInventory: false,
          syncedToFinance: false,
          isOfflineMode: false,
          pricingEngineSnapshot: {},
          taxBreakup: {},
          createdAt: now,
          updatedAt: now,
        );

        // 4. Save transaction to database
        debugPrint('💾 Saving POS transaction to Firestore...');
        final savedTransactionId = await PosService.createTransaction(unifiedTransaction as dynamic);
        debugPrint('✅ POS transaction saved with ID: $savedTransactionId');

        // 5. Emit POS transaction created event
        debugPrint('📡 Emitting POS transaction event for business logic updates...');
        emitEvent(POSTransactionCreatedEvent(
          eventId: 'pos_created_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedPOSService',
          transactionId: transactionId,
          storeId: storeId,
          cashierId: cashierId,
          customerId: customerId,
          items: items.map((item) => {
            'product_id': item.productId,
            'product_name': item.productName,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
            'total_price': item.totalPrice,
          }).toList(),
          totalAmount: transactionData['totalAmount'] ?? 0.0,
          paymentMethod: paymentMethod,
        ));
        debugPrint('✅ POS event emitted - inventory and loyalty updates will be triggered');

        // 6. Update customer loyalty points if applicable
        if (customerId != null) {
          debugPrint('🎁 Updating customer loyalty points for customer: $customerId');
          await _updateCustomerLoyalty(customerId, transactionData['totalAmount'] ?? 0.0);
          debugPrint('✅ Customer loyalty points updated');
        } else {
          debugPrint('⚠️ No customer ID provided - skipping loyalty points update');
        }

        // 7. Track analytics
        debugPrint('📊 Tracking transaction analytics...');
        _trackTransactionAnalytics(unifiedTransaction, items);
        debugPrint('✅ Analytics tracked');

        debugPrint('══════════════════════════════════════════════════════════');
        debugPrint('🎉 POS Transaction Complete!');
        debugPrint('📄 Transaction ID: $transactionId');
        debugPrint('💰 Total Amount: \$${transactionData['totalAmount']?.toStringAsFixed(2)}');
        debugPrint('🛍️ Items: ${items.length}');
        debugPrint('🏪 Store: $storeId');
        debugPrint('══════════════════════════════════════════════════════════');
        return transactionId;
      },
      affectedModules: ['pos', 'inventory', 'customer', 'analytics'],
      metadata: {
        ...metadata,
        'item_count': items.length,
        'customer_transaction': customerId != null,
      },
    );
  }

  /// Validate inventory availability for all items
  Future<void> _validateInventoryAvailability(List<UnifiedCartItem> items, String storeId) async {
    debugPrint('🔍 Validating inventory for ${items.length} items...');
    
    for (final item in items) {
      debugPrint('  • Checking stock for: ${item.productName} (ID: ${item.productId})');
      final inventory = await InventoryService.getInventoryByProductId(item.productId);
      
      if (inventory == null) {
        debugPrint('❌ Product not found in inventory: ${item.productId}');
        throw Exception('Product not found in inventory: ${item.productId}');
      }
      
      debugPrint('    Current stock: ${inventory.currentQuantity}, Requested: ${item.quantity}');
      
      if (inventory.currentQuantity < item.quantity) {
        debugPrint('❌ Insufficient stock for ${item.productName}');
        throw Exception(
          'Insufficient stock for ${item.productName}. '
          'Available: ${inventory.currentQuantity}, Requested: ${item.quantity}'
        );
      }
      
      debugPrint('    ✅ Stock validation passed');
    }
    
    debugPrint('✅ All inventory validations passed');
  }

  /// Calculate transaction totals with business rules
  Future<Map<String, double>> _calculateTransactionTotals(
    List<UnifiedCartItem> items,
    String? customerId,
    double discountAmount,
  ) async {
    double subtotal = 0.0;
    double taxAmount = 0.0;
    double totalDiscountAmount = discountAmount;

    // Calculate item totals
    for (final item in items) {
      subtotal += item.totalPrice;
      taxAmount += item.taxAmount;
      totalDiscountAmount += item.discountAmount;
    }

    // Apply customer-specific discounts
    if (customerId != null) {
      final customerDiscount = await _calculateCustomerDiscount(customerId, subtotal);
      totalDiscountAmount += customerDiscount;
    }

    final totalAmount = subtotal + taxAmount - totalDiscountAmount;

    return {
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': totalDiscountAmount,
      'totalAmount': totalAmount,
    };
  }

  /// Calculate customer-specific discounts
  Future<double> _calculateCustomerDiscount(String customerId, double subtotal) async {
    try {
      final customer = await CustomerProfileService.getProfile(customerId);
      if (customer != null) {
        // Apply loyalty discount based on customer tier
        switch (customer.loyaltyTier) {
          case 'Gold':
            return subtotal * 0.10; // 10% discount
          case 'Silver':
            return subtotal * 0.05; // 5% discount
          default:
            return 0.0;
        }
      }
    } catch (e) {
      debugPrint('Error calculating customer discount: $e');
    }
    return 0.0;
  }

  /// Update customer loyalty points
  Future<void> _updateCustomerLoyalty(String customerId, double transactionAmount) async {
    try {
      // Calculate points (1 point per dollar spent)
      final pointsEarned = transactionAmount.floor();
      
      emitEvent(CustomerLoyaltyUpdatedEvent(
        eventId: 'loyalty_update_${DateTime.now().millisecondsSinceEpoch}',
        source: 'EnhancedPOSService',
        customerId: customerId,
        pointsEarned: pointsEarned,
        transactionAmount: transactionAmount,
        metadata: {'transaction_source': 'pos'},
      ));
      
      debugPrint('🎯 Customer $customerId earned $pointsEarned loyalty points');
    } catch (e) {
      debugPrint('Error updating customer loyalty: $e');
    }
  }

  /// Track comprehensive transaction analytics
  void _trackTransactionAnalytics(PosTransaction transaction, List<UnifiedCartItem> items) {
    // Track overall transaction metrics
    trackMetric('pos.transaction_amount', transaction.totalAmount, tags: {
      'store_id': transaction.storeId ?? 'unknown',
      'payment_method': transaction.paymentMode,
      'has_customer': (transaction.customerId != null).toString(),
    });

    trackMetric('pos.transaction_count', 1.0, tags: {
      'store_id': transaction.storeId ?? 'unknown',
      'cashier_id': transaction.cashierId,
    });

    // Track item-level metrics
    for (final item in items) {
      trackMetric('pos.item_sold', item.quantity.toDouble(), tags: {
        'product_id': item.productId,
        'store_id': transaction.storeId ?? 'unknown',
      });

      trackMetric('pos.revenue_per_product', item.totalPrice, tags: {
        'product_id': item.productId,
        'store_id': transaction.storeId ?? 'unknown',
      });
    }

    // Track hourly sales patterns
    final hour = transaction.createdAt.hour;
    trackMetric('pos.hourly_sales', transaction.totalAmount, tags: {
      'hour': hour.toString(),
      'store_id': transaction.storeId ?? 'unknown',
    });
  }

  /// Handle inventory updates for real-time stock display
  Future<void> _handleInventoryUpdate(InventoryUpdatedEvent event) async {
    // Emit real-time stock update to POS terminals
    emitEvent(POSStockUpdateEvent(
      eventId: 'pos_stock_${DateTime.now().millisecondsSinceEpoch}',
      source: 'EnhancedPOSService',
      productId: event.productId,
      newQuantity: event.newQuantity,
      location: event.location,
    ));
  }

  /// Handle customer profile updates for personalized experience
  Future<void> _handleCustomerUpdate(CustomerProfileUpdatedEvent event) async {
    // Could trigger personalized offers, update loyalty display, etc.
    debugPrint('📱 Customer profile updated: ${event.customerId}');
  }

  /// Handle low stock alerts at POS
  Future<void> _handleLowStockAlert(LowStockAlertEvent event) async {
    // Notify POS terminals about low stock items
    emitEvent(POSLowStockNotificationEvent(
      eventId: 'pos_low_stock_${DateTime.now().millisecondsSinceEpoch}',
      source: 'EnhancedPOSService',
      productId: event.productId,
      currentQuantity: event.currentQuantity,
      minimumQuantity: event.minimumQuantity,
      location: event.location,
    ));
    
    debugPrint('⚠️ POS notified of low stock: ${event.productId}');
  }

  /// Handle product updates (price changes, etc.)
  Future<void> _handleProductUpdate(ProductUpdatedEvent event) async {
    // Emit price update to POS terminals
    emitEvent(POSPriceUpdateEvent(
      eventId: 'pos_price_${DateTime.now().millisecondsSinceEpoch}',
      source: 'EnhancedPOSService',
      productId: event.productId,
      metadata: event.metadata,
    ));
  }

  /// Get enhanced transaction history with analytics
  Stream<List<UnifiedPOSTransaction>> getEnhancedTransactionStream(String storeId) {
    return PosService.getTransactionsByStore(storeId).map((transactions) {
      return transactions.map((transaction) => UnifiedPOSTransaction(
        id: transaction.posTransactionId,
        posTransactionId: transaction.posTransactionId,
        transactionId: transaction.posTransactionId,
        storeId: transaction.storeId,
        terminalId: transaction.terminalId,
        cashierId: transaction.cashierId,
        customerId: transaction.customerId,
        productItems: transaction.productItems.map((item) => UnifiedPOSTransactionItem(
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.sellingPrice,
          totalPrice: item.finalPrice,
          discount: item.discountAmount,
        )).toList(),
        subTotal: transaction.subTotal,
        taxAmount: 0.0, // Use taxAmount if available
        discountApplied: transaction.discountApplied,
        roundOffAmount: transaction.roundOffAmount,
        totalAmount: transaction.totalAmount,
        paymentMode: transaction.paymentMode,
        walletUsed: transaction.walletUsed,
        changeReturned: transaction.changeReturned,
        loyaltyPointsEarned: transaction.loyaltyPointsEarned,
        loyaltyPointsUsed: transaction.loyaltyPointsUsed,
        invoiceNumber: transaction.invoiceNumber,
        invoiceType: transaction.invoiceType,
        refundStatus: transaction.refundStatus,
        syncedToServer: transaction.syncedToServer,
        syncedToInventory: transaction.syncedToInventory,
        syncedToFinance: transaction.syncedToFinance,
        isOfflineMode: transaction.isOfflineMode,
        pricingEngineSnapshot: transaction.pricingEngineSnapshot,
        taxBreakup: transaction.taxBreakup,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
      )).toList();
    });
  }

  bool _isPeakHour(DateTime transactionTime) {
    final hour = transactionTime.hour;
    return (hour >= 11 && hour <= 13) || (hour >= 17 && hour <= 19); // Lunch and dinner rush
  }

  /// Process returns with full business logic
  Future<String> processReturn({
    required String originalTransactionId,
    required List<UnifiedReturnItem> returnItems,
    required String reason,
    required String processedBy,
    Map<String, dynamic> metadata = const {},
  }) async {
    return await executeInTransaction(
      'pos_return_${DateTime.now().millisecondsSinceEpoch}',
      () async {
        // 1. Validate original transaction
        final originalTransaction = await PosService.getTransaction(originalTransactionId);
        if (originalTransaction == null) {
          throw Exception('Original transaction not found: $originalTransactionId');
        }

        // 2. Process return items and update inventory
        double refundAmount = 0.0;
        for (final returnItem in returnItems) {
          // Add quantity back to inventory
          emitEvent(InventoryAdjustmentEvent(
            eventId: 'return_adj_${DateTime.now().millisecondsSinceEpoch}',
            source: 'EnhancedPOSService',
            productId: returnItem.productId,
            adjustmentQuantity: returnItem.quantity,
            reason: 'Product Return',
            location: originalTransaction.storeId ?? 'unknown',
            metadata: {
              'original_transaction_id': originalTransactionId,
              'return_reason': reason,
            },
          ));

          refundAmount += returnItem.totalRefund;
        }

        // 3. Create return record
        final returnId = 'return_${DateTime.now().millisecondsSinceEpoch}';
        
        // 4. Emit return event
        emitEvent(POSReturnProcessedEvent(
          eventId: 'pos_return_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedPOSService',
          returnId: returnId,
          originalTransactionId: originalTransactionId,
          returnItems: returnItems.map((item) => item.toMap()).toList(),
          refundAmount: refundAmount,
          reason: reason,
          processedBy: processedBy,
          metadata: metadata,
        ));

        // 5. Track analytics
        trackMetric('pos.return_amount', refundAmount, tags: {
          'store_id': originalTransaction.storeId ?? 'unknown',
          'reason': reason,
        });

        debugPrint('✅ Return processed: $returnId, Refund: $refundAmount');
        return returnId;
      },
      affectedModules: ['pos', 'inventory', 'analytics'],
      metadata: {
        ...metadata,
        'return_item_count': returnItems.length,
        'original_transaction_id': originalTransactionId,
      },
    );
  }
}
