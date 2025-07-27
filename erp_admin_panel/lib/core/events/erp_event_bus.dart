// Enhanced ERP System - Central Event Bus
// Real-time event communication between all modules

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'erp_events.dart';

/// Centralized event bus for cross-module communication
class ERPEventBus {
  static final ERPEventBus _instance = ERPEventBus._internal();
  factory ERPEventBus() => _instance;
  ERPEventBus._internal();

  final _eventController = StreamController<ERPEvent>.broadcast();
  final _subscriptions = <String, StreamSubscription>{};
  final _eventHistory = <ERPEvent>[];
  final _uuid = const Uuid();
  
  // Firestore for event persistence
  final _firestore = FirebaseFirestore.instance;
  final String _eventCollection = 'erp_events';

  // Event metrics
  int _eventsEmitted = 0;
  int _eventsProcessed = 0;
  final Map<String, int> _eventTypeCount = {};

  /// Get the main event stream
  Stream<ERPEvent> get events => _eventController.stream;

  /// Initialize the event bus
  Future<void> initialize() async {
    debugPrint('🚌 ERPEventBus: Initializing...');
    
    // Listen to all events for logging and persistence
    _subscriptions['main_listener'] = events.listen(
      _handleEventForPersistence,
      onError: (error) => debugPrint('❌ ERPEventBus error: $error'),
    );

    // Start Firestore listener for distributed events
    _startFirestoreListener();
    
    debugPrint('✅ ERPEventBus: Initialized successfully');
  }

  /// Emit an event to all subscribers
  Future<void> emit(ERPEvent event) async {
    try {
      _eventsEmitted++;
      _eventTypeCount[event.runtimeType.toString()] = 
          (_eventTypeCount[event.runtimeType.toString()] ?? 0) + 1;

      // Add to local history
      _eventHistory.add(event);
      if (_eventHistory.length > 1000) {
        _eventHistory.removeAt(0); // Keep only last 1000 events
      }

      // Emit to local subscribers
      _eventController.add(event);
      
      debugPrint('📢 Event emitted: ${event.runtimeType} from ${event.source}');
      
    } catch (e) {
      debugPrint('❌ Error emitting event: $e');
    }
  }

  /// Listen to specific event types
  Stream<T> on<T extends ERPEvent>() {
    return events.where((event) => event is T).cast<T>();
  }

  /// Listen to events from specific source
  Stream<ERPEvent> fromSource(String source) {
    return events.where((event) => event.source == source);
  }

  /// Listen to events targeting specific module
  Stream<ERPEvent> forModule(String moduleName) {
    return events.where((event) => 
      event.metadata.containsKey('target_module') && 
      event.metadata['target_module'] == moduleName
    );
  }

  /// Subscribe to events with custom filter
  StreamSubscription<ERPEvent> subscribe(
    String subscriptionId,
    bool Function(ERPEvent) filter,
    void Function(ERPEvent) handler,
  ) {
    final subscription = events
        .where(filter)
        .listen(
          handler,
          onError: (error) => debugPrint('❌ Subscription $subscriptionId error: $error'),
        );
    
    _subscriptions[subscriptionId] = subscription;
    return subscription;
  }

  /// Unsubscribe from events
  void unsubscribe(String subscriptionId) {
    _subscriptions[subscriptionId]?.cancel();
    _subscriptions.remove(subscriptionId);
  }

  /// Listen to all events with a handler
  StreamSubscription<ERPEvent> listen(void Function(ERPEvent) handler) {
    return events.listen(handler);
  }

  /// Get event bus statistics
  Map<String, dynamic> getStats() {
    return {
      'events_emitted': _eventsEmitted,
      'events_processed': _eventsProcessed,
      'event_type_counts': Map<String, int>.from(_eventTypeCount),
      'active_subscriptions': _subscriptions.length,
      'history_size': _eventHistory.length,
    };
  }

  /// Get event bus metrics
  Map<String, dynamic> getMetrics() {
    return {
      'events_emitted': _eventsEmitted,
      'events_processed': _eventsProcessed,
      'active_subscriptions': _subscriptions.length,
      'event_type_counts': Map.from(_eventTypeCount),
      'history_size': _eventHistory.length,
    };
  }

  /// Get recent events
  List<ERPEvent> getRecentEvents({int limit = 50}) {
    final recentEvents = _eventHistory.reversed.take(limit).toList();
    return recentEvents.reversed.toList();
  }

  /// Get events by type
  List<T> getEventsByType<T extends ERPEvent>({int limit = 50}) {
    return _eventHistory
        .where((event) => event is T)
        .cast<T>()
        .take(limit)
        .toList();
  }

  /// Clear event history
  void clearHistory() {
    _eventHistory.clear();
    debugPrint('🧹 Event history cleared');
  }

  /// Handle event persistence and processing
  Future<void> _handleEventForPersistence(ERPEvent event) async {
    try {
      _eventsProcessed++;

      // Persist critical events to Firestore
      if (_shouldPersistEvent(event)) {
        await _persistEventToFirestore(event);
      }

      // Log event for debugging
      _logEvent(event);

    } catch (e) {
      debugPrint('❌ Error handling event for persistence: $e');
    }
  }

  /// Determine if event should be persisted
  bool _shouldPersistEvent(ERPEvent event) {
    // Persist all business-critical events
    return event is ProductSoldEvent ||
           event is InventoryUpdatedEvent ||
           event is LowStockAlertEvent ||
           event is PurchaseOrderCreatedEvent ||
           event is CustomerCreatedEvent ||
           event is GoodsReceivedEvent ||
           event is RefundProcessedEvent;
  }

  /// Persist event to Firestore
  Future<void> _persistEventToFirestore(ERPEvent event) async {
    try {
      await _firestore.collection(_eventCollection).add(event.toMap());
    } catch (e) {
      debugPrint('❌ Error persisting event to Firestore: $e');
    }
  }

  /// Start listening to Firestore for distributed events
  void _startFirestoreListener() {
    _firestore
        .collection(_eventCollection)
        .where('timestamp', isGreaterThan: Timestamp.now())
        .snapshots()
        .listen(
          (snapshot) {
            for (final doc in snapshot.docChanges) {
              if (doc.type == DocumentChangeType.added) {
                _handleFirestoreEvent(doc.doc.data()!);
              }
            }
          },
          onError: (error) => debugPrint('❌ Firestore listener error: $error'),
        );
  }

  /// Handle events from Firestore (distributed system)
  void _handleFirestoreEvent(Map<String, dynamic> data) {
    try {
      // Reconstruct event from Firestore data
      final eventType = data['event_type'] as String;
      
      // Only process events from other instances (avoid loops)
      if (data['source'] != 'local_instance') {
        // Create appropriate event based on type
        final event = _reconstructEventFromData(eventType, data);
        if (event != null) {
          _eventController.add(event);
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling Firestore event: $e');
    }
  }

  /// Reconstruct event object from Firestore data
  ERPEvent? _reconstructEventFromData(String eventType, Map<String, dynamic> data) {
    try {
      // Basic event reconstruction - extend as needed
      switch (eventType) {
        case 'ProductSoldEvent':
          return ProductSoldEvent(
            eventId: data['event_id'],
            source: data['source'],
            transactionId: data['transaction_id'] ?? '',
            productId: data['product_id'] ?? '',
            customerId: data['customer_id'] ?? '',
            quantity: data['quantity'] ?? 0,
            unitPrice: (data['unit_price'] ?? 0).toDouble(),
            totalAmount: (data['total_amount'] ?? 0).toDouble(),
            storeId: data['store_id'] ?? '',
            metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
          );
        // Add more event types as needed
        default:
          debugPrint('⚠️ Unknown event type for reconstruction: $eventType');
          return null;
      }
    } catch (e) {
      debugPrint('❌ Error reconstructing event: $e');
      return null;
    }
  }

  /// Log event for debugging
  void _logEvent(ERPEvent event) {
    if (kDebugMode) {
      debugPrint('''
📝 Event Log:
   Type: ${event.runtimeType}
   Source: ${event.source}
   Time: ${event.timestamp}
   Metadata: ${event.metadata}
      ''');
    }
  }

  /// Dispose the event bus
  void dispose() {
    debugPrint('🚌 ERPEventBus: Disposing...');
    
    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Close the main controller
    _eventController.close();
    
    debugPrint('✅ ERPEventBus: Disposed');
  }

  /// Health check for the event bus
  Map<String, dynamic> healthCheck() {
    return {
      'status': _eventController.isClosed ? 'closed' : 'active',
      'subscriptions': _subscriptions.length,
      'events_emitted': _eventsEmitted,
      'events_processed': _eventsProcessed,
      'last_event_time': _eventHistory.isNotEmpty 
          ? _eventHistory.last.timestamp.toIso8601String()
          : null,
    };
  }
}

/// Convenience methods for common event operations
extension ERPEventBusExtensions on ERPEventBus {
  /// Quick emit with auto-generated ID
  Future<void> emitQuick(ERPEvent event) async {
    await emit(event);
  }

  /// Emit product sold event
  Future<void> emitProductSold({
    required String transactionId,
    required String productId,
    required String customerId,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    required String storeId,
  }) async {
    await emit(ProductSoldEvent(
      eventId: _uuid.v4(),
      source: 'pos_module',
      transactionId: transactionId,
      productId: productId,
      customerId: customerId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      storeId: storeId,
    ));
  }

  /// Emit inventory updated event
  Future<void> emitInventoryUpdated({
    required String productId,
    required int previousQuantity,
    required int newQuantity,
    required String location,
    required String reason,
  }) async {
    await emit(InventoryUpdatedEvent(
      eventId: _uuid.v4(),
      source: 'inventory_module',
      productId: productId,
      previousQuantity: previousQuantity,
      newQuantity: newQuantity,
      location: location,
      reason: reason,
    ));
  }

  /// Emit low stock alert
  Future<void> emitLowStockAlert({
    required String productId,
    required String productName,
    required int currentQuantity,
    required int minimumQuantity,
    required String location,
  }) async {
    await emit(LowStockAlertEvent(
      eventId: _uuid.v4(),
      source: 'inventory_module',
      productId: productId,
      productName: productName,
      currentQuantity: currentQuantity,
      minimumQuantity: minimumQuantity,
      location: location,
    ));
  }
}
