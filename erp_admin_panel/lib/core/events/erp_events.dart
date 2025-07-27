// Enhanced ERP System - Event Definitions
// Core event system for cross-module communication

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';

/// Base class for all ERP events
abstract class ERPEvent {
  final String eventId;
  final DateTime timestamp;
  final String source;
  final Map<String, dynamic> metadata;

  ERPEvent({
    required this.eventId,
    required this.source,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'timestamp': Timestamp.fromDate(timestamp),
      'source': source,
      'metadata': metadata,
      'event_type': runtimeType.toString(),
    };
  }
}

// ==================== INVENTORY EVENTS ====================

class InventoryUpdatedEvent extends ERPEvent {
  final String productId;
  final int previousQuantity;
  final int newQuantity;
  final String location;
  final String reason;

  InventoryUpdatedEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.previousQuantity,
    required this.newQuantity,
    required this.location,
    required this.reason,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class LowStockAlertEvent extends ERPEvent {
  final String productId;
  final String productName;
  final int currentQuantity;
  final int minimumQuantity;
  final String location;

  LowStockAlertEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.productName,
    required this.currentQuantity,
    required this.minimumQuantity,
    required this.location,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class OutOfStockEvent extends ERPEvent {
  final String productId;
  final String productName;
  final String location;

  OutOfStockEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.productName,
    required this.location,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

// ==================== SALES EVENTS ====================

class ProductSoldEvent extends ERPEvent {
  final String transactionId;
  final String productId;
  final String customerId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String storeId;

  ProductSoldEvent({
    required String eventId,
    required String source,
    required this.transactionId,
    required this.productId,
    required this.customerId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.storeId,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class SaleCompletedEvent extends ERPEvent {
  final String transactionId;
  final String customerId;
  final double totalAmount;
  final String paymentMode;
  final List<Map<String, dynamic>> items;
  final String storeId;

  SaleCompletedEvent({
    required String eventId,
    required String source,
    required this.transactionId,
    required this.customerId,
    required this.totalAmount,
    required this.paymentMode,
    required this.items,
    required this.storeId,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class RefundProcessedEvent extends ERPEvent {
  final String originalTransactionId;
  final String refundTransactionId;
  final double refundAmount;
  final String reason;
  final List<Map<String, dynamic>> refundedItems;

  RefundProcessedEvent({
    required String eventId,
    required String source,
    required this.originalTransactionId,
    required this.refundTransactionId,
    required this.refundAmount,
    required this.reason,
    required this.refundedItems,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

// ==================== CUSTOMER EVENTS ====================

class CustomerCreatedEvent extends ERPEvent {
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  CustomerCreatedEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class CustomerPurchaseEvent extends ERPEvent {
  final String customerId;
  final String transactionId;
  final double purchaseAmount;
  final int itemCount;
  final DateTime purchaseDate;

  CustomerPurchaseEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.transactionId,
    required this.purchaseAmount,
    required this.itemCount,
    required this.purchaseDate,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class CustomerSegmentChangedEvent extends ERPEvent {
  final String customerId;
  final String previousSegment;
  final String newSegment;
  final String reason;

  CustomerSegmentChangedEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.previousSegment,
    required this.newSegment,
    required this.reason,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

// ==================== PROCUREMENT EVENTS ====================

class PurchaseOrderCreatedEvent extends ERPEvent {
  final String purchaseOrderId;
  final String supplierId;
  final double totalAmount;
  final List<Map<String, dynamic>> items;
  final String priority;

  PurchaseOrderCreatedEvent({
    required String eventId,
    required String source,
    required this.purchaseOrderId,
    required this.supplierId,
    required this.totalAmount,
    required this.items,
    required this.priority,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class PurchaseOrderStatusChangedEvent extends ERPEvent {
  final String purchaseOrderId;
  final String previousStatus;
  final String newStatus;
  final String changedBy;

  PurchaseOrderStatusChangedEvent({
    required String eventId,
    required String source,
    required this.purchaseOrderId,
    required this.previousStatus,
    required this.newStatus,
    required this.changedBy,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class GoodsReceivedEvent extends ERPEvent {
  final String purchaseOrderId;
  final Map<String, int> receivedQuantities; // productId -> quantity
  final String receivedBy;
  final DateTime receivedDate;

  GoodsReceivedEvent({
    required String eventId,
    required String source,
    required this.purchaseOrderId,
    required this.receivedQuantities,
    required this.receivedBy,
    required this.receivedDate,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

// ==================== SUPPLIER EVENTS ====================

class SupplierPerformanceUpdatedEvent extends ERPEvent {
  final String supplierId;
  final double onTimeDeliveryRate;
  final double qualityRating;
  final int totalOrders;
  final double averageLeadTime;

  SupplierPerformanceUpdatedEvent({
    required String eventId,
    required String source,
    required this.supplierId,
    required this.onTimeDeliveryRate,
    required this.qualityRating,
    required this.totalOrders,
    required this.averageLeadTime,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

// ==================== PRODUCT EVENTS ====================

class ProductCreatedEvent extends ERPEvent {
  final String productId;
  final String productName;
  final String category;
  final double price;
  final String supplierId;

  ProductCreatedEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.productName,
    required this.category,
    required this.price,
    required this.supplierId,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class ProductPriceChangedEvent extends ERPEvent {
  final String productId;
  final double previousPrice;
  final double newPrice;
  final String reason;

  ProductPriceChangedEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.previousPrice,
    required this.newPrice,
    required this.reason,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

// ==================== SYSTEM EVENTS ====================

class SystemNotificationEvent extends ERPEvent {
  final String title;
  final String message;
  final String severity; // info, warning, error, critical
  final String targetModule;
  final List<String> targetUsers;

  SystemNotificationEvent({
    required String eventId,
    required String source,
    required this.title,
    required this.message,
    required this.severity,
    required this.targetModule,
    required this.targetUsers,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class ModuleSyncCompletedEvent extends ERPEvent {
  final String moduleName;
  final int recordsProcessed;
  final List<String> errors;
  final Duration syncDuration;

  ModuleSyncCompletedEvent({
    required String eventId,
    required String source,
    required this.moduleName,
    required this.recordsProcessed,
    required this.errors,
    required this.syncDuration,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class SystemInitializedEvent extends ERPEvent {
  final List<String> services;
  final DateTime initializationTime;

  SystemInitializedEvent({
    required String eventId,
    required String source,
    required this.services,
    required this.initializationTime,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class SystemHealthCheckEvent extends ERPEvent {
  final String checkType;

  SystemHealthCheckEvent({
    required String eventId,
    required String source,
    required this.checkType,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

// ==================== TRANSACTION EVENTS ====================

class TransactionCompletedEvent extends ERPEvent {
  final String transactionId;
  final String transactionType;
  final Map<String, dynamic> result;
  final Duration duration;

  TransactionCompletedEvent({
    required String eventId,
    required String source,
    required this.transactionId,
    required this.transactionType,
    required this.result,
    required this.duration,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class TransactionFailedEvent extends ERPEvent {
  final String transactionId;
  final String transactionType;
  final String error;
  final Duration duration;

  TransactionFailedEvent({
    required String eventId,
    required String source,
    required this.transactionId,
    required this.transactionType,
    required this.error,
    required this.duration,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

// ==================== MISSING EVENT CLASSES ====================

class AnalyticsEvent extends ERPEvent {
  final String metricName;
  final Map<String, dynamic> data;

  AnalyticsEvent({
    required String eventId,
    required String source,
    required this.metricName,
    required this.data,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class POSTransactionCreatedEvent extends ERPEvent {
  final String transactionId;
  final String storeId;
  final String cashierId;
  final String? customerId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String paymentMethod;

  POSTransactionCreatedEvent({
    required String eventId,
    required String source,
    required this.transactionId,
    required this.storeId,
    required this.cashierId,
    this.customerId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class CustomerProfileCreatedEvent extends ERPEvent {
  final String customerId;
  final Map<String, dynamic> customerData;

  CustomerProfileCreatedEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.customerData,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class CustomerProfileUpdatedEvent extends ERPEvent {
  final String customerId;
  final Map<String, dynamic> updatedFields;

  CustomerProfileUpdatedEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.updatedFields,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class CustomerLoyaltyUpdatedEvent extends ERPEvent {
  final String customerId;
  final int pointsEarned;
  final double transactionAmount;

  CustomerLoyaltyUpdatedEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.pointsEarned,
    required this.transactionAmount,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class CustomerTierPromotedEvent extends ERPEvent {
  final String customerId;
  final String previousTier;
  final String newTier;
  final double totalSpent;

  CustomerTierPromotedEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.previousTier,
    required this.newTier,
    required this.totalSpent,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class CustomerBehaviorEvent extends ERPEvent {
  final String customerId;
  final String behaviorType;
  final Map<String, dynamic> data;

  CustomerBehaviorEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.behaviorType,
    required this.data,
    required DateTime timestamp,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class CustomerOfferSentEvent extends ERPEvent {
  final String customerId;
  final String offerType;
  final Map<String, dynamic> offerData;
  final DateTime sentDate;

  CustomerOfferSentEvent({
    required String eventId,
    required String source,
    required this.customerId,
    required this.offerType,
    required this.offerData,
    required this.sentDate,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class InventoryAdjustmentEvent extends ERPEvent {
  final String productId;
  final int adjustmentQuantity;
  final String reason;
  final String location;

  InventoryAdjustmentEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.adjustmentQuantity,
    required this.reason,
    required this.location,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class InventoryErrorEvent extends ERPEvent {
  final String errorType;
  final String productId;
  final String errorMessage;

  InventoryErrorEvent({
    required String eventId,
    required String source,
    required this.errorType,
    required this.productId,
    required this.errorMessage,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class PurchaseOrderReceivedEvent extends ERPEvent {
  final String purchaseOrderId;
  final String supplierId;
  final List<Map<String, dynamic>> items;
  final DateTime receivedDate;

  PurchaseOrderReceivedEvent({
    required String eventId,
    required String source,
    required this.purchaseOrderId,
    required this.supplierId,
    required this.items,
    required this.receivedDate,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class AutoReorderTriggeredEvent extends ERPEvent {
  final String productId;
  final String purchaseOrderId;
  final int reorderQuantity;
  final String supplierId;
  final String triggerEvent;

  AutoReorderTriggeredEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.purchaseOrderId,
    required this.reorderQuantity,
    required this.supplierId,
    required this.triggerEvent,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class AutoReorderFailedEvent extends ERPEvent {
  final String productId;
  final String errorMessage;
  final String triggerEvent;

  AutoReorderFailedEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.errorMessage,
    required this.triggerEvent,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class SupplierUpdatedEvent extends ERPEvent {
  final String supplierId;

  SupplierUpdatedEvent({
    required String eventId,
    required String source,
    required this.supplierId,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class ProductUpdatedEvent extends ERPEvent {
  final String productId;

  ProductUpdatedEvent({
    required String eventId,
    required String source,
    required this.productId,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class POSStockUpdateEvent extends ERPEvent {
  final String productId;
  final int newQuantity;
  final String location;

  POSStockUpdateEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.newQuantity,
    required this.location,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class POSLowStockNotificationEvent extends ERPEvent {
  final String productId;
  final int currentQuantity;
  final int minimumQuantity;
  final String location;

  POSLowStockNotificationEvent({
    required String eventId,
    required String source,
    required this.productId,
    required this.currentQuantity,
    required this.minimumQuantity,
    required this.location,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class POSPriceUpdateEvent extends ERPEvent {
  final String productId;

  POSPriceUpdateEvent({
    required String eventId,
    required String source,
    required this.productId,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}

class POSReturnProcessedEvent extends ERPEvent {
  final String returnId;
  final String originalTransactionId;
  final List<Map<String, dynamic>> returnItems;
  final double refundAmount;
  final String reason;
  final String processedBy;

  POSReturnProcessedEvent({
    required String eventId,
    required String source,
    required this.returnId,
    required this.originalTransactionId,
    required this.returnItems,
    required this.refundAmount,
    required this.reason,
    required this.processedBy,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}
