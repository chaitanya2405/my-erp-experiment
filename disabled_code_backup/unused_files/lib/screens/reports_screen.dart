import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedReportType = 'sales';
  String _selectedPeriod = 'today';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _setDateRange();
  }

  void _setDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
        break;
      case 'week':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'quarter':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        _startDate = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        _endDate = now;
        break;
      case 'year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReport,
            tooltip: 'Print Report',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildReportFilters(),
          Expanded(child: _buildReportContent()),
        ],
      ),
    );
  }

  Widget _buildReportFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.deepPurple.shade50,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedReportType,
              decoration: InputDecoration(
                labelText: 'Report Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'sales', child: Text('Sales Report')),
                DropdownMenuItem(value: 'inventory', child: Text('Inventory Report')),
                DropdownMenuItem(value: 'purchase', child: Text('Purchase Report')),
                DropdownMenuItem(value: 'customer', child: Text('Customer Report')),
                DropdownMenuItem(value: 'supplier', child: Text('Supplier Report')),
                DropdownMenuItem(value: 'financial', child: Text('Financial Summary')),
                DropdownMenuItem(value: 'profit', child: Text('Profit & Loss')),
              ],
              onChanged: (value) => setState(() => _selectedReportType = value!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: InputDecoration(
                labelText: 'Time Period',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'today', child: Text('Today')),
                DropdownMenuItem(value: 'week', child: Text('This Week')),
                DropdownMenuItem(value: 'month', child: Text('This Month')),
                DropdownMenuItem(value: 'quarter', child: Text('This Quarter')),
                DropdownMenuItem(value: 'year', child: Text('This Year')),
                DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                  if (value != 'custom') {
                    _setDateRange();
                  }
                });
                if (value == 'custom') {
                  _selectCustomDateRange();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() => _setDateRange()),
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

  Widget _buildReportContent() {
    switch (_selectedReportType) {
      case 'sales':
        return _buildSalesReport();
      case 'inventory':
        return _buildInventoryReport();
      case 'purchase':
        return _buildPurchaseReport();
      case 'customer':
        return _buildCustomerReport();
      case 'supplier':
        return _buildSupplierReport();
      case 'financial':
        return _buildFinancialReport();
      case 'profit':
        return _buildProfitLossReport();
      default:
        return _buildSalesReport();
    }
  }

  Widget _buildSalesReport() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .where('created_at', isGreaterThanOrEqualTo: _startDate)
          .where('created_at', isLessThanOrEqualTo: _endDate)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;
        final totalSales = orders.fold<double>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + ((data['total_amount'] as num?)?.toDouble() ?? 0.0);
        });

        final totalOrders = orders.length;
        final avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;

        // Calculate daily sales for chart
        final dailySales = <String, double>{};
        for (final doc in orders) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['created_at'] as Timestamp?;
          if (timestamp != null) {
            final date = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
            final amount = (data['total_amount'] as num?)?.toDouble() ?? 0.0;
            dailySales[date] = (dailySales[date] ?? 0.0) + amount;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Report',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Total Sales', '₹${totalSales.toStringAsFixed(2)}', Icons.currency_rupee, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Total Orders', totalOrders.toString(), Icons.shopping_cart, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Avg Order Value', '₹${avgOrderValue.toStringAsFixed(2)}', Icons.trending_up, Colors.orange)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sales Chart
              if (dailySales.isNotEmpty) ...[
                const Text('Sales Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final dates = dailySales.keys.toList()..sort();
                              if (value.toInt() >= 0 && value.toInt() < dates.length) {
                                final date = DateTime.parse(dates[value.toInt()]);
                                return Text(DateFormat('MM/dd').format(date));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text('₹${value.toInt()}'),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: () {
                            final sortedEntries = dailySales.entries.toList()
                              ..sort((a, b) => a.key.compareTo(b.key));
                            return sortedEntries
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.value,
                              ))
                              .toList();
                          }(),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Detailed Order List
              const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildOrderDetailsTable(orders),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryReport() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;
        final totalProducts = products.length;
        final lowStockProducts = products.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final stock = (data['stock_quantity'] as num?)?.toInt() ?? 0;
          final minStock = (data['min_stock_level'] as num?)?.toInt() ?? 0;
          return stock <= minStock;
        }).length;

        final totalStockValue = products.fold<double>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final stock = (data['stock_quantity'] as num?)?.toDouble() ?? 0.0;
          final cost = (data['cost_price'] as num?)?.toDouble() ?? 0.0;
          return sum + (stock * cost);
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inventory Report',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Total Products', totalProducts.toString(), Icons.inventory, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Low Stock Items', lowStockProducts.toString(), Icons.warning, Colors.red)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Stock Value', '₹${totalStockValue.toStringAsFixed(2)}', Icons.currency_rupee, Colors.green)),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Product Inventory Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildInventoryDetailsTable(products),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchaseReport() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('purchase_orders')
          .where('created_at', isGreaterThanOrEqualTo: _startDate)
          .where('created_at', isLessThanOrEqualTo: _endDate)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final purchaseOrders = snapshot.data!.docs;
        final totalPurchases = purchaseOrders.fold<double>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + ((data['total_amount'] as num?)?.toDouble() ?? 0.0);
        });

        final pendingOrders = purchaseOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'pending';
        }).length;

        final receivedOrders = purchaseOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'received';
        }).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Purchase Report',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Total Purchases', '₹${totalPurchases.toStringAsFixed(2)}', Icons.shopping_bag, Colors.purple)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Pending Orders', pendingOrders.toString(), Icons.pending, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Received Orders', receivedOrders.toString(), Icons.check_circle, Colors.green)),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Purchase Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPurchaseOrderDetailsTable(purchaseOrders),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerReport() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('customers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final customers = snapshot.data!.docs;
        final totalCustomers = customers.length;
        final vipCustomers = customers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['segment'] == 'VIP';
        }).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Report',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Total Customers', totalCustomers.toString(), Icons.people, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('VIP Customers', vipCustomers.toString(), Icons.star, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('New This Month', '0', Icons.person_add, Colors.green)),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildCustomerDetailsTable(customers),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupplierReport() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('suppliers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final suppliers = snapshot.data!.docs;
        final totalSuppliers = suppliers.length;
        final preferredSuppliers = suppliers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['is_preferred'] == true;
        }).length;

        final totalOrderValue = suppliers.fold<double>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + ((data['total_order_value'] as num?)?.toDouble() ?? 0.0);
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Supplier Report',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Total Suppliers', totalSuppliers.toString(), Icons.business, Colors.indigo)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Preferred Suppliers', preferredSuppliers.toString(), Icons.star, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Total Orders Value', '₹${totalOrderValue.toStringAsFixed(2)}', Icons.currency_rupee, Colors.green)),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Supplier Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSupplierDetailsTable(suppliers),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialReport() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Financial Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Comprehensive financial summary coming soon...'),
        ],
      ),
    );
  }

  Widget _buildProfitLossReport() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Profit & Loss Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('P&L statement generation coming soon...'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsTable(List<QueryDocumentSnapshot> orders) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Order ID')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
        ],
        rows: orders.take(10).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['created_at'] as Timestamp?;
          return DataRow(cells: [
            DataCell(Text(doc.id.substring(0, 8))),
            DataCell(Text(data['customer_name'] ?? 'N/A')),
            DataCell(Text(timestamp != null ? DateFormat('MMM dd, yyyy').format(timestamp.toDate()) : 'N/A')),
            DataCell(Text('₹${((data['total_amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}')),
            DataCell(Text(data['status'] ?? 'completed')),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildInventoryDetailsTable(List<QueryDocumentSnapshot> products) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Product')),
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Min Stock')),
          DataColumn(label: Text('Status')),
        ],
        rows: products.take(10).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final stock = (data['stock_quantity'] as num?)?.toInt() ?? 0;
          final minStock = (data['min_stock_level'] as num?)?.toInt() ?? 0;
          final isLowStock = stock <= minStock;
          
          return DataRow(cells: [
            DataCell(Text(data['name'] ?? 'N/A')),
            DataCell(Text(data['sku'] ?? 'N/A')),
            DataCell(Text(stock.toString())),
            DataCell(Text(minStock.toString())),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLowStock ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isLowStock ? 'Low Stock' : 'OK',
                style: TextStyle(
                  color: isLowStock ? Colors.red.shade700 : Colors.green.shade700,
                  fontSize: 12,
                ),
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildPurchaseOrderDetailsTable(List<QueryDocumentSnapshot> orders) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('PO ID')),
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
        ],
        rows: orders.take(10).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['created_at'] as Timestamp?;
          return DataRow(cells: [
            DataCell(Text(doc.id.substring(0, 8))),
            DataCell(Text(data['supplier_name'] ?? 'N/A')),
            DataCell(Text(timestamp != null ? DateFormat('MMM dd, yyyy').format(timestamp.toDate()) : 'N/A')),
            DataCell(Text('₹${((data['total_amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}')),
            DataCell(Text(data['status'] ?? 'pending')),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerDetailsTable(List<QueryDocumentSnapshot> customers) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Segment')),
          DataColumn(label: Text('Orders')),
        ],
        rows: customers.take(10).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DataRow(cells: [
            DataCell(Text(data['name'] ?? 'N/A')),
            DataCell(Text(data['email'] ?? 'N/A')),
            DataCell(Text(data['phone'] ?? 'N/A')),
            DataCell(Text(data['segment'] ?? 'Regular')),
            DataCell(Text((data['total_orders'] ?? 0).toString())),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildSupplierDetailsTable(List<QueryDocumentSnapshot> suppliers) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Rating')),
          DataColumn(label: Text('Orders')),
          DataColumn(label: Text('Total Value')),
        ],
        rows: suppliers.take(10).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
          return DataRow(cells: [
            DataCell(Text(data['supplier_name'] ?? 'N/A')),
            DataCell(Text(data['supplier_type'] ?? 'N/A')),
            DataCell(Text('${rating.toStringAsFixed(1)}/5')),
            DataCell(Text((data['total_orders_supplied'] ?? 0).toString())),
            DataCell(Text('₹${((data['total_order_value'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}')),
          ]);
        }).toList(),
      ),
    );
  }

  void _selectCustomDateRange() async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon...')),
    );
  }

  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon...')),
    );
  }
}
