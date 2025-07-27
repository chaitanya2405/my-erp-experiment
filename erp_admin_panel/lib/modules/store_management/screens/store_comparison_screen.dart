import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/store_models.dart';
import '../services/store_service.dart';

/// 📊 Store Comparison Screen
/// Compare performance metrics across multiple stores
class StoreComparisonScreen extends StatefulWidget {
  @override
  _StoreComparisonScreenState createState() => _StoreComparisonScreenState();
}

class _StoreComparisonScreenState extends State<StoreComparisonScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMetric = 'Sales';
  String _selectedPeriod = 'Last 30 Days';
  List<String> _selectedStoreIds = [];
  bool _isLoading = true;
  
  List<Store> _stores = [];
  Map<String, List<StorePerformance>> _performanceData = {};
  Map<String, dynamic> _comparisonData = {};
  
  final List<String> _metrics = ['Sales', 'Transactions', 'Customer Count', 'Avg Transaction Value', 'Profit'];
  final List<String> _periods = [
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
    _loadData();
    
    print('📊 Initializing Store Comparison Screen...');
    print('  📈 Loading multi-store performance data');
    print('  🎯 Setting up comparative analytics');
    print('  📋 Preparing benchmark analysis');
    print('  ✅ Ready for store comparisons');
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
        // Select first 3 stores by default
        if (_stores.length >= 3) {
          _selectedStoreIds = _stores.take(3).map((s) => s.storeId).toList();
        } else {
          _selectedStoreIds = _stores.map((s) => s.storeId).toList();
        }
      });
      
      await _loadPerformanceData();
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
      _generateMockData();
    }
  }

  Future<void> _loadPerformanceData() async {
    try {
      _performanceData.clear();
      
      for (String storeId in _selectedStoreIds) {
        try {
          final performance = await StoreService.getStorePerformance(
            storeId,
            startDate: _getStartDate(),
            endDate: DateTime.now(),
          );
          _performanceData[storeId] = performance;
        } catch (e) {
          // Generate mock data if service fails
          _performanceData[storeId] = _generateMockPerformanceData(storeId);
        }
      }
      
      _generateComparisonData();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading performance data: $e');
    }
  }

  void _generateMockData() {
    // Generate mock performance data for demo
    for (String storeId in _selectedStoreIds) {
      _performanceData[storeId] = _generateMockPerformanceData(storeId);
    }
    
    _generateComparisonData();
    setState(() => _isLoading = false);
  }

  List<StorePerformance> _generateMockPerformanceData(String storeId) {
    final store = _stores.firstWhere((s) => s.storeId == storeId);
    final random = store.hashCode;
    final days = _getDaysCount();
    
    return List.generate(days, (index) {
      final date = _getStartDate().add(Duration(days: index));
      return StorePerformance(
        storeId: store.storeId,
        storeCode: store.storeCode,
        storeName: store.storeName,
        date: date,
        totalSales: 5000 + (random % 3000) + (index * 100).toDouble(),
        totalTransactions: 30 + (random % 20) + index,
        customerCount: 25 + (random % 15) + index,
        averageTransactionValue: 1000 + (random % 500).toDouble(),
        grossProfit: 1500 + (random % 900).toDouble(),
        netProfit: 1200 + (random % 600).toDouble(),
        inventoryTurnover: 1 + (random % 2),
        footfallCount: 50 + (random % 25).toDouble(),
        conversionRate: 0.4 + ((random % 15) / 100),
      );
    });
  }

  void _generateComparisonData() {
    _comparisonData.clear();
    
    for (String storeId in _selectedStoreIds) {
      final performance = _performanceData[storeId] ?? [];
      final store = _stores.firstWhere((s) => s.storeId == storeId);
      
      if (performance.isNotEmpty) {
        _comparisonData[storeId] = {
          'store_name': store.storeName,
          'store_code': store.storeCode,
          'total_sales': performance.fold<double>(0, (sum, p) => sum + p.totalSales),
          'total_transactions': performance.fold<int>(0, (sum, p) => sum + p.totalTransactions),
          'total_customers': performance.fold<int>(0, (sum, p) => sum + p.customerCount),
          'avg_transaction_value': performance.isNotEmpty 
              ? performance.map((p) => p.averageTransactionValue).reduce((a, b) => a + b) / performance.length
              : 0.0,
          'total_profit': performance.fold<double>(0, (sum, p) => sum + p.netProfit),
          'avg_conversion_rate': performance.isNotEmpty
              ? performance.map((p) => p.conversionRate).reduce((a, b) => a + b) / performance.length
              : 0.0,
          'performance_data': performance,
        };
      }
    }
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Last 7 Days':
        return now.subtract(const Duration(days: 7));
      case 'Last 30 Days':
        return now.subtract(const Duration(days: 30));
      case 'Last 3 Months':
        return now.subtract(const Duration(days: 90));
      case 'Last 6 Months':
        return now.subtract(const Duration(days: 180));
      case 'This Year':
        return DateTime(now.year, 1, 1);
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  int _getDaysCount() {
    switch (_selectedPeriod) {
      case 'Last 7 Days':
        return 7;
      case 'Last 30 Days':
        return 30;
      case 'Last 3 Months':
        return 90;
      case 'Last 6 Months':
        return 180;
      case 'This Year':
        return DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      default:
        return 30;
    }
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
            Text('Loading comparison data...'),
          ],
        ),
      );
    }

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
                    const Icon(Icons.compare_arrows, color: Colors.indigo, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Store Comparison',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loadPerformanceData,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Data',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Filters
                Row(
                  children: [
                    // Store Selection
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Stores to Compare',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _stores.map((store) {
                              final isSelected = _selectedStoreIds.contains(store.storeId);
                              return FilterChip(
                                label: Text(store.storeName),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      if (_selectedStoreIds.length < 5) {
                                        _selectedStoreIds.add(store.storeId);
                                      }
                                    } else {
                                      _selectedStoreIds.remove(store.storeId);
                                    }
                                  });
                                  _loadPerformanceData();
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.indigo[100],
                                checkmarkColor: Colors.indigo,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Metric Selection
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _selectedMetric,
                        decoration: InputDecoration(
                          labelText: 'Metric',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _metrics.map((metric) => DropdownMenuItem(
                          value: metric,
                          child: Text(metric),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedMetric = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Period Selection
                    SizedBox(
                      width: 150,
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
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.indigo,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.indigo,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Trends'),
                    Tab(text: 'Rankings'),
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
                _buildRankingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_selectedStoreIds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select stores to compare',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comparison Cards
          Row(
            children: _selectedStoreIds.map((storeId) {
              final data = _comparisonData[storeId];
              if (data == null) return const SizedBox.shrink();
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildStoreComparisonCard(data),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Metric Comparison Chart
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedMetric Comparison',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
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
                                  _formatChartValue(value),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < _selectedStoreIds.length) {
                                  final storeId = _selectedStoreIds[value.toInt()];
                                  final data = _comparisonData[storeId];
                                  return Text(
                                    data?['store_code'] ?? '',
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

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedMetric Trends',
                    style: const TextStyle(
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
                                  _formatChartValue(value),
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
                                final days = _getDaysCount();
                                if (value.toInt() < days) {
                                  final date = _getStartDate().add(Duration(days: value.toInt()));
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
                        lineBarsData: _getLineChartData(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Wrap(
                    spacing: 16,
                    children: _selectedStoreIds.asMap().entries.map((entry) {
                      final index = entry.key;
                      final storeId = entry.value;
                      final data = _comparisonData[storeId];
                      final color = _getStoreColor(index);
                      
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 3,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Text(data?['store_name'] ?? ''),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsTab() {
    // Sort stores by selected metric
    final sortedData = _comparisonData.entries.toList()
      ..sort((a, b) => _getMetricValue(b.value).compareTo(_getMetricValue(a.value)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Store Rankings by $_selectedMetric',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          ...sortedData.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final storeData = entry.value.value;
            return _buildRankingCard(rank, storeData);
          }),
        ],
      ),
    );
  }

  Widget _buildStoreComparisonCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['store_name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              data['store_code'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Sales', '₹${_formatNumber(data['total_sales'])}'),
            _buildMetricRow('Transactions', '${data['total_transactions']}'),
            _buildMetricRow('Customers', '${data['total_customers']}'),
            _buildMetricRow('Avg Value', '₹${_formatNumber(data['avg_transaction_value'])}'),
            _buildMetricRow('Profit', '₹${_formatNumber(data['total_profit'])}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(int rank, Map<String, dynamic> data) {
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
                    data['store_name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    data['store_code'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Metric Value
            Text(
              _formatMetricValue(_getMetricValue(data)),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    final colors = [Colors.indigo, Colors.green, Colors.orange, Colors.red, Colors.purple];
    
    return _selectedStoreIds.asMap().entries.map((entry) {
      final index = entry.key;
      final storeId = entry.value;
      final data = _comparisonData[storeId];
      final value = _getMetricValue(data ?? {});
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: colors[index % colors.length],
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  List<LineChartBarData> _getLineChartData() {
    final colors = [Colors.indigo, Colors.green, Colors.orange, Colors.red, Colors.purple];
    
    return _selectedStoreIds.asMap().entries.map((entry) {
      final index = entry.key;
      final storeId = entry.value;
      final performanceData = _performanceData[storeId] ?? [];
      
      final spots = performanceData.asMap().entries.map((dataEntry) {
        final dayIndex = dataEntry.key;
        final performance = dataEntry.value;
        final value = _getPerformanceMetricValue(performance);
        return FlSpot(dayIndex.toDouble(), value);
      }).toList();
      
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: colors[index % colors.length],
        barWidth: 3,
        dotData: FlDotData(show: false),
      );
    }).toList();
  }

  double _getMetricValue(Map<String, dynamic> data) {
    switch (_selectedMetric) {
      case 'Sales':
        return data['total_sales']?.toDouble() ?? 0.0;
      case 'Transactions':
        return data['total_transactions']?.toDouble() ?? 0.0;
      case 'Customer Count':
        return data['total_customers']?.toDouble() ?? 0.0;
      case 'Avg Transaction Value':
        return data['avg_transaction_value']?.toDouble() ?? 0.0;
      case 'Profit':
        return data['total_profit']?.toDouble() ?? 0.0;
      default:
        return 0.0;
    }
  }

  double _getPerformanceMetricValue(StorePerformance performance) {
    switch (_selectedMetric) {
      case 'Sales':
        return performance.totalSales;
      case 'Transactions':
        return performance.totalTransactions.toDouble();
      case 'Customer Count':
        return performance.customerCount.toDouble();
      case 'Avg Transaction Value':
        return performance.averageTransactionValue;
      case 'Profit':
        return performance.netProfit;
      default:
        return 0.0;
    }
  }

  String _formatMetricValue(double value) {
    switch (_selectedMetric) {
      case 'Sales':
      case 'Avg Transaction Value':
      case 'Profit':
        return '₹${_formatNumber(value)}';
      default:
        return _formatNumber(value);
    }
  }

  String _formatChartValue(double value) {
    if (_selectedMetric == 'Sales' || _selectedMetric == 'Avg Transaction Value' || _selectedMetric == 'Profit') {
      return '₹${_formatNumber(value)}';
    }
    return _formatNumber(value);
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

  Color _getStoreColor(int index) {
    final colors = [Colors.indigo, Colors.green, Colors.orange, Colors.red, Colors.purple];
    return colors[index % colors.length];
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

  double _getXAxisInterval() {
    final days = _getDaysCount();
    if (days <= 7) return 1;
    if (days <= 30) return 5;
    return 10;
  }
}
