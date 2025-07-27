import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_providers.dart';

class InventoryAnalyticsScreen extends StatefulWidget {
  const InventoryAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<InventoryAnalyticsScreen> createState() => _InventoryAnalyticsScreenState();
}

class _InventoryAnalyticsScreenState extends State<InventoryAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Analytics'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, child) {
          if (inventoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = inventoryProvider.items;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(items),
                const SizedBox(height: 24),
                _buildCategoryAnalysis(items),
                const SizedBox(height: 24),
                _buildLowStockAlert(items),
                const SizedBox(height: 24),
                _buildTopValueItems(items),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<InventoryItem> items) {
    final totalItems = items.length;
    final totalValue = items.fold<double>(0, (sum, item) => sum + (item.currentStock * item.costPrice));
    final lowStockItems = items.where((item) => item.currentStock <= item.minStockLevel).length;
    final outOfStockItems = items.where((item) => item.currentStock == 0).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory Summary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Total Items',
              totalItems.toString(),
              Icons.inventory_2,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Total Value',
              '₹${totalValue.toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              'Low Stock',
              lowStockItems.toString(),
              Icons.warning,
              Colors.orange,
            ),
            _buildSummaryCard(
              'Out of Stock',
              outOfStockItems.toString(),
              Icons.error,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalysis(List<InventoryItem> items) {
    final categoryMap = <String, List<InventoryItem>>{};
    
    for (final item in items) {
      final category = item.category ?? 'Uncategorized';
      categoryMap.putIfAbsent(category, () => []).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Analysis',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: categoryMap.entries.map((entry) {
                final category = entry.key;
                final categoryItems = entry.value;
                final totalValue = categoryItems.fold<double>(
                  0, 
                  (sum, item) => sum + (item.currentStock * item.costPrice)
                );
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          category,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('${categoryItems.length} items'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${totalValue.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockAlert(List<InventoryItem> items) {
    final lowStockItems = items
        .where((item) => item.currentStock <= item.minStockLevel)
        .toList();

    if (lowStockItems.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Alerts',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 16),
                  const Text('All items are adequately stocked'),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Alerts',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '${lowStockItems.length} items need attention',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...lowStockItems.take(5).map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(item.itemName),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Stock: ${item.currentStock}',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Min: ${item.minStockLevel}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                )),
                if (lowStockItems.length > 5) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+ ${lowStockItems.length - 5} more items',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopValueItems(List<InventoryItem> items) {
    final itemsWithValue = items.map((item) {
      return {
        'item': item,
        'value': item.currentStock * item.costPrice,
      };
    }).toList();

    itemsWithValue.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    final topItems = itemsWithValue.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Value Items',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const Divider(),
                ...topItems.map((itemData) {
                  final item = itemData['item'] as InventoryItem;
                  final value = itemData['value'] as double;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(item.itemName),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(item.currentStock.toString()),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹${value.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
