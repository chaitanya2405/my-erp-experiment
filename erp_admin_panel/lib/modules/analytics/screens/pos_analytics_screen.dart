import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../pos_management/providers/pos_providers.dart';

class PosAnalyticsScreen extends ConsumerStatefulWidget {
  const PosAnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PosAnalyticsScreen> createState() => _PosAnalyticsScreenState();
}

class _PosAnalyticsScreenState extends ConsumerState<PosAnalyticsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = '30_days';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  void _loadAnalytics() {
    ref.read(posStateProvider.notifier).loadAnalytics(_startDate, _endDate);
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posStateProvider);
    
    return RefreshIndicator(
      onRefresh: () async => _loadAnalytics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  if (posState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (posState.error != null)
                    _buildErrorWidget(posState.error!)
                  else ...[
                    _buildSummaryCards(posState.analytics),
                    const SizedBox(height: 20),
                    _buildSalesChart(posState.transactions),
                    const SizedBox(height: 20),
                    _buildPaymentModeChart(posState.analytics),
                    const SizedBox(height: 20),
                    _buildTopProducts(posState),
                    const SizedBox(height: 20),
                    _buildRecentTransactions(posState.transactions.take(5).toList()),
                  ],
                ],
              ),
            ),
          );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildPeriodChip('7_days', '7 Days'),
                _buildPeriodChip('30_days', '30 Days'),
                _buildPeriodChip('90_days', '90 Days'),
                _buildPeriodChip('custom', 'Custom'),
              ],
            ),
            if (_selectedPeriod == 'custom') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'From: ${_formatDate(_startDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'To: ${_formatDate(_endDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = period;
          _updateDateRange(period);
        });
        _loadAnalytics();
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
    );
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case '7_days':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case '30_days':
        _startDate = now.subtract(const Duration(days: 30));
        _endDate = now;
        break;
      case '90_days':
        _startDate = now.subtract(const Duration(days: 90));
        _endDate = now;
        break;
    }
  }

  Widget _buildSummaryCards(Map<String, dynamic> analytics) {
    final totalSales = analytics['total_sales'] ?? 0.0;
    final totalTransactions = analytics['total_transactions'] ?? 0;
    final avgBillValue = analytics['average_bill_value'] ?? 0.0;
    final totalDiscount = analytics['total_discount'] ?? 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Sales',
                '₹${totalSales.toStringAsFixed(2)}',
                Icons.currency_rupee,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Transactions',
                totalTransactions.toString(),
                Icons.receipt,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Avg. Bill Value',
                '₹${avgBillValue.toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Discounts',
                '₹${totalDiscount.toStringAsFixed(2)}',
                Icons.local_offer,
                Colors.purple,
              ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(List transactions) {
    if (transactions.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          child: const Center(
            child: Text('No data available for chart'),
          ),
        ),
      );
    }

    // Group transactions by date
    Map<String, double> dailySales = {};
    for (var transaction in transactions) {
      final date = _formatDate(transaction.transactionTime);
      dailySales[date] = (dailySales[date] ?? 0) + transaction.totalAmount;
    }

    final spots = dailySales.entries
        .map((entry) => FlSpot(
              dailySales.keys.toList().indexOf(entry.key).toDouble(),
              entry.value,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${(value / 1000).toStringAsFixed(0)}K',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dailySales.length) {
                            final date = dailySales.keys.elementAt(index);
                            return Text(
                              date.split('/')[0], // Show only day
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
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
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

  Widget _buildPaymentModeChart(Map<String, dynamic> analytics) {
    final paymentModes = analytics['payment_modes'] as Map<String, int>? ?? {};
    
    if (paymentModes.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          child: const Center(
            child: Text('No payment data available'),
          ),
        ),
      );
    }

    final total = paymentModes.values.fold(0, (sum, count) => sum + count);
    final colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.red];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Modes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: paymentModes.entries.map((entry) {
                          final index = paymentModes.keys.toList().indexOf(entry.key);
                          final percentage = (entry.value / total) * 100;
                          return PieChartSectionData(
                            value: entry.value.toDouble(),
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: colors[index % colors.length],
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: paymentModes.entries.map((entry) {
                      final index = paymentModes.keys.toList().indexOf(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: colors[index % colors.length],
                            ),
                            const SizedBox(width: 8),
                            Text('${entry.key}: ${entry.value}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(PosState posState) {
    final topProducts = ref.read(posStateProvider.notifier).getTopSellingProducts(5);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Selling Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (topProducts.isEmpty)
              const Center(
                child: Text('No product data available'),
              )
            else
              ...topProducts.entries.map((entry) => _buildProductRow(
                    entry.key,
                    entry.value,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(String productName, int quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              productName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List transactions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              const Center(
                child: Text('No recent transactions'),
              )
            else
              ...transactions.map((transaction) => _buildTransactionRow(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.invoiceNumber,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDateTime(transaction.transactionTime),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${transaction.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
      _loadAnalytics();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
