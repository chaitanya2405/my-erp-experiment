// Test file to validate core architecture compilation
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import our enhanced core architecture
import '../lib/core/events/erp_event_bus.dart';
import '../lib/core/events/erp_events.dart';
import '../lib/core/models/unified_models.dart';
import '../lib/core/orchestration/transaction_orchestrator.dart';
import '../lib/core/services/erp_service_registry.dart';

void main() {
  group('Enhanced ERP Core Architecture Tests', () {
    test('Event Bus initialization', () async {
      final eventBus = ERPEventBus();
      await eventBus.initialize();
      
      expect(eventBus.events, isNotNull);
      expect(eventBus.getStats()['events_emitted'], equals(0));
    });

    test('Unified Models creation', () {
      final product = UnifiedProduct(
        id: 'test-id',
        name: 'Test Product',
        code: 'TEST001',
        costPrice: 100.0,
        salePrice: 150.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(product.id, equals('test-id'));
      expect(product.name, equals('Test Product'));
      expect(product.costPrice, equals(100.0));
      expect(product.salePrice, equals(150.0));
    });

    test('Transaction Orchestrator initialization', () async {
      final eventBus = ERPEventBus();
      final orchestrator = TransactionOrchestrator(eventBus);
      
      await orchestrator.initialize();
      
      final stats = orchestrator.getStats();
      expect(stats['total_transactions'], equals(0));
    });

    test('Service Registry initialization', () async {
      final registry = ERPServiceRegistry();
      
      // This should not throw any compilation errors
      expect(registry.isInitialized, isFalse);
    });

    test('Event creation and emission', () async {
      final eventBus = ERPEventBus();
      await eventBus.initialize();
      
      final event = InventoryUpdatedEvent(
        eventId: 'test-event',
        source: 'test',
        productId: 'product-1',
        previousQuantity: 10,
        newQuantity: 8,
        location: 'Store-A',
        reason: 'Sale',
      );
      
      await eventBus.emit(event);
      
      final stats = eventBus.getStats();
      expect(stats['events_emitted'], equals(1));
    });
  });
}
