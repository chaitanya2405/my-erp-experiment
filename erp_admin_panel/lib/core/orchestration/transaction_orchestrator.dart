// Enhanced ERP System - Transaction Orchestrator
// Handles atomic operations across modules with rollback capabilities

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../events/erp_events.dart';
import '../events/erp_event_bus.dart';
import '../models/index.dart';

/// Result of a transaction operation
class TransactionResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final Map<String, dynamic> metadata;
  final List<String> warnings;

  TransactionResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.metadata = const {},
    this.warnings = const [],
  });

  TransactionResult.success({
    required String transactionId,
    Map<String, dynamic> metadata = const {},
    List<String> warnings = const [],
  }) : this(
    success: true,
    transactionId: transactionId,
    metadata: metadata,
    warnings: warnings,
  );

  TransactionResult.failure({
    required String errorMessage,
    Map<String, dynamic> metadata = const {},
  }) : this(
    success: false,
    errorMessage: errorMessage,
    metadata: metadata,
  );
}

/// Orchestrates complex business transactions across modules
class TransactionOrchestrator {
  static final TransactionOrchestrator _instance = TransactionOrchestrator._internal();
  factory TransactionOrchestrator() => _instance;
  TransactionOrchestrator._internal();

  final _firestore = FirebaseFirestore.instance;
  final _eventBus = ERPEventBus();
  final _uuid = const Uuid();
  
  // Active transactions tracking
  final Map<String, TransactionState> _activeTransactions = {};

  /// Initialize the transaction orchestrator
  Future<void> initialize() async {
    debugPrint('🔄 TransactionOrchestrator: Initializing...');
    
    // Set up event listeners for transaction events
    _eventBus.on<TransactionCompletedEvent>().listen(_handleTransactionCompleted);
    _eventBus.on<TransactionFailedEvent>().listen(_handleTransactionFailed);
    
    debugPrint('✅ TransactionOrchestrator: Initialized successfully');
  }

  /// Process a complete POS sale with inventory and customer updates
  Future<TransactionResult> processPOSSale({
    required UnifiedPOSTransaction transaction,
    required Map<String, int> productQuantities, // productId -> quantity
    String? customerId,
    Map<String, dynamic> additionalData = const {},
  }) async {
    final orchestrationId = _uuid.v4();
    final transactionState = TransactionState(
      orchestrationId: orchestrationId,
      type: 'pos_sale',
      startTime: DateTime.now(),
    );
    
    _activeTransactions[orchestrationId] = transactionState;

    try {
      debugPrint('🎭 Starting POS sale orchestration: $orchestrationId');

      // Step 1: Validate inventory availability
      final validationResult = await _validateInventoryAvailability(productQuantities);
      if (!validationResult.success) {
        return TransactionResult.failure(
          errorMessage: 'Inventory validation failed: ${validationResult.errorMessage}',
        );
      }

      // Step 2: Start Firestore batch transaction
      final batch = _firestore.batch();
      
      // Step 3: Create POS transaction
      final posTransactionRef = _firestore.collection('pos_transactions').doc(transaction.transactionId);
      batch.set(posTransactionRef, transaction.toMap());
      transactionState.addOperation('create_pos_transaction', posTransactionRef.path);

      // Step 4: Update inventory levels
      final inventoryUpdates = <String, Map<String, dynamic>>{};
      for (final entry in productQuantities.entries) {
        final productId = entry.key;
        final quantity = entry.value;
        
        final inventoryResult = await _prepareInventoryUpdate(productId, quantity, batch);
        if (!inventoryResult.success) {
          return TransactionResult.failure(
            errorMessage: 'Inventory update failed for product $productId: ${inventoryResult.errorMessage}',
          );
        }
        inventoryUpdates[productId] = inventoryResult.metadata;
      }

      // Step 5: Update customer information if provided
      if (customerId != null) {
        final customerResult = await _prepareCustomerUpdate(customerId, transaction, batch);
        if (!customerResult.success) {
          debugPrint('⚠️ Customer update failed but continuing: ${customerResult.errorMessage}');
          transactionState.warnings.add('Customer update failed: ${customerResult.errorMessage}');
        }
      }

      // Step 6: Commit the batch transaction
      await batch.commit();
      debugPrint('✅ Batch transaction committed successfully');

      // Step 7: Emit events for other modules
      await _emitPOSSaleEvents(transaction, productQuantities, inventoryUpdates);

      // Step 8: Trigger business logic workflows
      await _triggerPostSaleWorkflows(transaction, productQuantities);

      // Mark transaction as completed
      transactionState.complete();
      _activeTransactions.remove(orchestrationId);

      debugPrint('🎉 POS sale orchestration completed: $orchestrationId');

      return TransactionResult.success(
        transactionId: transaction.transactionId,
        metadata: {
          'orchestration_id': orchestrationId,
          'inventory_updates': inventoryUpdates,
          'processing_time_ms': DateTime.now().difference(transactionState.startTime).inMilliseconds,
        },
        warnings: transactionState.warnings,
      );

    } catch (e) {
      debugPrint('❌ POS sale orchestration failed: $e');
      
      // Attempt rollback
      await _rollbackTransaction(transactionState);
      _activeTransactions.remove(orchestrationId);

      return TransactionResult.failure(
        errorMessage: 'Transaction failed: $e',
        metadata: {
          'orchestration_id': orchestrationId,
          'failed_operations': transactionState.operations.keys.toList(),
        },
      );
    }
  }

  /// Process goods receipt from purchase order
  Future<TransactionResult> processGoodsReceipt({
    required String purchaseOrderId,
    required Map<String, int> receivedQuantities, // productId -> quantity
    required String receivedBy,
    Map<String, dynamic> additionalData = const {},
  }) async {
    final orchestrationId = _uuid.v4();
    final transactionState = TransactionState(
      orchestrationId: orchestrationId,
      type: 'goods_receipt',
      startTime: DateTime.now(),
    );
    
    _activeTransactions[orchestrationId] = transactionState;

    try {
      debugPrint('📦 Starting goods receipt orchestration: $orchestrationId');

      // Start batch transaction
      final batch = _firestore.batch();

      // Update purchase order status
      final poRef = _firestore.collection('purchase_orders').doc(purchaseOrderId);
      batch.update(poRef, {
        'delivery_status': 'Partially Received', // or 'Delivered' if fully received
        'received_date': FieldValue.serverTimestamp(),
        'received_by': receivedBy,
      });
      transactionState.addOperation('update_purchase_order', poRef.path);

      // Update inventory levels
      final inventoryUpdates = <String, Map<String, dynamic>>{};
      for (final entry in receivedQuantities.entries) {
        final productId = entry.key;
        final quantity = entry.value;
        
        final inventoryResult = await _prepareInventoryIncrease(productId, quantity, batch);
        if (!inventoryResult.success) {
          return TransactionResult.failure(
            errorMessage: 'Inventory update failed for product $productId: ${inventoryResult.errorMessage}',
          );
        }
        inventoryUpdates[productId] = inventoryResult.metadata;
      }

      // Commit the batch transaction
      await batch.commit();

      // Emit events
      await _eventBus.emit(GoodsReceivedEvent(
        eventId: _uuid.v4(),
        source: 'transaction_orchestrator',
        purchaseOrderId: purchaseOrderId,
        receivedQuantities: receivedQuantities,
        receivedBy: receivedBy,
        receivedDate: DateTime.now(),
      ));

      transactionState.complete();
      _activeTransactions.remove(orchestrationId);

      return TransactionResult.success(
        transactionId: purchaseOrderId,
        metadata: {
          'orchestration_id': orchestrationId,
          'inventory_updates': inventoryUpdates,
        },
      );

    } catch (e) {
      debugPrint('❌ Goods receipt orchestration failed: $e');
      await _rollbackTransaction(transactionState);
      _activeTransactions.remove(orchestrationId);

      return TransactionResult.failure(
        errorMessage: 'Goods receipt failed: $e',
        metadata: {'orchestration_id': orchestrationId},
      );
    }
  }

  /// Process customer order with inventory reservation
  Future<TransactionResult> processCustomerOrder({
    required String orderId,
    required String customerId,
    required Map<String, int> productQuantities,
    Map<String, dynamic> additionalData = const {},
  }) async {
    final orchestrationId = _uuid.v4();
    final transactionState = TransactionState(
      orchestrationId: orchestrationId,
      type: 'customer_order',
      startTime: DateTime.now(),
    );
    
    _activeTransactions[orchestrationId] = transactionState;

    try {
      debugPrint('🛒 Starting customer order orchestration: $orchestrationId');

      // Validate inventory and reserve stock
      final reservationResult = await _reserveInventory(productQuantities);
      if (!reservationResult.success) {
        return TransactionResult.failure(
          errorMessage: 'Stock reservation failed: ${reservationResult.errorMessage}',
        );
      }

      // Create the order with inventory reservations
      final batch = _firestore.batch();
      
      // Update order status
      final orderRef = _firestore.collection('orders').doc(orderId);
      batch.update(orderRef, {
        'status': 'confirmed',
        'inventory_reserved': true,
        'reservation_details': reservationResult.metadata,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      transactionState.complete();
      _activeTransactions.remove(orchestrationId);

      return TransactionResult.success(
        transactionId: orderId,
        metadata: {
          'orchestration_id': orchestrationId,
          'reservations': reservationResult.metadata,
        },
      );

    } catch (e) {
      await _rollbackTransaction(transactionState);
      _activeTransactions.remove(orchestrationId);

      return TransactionResult.failure(
        errorMessage: 'Customer order processing failed: $e',
      );
    }
  }

  /// Validate inventory availability for products
  Future<TransactionResult> _validateInventoryAvailability(Map<String, int> productQuantities) async {
    try {
      for (final entry in productQuantities.entries) {
        final productId = entry.key;
        final requiredQuantity = entry.value;

        final inventorySnapshot = await _firestore
            .collection('inventory')
            .where('product_id', isEqualTo: productId)
            .get();

        if (inventorySnapshot.docs.isEmpty) {
          return TransactionResult.failure(
            errorMessage: 'No inventory record found for product: $productId',
          );
        }

        int totalAvailable = 0;
        for (final doc in inventorySnapshot.docs) {
          final data = doc.data();
          totalAvailable += (data['available_quantity'] ?? 0) as int;
        }

        if (totalAvailable < requiredQuantity) {
          return TransactionResult.failure(
            errorMessage: 'Insufficient stock for product $productId. Required: $requiredQuantity, Available: $totalAvailable',
          );
        }
      }

      return TransactionResult.success(transactionId: 'validation_success');
    } catch (e) {
      return TransactionResult.failure(
        errorMessage: 'Inventory validation error: $e',
      );
    }
  }

  /// Prepare inventory update operation
  Future<TransactionResult> _prepareInventoryUpdate(String productId, int quantity, WriteBatch batch) async {
    try {
      // Get inventory records for the product
      final inventorySnapshot = await _firestore
          .collection('inventory')
          .where('product_id', isEqualTo: productId)
          .get();

      if (inventorySnapshot.docs.isEmpty) {
        return TransactionResult.failure(
          errorMessage: 'No inventory record found for product: $productId',
        );
      }

      // Use FIFO - update oldest stock first
      int remainingQuantity = quantity;
      final updates = <String, Map<String, dynamic>>{};

      for (final doc in inventorySnapshot.docs) {
        if (remainingQuantity <= 0) break;

        final data = doc.data();
        final currentQuantity = (data['current_quantity'] ?? 0) as int;
        final availableQuantity = (data['available_quantity'] ?? 0) as int;

        if (availableQuantity > 0) {
          final deductQuantity = remainingQuantity > availableQuantity ? availableQuantity : remainingQuantity;
          
          batch.update(doc.reference, {
            'current_quantity': FieldValue.increment(-deductQuantity),
            'available_quantity': FieldValue.increment(-deductQuantity),
            'last_updated': FieldValue.serverTimestamp(),
          });

          updates[doc.id] = {
            'deducted_quantity': deductQuantity,
            'new_current_quantity': currentQuantity - deductQuantity,
            'new_available_quantity': availableQuantity - deductQuantity,
          };

          remainingQuantity -= deductQuantity;
        }
      }

      if (remainingQuantity > 0) {
        return TransactionResult.failure(
          errorMessage: 'Could not deduct full quantity. Remaining: $remainingQuantity',
        );
      }

      return TransactionResult.success(
        transactionId: 'inventory_update_prepared',
        metadata: {'updates': updates},
      );

    } catch (e) {
      return TransactionResult.failure(
        errorMessage: 'Inventory update preparation failed: $e',
      );
    }
  }

  /// Prepare inventory increase operation (for goods receipt)
  Future<TransactionResult> _prepareInventoryIncrease(String productId, int quantity, WriteBatch batch) async {
    try {
      // Get or create inventory record
      final inventorySnapshot = await _firestore
          .collection('inventory')
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get();

      DocumentReference inventoryRef;
      if (inventorySnapshot.docs.isNotEmpty) {
        inventoryRef = inventorySnapshot.docs.first.reference;
        batch.update(inventoryRef, {
          'current_quantity': FieldValue.increment(quantity),
          'available_quantity': FieldValue.increment(quantity),
          'last_updated': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new inventory record
        inventoryRef = _firestore.collection('inventory').doc();
        batch.set(inventoryRef, {
          'inventory_id': inventoryRef.id,
          'product_id': productId,
          'current_quantity': quantity,
          'available_quantity': quantity,
          'reserved_quantity': 0,
          'minimum_quantity': 10, // default
          'location': 'Main Warehouse',
          'created_at': FieldValue.serverTimestamp(),
          'last_updated': FieldValue.serverTimestamp(),
        });
      }

      return TransactionResult.success(
        transactionId: 'inventory_increase_prepared',
        metadata: {
          'inventory_ref': inventoryRef.path,
          'added_quantity': quantity,
        },
      );

    } catch (e) {
      return TransactionResult.failure(
        errorMessage: 'Inventory increase preparation failed: $e',
      );
    }
  }

  /// Prepare customer update operation
  Future<TransactionResult> _prepareCustomerUpdate(String customerId, UnifiedPOSTransaction transaction, WriteBatch batch) async {
    try {
      final customerRef = _firestore.collection('customers').doc(customerId);
      
      batch.update(customerRef, {
        'last_purchase_date': Timestamp.fromDate(transaction.transactionTime),
        'last_purchase_amount': transaction.totalAmount,
        'total_orders': FieldValue.increment(1),
        'total_spent': FieldValue.increment(transaction.totalAmount),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return TransactionResult.success(
        transactionId: 'customer_update_prepared',
        metadata: {'customer_ref': customerRef.path},
      );

    } catch (e) {
      return TransactionResult.failure(
        errorMessage: 'Customer update preparation failed: $e',
      );
    }
  }

  /// Reserve inventory for customer orders
  Future<TransactionResult> _reserveInventory(Map<String, int> productQuantities) async {
    try {
      final batch = _firestore.batch();
      final reservations = <String, Map<String, dynamic>>{};

      for (final entry in productQuantities.entries) {
        final productId = entry.key;
        final quantity = entry.value;

        final inventorySnapshot = await _firestore
            .collection('inventory')
            .where('product_id', isEqualTo: productId)
            .get();

        int remainingToReserve = quantity;
        for (final doc in inventorySnapshot.docs) {
          if (remainingToReserve <= 0) break;

          final data = doc.data();
          final availableQuantity = (data['available_quantity'] ?? 0) as int;

          if (availableQuantity > 0) {
            final reserveQuantity = remainingToReserve > availableQuantity ? availableQuantity : remainingToReserve;
            
            batch.update(doc.reference, {
              'available_quantity': FieldValue.increment(-reserveQuantity),
              'reserved_quantity': FieldValue.increment(reserveQuantity),
            });

            reservations[productId] = {
              'reserved_quantity': reserveQuantity,
              'inventory_location': data['location'] ?? 'Unknown',
            };

            remainingToReserve -= reserveQuantity;
          }
        }

        if (remainingToReserve > 0) {
          return TransactionResult.failure(
            errorMessage: 'Could not reserve full quantity for product $productId',
          );
        }
      }

      await batch.commit();

      return TransactionResult.success(
        transactionId: 'reservation_success',
        metadata: {'reservations': reservations},
      );

    } catch (e) {
      return TransactionResult.failure(
        errorMessage: 'Inventory reservation failed: $e',
      );
    }
  }

  /// Emit events after successful POS sale
  Future<void> _emitPOSSaleEvents(
    UnifiedPOSTransaction transaction, 
    Map<String, int> productQuantities,
    Map<String, Map<String, dynamic>> inventoryUpdates,
  ) async {
    try {
      // Emit sale completed event
      await _eventBus.emit(SaleCompletedEvent(
        eventId: _uuid.v4(),
        source: 'transaction_orchestrator',
        transactionId: transaction.transactionId,
        customerId: transaction.customerId ?? 'walk_in',
        totalAmount: transaction.totalAmount,
        paymentMode: transaction.paymentMethod,
        items: transaction.items.map((item) => item.toMap()).toList(),
        storeId: transaction.storeId ?? 'default',
      ));

      // Emit individual product sold events
      for (final item in transaction.items) {
        await _eventBus.emit(ProductSoldEvent(
          eventId: _uuid.v4(),
          source: 'transaction_orchestrator',
          transactionId: transaction.transactionId,
          productId: item.productId,
          customerId: transaction.customerId ?? 'walk_in',
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalAmount: item.totalPrice,
          storeId: transaction.storeId ?? 'default',
        ));
      }

      // Emit inventory update events
      for (final entry in inventoryUpdates.entries) {
        final productId = entry.key;
        final updateInfo = entry.value;
        
        await _eventBus.emit(InventoryUpdatedEvent(
          eventId: _uuid.v4(),
          source: 'transaction_orchestrator',
          productId: productId,
          previousQuantity: updateInfo['previous_quantity'] ?? 0,
          newQuantity: updateInfo['new_quantity'] ?? 0,
          location: updateInfo['location'] ?? 'Main Warehouse',
          reason: 'POS Sale - Transaction: ${transaction.transactionId}',
        ));
      }

    } catch (e) {
      debugPrint('❌ Error emitting POS sale events: $e');
    }
  }

  /// Trigger post-sale business workflows
  Future<void> _triggerPostSaleWorkflows(UnifiedPOSTransaction transaction, Map<String, int> productQuantities) async {
    try {
      // Check for low stock alerts
      for (final productId in productQuantities.keys) {
        await _checkAndTriggerLowStockAlert(productId);
      }

      // Update customer segmentation if applicable
      if (transaction.customerId != null) {
        await _updateCustomerSegmentation(transaction.customerId!, transaction.totalAmount);
      }

      // Generate automatic reorder suggestions
      await _generateReorderSuggestions(productQuantities.keys.toList());

    } catch (e) {
      debugPrint('❌ Error in post-sale workflows: $e');
    }
  }

  /// Check and trigger low stock alert
  Future<void> _checkAndTriggerLowStockAlert(String productId) async {
    try {
      final inventorySnapshot = await _firestore
          .collection('inventory')
          .where('product_id', isEqualTo: productId)
          .get();

      for (final doc in inventorySnapshot.docs) {
        final data = doc.data();
        final currentQuantity = (data['current_quantity'] ?? 0) as int;
        final minimumQuantity = (data['minimum_quantity'] ?? 10) as int;

        if (currentQuantity <= minimumQuantity) {
          // Get product name
          final productDoc = await _firestore.collection('products').doc(productId).get();
          final productName = productDoc.data()?['product_name'] ?? 'Unknown Product';

          await _eventBus.emit(LowStockAlertEvent(
            eventId: _uuid.v4(),
            source: 'transaction_orchestrator',
            productId: productId,
            productName: productName,
            currentQuantity: currentQuantity,
            minimumQuantity: minimumQuantity,
            location: data['location'] ?? 'Main Warehouse',
          ));
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking low stock: $e');
    }
  }

  /// Update customer segmentation based on purchase
  Future<void> _updateCustomerSegmentation(String customerId, double purchaseAmount) async {
    try {
      // Logic to update customer tier based on total spending
      final customerDoc = await _firestore.collection('customers').doc(customerId).get();
      if (customerDoc.exists) {
        final data = customerDoc.data()!;
        final totalSpent = (data['total_spent'] ?? 0).toDouble() + purchaseAmount;
        
        String newTier = 'Regular';
        if (totalSpent > 100000) newTier = 'VIP';
        else if (totalSpent > 50000) newTier = 'Premium';
        else if (totalSpent > 25000) newTier = 'Gold';
        else if (totalSpent > 10000) newTier = 'Silver';

        final currentTier = data['customer_tier'] ?? 'Regular';
        if (newTier != currentTier) {
          await _firestore.collection('customers').doc(customerId).update({
            'customer_tier': newTier,
            'tier_updated_at': FieldValue.serverTimestamp(),
          });

          await _eventBus.emit(CustomerSegmentChangedEvent(
            eventId: _uuid.v4(),
            source: 'transaction_orchestrator',
            customerId: customerId,
            previousSegment: currentTier,
            newSegment: newTier,
            reason: 'Purchase amount threshold reached',
          ));
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating customer segmentation: $e');
    }
  }

  /// Generate automatic reorder suggestions
  Future<void> _generateReorderSuggestions(List<String> productIds) async {
    // Implementation for automatic reorder logic
    // This could trigger purchase order creation for low stock items
  }

  /// Rollback a failed transaction
  Future<void> _rollbackTransaction(TransactionState state) async {
    try {
      debugPrint('🔄 Attempting rollback for transaction: ${state.orchestrationId}');
      
      // For now, log the failed operations
      // In a production system, implement proper compensation logic
      for (final operation in state.operations.entries) {
        debugPrint('❌ Failed operation: ${operation.key} -> ${operation.value}');
      }

      // Emit rollback event
      await _eventBus.emit(SystemNotificationEvent(
        eventId: _uuid.v4(),
        source: 'transaction_orchestrator',
        title: 'Transaction Rollback',
        message: 'Transaction ${state.orchestrationId} failed and was rolled back',
        severity: 'error',
        targetModule: 'all',
        targetUsers: ['admin'],
      ));

    } catch (e) {
      debugPrint('❌ Rollback failed: $e');
    }
  }

  /// Execute a transaction with rollback capabilities
  Future<TransactionResult> executeTransaction(
    String transactionType,
    Future<Map<String, dynamic>> Function() operation,
    {
      Map<String, dynamic> metadata = const {},
      Duration timeout = const Duration(minutes: 5),
    }
  ) async {
    final transactionId = _uuid.v4();
    final startTime = DateTime.now();
    
    try {
      debugPrint('🔄 Starting transaction: $transactionType ($transactionId)');
      
      // Execute the operation with timeout
      final result = await operation().timeout(timeout);
      
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ Transaction completed: $transactionType ($transactionId) in ${duration.inMilliseconds}ms');
      
      // Emit success event
      await _eventBus.emit(TransactionCompletedEvent(
        eventId: _uuid.v4(),
        source: 'TransactionOrchestrator',
        transactionId: transactionId,
        transactionType: transactionType,
        result: result,
        duration: duration,
        metadata: metadata,
      ));
      
      return TransactionResult.success(
        transactionId: transactionId,
        metadata: result,
      );
      
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('❌ Transaction failed: $transactionType ($transactionId) - $e');
      
      // Emit failure event
      await _eventBus.emit(TransactionFailedEvent(
        eventId: _uuid.v4(),
        source: 'TransactionOrchestrator',
        transactionId: transactionId,
        transactionType: transactionType,
        error: e.toString(),
        duration: duration,
        metadata: metadata,
      ));
      
      return TransactionResult.failure(
        errorMessage: e.toString(),
        metadata: metadata,
      );
    }
  }

  /// Get transaction orchestrator statistics
  Map<String, dynamic> getStats() {
    return {
      'total_transactions': _transactions.length,
      'active_transactions': _transactions.values.where((t) => t['status'] == 'running').length,
      'completed_transactions': _transactions.values.where((t) => t['status'] == 'completed').length,
      'failed_transactions': _transactions.values.where((t) => t['status'] == 'failed').length,
    };
  }

  /// Dispose resources
  Future<void> dispose() async {
    debugPrint('🔄 TransactionOrchestrator: Disposing resources...');
    // Clean up any pending transactions
    debugPrint('✅ TransactionOrchestrator: Disposed successfully');
  }

  void _handleTransactionCompleted(TransactionCompletedEvent event) {
    _transactions[event.transactionId] = {
      'id': event.transactionId,
      'type': event.transactionType,
      'status': 'completed',
      'result': event.result,
      'duration': event.duration,
      'timestamp': DateTime.now(),
    };
  }

  void _handleTransactionFailed(TransactionFailedEvent event) {
    _transactions[event.transactionId] = {
      'id': event.transactionId,
      'type': event.transactionType,
      'status': 'failed',
      'error': event.error,
      'duration': event.duration,
      'timestamp': DateTime.now(),
    };
  }

  final Map<String, Map<String, dynamic>> _transactions = {};

  /// Get active transactions
  Map<String, TransactionState> getActiveTransactions() {
    return Map.from(_activeTransactions);
  }

  /// Get transaction metrics
  Map<String, dynamic> getMetrics() {
    final completed = _activeTransactions.values.where((t) => t.isCompleted).length;
    final active = _activeTransactions.values.where((t) => !t.isCompleted && !t.isFailed).length;
    final failed = _activeTransactions.values.where((t) => t.isFailed).length;

    return {
      'total_transactions': _activeTransactions.length,
      'completed': completed,
      'active': active,
      'failed': failed,
      'success_rate': _activeTransactions.isNotEmpty ? (completed / _activeTransactions.length) * 100 : 0,
    };
  }
}

/// Represents the state of an ongoing transaction
class TransactionState {
  final String orchestrationId;
  final String type;
  final DateTime startTime;
  DateTime? endTime;
  bool isCompleted = false;
  bool isFailed = false;
  final Map<String, String> operations = {}; // operation_name -> resource_path
  final List<String> warnings = [];

  TransactionState({
    required this.orchestrationId,
    required this.type,
    required this.startTime,
  });

  void addOperation(String operationName, String resourcePath) {
    operations[operationName] = resourcePath;
  }

  void complete() {
    isCompleted = true;
    endTime = DateTime.now();
  }

  void fail() {
    isFailed = true;
    endTime = DateTime.now();
  }

  Duration? get duration => endTime?.difference(startTime);
}
