// Inventory Management Test and Demo
// This file demonstrates how the enhanced inventory system works

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/unified_models.dart';
import '../../../modules/crm/services/enhanced_services.dart';

class InventoryTestScreen extends StatefulWidget {
  const InventoryTestScreen({super.key});

  @override
  State<InventoryTestScreen> createState() => _InventoryTestScreenState();
}

class _InventoryTestScreenState extends State<InventoryTestScreen> {
  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedAction = 'sale';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Inventory Management Test'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Controls
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎛️ Test Inventory Updates',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedAction,
                      decoration: const InputDecoration(
                        labelText: 'Action Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'sale', child: Text('📉 Sale (Reduce Stock)')),
                        DropdownMenuItem(value: 'purchase', child: Text('📈 Purchase (Add Stock)')),
                        DropdownMenuItem(value: 'check', child: Text('🔍 Check Stock')),
                      ],
                      onChanged: (value) => setState(() => _selectedAction = value!),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _productController,
                      decoration: const InputDecoration(
                        labelText: 'Product ID (e.g., from products collection)',
                        border: OutlineInputBorder(),
                        hintText: 'Enter product ID to test',
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        hintText: 'Enter quantity to add/reduce',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _performAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Execute ${_selectedAction.toUpperCase()}'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _createSampleInventory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Create Sample'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Real-time Inventory Display
            const Text(
              '📊 Live Inventory Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: StreamBuilder<List<UnifiedInventoryItem>>(
                stream: EnhancedInventoryService.getInventoryItemsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final inventoryItems = snapshot.data ?? [];
                  
                  if (inventoryItems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No inventory items found. Create sample data first.'),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: inventoryItems.length,
                    itemBuilder: (context, index) {
                      final item = inventoryItems[index];
                      return _buildInventoryCard(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(UnifiedInventoryItem item) {
    final quantityAvailable = item.currentStock;
    final reorderPoint = item.minStockLevel;
    final isLowStock = quantityAvailable <= reorderPoint;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isLowStock ? Colors.red.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.red : Colors.green,
          child: Text(
            quantityAvailable.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('Product ID: ${item.productId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Stock: $quantityAvailable'),
            Text('Reserved: ${item.reservedStock ?? 0} | Available: ${item.availableStock ?? 0}'),
            Text('Min Level: $reorderPoint'),
            Text('Location: ${item.location ?? 'Unknown'}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLowStock) ...[
              const Icon(Icons.warning, color: Colors.red),
              const Text('LOW STOCK', style: TextStyle(color: Colors.red, fontSize: 10)),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.green),
              const Text('OK', style: TextStyle(color: Colors.green, fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }

  void _performAction() async {
    final productId = _productController.text.trim();
    final quantityText = _quantityController.text.trim();
    
    if (productId.isEmpty) {
      _showMessage('❌ Please enter a product ID');
      return;
    }
    
    if (_selectedAction != 'check' && quantityText.isEmpty) {
      _showMessage('❌ Please enter a quantity');
      return;
    }
    
    final quantity = _selectedAction == 'check' ? 0 : int.tryParse(quantityText) ?? 0;
    
    try {
      switch (_selectedAction) {
        case 'sale':
          _showMessage('🔄 Processing sale...');
          final success = await EnhancedInventoryService.updateStock(
            productId, 
            -quantity,  // Negative for sales
            reason: 'Test Sale Transaction'
          );
          _showMessage(success 
            ? '✅ Sale processed! Stock reduced by $quantity'
            : '❌ Sale failed! Check if sufficient stock is available');
          break;
          
        case 'purchase':
          _showMessage('🔄 Processing purchase...');
          final success = await EnhancedInventoryService.updateStock(
            productId, 
            quantity,   // Positive for purchases
            reason: 'Test Purchase Order'
          );
          _showMessage(success 
            ? '✅ Purchase processed! Stock increased by $quantity'
            : '❌ Purchase failed! Check product ID');
          break;
          
        case 'check':
          _showMessage('🔄 Checking stock...');
          final inventoryItems = await EnhancedInventoryService.getInventoryByProductId(productId);
          if (inventoryItems.isNotEmpty) {
            final item = inventoryItems.first;
            _showMessage('📊 Stock Status:\n'
              'Current: ${item.currentStock}\n'
              'Reserved: ${item.reservedStock}\n'
              'Available: ${item.availableStock}\n'
              'Min Level: ${item.minStockLevel}');
          } else {
            _showMessage('❌ No inventory found for product $productId');
          }
          break;
      }
    } catch (e) {
      _showMessage('❌ Error: $e');
    }
  }

  void _createSampleInventory() async {
    try {
      _showMessage('🔄 Creating sample inventory...');
      
      // TODO: Update sample inventory creation to use InventoryRecord
      _showMessage('⚠️ Sample inventory creation temporarily disabled');
      /*
      // Create sample inventory items
      final sampleItems = [
        InventoryRecord(
          inventoryId: '',
          productId: 'sample_product_1',
          storeLocation: 'default_store',
          quantityAvailable: 100,
          reservedStock: 0,
          availableStock: 100,
          minStockLevel: 20,
          maxStockLevel: 200,
          location: 'Warehouse A',
          batchNumber: 'BATCH_001',
          expiryDate: null,
          costPrice: 50.0,
          status: 'active',
          lastUpdated: Timestamp.now(),
          lastUpdatedBy: 'test_system',
        ),
        InventoryRecord(
          inventoryId: '',
          productId: 'sample_product_2',
          storeLocation: 'default_store',
          quantityAvailable: 15,  // Low stock for testing
          quantityReserved: 5,
          availableStock: 10,
          minStockLevel: 20,
          maxStockLevel: 100,
          location: 'Warehouse B',
          batchNumber: 'BATCH_002',
          expiryDate: null,
          costPrice: 75.0,
          status: 'active',
          lastUpdated: Timestamp.now(),
          lastUpdatedBy: 'test_system',
        ),
      ];
      
      for (final item in sampleItems) {
        await EnhancedInventoryService.addInventoryItem(item);
      }
      
      _showMessage('✅ Sample inventory created! You can now test with:\n'
        '• sample_product_1 (100 units)\n'
        '• sample_product_2 (15 units - low stock)');
        */
        
    } catch (e) {
      _showMessage('❌ Error creating sample: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
