import 'dart:async';
import 'package:flutter/foundation.dart';
import 'universal_erp_bridge.dart';

/// 🛠️ Bridge Helper - Makes module integration super simple
/// 
/// This helper automatically handles all the complex bridge interactions
/// so any module can easily connect with just a few lines of code.
class BridgeHelper {
  static final BridgeHelper _instance = BridgeHelper._internal();
  static BridgeHelper get instance => _instance;
  BridgeHelper._internal();

  UniversalERPBridge get bridge => UniversalERPBridge.instance;

  /// 🚀 Quick module registration - One line to connect any module
  static Future<void> connectModule({
    required String moduleName,
    required List<String> capabilities,
    required Map<String, dynamic> schema,
    required Future<dynamic> Function(String dataType, Map<String, dynamic> filters) dataProvider,
    required Future<void> Function(UniversalEvent event) eventHandler,
  }) async {
    final connector = SimpleModuleConnector(
      moduleName: moduleName,
      capabilities: capabilities,
      schema: schema,
      dataProvider: dataProvider,
      eventHandler: eventHandler,
    );
    
    await UniversalERPBridge.instance.registerModule(connector);
  }

  /// 📊 Super simple data request
  static Future<T?> getData<T>(
    String fromModule,
    String dataType, {
    Map<String, dynamic>? filters,
    bool useCache = true,
  }) async {
    try {
      final result = await UniversalERPBridge.instance.requestData(
        fromModule: fromModule,
        dataType: dataType,
        filters: filters,
        useCache: useCache,
      );
      return result as T?;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BridgeHelper getData failed: $e');
      }
      return null;
    }
  }

  /// 📢 Super simple event broadcasting
  static Future<void> sendEvent(
    String eventType,
    dynamic data, {
    List<String>? toModules,
    String? fromModule,
  }) async {
    await UniversalERPBridge.instance.broadcastEvent(
      eventType: eventType,
      data: data,
      targetModules: toModules,
      sourceModule: fromModule,
    );
  }

  /// 👂 Super simple event listening
  static Stream<T> listenTo<T>(String eventType) {
    return UniversalERPBridge.instance
        .listenToEvents(eventType)
        .map((event) => event.data as T);
  }

  /// 🔄 Auto-sync data between modules
  static Future<void> setupAutoSync({
    required String sourceModule,
    required String dataType,
    required String targetEventType,
    Duration interval = const Duration(minutes: 5),
  }) async {
    Timer.periodic(interval, (timer) async {
      try {
        final data = await getData(sourceModule, dataType);
        if (data != null) {
          await sendEvent(targetEventType, data, fromModule: 'auto_sync');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Auto-sync failed for $sourceModule.$dataType: $e');
        }
      }
    });
  }

  /// 🎯 Business rule helpers
  static void addSimpleRule({
    required String name,
    required bool Function(UniversalEvent event) condition,
    required Future<void> Function(UniversalEvent event, UniversalERPBridge bridge) action,
  }) {
    final rule = SimpleBusinessRule(
      name: name,
      condition: condition,
      action: action,
    );
    UniversalERPBridge.instance.addBusinessRule(rule);
  }

  /// 📊 Quick status check
  static BridgeStatus getStatus() {
    return UniversalERPBridge.instance.getStatus();
  }

  /// 🔍 Find modules by capability
  static List<String> findModulesByCapability(String capability) {
    final status = getStatus();
    // This would be enhanced to actually check capabilities
    return status.modules;
  }
}

/// 🔌 Simple Module Connector Implementation
class SimpleModuleConnector extends ModuleConnector {
  @override
  final String moduleName;
  
  @override
  final List<String> capabilities;
  
  @override
  final Map<String, dynamic> schema;
  
  final Future<dynamic> Function(String dataType, Map<String, dynamic> filters) dataProvider;
  final Future<void> Function(UniversalEvent event) eventHandler;

  SimpleModuleConnector({
    required this.moduleName,
    required this.capabilities,
    required this.schema,
    required this.dataProvider,
    required this.eventHandler,
  });

  @override
  Future<void> initializeBridgeConnection(UniversalERPBridge bridge) async {
    if (kDebugMode) {
      print('🔗 $moduleName connected to Universal Bridge');
    }
  }

  @override
  Future<dynamic> getData(String dataType, Map<String, dynamic> filters) async {
    return await dataProvider(dataType, filters);
  }

  @override
  Future<void> receiveEvent(UniversalEvent event) async {
    await eventHandler(event);
  }

  @override
  Future<Map<String, dynamic>> getHealthStatus() async {
    return {
      'module_name': moduleName,
      'status': 'healthy',
      'capabilities': capabilities,
      'last_check': DateTime.now().toIso8601String(),
    };
  }
}

/// 📋 Simple Business Rule Implementation
class SimpleBusinessRule extends BridgeRule {
  @override
  final String name;
  
  final bool Function(UniversalEvent event) condition;
  final Future<void> Function(UniversalEvent event, UniversalERPBridge bridge) action;

  SimpleBusinessRule({
    required this.name,
    required this.condition,
    required this.action,
  });

  @override
  bool shouldApply(UniversalEvent event) => condition(event);

  @override
  Future<void> execute(UniversalEvent event, UniversalERPBridge bridge) async {
    await action(event, bridge);
  }
}

/// 🎯 Pre-built Business Rules for common scenarios
class CommonBusinessRules {
  
  /// Auto-update inventory when POS sale happens
  static BridgeRule inventoryUpdateOnSale() {
    return SimpleBusinessRule(
      name: 'auto_inventory_update_on_sale',
      condition: (event) => event.type == 'pos_sale_completed',
      action: (event, bridge) async {
        final saleData = event.data as Map<String, dynamic>;
        await bridge.broadcastEvent(
          eventType: 'inventory_update_required',
          data: {
            'items': saleData['items'],
            'store_id': saleData['store_id'],
            'operation': 'decrease_quantity',
          },
          sourceModule: 'bridge_rule',
        );
      },
    );
  }

  /// Auto-create customer order when POS transaction completes
  static BridgeRule createCustomerOrderOnPOS() {
    return SimpleBusinessRule(
      name: 'auto_customer_order_on_pos',
      condition: (event) => event.type == 'pos_transaction_completed',
      action: (event, bridge) async {
        final transactionData = event.data as Map<String, dynamic>;
        await bridge.broadcastEvent(
          eventType: 'create_customer_order',
          data: {
            'transaction_id': transactionData['id'],
            'customer_id': transactionData['customer_id'],
            'items': transactionData['items'],
            'total': transactionData['total'],
          },
          sourceModule: 'bridge_rule',
        );
      },
    );
  }

  /// Update customer profile on purchase
  static BridgeRule updateCustomerOnPurchase() {
    return SimpleBusinessRule(
      name: 'update_customer_profile_on_purchase',
      condition: (event) => event.type == 'purchase_completed',
      action: (event, bridge) async {
        final purchaseData = event.data as Map<String, dynamic>;
        if (purchaseData['customer_id'] != null) {
          await bridge.broadcastEvent(
            eventType: 'update_customer_stats',
            data: {
              'customer_id': purchaseData['customer_id'],
              'purchase_amount': purchaseData['total'],
              'items_purchased': purchaseData['items_count'],
            },
            sourceModule: 'bridge_rule',
          );
        }
      },
    );
  }

  /// Notify on low inventory
  static BridgeRule lowInventoryNotification() {
    return SimpleBusinessRule(
      name: 'low_inventory_notification',
      condition: (event) => event.type == 'inventory_updated',
      action: (event, bridge) async {
        final inventoryData = event.data as Map<String, dynamic>;
        final quantity = inventoryData['quantity'] as int? ?? 0;
        final minStock = inventoryData['min_stock'] as int? ?? 10;
        
        if (quantity <= minStock) {
          await bridge.broadcastEvent(
            eventType: 'low_inventory_alert',
            data: {
              'product_id': inventoryData['product_id'],
              'current_quantity': quantity,
              'min_stock': minStock,
              'store_id': inventoryData['store_id'],
            },
            sourceModule: 'bridge_rule',
          );
        }
      },
    );
  }

  /// All common rules
  static List<BridgeRule> getAllCommonRules() {
    return [
      inventoryUpdateOnSale(),
      createCustomerOrderOnPOS(),
      updateCustomerOnPurchase(),
      lowInventoryNotification(),
    ];
  }
}

/// 🚀 Quick Bridge Setup for the entire app
class QuickBridgeSetup {
  
  /// Initialize bridge with all common rules
  static Future<void> initializeWithDefaults() async {
    final bridge = UniversalERPBridge.instance;
    
    // Initialize the bridge
    await bridge.initialize();
    
    // Add all common business rules
    for (final rule in CommonBusinessRules.getAllCommonRules()) {
      bridge.addBusinessRule(rule);
    }
    
    if (kDebugMode) {
      print('🚀 Bridge initialized with default configuration');
    }
  }
  
  /// Connect all existing modules
  static Future<void> connectAllModules() async {
    // This will be called to auto-connect all existing modules
    // Each module will call BridgeHelper.connectModule() to register itself
    
    if (kDebugMode) {
      print('🔗 Connecting all modules to bridge...');
    }
  }
}
