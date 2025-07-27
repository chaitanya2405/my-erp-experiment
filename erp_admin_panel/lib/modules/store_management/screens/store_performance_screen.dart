import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/store_models.dart';
import '../services/store_service.dart';

/// 📈 Store Performance Screen
/// Detailed performance tracking and analytics for individual stores
class StorePerformanceScreen extends StatefulWidget {
  final String? storeId;

  const StorePerformanceScreen({Key? key, this.storeId}) : super(key: key);

  @override
  _StorePerformanceScreenState createState() => _StorePerformanceScreenState();
}

class _StorePerformanceScreenState extends State<StorePerformanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStoreId = '';
  String _selectedPeriod = 'Last 30 Days';
  bool _isLoading = true;
  
  List<Store> _stores = [];
  List<StorePerformance> _performanceData = [];
  Map<String, dynamic> _kpis = {};
  
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
    _tabController = TabController(length: 3, vsync: this);
    _selectedStoreId = widget.storeId ?? '';
    _loadData();
    
    print('📈 Initializing Store Performance Screen...');
    print('  📊 Loading detailed performance metrics');
    print('  🎯 Setting up KPI tracking');
    print('  📅 Preparing historical analysis');
    print('  💡 Ready for performance insights');
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
        _stores = storesSnapshot.where((s) => s.storeStatus == 'Active').toList();
        if (_selectedStoreId.isEmpty && _stores.isNotEmpty) {
          _selectedStoreId = _stores.first.storeId;
        }
      });
      
      if (_selectedStoreId.isNotEmpty) {
        await _loadPerformanceData();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
    }
  }

  Future<void> _loadPerformanceData() async {
    try {
      // Calculate date range based on selected period
      final endDate = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'Today':
          startDate = DateTime(endDate.year, endDate.month, endDate.day);
          break;
        case 'Yesterday':
          startDate = DateTime(endDate.year, endDate.month, endDate.day - 1);
          break;
        case 'Last 7 Days':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case 'Last 30 Days':
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case 'Last 3 Months':
          startDate = endDate.subtract(const Duration(days: 90));
          break;
        case 'Last 6 Months':
          startDate = endDate.subtract(const Duration(days: 180));
          break;
        case 'This Year':
          startDate = DateTime(endDate.year, 1, 1);
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 30));
      }
      
      // Load performance data
      final performanceData = await StoreService.getStorePerformance(
        _selectedStoreId,
        startDate: startDate,
        endDate: endDate,
      );
      
      setState(() {
        _performanceData = performanceData;
        _calculateKPIs();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading performance data: $e');
      // Generate mock data for demo
      _generateMockData();
    }
  }

  void _generateMockData() {
    // Generate mock performance data for demo
    final store = _stores.firstWhere((s) => s.storeId == _selectedStoreId);
    final random = store.hashCode;
    
    _performanceData = List.generate(30, (index) {
      final date = DateTime.now().subtract(Duration(days: 29 - index));
      return StorePerformance(
        storeId: store.storeId,
        storeCode: store.storeCode,
        storeName: store.storeName,
        date: date,
        totalSales: 8000 + (random % 5000) + (index * 200).toDouble(),
        totalTransactions: 45 + (random % 30) + index,
        customerCount: 35 + (random % 20) + index,
        averageTransactionValue: 1200 + (random % 800).toDouble(),
        grossProfit: 2400 + (random % 1500).toDouble(),
        netProfit: 1800 + (random % 1000).toDouble(),
        inventoryTurnover: 2 + (random % 3),
        footfallCount: 65 + (random % 35).toDouble(),
        conversionRate: 0.45 + ((random % 20) / 100),
      );
    });
    
    _calculateKPIs();
    setState(() => _isLoading = false);
  }

  void _calculateKPIs() {
    if (_performanceData.isEmpty) return;
    
    final totalSales = _performanceData.fold<double>(0, (sum, p) => sum + p.totalSales);
    final totalTransactions = _performanceData.fold<int>(0, (sum, p) => sum + p.totalTransactions);
    final avgSalesPerDay = totalSales / _performanceData.length;
    final avgTransactionsPerDay = totalTransactions / _performanceData.length;
    
    final lastWeek = _performanceData.length >= 7 
        ? _performanceData.sublist(_performanceData.length - 7)
        : _performanceData;
    final lastWeekSales = lastWeek.fold<double>(0, (sum, p) => sum + p.totalSales);
    
    final previousWeek = _performanceData.length >= 14
        ? _performanceData.sublist(_performanceData.length - 14, _performanceData.length - 7)
        : _performanceData.take(7).toList();
    final previousWeekSales = previousWeek.fold<double>(0, (sum, p) => sum + p.totalSales);
    
    final salesGrowth = previousWeekSales > 0 
        ? ((lastWeekSales - previousWeekSales) / previousWeekSales) * 100
        : 0.0;

    _kpis = {
      'total_sales': totalSales,
      'total_transactions': totalTransactions,
      'avg_sales_per_day': avgSalesPerDay,
      'avg_transactions_per_day': avgTransactionsPerDay,
      'sales_growth': salesGrowth,
      'avg_transaction_value': totalSales / totalTransactions,
      'peak_sales_day': _performanceData.reduce((a, b) => a.totalSales > b.totalSales ? a : b).date,
      'total_customers': _performanceData.fold<int>(0, (sum, p) => sum + p.customerCount),
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
            Text('Loading performance data...'),
          ],
        ),
      );
    }

    final selectedStore = _stores.firstWhere(
      (s) => s.storeId == _selectedStoreId,
      orElse: () => _stores.first,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
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
                    const Icon(Icons.dashboard, color: Colors.indigo, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Store Performance',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _loadPerformanceData(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Data',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Store and Period Selection
                Row(
                  children: [
                    // Store Selection
                    SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<String>(
                        value: _selectedStoreId,
                        decoration: InputDecoration(
                          labelText: 'Select Store',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _stores.map((store) => DropdownMenuItem(
                          value: store.storeId,
                          child: Row(
                            children: [
                              Text(store.storeTypeIcon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(store.storeName)),
                            ],
                          ),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedStoreId = value!);
                          _loadPerformanceData();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Period Selection
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
                        onChanged: (value) {
                          setState(() => _selectedPeriod = value!);
                          _loadPerformanceData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Selected Store Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo[200]!),
                  ),
                  child: Row(
                    children: [
                      Text(selectedStore.storeTypeIcon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedStore.storeName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              '${selectedStore.storeCode} • ${selectedStore.city}, ${selectedStore.state}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedStore.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selectedStore.statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          selectedStore.storeStatus,
                          style: TextStyle(
                            color: selectedStore.statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    Tab(text: 'Trends'),
                    Tab(text: 'Analysis'),
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
                _buildTrendsTab(),
                _buildAnalysisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(child: _buildKPICard(
                'Total Sales',
                '₹${_formatNumber(_kpis['total_sales'])}',
                Icons.currency_rupee,
                Colors.green,
                subtitle: '${_selectedPeriod.toLowerCase()}',
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildKPICard(
                'Transactions',
                '${_kpis['total_transactions']}',
                Icons.receipt,
                Colors.blue,
                subtitle: '${(_kpis['avg_transactions_per_day'] ?? 0).toStringAsFixed(1)}/day avg',
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildKPICard(
                'Avg Transaction',
                '₹${_formatNumber(_kpis['avg_transaction_value'])}',
                Icons.analytics,
                Colors.orange,
                subtitle: 'per transaction',
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildKPICard(
                'Growth',
                '${(_kpis['sales_growth'] ?? 0).toStringAsFixed(1)}%',
                _kpis['sales_growth'] >= 0 ? Icons.trending_up : Icons.trending_down,
                _kpis['sales_growth'] >= 0 ? Colors.green : Colors.red,
                subtitle: 'week over week',
              )),
            ],
          ),
          const SizedBox(height: 24),
          // Performance Chart
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sales Performance',
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
                                  '₹${_formatNumber(value)}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: _getXAxisInterval(),
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < _performanceData.length) {
                                  final date = _performanceData[value.toInt()].date;
                                  return Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(fontSize: 10),
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
                            dotData: FlDotData(show: false),
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
          // Recent Performance Highlights
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Highlights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHighlightItem(
                    '🎯',
                    'Peak Sales Day',
                    '${(_kpis['peak_sales_day'] as DateTime).day}/${(_kpis['peak_sales_day'] as DateTime).month}',
                    'Best performing day',
                  ),
                  _buildHighlightItem(
                    '👥',
                    'Total Customers',
                    '${_kpis['total_customers']}',
                    'Unique customers served',
                  ),
                  _buildHighlightItem(
                    '📊',
                    'Daily Average',
                    '₹${_formatNumber(_kpis['avg_sales_per_day'])}',
                    'Average daily sales',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sales and Transactions Chart
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sales & Transaction Trends',
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
                                  _formatNumber(value),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: _getXAxisInterval(),
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < _performanceData.length) {
                                  final date = _performanceData[value.toInt()].date;
                                  return Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(fontSize: 10),
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
                            dotData: FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: _getTransactionSpots(),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.indigo, 'Sales'),
                      const SizedBox(width: 24),
                      _buildLegendItem(Colors.orange, 'Transactions'),
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

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Analysis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          // Analysis insights would go here
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Insights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('• Consistent growth in daily sales'),
                  const Text('• Peak performance on weekends'),
                  const Text('• Average transaction value increasing'),
                  const Text('• Customer retention improving'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, {String? subtitle}) {
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
                if (title == 'Growth')
                  Icon(
                    _kpis['sales_growth'] >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: _kpis['sales_growth'] >= 0 ? Colors.green : Colors.red,
                    size: 20,
                  ),
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
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem(String emoji, String title, String value, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  List<FlSpot> _getSalesSpots() {
    return _performanceData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalSales);
    }).toList();
  }

  List<FlSpot> _getTransactionSpots() {
    // Scale transactions to be visible on the same chart as sales
    final maxSales = _performanceData.map((p) => p.totalSales).reduce((a, b) => a > b ? a : b);
    final maxTransactions = _performanceData.map((p) => p.totalTransactions).reduce((a, b) => a > b ? a : b);
    final scale = maxSales / maxTransactions;
    
    return _performanceData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalTransactions * scale);
    }).toList();
  }

  double _getXAxisInterval() {
    if (_performanceData.length <= 7) return 1;
    if (_performanceData.length <= 30) return 5;
    return 10;
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
