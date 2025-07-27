import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/store_models.dart';
import '../services/store_integration_service.dart';
import '../services/store_service.dart';
import '../../../core/activity_tracker.dart';

/// 🎯 Store Integration Dashboard
/// Comprehensive view of store operations with cross-module data integration
class StoreIntegrationDashboard extends StatefulWidget {
  @override
  _StoreIntegrationDashboardState createState() => _StoreIntegrationDashboardState();
}

class _StoreIntegrationDashboardState extends State<StoreIntegrationDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStoreId = 'STORE_001';
  bool _isLoading = true;
  
  List<Store> _stores = [];
  Map<String, dynamic> _storeAnalytics = {};
  Map<String, bool> _moduleStatus = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
    
    // Track screen initialization
    ActivityTracker().trackNavigation(
      screenName: 'StoreIntegrationDashboard',
      routeName: '/store/integration-dashboard',
      relatedFiles: [
        'lib/modules/store_management/screens/store_integration_dashboard.dart',
        'lib/modules/store_management/services/store_integration_service.dart',
      ],
    );
    
    print('🎯 Initializing Store Integration Dashboard...');
    print('  🔗 Setting up cross-module communications');
    print('  📊 Loading comprehensive analytics');
    print('  🛠️ Testing module integrations');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load stores
      final storesStream = StoreService.getStoresStream();
      final storesSnapshot = await storesStream.first;
      
      setState(() {
        _stores = storesSnapshot;
        if (_stores.isNotEmpty && _selectedStoreId == 'STORE_001') {
          _selectedStoreId = _stores.first.storeId;
        }
      });
      
      // Load comprehensive analytics for selected store
      await _loadStoreAnalytics();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
    }
  }

  Future<void> _loadStoreAnalytics() async {
    try {
      // Track analytics loading
      ActivityTracker().trackInteraction(
        action: 'load_store_analytics',
        element: 'integration_dashboard',
        data: {
          'store_id': _selectedStoreId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final analytics = await StoreIntegrationService.getComprehensiveStoreAnalytics(_selectedStoreId);
      final moduleStatus = await StoreIntegrationService.testModuleCommunication(_selectedStoreId);
      
      setState(() {
        _storeAnalytics = analytics;
        _moduleStatus = moduleStatus;
      });
      
      print('📊 Loaded comprehensive analytics for store: $_selectedStoreId');
    } catch (e) {
      print('Error loading store analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Integration Dashboard'),
        backgroundColor: Colors.deepPurple.shade700,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'CRM Integration'),
            Tab(icon: Icon(Icons.inventory_2), text: 'Products & Inventory'),
            Tab(icon: Icon(Icons.business), text: 'Suppliers & POs'),
            Tab(icon: Icon(Icons.point_of_sale), text: 'POS & Orders'),
            Tab(icon: Icon(Icons.network_check), text: 'Integration Status'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStoreSelector(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildCRMIntegrationTab(),
                      _buildProductsInventoryTab(),
                      _buildSuppliersTab(),
                      _buildPOSOrdersTab(),
                      _buildIntegrationStatusTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStoreSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const Icon(Icons.store, color: Colors.deepPurple),
          const SizedBox(width: 8),
          const Text('Store:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStoreId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _stores.map((store) => DropdownMenuItem(
                value: store.storeId,
                child: Text('${store.storeName} (${store.storeId})'),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStoreId = value;
                  });
                  _loadStoreAnalytics();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _loadStoreAnalytics,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final summary = _storeAnalytics['summary'] as Map<String, dynamic>? ?? {};
    final recentActivity = _storeAnalytics['recentActivity'] as Map<String, dynamic>? ?? {};
    final integrationStatus = _storeAnalytics['integrationStatus'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(summary),
          const SizedBox(height: 24),
          
          // Recent Activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActivityMetric(
                          'Orders This Week',
                          '${recentActivity['ordersLastWeek'] ?? 0}',
                          Icons.receipt,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildActivityMetric(
                          'Transactions This Week',
                          '${recentActivity['transactionsLastWeek'] ?? 0}',
                          Icons.point_of_sale,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Integration Status Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Module Integration Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildModuleStatusGrid(integrationStatus),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Total Customers',
          '${summary['totalCustomers'] ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Total Products',
          '${summary['totalProducts'] ?? 0}',
          Icons.inventory_2,
          Colors.green,
        ),
        _buildSummaryCard(
          'Total Revenue',
          '\$${(summary['totalRevenue'] as num? ?? 0).toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.purple,
        ),
        _buildSummaryCard(
          'Profit Margin',
          '${(summary['profitMargin'] as num? ?? 0).toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
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
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleStatusGrid(Map<String, dynamic> integrationStatus) {
    final modules = [
      {'name': 'CRM', 'key': 'crmConnected', 'icon': Icons.people},
      {'name': 'Inventory', 'key': 'inventoryConnected', 'icon': Icons.inventory},
      {'name': 'POS', 'key': 'posConnected', 'icon': Icons.point_of_sale},
      {'name': 'Products', 'key': 'productsConnected', 'icon': Icons.inventory_2},
      {'name': 'Orders', 'key': 'ordersConnected', 'icon': Icons.receipt},
      {'name': 'Suppliers', 'key': 'supplierConnected', 'icon': Icons.business},
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: modules.map((module) {
        final isConnected = integrationStatus[module['key']] as bool? ?? false;
        final color = isConnected ? Colors.green : Colors.red;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(module['icon'] as IconData, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                module['name'] as String,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Icon(
                isConnected ? Icons.check_circle : Icons.error,
                size: 16,
                color: color,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCRMIntegrationTab() {
    final moduleData = _storeAnalytics['moduleData'] as Map<String, dynamic>? ?? {};
    final customers = moduleData['customers'] as List? ?? [];
    final customerOrders = moduleData['customerOrders'] as List? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CRM Overview
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Total Customers',
                  '${customers.length}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Customer Orders',
                  '${customerOrders.length}',
                  Icons.receipt,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Customer List
          if (customers.isNotEmpty) ...[
            const Text(
              'Recent Customers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customers.take(10).length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(customer['customerName']?[0] ?? 'C'),
                    ),
                    title: Text(customer['customerName'] ?? 'Unknown'),
                    subtitle: Text(customer['email'] ?? 'No email'),
                    trailing: Text(
                      'Orders: ${customerOrders.where((order) => order['customerId'] == customer['id']).length}',
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No customer data available for this store'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsInventoryTab() {
    final moduleData = _storeAnalytics['moduleData'] as Map<String, dynamic>? ?? {};
    final products = moduleData['products'] as List? ?? [];
    final inventory = moduleData['inventory'] as List? ?? [];
    final summary = _storeAnalytics['summary'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inventory Overview
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Total Products',
                  '${products.length}',
                  Icons.inventory_2,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Inventory Items',
                  '${summary['totalInventoryItems'] ?? 0}',
                  Icons.inventory,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Low Stock Items',
                  '${summary['lowStockItems'] ?? 0}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Inventory List
          if (inventory.isNotEmpty) ...[
            const Text(
              'Current Inventory',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inventory.take(10).length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  final currentStock = item['currentStock'] as int? ?? 0;
                  final minStock = item['minStockLevel'] as int? ?? 0;
                  final isLowStock = currentStock < minStock;
                  
                  return ListTile(
                    leading: Icon(
                      Icons.inventory_2,
                      color: isLowStock ? Colors.red : Colors.green,
                    ),
                    title: Text(item['productName'] ?? 'Unknown Product'),
                    subtitle: Text('Product ID: ${item['productId'] ?? 'N/A'}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Stock: $currentStock',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLowStock ? Colors.red : Colors.green,
                          ),
                        ),
                        Text('Min: $minStock', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.inventory_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No inventory data available for this store'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuppliersTab() {
    final moduleData = _storeAnalytics['moduleData'] as Map<String, dynamic>? ?? {};
    final suppliers = moduleData['suppliers'] as List? ?? [];
    final purchaseOrders = moduleData['purchaseOrders'] as List? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suppliers Overview
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Total Suppliers',
                  '${suppliers.length}',
                  Icons.business,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Purchase Orders',
                  '${purchaseOrders.length}',
                  Icons.shopping_cart,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Suppliers List
          if (suppliers.isNotEmpty) ...[
            const Text(
              'Store Suppliers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suppliers.take(10).length,
                itemBuilder: (context, index) {
                  final supplier = suppliers[index];
                  final supplierOrders = purchaseOrders.where(
                    (order) => order['supplierId'] == supplier['id']
                  ).length;
                  
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.business),
                    ),
                    title: Text(supplier['companyName'] ?? 'Unknown Supplier'),
                    subtitle: Text(supplier['contactEmail'] ?? 'No email'),
                    trailing: Text('Orders: $supplierOrders'),
                  );
                },
              ),
            ),
          ] else ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No supplier data available for this store'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPOSOrdersTab() {
    final moduleData = _storeAnalytics['moduleData'] as Map<String, dynamic>? ?? {};
    final posTransactions = moduleData['posTransactions'] as List? ?? [];
    final customerOrders = moduleData['customerOrders'] as List? ?? [];
    final summary = _storeAnalytics['summary'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // POS Overview
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'POS Transactions',
                  '${posTransactions.length}',
                  Icons.point_of_sale,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Customer Orders',
                  '${customerOrders.length}',
                  Icons.receipt,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Total Revenue',
                  '\$${(summary['totalRevenue'] as num? ?? 0).toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Avg Transaction',
                  '\$${(summary['totalRevenue'] as num? ?? 0) / (posTransactions.length > 0 ? posTransactions.length : 1)}',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Transactions
          if (posTransactions.isNotEmpty) ...[
            const Text(
              'Recent POS Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posTransactions.take(10).length,
                itemBuilder: (context, index) {
                  final transaction = posTransactions[index];
                  final amount = (transaction['totalAmount'] as num? ?? 0).toDouble();
                  final date = transaction['transactionDate'] as DateTime?;
                  
                  return ListTile(
                    leading: const Icon(Icons.point_of_sale, color: Colors.green),
                    title: Text('Transaction #${transaction['id'] ?? 'Unknown'}'),
                    subtitle: Text(
                      date != null 
                        ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                        : 'Unknown date'
                    ),
                    trailing: Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.point_of_sale_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No POS transaction data available for this store'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIntegrationStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Module Integration Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Test Communication Button
          ElevatedButton.icon(
            onPressed: () async {
              setState(() => _isLoading = true);
              await _loadStoreAnalytics();
              setState(() => _isLoading = false);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Integration test completed!')),
              );
            },
            icon: const Icon(Icons.network_check),
            label: const Text('Test All Integrations'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Module Status List
          Card(
            child: Column(
              children: _moduleStatus.entries.map((entry) {
                final module = entry.key;
                final isConnected = entry.value;
                
                return ListTile(
                  leading: Icon(
                    _getModuleIcon(module),
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  title: Text(_getModuleName(module)),
                  subtitle: Text(
                    isConnected ? 'Connected and operational' : 'Not connected or no data',
                  ),
                  trailing: Icon(
                    isConnected ? Icons.check_circle : Icons.error,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Integration Health Score
          _buildIntegrationHealthCard(),
        ],
      ),
    );
  }

  Widget _buildIntegrationHealthCard() {
    final connectedModules = _moduleStatus.values.where((connected) => connected).length;
    final totalModules = _moduleStatus.length;
    final healthScore = totalModules > 0 ? (connectedModules / totalModules) * 100 : 0.0;
    
    Color healthColor;
    String healthStatus;
    
    if (healthScore >= 80) {
      healthColor = Colors.green;
      healthStatus = 'Excellent';
    } else if (healthScore >= 60) {
      healthColor = Colors.orange;
      healthStatus = 'Good';
    } else if (healthScore >= 40) {
      healthColor = Colors.yellow.shade700;
      healthStatus = 'Fair';
    } else {
      healthColor = Colors.red;
      healthStatus = 'Poor';
    }
    
    return Card(
      color: healthColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: healthColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Integration Health Score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: healthColor,
                        ),
                      ),
                      Text(
                        '$connectedModules of $totalModules modules connected',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${healthScore.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: healthColor,
                      ),
                    ),
                    Text(
                      healthStatus,
                      style: TextStyle(color: healthColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: healthScore / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModuleIcon(String module) {
    switch (module) {
      case 'crm': return Icons.people;
      case 'suppliers': return Icons.business;
      case 'inventory': return Icons.inventory;
      case 'pos': return Icons.point_of_sale;
      case 'orders': return Icons.receipt;
      case 'products': return Icons.inventory_2;
      default: return Icons.extension;
    }
  }

  String _getModuleName(String module) {
    switch (module) {
      case 'crm': return 'Customer Relationship Management';
      case 'suppliers': return 'Supplier Management';
      case 'inventory': return 'Inventory Management';
      case 'pos': return 'Point of Sale System';
      case 'orders': return 'Customer Orders';
      case 'products': return 'Product Management';
      default: return module.toUpperCase();
    }
  }
}
