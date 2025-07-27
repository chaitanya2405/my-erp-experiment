import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'dart:typed_data';
import '../models/original_models.dart';
import 'customer_order_detail_screen.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../services/file_download_service.dart';

class CustomerOrderAnalyticsScreen extends StatefulWidget {
  const CustomerOrderAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerOrderAnalyticsScreen> createState() => _CustomerOrderAnalyticsScreenState();
}

class _CustomerOrderAnalyticsScreenState extends State<CustomerOrderAnalyticsScreen> {
  String _search = '';
  String _statusFilter = 'All';
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Order Management Dashboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('customer_orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!.docs
              .map((doc) => CustomerOrder.fromFirestore(doc))
              .toList();

          // Filtering
          final filteredOrders = orders.where((o) {
            final matchesSearch = _search.isEmpty ||
                o.orderNumber.toLowerCase().contains(_search) ||
                o.customerId.toLowerCase().contains(_search) ||
                o.orderStatus.toLowerCase().contains(_search);
            final matchesStatus = _statusFilter == 'All' || o.orderStatus == _statusFilter;
            final matchesDate = _dateRange == null ||
                (o.orderDate != null &&
                  o.orderDate!.toDate().isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
                  o.orderDate!.toDate().isBefore(_dateRange!.end.add(const Duration(days: 1))));
            return matchesSearch && matchesStatus && matchesDate;
          }).toList();

          // Analytics
          final totalOrders = orders.length;
          final totalRevenue = orders.fold<double>(0, (sum, o) => sum + o.grandTotal);
          final completedOrders = orders.where((o) => o.orderStatus == 'Completed').length;
          final cancelledOrders = orders.where((o) => o.orderStatus == 'Cancelled').length;
          final subscriptionOrders = orders.where((o) => o.subscriptionFlag).length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Analytics Cards & Charts
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard('Total Orders', totalOrders.toString(), Icons.shopping_cart),
                      _buildStatCard('Total Revenue', '₹${totalRevenue.toStringAsFixed(2)}', Icons.attach_money),
                      _buildStatCard('Completed', completedOrders.toString(), Icons.check_circle, color: Colors.green),
                      _buildStatCard('Cancelled', cancelledOrders.toString(), Icons.cancel, color: Colors.red),
                      _buildStatCard('Subscriptions', subscriptionOrders.toString(), Icons.repeat),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 350,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('Order Status Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 200,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      barGroups: [
                                        _barGroup('New', orders.where((o) => o.orderStatus == 'New').length, Colors.blue),
                                        _barGroup('Confirmed', orders.where((o) => o.orderStatus == 'Confirmed').length, Colors.orange),
                                        _barGroup('Packed', orders.where((o) => o.orderStatus == 'Packed').length, Colors.purple),
                                        _barGroup('Out', orders.where((o) => o.orderStatus == 'Out for Delivery').length, Colors.teal),
                                        _barGroup('Completed', completedOrders, Colors.green),
                                        _barGroup('Cancelled', cancelledOrders, Colors.red),
                                      ],
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (double value, TitleMeta meta) {
                                              const labels = ['New', 'Confirmed', 'Packed', 'Out', 'Completed', 'Cancelled'];
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10)),
                                              );
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(show: false),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 350,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('Revenue Trend (Last 7 Days)', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 200,
                                  child: LineChart(
                                    LineChartData(
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: List.generate(7, (i) => FlSpot(i.toDouble(), Random().nextDouble() * 10000)),
                                          isCurved: true,
                                          color: Colors.teal,
                                          barWidth: 3,
                                          dotData: FlDotData(show: false),
                                        ),
                                      ],
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (double value, TitleMeta meta) {
                                              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                child: Text(days[value.toInt() % 7], style: const TextStyle(fontSize: 10)),
                                              );
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(show: false),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 350,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('Payment Mode Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 180,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        _pieSection('UPI', orders.where((o) => o.paymentMode == 'UPI').length, Colors.blue),
                                        _pieSection('Card', orders.where((o) => o.paymentMode == 'Card').length, Colors.orange),
                                        _pieSection('COD', orders.where((o) => o.paymentMode == 'COD').length, Colors.green),
                                        _pieSection('Wallet', orders.where((o) => o.paymentMode == 'Wallet').length, Colors.purple),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Search & Filter Bar
                Row(
                  children: [
                    // Search
                    SizedBox(
                      width: 250,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by order #, customer, status...',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                        ),
                        onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status Filter
                    DropdownButton<String>(
                      value: _statusFilter,
                      items: ['All', 'New', 'Confirmed', 'Packed', 'Out for Delivery', 'Completed', 'Cancelled']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
                    ),
                    const SizedBox(width: 16),
                    // Date Range Filter
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(_dateRange == null
                          ? 'Filter by Date'
                          : '${_dateRange!.start.toString().split(' ').first} - ${_dateRange!.end.toString().split(' ').first}'),
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2022),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _dateRange = picked);
                      },
                    ),
                    if (_dateRange != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dateRange = null),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Export Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Export to CSV'),
                      onPressed: () => _exportOrdersToCSV(filteredOrders),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Orders Table
                Expanded(
                  child: CustomerOrderDataTable(orders: filteredOrders),
                ),
                // Top Customers Leaderboard
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top Customers', style: TextStyle(fontWeight: FontWeight.bold)),
                        ..._topCustomers(orders).map((e) => Text('${e.key}: ${e.value} orders')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color color = Colors.blue}) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.08),
      child: SizedBox(
        width: 180,
        height: 90,
        child: Center(
          child: ListTile(
            leading: Icon(icon, color: color, size: 36),
            title: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            subtitle: Text(label, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ),
    );
  }

  Future<void> _exportOrdersToCSV(List<CustomerOrder> orders) async {
    final headers = [
      'Order #', 'Order ID', 'Customer ID', 'Store ID', 'Order Date', 'Status', 'Payment Status',
      'Payment Mode', 'Delivery Mode', 'Delivery Address', 'Products', 'Total Amount', 'Discount',
      'Tax', 'Delivery Charges', 'Grand Total', 'Subscription', 'Plan', 'Wallet Used', 'Delivery Slot',
      'Delivery Person', 'Invoice ID', 'Remarks', 'Created', 'Updated'
    ];
    final rows = [
      headers,
      ...orders.map((o) => [
        o.orderNumber,
        o.orderId,
        o.customerId,
        o.storeId,
        o.orderDate?.toDate().toString().split(' ').first ?? '-',
        o.orderStatus,
        o.paymentStatus,
        o.paymentMode,
        o.deliveryMode,
        o.deliveryAddress?.toString() ?? '-',
        o.productsOrdered.map((p) => p['name'] ?? '').join(', '),
        o.totalAmount,
        o.discount,
        o.taxAmount,
        o.deliveryCharges,
        o.grandTotal,
        o.subscriptionFlag ? 'Yes' : 'No',
        o.subscriptionPlan ?? '-',
        o.walletUsed,
        o.deliverySlot ?? '-',
        o.deliveryPersonId ?? '-',
        o.invoiceId ?? '-',
        o.remarks ?? '-',
        o.createdAt?.toDate().toString().split(' ').first ?? '-',
        o.updatedAt?.toDate().toString().split(' ').first ?? '-',
      ])
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(utf8.encode(csv));
    await FileDownloadService.downloadFile(bytes, 'customer_orders.csv');
  }

  // Helper for leaderboard
  List<MapEntry<String, int>> _topCustomers(List<CustomerOrder> orders) {
    final counts = <String, int>{};
    for (final o in orders) {
      counts[o.customerId] = (counts[o.customerId] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }
}

// --- Data Table with Quick Actions ---
class CustomerOrderDataTable extends StatefulWidget {
  final List<CustomerOrder> orders;
  const CustomerOrderDataTable({required this.orders, Key? key}) : super(key: key);

  @override
  State<CustomerOrderDataTable> createState() => _CustomerOrderDataTableState();
}

class _CustomerOrderDataTableState extends State<CustomerOrderDataTable> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final ScrollController _horizontal = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _horizontal,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: 2400,
            child: PaginatedDataTable(
              columns: const [
                DataColumn(label: Text('Order #')),
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Customer ID')),
                DataColumn(label: Text('Store ID')),
                DataColumn(label: Text('Order Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Payment Status')),
                DataColumn(label: Text('Payment Mode')),
                DataColumn(label: Text('Delivery Mode')),
                DataColumn(label: Text('Delivery Address')),
                DataColumn(label: Text('Products')),
                DataColumn(label: Text('Total Amount')),
                DataColumn(label: Text('Discount')),
                DataColumn(label: Text('Tax')),
                DataColumn(label: Text('Delivery Charges')),
                DataColumn(label: Text('Grand Total')),
                DataColumn(label: Text('Subscription')),
                DataColumn(label: Text('Plan')),
                DataColumn(label: Text('Wallet Used')),
                DataColumn(label: Text('Delivery Slot')),
                DataColumn(label: Text('Delivery Person')),
                DataColumn(label: Text('Invoice ID')),
                DataColumn(label: Text('Remarks')),
                DataColumn(label: Text('Created')),
                DataColumn(label: Text('Updated')),
                DataColumn(label: Text('Details')),
              ],
              source: _CustomerOrderTableSource(widget.orders, context),
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: (v) {
                if (v != null) setState(() => _rowsPerPage = v);
              },
              showFirstLastButtons: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerOrderTableSource extends DataTableSource {
  final List<CustomerOrder> orders;
  final BuildContext context;

  _CustomerOrderTableSource(this.orders, this.context);

  @override
  DataRow getRow(int index) {
    if (index >= orders.length) return const DataRow(cells: []);
    final o = orders[index];
    return DataRow(
      cells: [
        DataCell(Text(o.orderNumber)),
        DataCell(Text(o.orderId)),
        DataCell(Text(o.customerId)),
        DataCell(Text(o.storeId)),
        DataCell(Text(o.orderDate?.toDate().toString().split(' ').first ?? '-')),
        DataCell(Text(o.orderStatus)),
        DataCell(Text(o.paymentStatus)),
        DataCell(Text(o.paymentMode)),
        DataCell(Text(o.deliveryMode)),
        DataCell(Text(o.deliveryAddress != null ? o.deliveryAddress.toString() : '-')),
        DataCell(Text(o.productsOrdered.map((p) => p['name'] ?? '').join(', '))),
        DataCell(Text(o.totalAmount.toString())),
        DataCell(Text(o.discount.toString())),
        DataCell(Text(o.taxAmount.toString())),
        DataCell(Text(o.deliveryCharges.toString())),
        DataCell(Text(o.grandTotal.toString())),
        DataCell(Text(o.subscriptionFlag ? 'Yes' : 'No')),
        DataCell(Text(o.subscriptionPlan ?? '-')),
        DataCell(Text(o.walletUsed.toString())),
        DataCell(Text(o.deliverySlot ?? '-')),
        DataCell(Text(o.deliveryPersonId ?? '-')),
        DataCell(Text(o.invoiceId ?? '-')),
        DataCell(Text(o.remarks ?? '-')),
        DataCell(Text(o.createdAt?.toDate().toString().split(' ').first ?? '-')),
        DataCell(Text(o.updatedAt?.toDate().toString().split(' ').first ?? '-')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerOrderDetailScreen(order: o),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) async {
                  if (action == 'Mark Completed') {
                    await FirebaseFirestore.instance.collection('customer_orders').doc(o.orderId).update({'order_status': 'Completed'});
                  } else if (action == 'Refund') {
                    // Implement refund logic here
                  }
                  // Add more actions as needed
                },
                itemBuilder: (context) => [
                  if (o.orderStatus != 'Completed')
                    const PopupMenuItem(value: 'Mark Completed', child: Text('Mark as Completed')),
                  const PopupMenuItem(value: 'Refund', child: Text('Refund')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => orders.length;
  @override
  int get selectedRowCount => 0;
}

// Helper for bar chart
BarChartGroupData _barGroup(String label, int value, Color color) {
  final index = {
    'New': 0,
    'Confirmed': 1,
    'Packed': 2,
    'Out': 3,
    'Completed': 4,
    'Cancelled': 5,
  }[label]!;
  return BarChartGroupData(
    x: index,
    barRods: [
      BarChartRodData(toY: value.toDouble(), color: color, width: 18),
    ],
  );
}

// Helper for pie chart
PieChartSectionData _pieSection(String label, int value, Color color) {
  final total = value == 0 ? 1 : value;
  return PieChartSectionData(
    color: color,
    value: total.toDouble(),
    title: '$label\n$value',
    radius: 50,
    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
  );
}
