import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/supplier.dart';
import '../../../models/supplier_service.dart';

class SupplierAnalyticsScreen extends StatelessWidget {
  const SupplierAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Analytics'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: StreamBuilder<List<Supplier>>(
        stream: SupplierService().streamSuppliers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final suppliers = snapshot.data!;
          if (suppliers.isEmpty) {
            return const Center(child: Text('No supplier data available.'));
          }
          // Segmentation
          final typeCounts = <String, int>{};
          for (var s in suppliers) {
            typeCounts[s.supplierType] = (typeCounts[s.supplierType] ?? 0) + 1;
          }
          // Top spend
          final topSuppliers = [...suppliers]..sort((a, b) => b.totalOrderValue.compareTo(a.totalOrderValue));
          // Compliance
          final compliant = suppliers.where((s) => s.complianceDocuments.isNotEmpty && s.gstin.isNotEmpty && s.panNumber.isNotEmpty).length;
          final nonCompliant = suppliers.length - compliant;
          // On-time delivery
          final avgOnTime = suppliers.isNotEmpty ? suppliers.map((s) => s.onTimeDeliveryRate).reduce((a, b) => a + b) / suppliers.length : 0;
          // Lead time
          final avgLeadTime = suppliers.isNotEmpty ? suppliers.map((s) => s.averageLeadTimeDays).reduce((a, b) => a + b) / suppliers.length : 0;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Supplier Segmentation'),
                  subtitle: SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sections: typeCounts.entries.map((e) => PieChartSectionData(
                          value: e.value.toDouble(),
                          title: e.key,
                        )).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Compliance Status'),
                  subtitle: Row(
                    children: [
                      Text('Compliant: $compliant'),
                      const SizedBox(width: 16),
                      Text('Non-Compliant: $nonCompliant'),
                    ],
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Top 5 Suppliers by Spend'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topSuppliers.take(5).map((s) => Text('${s.supplierName}: ${s.totalOrderValue} ${s.defaultCurrency}')).toList(),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Average On-Time Delivery Rate'),
                  subtitle: Text('${avgOnTime.toStringAsFixed(1)}%'),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Average Lead Time'),
                  subtitle: Text('${avgLeadTime.toStringAsFixed(1)} days'),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Preferred vs. Others'),
                  subtitle: Row(
                    children: [
                      Text('Preferred: ${suppliers.where((s) => s.isPreferredSupplier).length}'),
                      const SizedBox(width: 16),
                      Text('Others: ${suppliers.where((s) => !s.isPreferredSupplier).length}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
