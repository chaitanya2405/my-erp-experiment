// Enhanced ERP System - Integration Example
// Demonstrates how to use the new event-driven, unified ERP architecture

import 'package:flutter/foundation.dart';
import 'core/services/erp_service_registry.dart';
import 'core/models/index.dart';

/// Example class demonstrating the Enhanced ERP System integration
class EnhancedERPDemo {
  static final ERPServiceRegistry _registry = ERPServiceRegistry.instance;

  /// Initialize and demonstrate the ERP system
  static Future<void> runDemo() async {
    debugPrint('🚀 Starting Enhanced ERP System Demo...');

    try {
      // 1. Initialize the ERP system
      await _registry.initialize();
      
      // 2. Run health check
      final healthy = await _registry.runHealthCheck();
      if (!healthy) {
        debugPrint('❌ System health check failed');
        return;
      }

      // 3. Demonstrate business workflows
      await _demonstrateFullBusinessWorkflow();
      
      // 4. Show analytics and insights
      await _demonstrateAnalyticsCapabilities();
      
      // 5. Test event-driven automation
      await _demonstrateAutomationFeatures();

      debugPrint('✅ Enhanced ERP System Demo completed successfully!');

    } catch (e) {
      debugPrint('❌ Demo failed: $e');
    }
  }

  /// Demonstrate a complete business workflow
  static Future<void> _demonstrateFullBusinessWorkflow() async {
    debugPrint('\n📋 === BUSINESS WORKFLOW DEMONSTRATION ===');

    try {
      // Step 1: Create a new customer
      final customerId = await _registry.customers.createEnhancedCustomerProfile(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        address: '123 Main St, City, State',
        metadata: {'source': 'demo', 'type': 'walk_in'},
      );
      debugPrint('✅ Customer created: $customerId');

      // Step 2: Create a POS transaction (this will automatically update inventory)
      final transactionId = await _registry.pos.createEnhancedTransaction(
        items: [
          UnifiedCartItem(
            productId: 'prod_001',
            productName: 'Demo Product 1',
            quantity: 2,
            unitPrice: 25.00,
            totalPrice: 50.00,
            taxAmount: 5.00,
            discountAmount: 0.00,
          ),
          UnifiedCartItem(
            productId: 'prod_002',
            productName: 'Demo Product 2',
            quantity: 1,
            unitPrice: 15.00,
            totalPrice: 15.00,
            taxAmount: 1.50,
            discountAmount: 2.00,
          ),
        ],
        storeId: 'store_main',
        cashierId: 'cashier_001',
        customerId: customerId,
        paymentMethod: 'credit_card',
        metadata: {'demo_transaction': true},
      );
      debugPrint('✅ POS transaction created: $transactionId');

      // Wait for event propagation
      await Future.delayed(const Duration(seconds: 2));

      // Step 3: Demonstrate automatic purchase order creation (triggered by low stock)
      debugPrint('📦 Simulating low stock scenario...');
      
      // Manually trigger low stock (normally this would happen automatically)
      await _registry.inventory.updateInventoryQuantity(
        productId: 'prod_001',
        quantityChange: -50, // Large reduction to trigger low stock
        reason: 'Demo Low Stock Scenario',
        location: 'store_main',
        metadata: {'demo': true},
      );

      // Wait for auto-reorder logic to kick in
      await Future.delayed(const Duration(seconds: 3));

      debugPrint('✅ Business workflow demonstration completed');

    } catch (e) {
      debugPrint('❌ Business workflow error: $e');
    }
  }

  /// Demonstrate analytics and reporting capabilities
  static Future<void> _demonstrateAnalyticsCapabilities() async {
    debugPrint('\n📊 === ANALYTICS DEMONSTRATION ===');

    try {
      // Generate sales dashboard
      final salesDashboard = await _registry.analytics.generateDashboard(
        dashboardType: 'sales_overview',
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );
      
      debugPrint('📈 Sales Dashboard Generated:');
      debugPrint('  Total Revenue: \$${salesDashboard['summary']?['total_revenue'] ?? 0}');
      debugPrint('  Total Transactions: ${salesDashboard['summary']?['total_transactions'] ?? 0}');
      debugPrint('  Avg Transaction Value: \$${salesDashboard['summary']?['average_transaction_value'] ?? 0}');

      // Generate executive dashboard
      final executiveDashboard = await _registry.analytics.generateDashboard(
        dashboardType: 'executive_summary',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
      
      debugPrint('👔 Executive Dashboard Generated:');
      debugPrint('  Dashboard Type: ${executiveDashboard['dashboard_type']}');
      debugPrint('  Generated At: ${executiveDashboard['generated_at']}');

      // Export analytics data
      final exportData = await _registry.analytics.exportAnalytics(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now(),
        format: 'json',
      );
      
      debugPrint('📤 Analytics Export:');
      debugPrint('  Records Exported: ${exportData['export_info']?['record_count'] ?? 0}');

      debugPrint('✅ Analytics demonstration completed');

    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Demonstrate automation and intelligence features
  static Future<void> _demonstrateAutomationFeatures() async {
    debugPrint('\n🤖 === AUTOMATION DEMONSTRATION ===');

    try {
      // Test customer insights
      final customerInsights = await _registry.customers.getCustomerInsights('cust_demo_001');
      debugPrint('🎯 Customer Insights:');
      debugPrint('  Customer ID: ${customerInsights['customer_id']}');
      debugPrint('  Lifetime Value: \$${customerInsights['lifetime_value'] ?? 0}');
      debugPrint('  Risk Level: ${customerInsights['risk_level']}');
      debugPrint('  Recommended Actions: ${customerInsights['recommended_actions']}');

      // Test system metrics
      final systemMetrics = await _registry.getSystemMetrics();
      debugPrint('🔧 System Metrics:');
      debugPrint('  System Health: ${systemMetrics['system_health']?['status']}');
      debugPrint('  Event Bus Stats: ${systemMetrics['event_bus_stats']}');

      // Demonstrate real-time streams
      debugPrint('📡 Setting up real-time data streams...');
      
      // Listen to inventory updates (in real app, this would be in UI)
      final inventorySubscription = _registry.inventory.getEnhancedInventoryStream().listen((inventory) {
        debugPrint('📦 Real-time inventory update: ${inventory.length} items');
      });

      // Listen to POS transactions (in real app, this would be in UI)
      final posSubscription = _registry.pos.getEnhancedTransactionStream('store_main').listen((transactions) {
        debugPrint('💰 Real-time POS update: ${transactions.length} transactions');
      });

      // Listen to purchase orders (in real app, this would be in UI)
      final poSubscription = _registry.purchaseOrders.getEnhancedPurchaseOrderStream().listen((pos) {
        debugPrint('📋 Real-time PO update: ${pos.length} purchase orders');
      });

      // Let streams run for a bit
      await Future.delayed(const Duration(seconds: 5));

      // Clean up subscriptions
      inventorySubscription.cancel();
      posSubscription.cancel();
      poSubscription.cancel();

      debugPrint('✅ Automation demonstration completed');

    } catch (e) {
      debugPrint('❌ Automation error: $e');
    }
  }

  /// Demonstrate specific use cases
  static Future<void> demonstrateSpecificUseCases() async {
    debugPrint('\n🎯 === SPECIFIC USE CASES ===');

    // Use Case 1: Return Processing
    await _demonstrateReturnProcessing();
    
    // Use Case 2: Bulk Operations
    await _demonstrateBulkOperations();
    
    // Use Case 3: Customer Loyalty Management
    await _demonstrateLoyaltyManagement();
  }

  static Future<void> _demonstrateReturnProcessing() async {
    debugPrint('\n🔄 Return Processing Use Case:');
    
    try {
      // Process a return
      final returnId = await _registry.pos.processReturn(
        originalTransactionId: 'txn_demo_001',
        returnItems: [
          UnifiedReturnItem(
            productId: 'prod_001',
            quantity: 1,
            refundAmount: 25.00,
            reason: 'Customer changed mind',
          ),
        ],
        reason: 'Customer return',
        processedBy: 'cashier_001',
        metadata: {'demo_return': true},
      );
      
      debugPrint('✅ Return processed: $returnId');
    } catch (e) {
      debugPrint('❌ Return processing error: $e');
    }
  }

  static Future<void> _demonstrateBulkOperations() async {
    debugPrint('\n📊 Bulk Operations Use Case:');
    
    try {
      // Bulk inventory update
      await _registry.inventory.bulkUpdateInventory([
        {
          'product_id': 'prod_003',
          'quantity_change': 100,
          'reason': 'Bulk Stock Replenishment',
          'location': 'warehouse_main',
          'metadata': {'bulk_demo': true},
        },
        {
          'product_id': 'prod_004',
          'quantity_change': 50,
          'reason': 'Bulk Stock Replenishment',
          'location': 'warehouse_main',
          'metadata': {'bulk_demo': true},
        },
      ]);
      
      debugPrint('✅ Bulk inventory update completed');
    } catch (e) {
      debugPrint('❌ Bulk operations error: $e');
    }
  }

  static Future<void> _demonstrateLoyaltyManagement() async {
    debugPrint('\n🎯 Loyalty Management Use Case:');
    
    try {
      // Send personalized offer
      await _registry.customers.sendPersonalizedOffer(
        customerId: 'cust_demo_001',
        offerType: 'birthday_discount',
        offerData: {
          'discount_percentage': 15,
          'valid_until': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'minimum_purchase': 50.0,
        },
        metadata: {'campaign_id': 'birthday_2024'},
      );
      
      debugPrint('✅ Personalized offer sent');
    } catch (e) {
      debugPrint('❌ Loyalty management error: $e');
    }
  }

  /// Clean up demo resources
  static Future<void> cleanup() async {
    debugPrint('\n🧹 Cleaning up demo resources...');
    
    try {
      await _registry.dispose();
      debugPrint('✅ ERP system disposed successfully');
    } catch (e) {
      debugPrint('❌ Cleanup error: $e');
    }
  }
}

/// Main demo runner
Future<void> runEnhancedERPDemo() async {
  debugPrint('🎬 Enhanced ERP System - Full Integration Demo');
  debugPrint('=' * 60);
  
  try {
    await EnhancedERPDemo.runDemo();
    await EnhancedERPDemo.demonstrateSpecificUseCases();
  } finally {
    await EnhancedERPDemo.cleanup();
  }
  
  debugPrint('=' * 60);
  debugPrint('🎭 Demo completed');
}
