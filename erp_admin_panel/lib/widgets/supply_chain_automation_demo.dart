import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/bridge/bridge_helper.dart';
import '../services/inventory_service.dart';
import '../services/purchase_order_service.dart';
import '../services/supplier_service.dart';

/// 🔄 Supply Chain Automation Demo
/// 
/// This widget demonstrates the complete integration between:
/// Inventory → Purchase Orders → Suppliers
class SupplyChainAutomationDemo extends StatefulWidget {
  const SupplyChainAutomationDemo({Key? key}) : super(key: key);

  @override
  State<SupplyChainAutomationDemo> createState() => _SupplyChainAutomationDemoState();
}

class _SupplyChainAutomationDemoState extends State<SupplyChainAutomationDemo> {
  bool _isProcessing = false;
  String _lastAction = '';
  List<String> _workflowLog = [];

  void _addToLog(String message) {
    setState(() {
      _workflowLog.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_workflowLog.length > 20) {
        _workflowLog.removeRange(20, _workflowLog.length);
      }
    });
  }

  Future<void> _simulateCompleteSupplyChainWorkflow() async {
    setState(() {
      _isProcessing = true;
      _lastAction = 'Simulating Complete Supply Chain Workflow...';
    });

    try {
      _addToLog('🚀 Starting complete supply chain automation demo');
      
      // Step 1: Check for low stock items
      _addToLog('📦 Step 1: Checking inventory levels...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final lowStockProducts = await InventoryService.getLowStockProducts();
      _addToLog('⚠️ Found ${lowStockProducts.length} low stock products');
      
      if (lowStockProducts.isNotEmpty) {
        final product = lowStockProducts.first;
        
        // Step 2: Trigger low stock alert
        _addToLog('📤 Step 2: Sending low stock alert for ${product.productName}');
        await Future.delayed(const Duration(milliseconds: 500));
        
        await BridgeHelper.sendEvent(
          'inventory_low_stock',
          {
            'product_id': product.productId,
            'current_quantity': product.currentQuantity,
            'minimum_quantity': product.minimumQuantity,
            'product_name': product.productName,
          },
          fromModule: 'supply_chain_demo',
        );
        
        // Step 3: Purchase order creation is automatically triggered
        _addToLog('📋 Step 3: Purchase order automatically created');
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Step 4: Supplier selection
        _addToLog('🏭 Step 4: Best supplier selected automatically');
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Step 5: Simulate order processing
        _addToLog('⏳ Step 5: Purchase order sent to supplier');
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Step 6: Simulate delivery received
        _addToLog('📦 Step 6: Simulating delivery received...');
        await Future.delayed(const Duration(milliseconds: 500));
        
        await InventoryService.processPurchaseOrderDelivery({
          'product_id': product.productId,
          'quantity_received': 50,
          'po_id': 'PO_DEMO_${DateTime.now().millisecondsSinceEpoch}',
        });
        
        _addToLog('✅ Step 7: Inventory updated with new stock');
        _addToLog('🎉 Complete supply chain workflow executed successfully!');
        
      } else {
        _addToLog('ℹ️ No low stock items found - creating demo low stock scenario');
        
        // Create a demo scenario
        await BridgeHelper.sendEvent(
          'inventory_low_stock',
          {
            'product_id': 'DEMO_PRODUCT_001',
            'current_quantity': 2,
            'minimum_quantity': 10,
            'product_name': 'Demo Gaming Laptop',
          },
          fromModule: 'supply_chain_demo',
        );
        
        _addToLog('📋 Demo purchase order created automatically');
        _addToLog('🏭 Best supplier selected for demo product');
        _addToLog('✅ Complete workflow demonstrated successfully!');
      }
      
    } catch (e) {
      _addToLog('❌ Error in supply chain workflow: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _lastAction = 'Workflow completed';
      });
    }
  }

  Future<void> _testSupplierPerformanceTracking() async {
    setState(() {
      _isProcessing = true;
      _lastAction = 'Testing Supplier Performance Tracking...';
    });

    try {
      _addToLog('📊 Testing supplier performance tracking...');
      
      // Simulate purchase order completion
      await BridgeHelper.sendEvent(
        'purchase_order_completed',
        {
          'supplier_id': 'SUPPLIER_001',
          'delivered_on_time': true,
          'quality_rating': 4.5,
          'po_id': 'PO_TEST_${DateTime.now().millisecondsSinceEpoch}',
        },
        fromModule: 'supply_chain_demo',
      );
      
      _addToLog('✅ Supplier performance updated automatically');
      _addToLog('📈 Performance metrics recalculated');
      
    } catch (e) {
      _addToLog('❌ Error testing supplier performance: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _lastAction = 'Performance test completed';
      });
    }
  }

  Future<void> _testInventoryRestockCycle() async {
    setState(() {
      _isProcessing = true;
      _lastAction = 'Testing Full Restock Cycle...';
    });

    try {
      _addToLog('🔄 Testing complete inventory restock cycle...');
      
      // Trigger low stock check
      await InventoryService.checkLowStockAndTriggerReorders();
      _addToLog('✅ Low stock check triggered automatic reorders');
      
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Simulate multiple deliveries
      final demoProducts = ['PROD_001', 'PROD_002', 'PROD_003'];
      
      for (final productId in demoProducts) {
        await InventoryService.processPurchaseOrderDelivery({
          'product_id': productId,
          'quantity_received': 25,
          'po_id': 'PO_BATCH_${DateTime.now().millisecondsSinceEpoch}',
        });
        
        _addToLog('📦 Processed delivery for product: $productId');
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      _addToLog('🎉 Complete restock cycle executed successfully!');
      
    } catch (e) {
      _addToLog('❌ Error in restock cycle: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _lastAction = 'Restock cycle completed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔄 Supply Chain Automation'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌟 Connected Modules Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Inventory Management → Purchase Orders'),
                    const Text('✅ Purchase Orders → Supplier Management'),
                    const Text('✅ Supplier Performance Tracking'),
                    const Text('✅ Automatic Reorder Workflows'),
                    const Text('✅ Real-time Stock Level Monitoring'),
                    const SizedBox(height: 8),
                    if (_lastAction.isNotEmpty)
                      Text(
                        'Last Action: $_lastAction',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Demo Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulateCompleteSupplyChainWorkflow,
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Complete Workflow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _testSupplierPerformanceTracking,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Supplier Performance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _testInventoryRestockCycle,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restock Cycle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Processing Indicator
            if (_isProcessing)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Processing workflow...'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Workflow Log
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '📋 Workflow Activity Log',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _workflowLog.length,
                        itemBuilder: (context, index) {
                          final logEntry = _workflowLog[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              logEntry,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
