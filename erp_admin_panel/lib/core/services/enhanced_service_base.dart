// Enhanced ERP System - Enhanced Service Base Classes
// Provides event-driven capabilities and orchestration for all business services

import '../events/erp_event_bus.dart';
import '../events/erp_events.dart';
import '../orchestration/transaction_orchestrator.dart';

/// Base class for all enhanced ERP services
/// Provides common event handling and orchestration capabilities
abstract class EnhancedERPService {
  final ERPEventBus _eventBus;
  final TransactionOrchestrator _orchestrator;

  EnhancedERPService(this._eventBus, this._orchestrator);

  /// Get the event bus instance
  ERPEventBus get eventBus => _eventBus;

  /// Get the transaction orchestrator
  TransactionOrchestrator get orchestrator => _orchestrator;

  /// Initialize the service - override to set up event listeners
  Future<void> initialize() async {
    await setupEventListeners();
  }

  /// Setup event listeners for this service
  /// Override this method to listen to relevant events
  Future<void> setupEventListeners() async {}

  /// Dispose of resources when service is no longer needed
  void dispose() {
    // Override if needed
  }

  /// Helper method to emit events
  void emitEvent(ERPEvent event) {
    _eventBus.emit(event);
  }

  /// Helper method to listen to specific event types
  void listenToEvent<T extends ERPEvent>(Function(T) handler) {
    _eventBus.listen((ERPEvent event) {
      if (event is T) {
        handler(event);
      }
    });
  }
}

/// Mixin for services that need transaction capabilities
mixin TransactionCapable {
  TransactionOrchestrator get orchestrator;

  /// Execute a business operation within a transaction
  Future<T> executeInTransaction<T>(
    String operationId,
    Future<T> Function() operation, {
    List<String> affectedModules = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    final result = await orchestrator.executeTransaction(
      operationId,
      () async {
        final operationResult = await operation();
        // Convert result to Map<String, dynamic> as expected by orchestrator
        return {
          'result': operationResult,
          'operation_id': operationId,
          'affected_modules': affectedModules,
        };
      },
      metadata: metadata,
    );
    
    if (result.success) {
      return result.metadata['result'] as T;
    } else {
      throw Exception(result.errorMessage ?? 'Transaction failed');
    }
  }
}

/// Mixin for services that handle real-time data sync
mixin RealTimeSyncCapable {
  ERPEventBus get eventBus;

  /// Setup real-time listeners for data changes
  void setupRealTimeSync() {
    // Listen to relevant events for real-time updates
    listenToDataChanges();
  }

  /// Override to implement specific real-time listeners
  void listenToDataChanges() {}

  /// Helper to listen to events
  void listenToEvent<T extends ERPEvent>(Function(T) handler) {
    eventBus.listen((ERPEvent event) {
      if (event is T) {
        handler(event);
      }
    });
  }
}

/// Mixin for services that provide analytics
mixin AnalyticsCapable {
  ERPEventBus get eventBus;

  /// Emit analytics events for business intelligence
  void emitAnalyticsEvent(String metricName, Map<String, dynamic> data) {
    eventBus.emit(AnalyticsEvent(
      eventId: 'analytics_${DateTime.now().millisecondsSinceEpoch}',
      source: runtimeType.toString(),
      metricName: metricName,
      data: data,
    ));
  }

  /// Track business metrics
  void trackMetric(String metric, double value, {Map<String, String>? tags}) {
    emitAnalyticsEvent(metric, {
      'value': value,
      'tags': tags ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
