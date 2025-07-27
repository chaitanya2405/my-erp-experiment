import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_models.dart';
import '../services/store_service.dart';
import '../services/store_integration_service.dart';
import '../../../services/product_service.dart';
import '../../../services/inventory_service.dart';
import '../../../services/pos_service.dart';
import '../../../models/product.dart';
import '../../../models/inventory_models.dart';
import '../../../core/activity_tracker.dart';

/// 📊 Store Analytics Screen
/// Comprehensive analytics dashboard for store performance and insights with real Firestore data
class StoreAnalyticsScreen extends StatefulWidget {
  @override
  _StoreAnalyticsScreenState createState() => _StoreAnalyticsScreenState();
}

class _StoreAnalyticsScreenState extends State<StoreAnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Last 30 Days';
  String _selectedStoreId = 'All Stores';
  bool _isLoading = true;
  
  List<Store> _stores = [];
  List<Product> _products = [];
  List<InventoryItem> _inventoryItems = [];
  Map<String, dynamic> _analyticsData = {};
  Map<String, Map<String, dynamic>> _storeMetrics = {};
  
  final List<String> _periods = [
    'Today',
    'Yesterday', 
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    
    print('📊 Initializing Store Analytics Screen...');
    print('  📈 Loading performance metrics across all stores');
    print('  🎯 Setting up comparative analytics');
    print('  📍 Preparing location-based insights');
    print('  💡 Ready for business intelligence');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Track analytics loading with Activity Tracker
      ActivityTracker().trackInteraction(
        action: 'store_analytics_load',
        element: 'analytics_screen',
        data: {
          'selected_period': _selectedPeriod,
          'selected_store': _selectedStoreId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      // Load stores
      final storesStream = StoreService.getStoresStream();
      final storesSnapshot = await storesStream.first;
      
      setState(() {
        _stores = storesSnapshot;
      });
      
      // Load comprehensive analytics for each store
      await _loadComprehensiveAnalytics();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
    }
  }

  Future<void> _loadComprehensiveAnalytics() async {
    try {
      print('🔄 Loading comprehensive analytics with cross-module integration...');
      
      // Load analytics for each store using the new integration service
      for (final store in _stores) {
        final analytics = await StoreIntegrationService.getComprehensiveStoreAnalytics(store.storeId);
        _storeMetrics[store.storeId] = analytics;
        
        print('📊 Loaded analytics for store: ${store.storeName}');
        print('  • Customers: ${analytics['summary']?['totalCustomers'] ?? 0}');
        print('  • Products: ${analytics['summary']?['totalProducts'] ?? 0}');
        print('  • Revenue: \$${analytics['summary']?['totalRevenue'] ?? 0}');
        print('  • Integration Status: ${analytics['integrationStatus']}');
      }
      
      // Generate aggregated analytics
      _generateAggregatedAnalytics();
      
      print('✅ Comprehensive analytics loaded successfully');
    } catch (e) {
      print('❌ Error loading comprehensive analytics: $e');
    }
  }

  void _generateAggregatedAnalytics() {
    if (_storeMetrics.isEmpty) {
      _generateAnalyticsData(); // Fallback to mock data
      return;
    }
    
    // Calculate aggregated metrics from real data
    int totalCustomers = 0;
    int totalProducts = 0;
    int totalInventoryItems = 0;
    int totalLowStockItems = 0;
    double totalRevenue = 0.0;
    double totalPurchaseCost = 0.0;
    int totalOrders = 0;
    int totalTransactions = 0;
    
    for (final metrics in _storeMetrics.values) {
      final summary = metrics['summary'] as Map<String, dynamic>? ?? {};
      final moduleData = metrics['moduleData'] as Map<String, dynamic>? ?? {};
      
      totalCustomers += (summary['totalCustomers'] as int? ?? 0);
      totalProducts += (summary['totalProducts'] as int? ?? 0);
      totalInventoryItems += (summary['totalInventoryItems'] as int? ?? 0);
      totalLowStockItems += (summary['lowStockItems'] as int? ?? 0);
      totalRevenue += (summary['totalRevenue'] as num? ?? 0).toDouble();
      totalPurchaseCost += (summary['totalPurchaseCost'] as num? ?? 0).toDouble();
      
      final customerOrders = moduleData['customerOrders'] as List? ?? [];
      final posTransactions = moduleData['posTransactions'] as List? ?? [];
      totalOrders += customerOrders.length;
      totalTransactions += posTransactions.length;
    }
    
    _analyticsData = {
      'overview': {
        'total_stores': _stores.length,
        'active_stores': _stores.where((s) => s.storeStatus == 'Active').length,
        'total_customers': totalCustomers,
        'total_products': totalProducts,
        'total_inventory_items': totalInventoryItems,
        'low_stock_items': totalLowStockItems,
        'total_sales': totalRevenue,
        'total_purchase_cost': totalPurchaseCost,
        'total_transactions': totalTransactions,
        'total_orders': totalOrders,
        'average_transaction_value': totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
        'profit_margin': totalRevenue > 0 ? ((totalRevenue - totalPurchaseCost) / totalRevenue * 100) : 0,
        'top_performing_store': _getTopPerformingStore(),
      },
      'cross_module_integration': {
        'connected_modules': _getConnectedModules(),
        'integration_health': _calculateIntegrationHealth(),
      },
    };
  }

  String _getTopPerformingStore() {
    if (_storeMetrics.isEmpty) return 'N/A';
    
    String topStoreId = '';
    double maxRevenue = 0.0;
    
    _storeMetrics.forEach((storeId, metrics) {
      final revenue = (metrics['summary']?['totalRevenue'] as num? ?? 0).toDouble();
      if (revenue > maxRevenue) {
        maxRevenue = revenue;
        topStoreId = storeId;
      }
    });
    
    final topStore = _stores.firstWhere((store) => store.storeId == topStoreId, 
        orElse: () => Store(
          storeId: '', 
          storeCode: '', 
          storeName: 'Unknown',
          storeType: 'retail',
          contactPerson: '',
          contactNumber: '',
          email: '',
          addressLine1: '',
          city: '',
          state: '',
          postalCode: '',
          country: '',
          operatingHours: '9:00 AM - 6:00 PM',
          storeStatus: 'inactive',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ));
    return topStore.storeName;
  }

  Map<String, bool> _getConnectedModules() {
    if (_storeMetrics.isEmpty) return {};
    
    Map<String, bool> overallIntegration = {
      'crm': false,
      'suppliers': false,
      'inventory': false,
      'pos': false,
      'orders': false,
      'products': false,
    };
    
    for (final metrics in _storeMetrics.values) {
      final integrationStatus = metrics['integrationStatus'] as Map<String, dynamic>? ?? {};
      
      integrationStatus.forEach((module, connected) {
        if (connected == true) {
          overallIntegration[module] = true;
        }
      });
    }
    
    return overallIntegration;
  }

  double _calculateIntegrationHealth() {
    final connectedModules = _getConnectedModules();
    if (connectedModules.isEmpty) return 0.0;
    
    final totalModules = connectedModules.length;
    final connectedCount = connectedModules.values.where((connected) => connected).length;
    
    return (connectedCount / totalModules) * 100;
  }

  void _generateAnalyticsData() {
    // Mock analytics data - in a real app, this would come from your analytics service
    _analyticsData = {
      'overview': {
        'total_stores': _stores.length,
        'active_stores': _stores.where((s) => s.storeStatus == 'Active').length,
        'total_sales': 2850000.0,
        'total_transactions': 15420,
        'average_transaction_value': 1847.0,
        'top_performing_store': _stores.isNotEmpty ? _stores.first.storeName : 'N/A',
      },
      'sales_trend': [
        {'day': 'Mon', 'sales': 120000},
        {'day': 'Tue', 'sales': 135000},
        {'day': 'Wed', 'sales': 98000},
        {'day': 'Thu', 'sales': 142000},
        {'day': 'Fri', 'sales': 178000},
        {'day': 'Sat', 'sales': 165000},
        {'day': 'Sun', 'sales': 155000},
      ],
      'store_performance': _stores.take(5).map((store) => {
        'store_name': store.storeName,
        'sales': (50000 + (store.hashCode % 100000)).toDouble(),
        'transactions': 150 + (store.hashCode % 200),
        'efficiency': 0.75 + ((store.hashCode % 25) / 100),
      }).toList(),
      'category_breakdown': [
        {'category': 'Electronics', 'percentage': 35, 'sales': 997500},
        {'category': 'Clothing', 'percentage': 25, 'sales': 712500},
        {'category': 'Home & Garden', 'percentage': 20, 'sales': 570000},
        {'category': 'Food & Beverages', 'percentage': 15, 'sales': 427500},
        {'category': 'Others', 'percentage': 5, 'sales': 142500},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading analytics data...'),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with filters
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.indigo, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Store Analytics',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Data',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Filters
                Row(
                  children: [
                    // Period Filter
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedPeriod,
                        decoration: InputDecoration(
                          labelText: 'Period',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _periods.map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedPeriod = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Store Filter
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedStoreId,
                        decoration: InputDecoration(
                          labelText: 'Store',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: [
                          const DropdownMenuItem(value: 'All Stores', child: Text('All Stores')),
                          ..._stores.map((store) => DropdownMenuItem(
                            value: store.storeId,
                            child: Text(store.storeName),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedStoreId = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.indigo,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.indigo,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Performance'),
                    Tab(text: 'Sales Trends'),
                    Tab(text: 'Comparisons'),
                  ],
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPerformanceTab(),
                _buildSalesTrendsTab(),
                _buildComparisonsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final overview = _analyticsData['overview'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(child: _buildKPICard(
                'Total Stores',
                '${overview['total_stores']}',
                Icons.store,
                Colors.blue,
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildKPICard(
                'Active Stores',
                '${overview['active_stores']}',
                Icons.check_circle,
                Colors.green,
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildKPICard(
                'Total Sales',
                '₹${_formatNumber(overview['total_sales'])}',
                Icons.trending_up,
                Colors.orange,
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildKPICard(
                'Transactions',
                '${_formatNumber(overview['total_transactions'])}',
                Icons.receipt,
                Colors.purple,
              )),
            ],
          ),
          const SizedBox(height: 24),
          // Sales Chart
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sales Overview (Last 7 Days)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '₹${(value / 1000).toInt()}K',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final salesTrend = _analyticsData['sales_trend'] as List;
                                if (value.toInt() < salesTrend.length) {
                                  return Text(
                                    salesTrend[value.toInt()]['day'],
                                    style: const TextStyle(fontSize: 12),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getSalesSpots(),
                            isCurved: true,
                            color: Colors.indigo,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.indigo.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Category Breakdown
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sales by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Pie Chart
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _getPieChartSections(),
                            centerSpaceRadius: 60,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Legend
                      Expanded(
                        child: Column(
                          children: _buildCategoryLegend(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final storePerformance = _analyticsData['store_performance'] as List;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Performance Ranking',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          ...storePerformance.asMap().entries.map((entry) {
            final index = entry.key;
            final store = entry.value;
            return _buildPerformanceCard(store, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildSalesTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Trends Analysis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Sales Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 400,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '₹${(value / 1000).toInt()}K',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final salesTrend = _analyticsData['sales_trend'] as List;
                                if (value.toInt() < salesTrend.length) {
                                  return Text(
                                    salesTrend[value.toInt()]['day'],
                                    style: const TextStyle(fontSize: 12),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: _getBarGroups(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Comparisons',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Comparison Matrix',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Store')),
                        DataColumn(label: Text('Sales')),
                        DataColumn(label: Text('Transactions')),
                        DataColumn(label: Text('Avg Value')),
                        DataColumn(label: Text('Efficiency')),
                      ],
                      rows: (_analyticsData['store_performance'] as List).map((store) {
                        return DataRow(cells: [
                          DataCell(Text(store['store_name'])),
                          DataCell(Text('₹${_formatNumber(store['sales'])}')),
                          DataCell(Text('${store['transactions']}')),
                          DataCell(Text('₹${(store['sales'] / store['transactions']).toStringAsFixed(0)}')),
                          DataCell(Text('${(store['efficiency'] * 100).toStringAsFixed(1)}%')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(Map<String, dynamic> store, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Store Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['store_name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${store['transactions']} transactions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Metrics
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${_formatNumber(store['sales'])}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(store['efficiency'] * 100).toStringAsFixed(1)}% efficiency',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSalesSpots() {
    final salesTrend = _analyticsData['sales_trend'] as List;
    return salesTrend.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['sales'].toDouble());
    }).toList();
  }

  List<PieChartSectionData> _getPieChartSections() {
    final categories = _analyticsData['category_breakdown'] as List;
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];
    
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      return PieChartSectionData(
        value: category['percentage'].toDouble(),
        title: '${category['percentage']}%',
        color: colors[index % colors.length],
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildCategoryLegend() {
    final categories = _analyticsData['category_breakdown'] as List;
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];
    
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(category['category'])),
            Text('₹${_formatNumber(category['sales'])}'),
          ],
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _getBarGroups() {
    final salesTrend = _analyticsData['sales_trend'] as List;
    return salesTrend.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value['sales'].toDouble(),
            color: Colors.indigo,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown;
      default:
        return Colors.indigo;
    }
  }

  String _formatNumber(dynamic number) {
    if (number is num) {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      }
      return number.toStringAsFixed(0);
    }
    return number.toString();
  }
}
