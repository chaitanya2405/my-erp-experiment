import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class PoAdvancedAnalytics extends StatefulWidget {
  const PoAdvancedAnalytics({Key? key}) : super(key: key);

  @override
  State<PoAdvancedAnalytics> createState() => _PoAdvancedAnalyticsState();
}

class _PoAdvancedAnalyticsState extends State<PoAdvancedAnalytics> {
  List<Map<String, dynamic>> _poData = [];
  List<Map<String, dynamic>> _suppliers = [];
  bool _loading = true;
  DateTimeRange? _dateRange;
  String? _selectedSupplier;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final poSnap = await FirebaseFirestore.instance.collection('purchase_orders').get();
    final supplierSnap = await FirebaseFirestore.instance.collection('suppliers').get();
    setState(() {
      _poData = poSnap.docs.map((d) => d.data()).toList();
      _suppliers = supplierSnap.docs.map((d) => d.data()).toList();
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredPOs {
    return _poData.where((po) {
      final date = (po['orderDate'] as Timestamp?)?.toDate();
      if (_dateRange != null && (date == null || date.isBefore(_dateRange!.start) || date.isAfter(_dateRange!.end))) return false;
      if (_selectedSupplier != null && _selectedSupplier!.isNotEmpty && po['supplierId'] != _selectedSupplier) return false;
      if (_selectedStatus != null && _selectedStatus!.isNotEmpty && po['status'] != _selectedStatus) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final filteredPOs = _filteredPOs;
    // POs per month
    final Map<String, int> poPerMonth = {};
    final Map<String, double> poValueTrend = {};
    for (var po in filteredPOs) {
      final date = (po['orderDate'] as Timestamp?)?.toDate();
      if (date != null) {
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        poPerMonth[key] = (poPerMonth[key] ?? 0) + 1;
        poValueTrend[key] = (poValueTrend[key] ?? 0) + (po['totalValue'] ?? 0.0);
      }
    }
    // Supplier PO share (pie chart)
    final Map<String, int> supplierCount = {};
    for (var po in filteredPOs) {
      final supplier = po['supplierId'] ?? 'Unknown';
      supplierCount[supplier] = (supplierCount[supplier] ?? 0) + 1;
    }
    final supplierPie = supplierCount.entries.toList();
    // Overdue/Delivered
    final now = DateTime.now();
    final overdue = filteredPOs.where((po) {
      final expected = (po['expectedDelivery'] as Timestamp?)?.toDate();
      return po['status'] != 'Delivered' && expected != null && expected.isBefore(now);
    }).length;
    final delivered = filteredPOs.where((po) => po['status'] == 'Delivered').length;
    final totalValue = filteredPOs.fold(0.0, (sum, po) => sum + (po['totalValue'] ?? 0.0));
    final statuses = _poData.map((po) => po['status'] as String?).toSet().whereType<String>().toList();
    // Supplier dropdown items
    final supplierItems = _suppliers
        .where((s) => s['supplier_id'] != null || s['id'] != null)
        .map((s) => DropdownMenuItem<String>(
          value: s['supplier_id'] ?? s['id'],
          child: Text(s['supplier_name'] ?? s['name'] ?? s['supplier_id'] ?? s['id'] ?? 'Unknown'),
        ))
        .toSet() // Remove duplicates
        .toList();
    // Status dropdown items
    final statusItems = statuses.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Advanced Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Filters
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text('Date Range'),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dateRange = picked);
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedSupplier,
                hint: const Text('Supplier'),
                items: [const DropdownMenuItem<String>(value: '', child: Text('All Suppliers'))] + supplierItems,
                onChanged: (v) => setState(() => _selectedSupplier = v == '' ? null : v),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedStatus,
                hint: const Text('Status'),
                items: [const DropdownMenuItem<String>(value: '', child: Text('All Statuses'))] + statusItems,
                onChanged: (v) => setState(() => _selectedStatus = v == '' ? null : v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Summary cards
          Row(
            children: [
              _SummaryCard(label: 'Total POs', value: filteredPOs.length.toString()),
              const SizedBox(width: 12),
              _SummaryCard(label: 'Total Value', value: '₹${totalValue.toStringAsFixed(2)}'),
              const SizedBox(width: 12),
              _SummaryCard(label: 'Overdue', value: overdue.toString()),
              const SizedBox(width: 12),
              _SummaryCard(label: 'Delivered', value: delivered.toString()),
            ],
          ),
          const SizedBox(height: 24),
          // POs per month (bar chart)
          const Text('POs per Month'),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: poPerMonth.entries.map((e) => BarChartGroupData(
                  x: int.parse(e.key.split('-')[1]),
                  barRods: [
                    BarChartRodData(toY: e.value.toDouble(), color: Colors.purple),
                  ],
                  showingTooltipIndicators: [0],
                )).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final month = value.toInt().toString().padLeft(2, '0');
                        return Text(month);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // PO Value Trend (line chart)
          const Text('PO Value Trend'),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: poValueTrend.entries.map((e) => FlSpot(
                      double.parse(e.key.split('-')[1]),
                      e.value,
                    )).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final month = value.toInt().toString().padLeft(2, '0');
                        return Text(month);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Supplier PO Share (pie chart)
          const Text('Supplier PO Share'),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: supplierPie.map((e) => PieChartSectionData(
                  value: e.value.toDouble(),
                  title: e.key.toString().substring(0, 6),
                  color: Colors.primaries[supplierPie.indexOf(e) % Colors.primaries.length],
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Top suppliers (list)
          const Text('Top Suppliers:'),
          ...supplierPie.take(5).map((e) {
            final supplier = _suppliers.firstWhere(
              (s) => s['supplier_id'] == e.key || s['id'] == e.key,
              orElse: () => {'supplier_name': e.key, 'name': e.key},
            );
            return Text('${supplier['supplier_name'] ?? supplier['name']}: ${e.value} POs');
          }),
          const SizedBox(height: 24),
          // Export/Print analytics
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export Report'),
                onPressed: () {
                  // Export analytics as PDF
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('Print Report'),
                onPressed: () {
                  // Print analytics
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
