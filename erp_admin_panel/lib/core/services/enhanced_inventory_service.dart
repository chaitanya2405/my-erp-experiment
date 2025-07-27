// Enhanced ERP System - Enhanced Inventory Service
// Provides event-driven inventory management with real-time sync and analytics

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/inventory_models.dart' as legacy;
import '../../services/inventory_service.dart';
import '../../services/product_service.dart';
import '../events/erp_events.dart';
import '../events/erp_event_bus.dart';
import '../orchestration/transaction_orchestrator.dart';
import '../models/index.dart';
import 'enhanced_service_base.dart';

class EnhancedInventoryService extends EnhancedERPService 
    with TransactionCapable, RealTimeSyncCapable, AnalyticsCapable {
  
  static EnhancedInventoryService? _instance;
  
  EnhancedInventoryService._(ERPEventBus eventBus, TransactionOrchestrator orchestrator)
      : super(eventBus, orchestrator);

  static EnhancedInventoryService getInstance(ERPEventBus eventBus, TransactionOrchestrator orchestrator) {
    _instance ??= EnhancedInventoryService._(eventBus, orchestrator);
    return _instance!;
  }

  @override
  Future<void> setupEventListeners() async {
    // Listen to POS sales to update inventory
    listenToEvent<POSTransactionCreatedEvent>(_handlePOSTransaction);
    
    // Listen to purchase orders to update inventory
    listenToEvent<PurchaseOrderReceivedEvent>(_handlePurchaseOrderReceived);
    
    // Listen to inventory adjustments
    listenToEvent<InventoryAdjustmentEvent>(_handleInventoryAdjustment);
    
    // Setup real-time sync
    setupRealTimeSync();
  }

  @override
  void listenToDataChanges() {
    // Listen to low stock situations
    listenToEvent<InventoryUpdatedEvent>(_checkLowStock);
  }

  /// Enhanced inventory update with event emission and validation
  Future<void> updateInventoryQuantity({
    required String productId,
    required int quantityChange,
    required String reason,
    required String location,
    String? transactionId,
    Map<String, dynamic> metadata = const {},
  }) async {
    await executeInTransaction(
      'inventory_update_${productId}_${DateTime.now().millisecondsSinceEpoch}',
      () async {
        // Get current inventory
        final currentInventory = await InventoryService.getInventoryByProductId(productId);
        if (currentInventory == null) {
          throw Exception('Inventory record not found for product: $productId');
        }

        final previousQuantity = currentInventory.currentQuantity;
        final newQuantity = previousQuantity + quantityChange;

        // Validate the operation
        if (newQuantity < 0) {
          throw Exception('Insufficient inventory. Available: $previousQuantity, Requested: ${quantityChange.abs()}');
        }

        // Update inventory record
        final updatedRecord = legacy.InventoryRecord(
          inventoryId: currentInventory.inventoryId,
          productId: productId,
          storeLocation: currentInventory.storeLocation,
          quantityAvailable: newQuantity,
          quantityReserved: currentInventory.quantityReserved,
          quantityOnOrder: currentInventory.quantityOnOrder,
          quantityDamaged: currentInventory.quantityDamaged,
          quantityReturned: currentInventory.quantityReturned,
          reorderPoint: currentInventory.reorderPoint,
          batchNumber: currentInventory.batchNumber,
          expiryDate: currentInventory.expiryDate,
          manufactureDate: currentInventory.manufactureDate,
          storageLocation: currentInventory.storageLocation,
          entryMode: currentInventory.entryMode,
          lastUpdated: Timestamp.fromDate(DateTime.now()),
          stockStatus: currentInventory.stockStatus,
          addedBy: currentInventory.addedBy,
          remarks: currentInventory.remarks,
          fifoLifoFlag: currentInventory.fifoLifoFlag,
          auditFlag: currentInventory.auditFlag,
          autoRestockEnabled: currentInventory.autoRestockEnabled,
          lastSoldDate: currentInventory.lastSoldDate,
          safetyStockLevel: currentInventory.safetyStockLevel,
          averageDailyUsage: currentInventory.averageDailyUsage,
          stockTurnoverRatio: currentInventory.stockTurnoverRatio,
        );

        await InventoryService.updateInventory(currentInventory.inventoryId, updatedRecord);

        // Log the movement
        final movementLog = legacy.InventoryMovementLog(
          movementId: 'mov_${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          fromLocation: location,
          toLocation: location,
          quantity: quantityChange.abs(),
          movementType: quantityChange > 0 ? 'IN' : 'OUT',
          initiatedBy: 'system',
          timestamp: Timestamp.now(),
        );

        await InventoryService.logMovement(movementLog);

        // Emit inventory updated event
        emitEvent(InventoryUpdatedEvent(
          eventId: 'inv_update_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedInventoryService',
          productId: productId,
          previousQuantity: previousQuantity.toInt(),
          newQuantity: newQuantity.toInt(),
          location: location,
          reason: reason,
          metadata: {
            ...metadata,
            'transaction_id': transactionId,
            'movement_id': movementLog.movementId,
          },
        ));

        // Track analytics
        trackMetric('inventory.quantity_changed', quantityChange.toDouble(), tags: {
          'product_id': productId,
          'location': location,
          'reason': reason,
        });

        debugPrint('✅ Inventory updated for $productId: $previousQuantity → $newQuantity ($reason)');
      },
      affectedModules: ['inventory', 'analytics'],
      metadata: metadata,
    );
  }

  /// Handle POS transaction to update inventory
  Future<void> _handlePOSTransaction(POSTransactionCreatedEvent event) async {
    debugPrint('📦 Processing inventory updates for POS transaction: ${event.transactionId}');
    
    for (final item in event.items) {
      try {
        await updateInventoryQuantity(
          productId: item['product_id'] ?? '',
          quantityChange: -(item['quantity'] ?? 0), // Subtract sold quantity
          reason: 'POS Sale',
          location: event.storeId,
          transactionId: event.transactionId,
          metadata: {
            'pos_transaction_id': event.transactionId,
            'cashier_id': event.cashierId,
            'customer_id': event.customerId,
          },
        );
      } catch (e) {
        debugPrint('❌ Failed to update inventory for product ${item['product_id']}: $e');
        // Emit error event for handling
        emitEvent(InventoryErrorEvent(
          eventId: 'inv_error_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedInventoryService',
          errorType: 'inventory_update_failed',
          productId: item['product_id'] ?? '',
          errorMessage: e.toString(),
          metadata: {
            'pos_transaction_id': event.transactionId,
            'attempted_quantity': item['quantity'] ?? 0,
          },
        ));
      }
    }
  }

  /// Handle purchase order received to update inventory
  Future<void> _handlePurchaseOrderReceived(PurchaseOrderReceivedEvent event) async {
    debugPrint('📦 Processing inventory updates for received PO: ${event.purchaseOrderId}');
    
    for (final item in event.items) {
      try {
        await updateInventoryQuantity(
          productId: item['product_id'] ?? '',
          quantityChange: item['received_quantity'] ?? 0,
          reason: 'Purchase Order Received',
          location: item['received_location'] ?? 'main_warehouse',
          transactionId: event.purchaseOrderId,
          metadata: {
            'po_id': event.purchaseOrderId,
            'supplier_id': event.supplierId,
            'po_line_item_id': item['line_item_id'],
            'ordered_quantity': item['ordered_quantity'] ?? 0,
            'received_quantity': item['received_quantity'] ?? 0,
          },
        );
      } catch (e) {
        debugPrint('❌ Failed to update inventory for PO item ${item['product_id']}: $e');
        emitEvent(InventoryErrorEvent(
          eventId: 'inv_error_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedInventoryService',
          errorType: 'po_inventory_update_failed',
          productId: item['product_id'] ?? '',
          errorMessage: e.toString(),
          metadata: {
            'po_id': event.purchaseOrderId,
            'line_item_id': item['line_item_id'],
          },
        ));
      }
    }
  }

  /// Handle manual inventory adjustments
  Future<void> _handleInventoryAdjustment(InventoryAdjustmentEvent event) async {
    debugPrint('📦 Processing inventory adjustment for: ${event.productId}');
    
    try {
      await updateInventoryQuantity(
        productId: event.productId,
        quantityChange: event.adjustmentQuantity,
        reason: event.reason,
        location: event.location,
        metadata: event.metadata,
      );
    } catch (e) {
      debugPrint('❌ Failed to process inventory adjustment: $e');
      emitEvent(InventoryErrorEvent(
        eventId: 'inv_error_${DateTime.now().millisecondsSinceEpoch}',
        source: 'EnhancedInventoryService',
        errorType: 'adjustment_failed',
        productId: event.productId,
        errorMessage: e.toString(),
        metadata: event.metadata,
      ));
    }
  }

  /// Check for low stock and emit alerts
  Future<void> _checkLowStock(InventoryUpdatedEvent event) async {
    final inventory = await InventoryService.getInventoryByProductId(event.productId);
    if (inventory != null && inventory.quantityAvailable <= inventory.reorderPoint) {
      // Get product name from product service or use productId as fallback
      String productName = event.productId; // Fallback
      try {
        final product = await ProductService.getProductById(event.productId);
        if (product != null) {
          productName = product.productName;
        }
      } catch (e) {
        debugPrint('Could not fetch product name for ${event.productId}');
      }

      emitEvent(LowStockAlertEvent(
        eventId: 'low_stock_${DateTime.now().millisecondsSinceEpoch}',
        source: 'EnhancedInventoryService',
        productId: event.productId,
        productName: productName,
        currentQuantity: inventory.quantityAvailable.toInt(),
        minimumQuantity: inventory.reorderPoint.toInt(),
        location: event.location,
        metadata: {
          'severity': inventory.quantityAvailable == 0 ? 'critical' : 'warning',
          'suggested_reorder_quantity': (inventory.reorderPoint * 2).toInt(), // Simple calculation
        },
      ));

      // Track low stock metric
      trackMetric('inventory.low_stock_alert', 1.0, tags: {
        'product_id': event.productId,
        'location': event.location,
        'severity': inventory.currentQuantity == 0 ? 'critical' : 'warning',
      });

      debugPrint('⚠️ Low stock alert for ${event.productId}: ${inventory.currentQuantity}/${inventory.minimumQuantity}');
    }
  }

  /// Get real-time inventory stream with enhanced data
  Stream<List<UnifiedInventoryRecord>> getEnhancedInventoryStream() {
    return InventoryService.getInventoryStream().map((inventoryList) {
      return inventoryList.map((inventory) => UnifiedInventoryRecord(
        id: inventory.inventoryId,
        productId: inventory.productId,
        productName: '', // Will be populated separately
        quantityAvailable: inventory.quantityAvailable.toInt(),
        quantityOnOrder: inventory.quantityOnOrder.toInt(),
        quantityReserved: inventory.quantityReserved.toInt(),
        quantityDamaged: inventory.quantityDamaged.toInt(),
        quantityReturned: inventory.quantityReturned.toInt(),
        reorderPoint: inventory.reorderPoint.toInt(),
        safetyStockLevel: inventory.safetyStockLevel.toInt(),
        averageDailyUsage: inventory.averageDailyUsage.toDouble(),
        stockTurnoverRatio: inventory.stockTurnoverRatio.toDouble(),
        storageLocation: inventory.storageLocation,
        storeLocation: inventory.storeLocation,
        batchNumber: inventory.batchNumber,
        entryMode: inventory.entryMode,
        addedBy: inventory.addedBy,
        autoRestockEnabled: inventory.autoRestockEnabled,
        fifoLifoFlag: inventory.fifoLifoFlag,
        stockStatus: inventory.stockStatus,
        auditFlag: inventory.auditFlag,
        remarks: inventory.remarks,
        createdAt: DateTime.now(), // Fallback
        updatedAt: inventory.lastUpdated.toDate(),
        maximumQuantity: 1000, // Default value - will be set properly
        location: inventory.storageLocation,
        costPrice: 0.0, // Will be fetched from product data
      )).toList();
    });
  }

  /// Bulk inventory update for efficiency
  Future<void> bulkUpdateInventory(List<Map<String, dynamic>> updates) async {
    await executeInTransaction(
      'bulk_inventory_update_${DateTime.now().millisecondsSinceEpoch}',
      () async {
        for (final update in updates) {
          await updateInventoryQuantity(
            productId: update['product_id'],
            quantityChange: update['quantity_change'],
            reason: update['reason'] ?? 'Bulk Update',
            location: update['location'] ?? 'main_warehouse',
            metadata: update['metadata'] ?? {},
          );
        }
      },
      affectedModules: ['inventory', 'analytics'],
      metadata: {'bulk_update_count': updates.length},
    );
  }
}
