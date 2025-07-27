import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/bridge/bridge_helper.dart';
import '../core/bridge/universal_erp_bridge.dart';
import '../examples/cross_module_examples.dart';

/// 🌉 Cross-Module Integration Demo Widget
/// 
/// This widget demonstrates how to trigger cross-module changes
/// through the Universal ERP Bridge system
class CrossModuleIntegrationDemo extends StatefulWidget {
  const CrossModuleIntegrationDemo({Key? key}) : super(key: key);

  @override
  State<CrossModuleIntegrationDemo> createState() => _CrossModuleIntegrationDemoState();
}

class _CrossModuleIntegrationDemoState extends State<CrossModuleIntegrationDemo> {
  bool _isProcessing = false;
  String _lastAction = '';
  List<String> _activityLog = [];

  void _addToLog(String message) {
    setState(() {
      _activityLog.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_activityLog.length > 10) {
        _activityLog.removeRange(10, _activityLog.length);
      }
    });
  }

  Future<void> _simulateOrderCreation() async {
    setState(() {
      _isProcessing = true;
      _lastAction = 'Creating Order...';
    });

    try {
      _addToLog('🛒 Starting order creation process');
      
      // Create sample order data
      final orderData = {
        'order_id': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        'order_number': 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
        'customer_id': 'CUST-001',
        'store_id': 'STORE_001',
        'items': [
          {
            'product_id': 'PROD-001',
            'sku': 'SKU-LAPTOP-001',
            'name': 'Gaming Laptop',
            'quantity': 1,
            'unit_price': 1299.99,
            'total_price': 1299.99
          },
          {
            'product_id': 'PROD-002',
            'sku': 'SKU-MOUSE-001', 
            'name': 'Wireless Mouse',
            'quantity': 2,
            'unit_price': 29.99,
            'total_price': 59.98
          }
        ],
        'total_amount': 1359.97,
        'status': 'pending',
        'customer_info': {
          'name': 'John Smith',
          'email': 'john.smith@email.com',
          'phone': '+1-555-0123'
        },
        'created_at': DateTime.now().toIso8601String()
      };

      _addToLog('📝 Order data prepared: ${orderData['order_number']}');

      // Broadcast order creation event through bridge
      await BridgeHelper.sendEvent('order_created', {
        'source': 'customer_order_management',
        'data': orderData,
        'timestamp': DateTime.now().toIso8601String()
      });

      _addToLog('📡 Order creation event broadcasted');
      _addToLog('✅ Cross-module integration triggered');

      // Simulate the cascading effects
      await Future.delayed(Duration(milliseconds: 500));
      _addToLog('📦 Inventory reservation completed');
      
      await Future.delayed(Duration(milliseconds: 300));
      _addToLog('👥 Customer loyalty points added');
      
      await Future.delayed(Duration(milliseconds: 400));
      _addToLog('📊 Analytics updated');
      
      await Future.delayed(Duration(milliseconds: 200));
      _addToLog('💳 POS transaction created');

      setState(() {
        _lastAction = 'Order created successfully!';
      });

    } catch (e) {
      _addToLog('❌ Error: $e');
      setState(() {
        _lastAction = 'Order creation failed';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _simulateLowStockAlert() async {
    setState(() {
      _isProcessing = true;
      _lastAction = 'Processing Low Stock Alert...';
    });

    try {
      _addToLog('⚠️ Low stock detected for Gaming Laptop');
      
      final lowStockData = {
        'product_id': 'PROD-001',
        'sku': 'SKU-LAPTOP-001',
        'current_stock': 3,
        'threshold': 10,
        'supplier_id': 'SUP-001',
        'reorder_quantity': 25
      };

      // Broadcast low stock event
      await BridgeHelper.sendEvent('low_stock_alert', {
        'source': 'inventory_management',
        'data': lowStockData,
        'timestamp': DateTime.now().toIso8601String()
      });

      _addToLog('📡 Low stock alert broadcasted');

      // Simulate automated responses
      await Future.delayed(Duration(milliseconds: 400));
      _addToLog('🛒 Auto purchase order created');
      
      await Future.delayed(Duration(milliseconds: 300));
      _addToLog('🏭 Supplier notification sent');
      
      await Future.delayed(Duration(milliseconds: 200));
      _addToLog('👤 Procurement team alerted');
      
      await Future.delayed(Duration(milliseconds: 500));
      _addToLog('📈 Demand forecast updated');

      setState(() {
        _lastAction = 'Low stock alert processed!';
      });

    } catch (e) {
      _addToLog('❌ Error: $e');
      setState(() {
        _lastAction = 'Low stock alert failed';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _simulatePaymentReceived() async {
    setState(() {
      _isProcessing = true;
      _lastAction = 'Processing Payment...';
    });

    try {
      _addToLog('💰 Payment received: \$1359.97');
      
      final paymentData = {
        'payment_id': 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        'order_id': 'ORD-12345',
        'customer_id': 'CUST-001',
        'amount': 1359.97,
        'payment_method': 'credit_card',
        'status': 'completed'
      };

      // Broadcast payment received event
      await BridgeHelper.sendEvent('payment_received', {
        'source': 'payment_processing',
        'data': paymentData,
        'timestamp': DateTime.now().toIso8601String()
      });

      _addToLog('📡 Payment event broadcasted');

      // Simulate automated responses
      await Future.delayed(Duration(milliseconds: 300));
      _addToLog('📋 Order status updated to PAID');
      
      await Future.delayed(Duration(milliseconds: 400));
      _addToLog('👥 Loyalty points awarded');
      
      await Future.delayed(Duration(milliseconds: 200));
      _addToLog('📦 Stock released for fulfillment');
      
      await Future.delayed(Duration(milliseconds: 300));
      _addToLog('📈 Revenue metrics updated');

      setState(() {
        _lastAction = 'Payment processed successfully!';
      });

    } catch (e) {
      _addToLog('❌ Error: $e');
      setState(() {
        _lastAction = 'Payment processing failed';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _simulatePriceChange() async {
    setState(() {
      _isProcessing = true;
      _lastAction = 'Updating Product Price...';
    });

    try {
      _addToLog('🏷️ Price change: Gaming Laptop \$1299.99 → \$1199.99');
      
      final priceChangeData = {
        'product_id': 'PROD-001',
        'sku': 'SKU-LAPTOP-001',
        'old_price': 1299.99,
        'new_price': 1199.99,
        'effective_date': DateTime.now().toIso8601String(),
        'reason': 'promotional_discount'
      };

      // Broadcast price change event
      await BridgeHelper.sendEvent('product_price_changed', {
        'source': 'product_management',
        'data': priceChangeData,
        'timestamp': DateTime.now().toIso8601String()
      });

      _addToLog('📡 Price change event broadcasted');

      // Simulate automated responses
      await Future.delayed(Duration(milliseconds: 300));
      _addToLog('💳 POS system prices updated');
      
      await Future.delayed(Duration(milliseconds: 400));
      _addToLog('📋 Pending order prices reviewed');
      
      await Future.delayed(Duration(milliseconds: 200));
      _addToLog('👥 Wishlist customers notified');
      
      await Future.delayed(Duration(milliseconds: 300));
      _addToLog('📊 Price analytics updated');

      setState(() {
        _lastAction = 'Price change propagated!';
      });

    } catch (e) {
      _addToLog('❌ Error: $e');
      setState(() {
        _lastAction = 'Price change failed';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _runFullExample() async {
    setState(() {
      _isProcessing = true;
      _lastAction = 'Running Full Integration Example...';
    });

    try {
      _addToLog('🚀 Starting comprehensive integration demo');
      
      // Run all examples from CrossModuleExamples class
      await CrossModuleExamples.processCustomerOrder();
      await Future.delayed(Duration(milliseconds: 1000));
      
      await CrossModuleExamples.handleLowStockAlert();
      await Future.delayed(Duration(milliseconds: 1000));
      
      await CrossModuleExamples.processPaymentReceived();
      await Future.delayed(Duration(milliseconds: 1000));
      
      await CrossModuleExamples.propagatePriceChange();

      _addToLog('✅ Full integration example completed');
      setState(() {
        _lastAction = 'Full example completed successfully!';
      });

    } catch (e) {
      _addToLog('❌ Error: $e');
      setState(() {
        _lastAction = 'Full example failed';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.hub, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Text(
                  'Cross-Module Integration Demo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800]
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Demonstrate how the Universal ERP Bridge enables seamless communication between modules',
              style: TextStyle(color: Colors.grey[600]),
            ),
            
            SizedBox(height: 24),
            
            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulateOrderCreation,
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Create Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulateLowStockAlert,
                  icon: Icon(Icons.warning),
                  label: Text('Low Stock Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulatePaymentReceived,
                  icon: Icon(Icons.payment),
                  label: Text('Process Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulatePriceChange,
                  icon: Icon(Icons.price_change),
                  label: Text('Change Price'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _runFullExample,
                  icon: Icon(Icons.play_arrow),
                  label: Text('Run Full Example'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Status
            if (_isProcessing) ...[
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(_lastAction, style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 16),
            ] else if (_lastAction.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(child: Text(_lastAction)),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            
            // Activity Log
            Text(
              'Activity Log',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _activityLog.isEmpty
                  ? Center(
                      child: Text(
                        'No activity yet. Click a button above to see cross-module integration in action!',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _activityLog.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _activityLog[index],
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            SizedBox(height: 16),
            
            // Bridge Status
            FutureBuilder<Map<String, dynamic>>(
              future: _getBridgeStatus(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final status = snapshot.data!;
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Universal ERP Bridge Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Connected Modules: ${status['connected_modules']}'),
                        Text('Active Listeners: ${status['active_listeners']}'),
                        Text('Events Processed: ${status['events_processed']}'),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getBridgeStatus() async {
    return {
      'connected_modules': 10,
      'active_listeners': 25,
      'events_processed': 1250,
    };
  }
}
