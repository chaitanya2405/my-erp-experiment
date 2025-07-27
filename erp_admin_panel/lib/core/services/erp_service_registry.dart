// Enhanced ERP System - Service Registry and Initialization
// Central registry for managing all enhanced services and their dependencies

import 'package:flutter/foundation.dart';
import '../events/erp_event_bus.dart';
import '../events/erp_events.dart';
import '../orchestration/transaction_orchestrator.dart';
import 'enhanced_service_base.dart';
import 'enhanced_inventory_service.dart';
import 'enhanced_pos_service.dart';
import 'enhanced_purchase_order_service.dart';
import 'enhanced_customer_service.dart';
import 'enhanced_analytics_service.dart';

/// Central service registry for the Enhanced ERP System
class ERPServiceRegistry {
  static ERPServiceRegistry? _instance;
  
  late final ERPEventBus _eventBus;
  late final TransactionOrchestrator _orchestrator;
  
  // Service instances
  late final EnhancedInventoryService _inventoryService;
  late final EnhancedPOSService _posService;
  late final EnhancedPurchaseOrderService _purchaseOrderService;
  late final EnhancedCustomerService _customerService;
  late final EnhancedAnalyticsService _analyticsService;
  
  bool _initialized = false;
  
  ERPServiceRegistry._();
  
  static ERPServiceRegistry get instance {
    _instance ??= ERPServiceRegistry._();
    return _instance!;
  }

  /// Initialize all services and their dependencies
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('🔄 ERP Service Registry already initialized');
      return;
    }

    try {
      debugPrint('🚀 Initializing Enhanced ERP Service Registry...');
      
      // 1. Initialize core infrastructure
      _eventBus = ERPEventBus();
      _orchestrator = TransactionOrchestrator();
      
      debugPrint('✅ Core infrastructure initialized');
      
      // 2. Initialize services
      _inventoryService = EnhancedInventoryService.getInstance(_eventBus, _orchestrator);
      _posService = EnhancedPOSService.getInstance(_eventBus, _orchestrator);
      _purchaseOrderService = EnhancedPurchaseOrderService.getInstance(_eventBus, _orchestrator);
      _customerService = EnhancedCustomerService.getInstance(_eventBus, _orchestrator);
      _analyticsService = EnhancedAnalyticsService.getInstance(_eventBus, _orchestrator);
      
      debugPrint('✅ Service instances created');
      
      // 3. Initialize each service (sets up event listeners)
      await _inventoryService.initialize();
      await _posService.initialize();
      await _purchaseOrderService.initialize();
      await _customerService.initialize();
      await _analyticsService.initialize();
      
      debugPrint('✅ Service event listeners configured');
      
      // 4. Start the orchestrator
      await _orchestrator.initialize();
      
      debugPrint('✅ Transaction orchestrator started');
      
      _initialized = true;
      
      // 5. Emit system ready event
      await _eventBus.emit(SystemInitializedEvent(
        eventId: 'system_init_${DateTime.now().millisecondsSinceEpoch}',
        source: 'ERPServiceRegistry',
        services: [
          'inventory',
          'pos',
          'purchase_orders',
          'customers',
          'analytics',
        ],
        initializationTime: DateTime.now(),
      ));
      
      debugPrint('🎉 Enhanced ERP System fully initialized and ready!');
      
    } catch (e) {
      debugPrint('❌ Failed to initialize ERP Service Registry: $e');
      rethrow;
    }
  }

  /// Dispose all services and clean up resources
  Future<void> dispose() async {
    if (!_initialized) return;
    
    debugPrint('🧹 Disposing Enhanced ERP Service Registry...');
    
    try {
      // Dispose services
      _inventoryService.dispose();
      _posService.dispose();
      _purchaseOrderService.dispose();
      _customerService.dispose();
      _analyticsService.dispose();
      
      // Dispose core infrastructure
      await _orchestrator.dispose();
      _eventBus.dispose();
      
      _initialized = false;
      debugPrint('✅ ERP Service Registry disposed');
      
    } catch (e) {
      debugPrint('❌ Error disposing ERP Service Registry: $e');
    }
  }

  // Service Getters
  EnhancedInventoryService get inventory {
    _ensureInitialized();
    return _inventoryService;
  }

  EnhancedPOSService get pos {
    _ensureInitialized();
    return _posService;
  }

  EnhancedPurchaseOrderService get purchaseOrders {
    _ensureInitialized();
    return _purchaseOrderService;
  }

  EnhancedCustomerService get customers {
    _ensureInitialized();
    return _customerService;
  }

  EnhancedAnalyticsService get analytics {
    _ensureInitialized();
    return _analyticsService;
  }

  ERPEventBus get eventBus {
    _ensureInitialized();
    return _eventBus;
  }

  TransactionOrchestrator get orchestrator {
    _ensureInitialized();
    return _orchestrator;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('ERP Service Registry not initialized. Call initialize() first.');
    }
  }

  /// Get service health status
  Map<String, dynamic> getHealthStatus() {
    if (!_initialized) {
      return {
        'status': 'not_initialized',
        'message': 'Service registry not initialized',
      };
    }

    return {
      'status': 'healthy',
      'initialized': _initialized,
      'services': {
        'inventory': 'active',
        'pos': 'active',
        'purchase_orders': 'active',
        'customers': 'active',
        'analytics': 'active',
      },
      'infrastructure': {
        'event_bus': 'active',
        'orchestrator': 'active',
      },
      'uptime': DateTime.now().toIso8601String(),
    };
  }

  /// Get system metrics
  Future<Map<String, dynamic>> getSystemMetrics() async {
    _ensureInitialized();
    
    return {
      'event_bus_stats': _eventBus.getStats(),
      'orchestrator_stats': await _orchestrator.getStats(),
      'system_health': getHealthStatus(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Restart the entire system
  Future<void> restart() async {
    debugPrint('🔄 Restarting Enhanced ERP System...');
    
    await dispose();
    await initialize();
    
    debugPrint('✅ Enhanced ERP System restarted successfully');
  }

  /// Test system connectivity and functionality
  Future<bool> runHealthCheck() async {
    try {
      _ensureInitialized();
      
      debugPrint('🔍 Running ERP system health check...');
      
      // Test event bus
      bool eventBusHealthy = true;
      try {
        await _eventBus.emit(SystemHealthCheckEvent(
          eventId: 'health_check_${DateTime.now().millisecondsSinceEpoch}',
          source: 'ERPServiceRegistry',
          checkType: 'event_bus',
        ));
      } catch (e) {
        eventBusHealthy = false;
        debugPrint('❌ Event bus health check failed: $e');
      }
      
      // Test orchestrator
      bool orchestratorHealthy = true;
      try {
        await _orchestrator.executeTransaction(
          'health_check_${DateTime.now().millisecondsSinceEpoch}',
          () async {
            // Simple test operation
            return {'status': 'healthy'};
          },
          metadata: {'type': 'health_check'},
        );
      } catch (e) {
        orchestratorHealthy = false;
        debugPrint('❌ Orchestrator health check failed: $e');
      }
      
      final healthy = eventBusHealthy && orchestratorHealthy;
      
      debugPrint(healthy 
          ? '✅ ERP system health check passed' 
          : '❌ ERP system health check failed');
      
      return healthy;
      
    } catch (e) {
      debugPrint('❌ Health check error: $e');
      return false;
    }
  }
}
