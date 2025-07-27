import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/supplier.dart'; // Import the Supplier model

const List<String> availableTags = [
  'Preferred',
  'Backup',
  'Seasonal',
  'Local',
  'High Spend',
  'Reliable',
];

class SupplierSegmentationWidget extends StatefulWidget {
  const SupplierSegmentationWidget({Key? key}) : super(key: key);

  @override
  State<SupplierSegmentationWidget> createState() => _SupplierSegmentationWidgetState();
}

class _SupplierSegmentationWidgetState extends State<SupplierSegmentationWidget> {
  void _toggleTag(String supplierId, List<dynamic> currentTags, String tag) async {
    final tags = List<String>.from(currentTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    await FirebaseFirestore.instance
        .collection('suppliers')
        .doc(supplierId)
        .update({'tags': tags});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No suppliers found.'));
        }

        // --- Segmentation Data ---
        Map<String, double> spendByTag = {for (var tag in availableTags) tag: 0};
        Map<String, int> orderVolumeByTag = {for (var tag in availableTags) tag: 0};
        Map<String, double> avgRatingByTag = {for (var tag in availableTags) tag: 0};
        Map<String, int> countByTag = {for (var tag in availableTags) tag: 0};

        for (var doc in docs) {
          final supplier = Supplier.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          final tags = supplier.tags;
          final spend = supplier.totalSpend;
          final orders = supplier.orderVolume is int ? supplier.orderVolume : (supplier.orderVolume as num).toInt();
          final rating = supplier.rating.toDouble();

          for (var tag in tags) {
            if (availableTags.contains(tag)) {
              spendByTag[tag] = (spendByTag[tag] ?? 0) + spend;
              orderVolumeByTag[tag] = (orderVolumeByTag[tag] ?? 0) + orders;
              avgRatingByTag[tag] = (avgRatingByTag[tag] ?? 0) + rating;
              countByTag[tag] = (countByTag[tag] ?? 0) + 1;
            }
          }
        }

        // Calculate average rating per tag
        for (var tag in availableTags) {
          if (countByTag[tag]! > 0) {
            avgRatingByTag[tag] = avgRatingByTag[tag]! / countByTag[tag]!;
          }
        }

        // --- Pie Chart Data (Spend) ---
        final spendSections = <PieChartSectionData>[];
        final totalSpend = spendByTag.values.fold<double>(0, (a, b) => a + b);
        int colorIndex = 0;
        final colors = [
          Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal
        ];

        for (var tag in availableTags) {
          final value = spendByTag[tag]!;
          if (value > 0) {
            spendSections.add(
              PieChartSectionData(
                color: colors[colorIndex % colors.length],
                value: value,
                title: '${tag}\n${(value / (totalSpend == 0 ? 1 : totalSpend) * 100).toStringAsFixed(1)}%',
                radius: 60,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            );
          }
          colorIndex++;
        }

        // --- Bar Chart Data (Order Volume) ---
        final orderBarGroups = <BarChartGroupData>[];
        colorIndex = 0;
        for (var i = 0; i < availableTags.length; i++) {
          final tag = availableTags[i];
          orderBarGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: orderVolumeByTag[tag]!.toDouble(),
                  color: colors[i % colors.length],
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }

        // --- Bar Chart Data (Average Rating) ---
        final ratingBarGroups = <BarChartGroupData>[];
        colorIndex = 0;
        for (var i = 0; i < availableTags.length; i++) {
          final tag = availableTags[i];
          ratingBarGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: avgRatingByTag[tag]!,
                  color: colors[i % colors.length],
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }

        // --- UI ---
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Supplier Segmentation Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: spendSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Order Volume by Tag', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: orderBarGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < availableTags.length) {
                            return Text(availableTags[idx], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                        reservedSize: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Average Rating by Tag', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: ratingBarGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < availableTags.length) {
                            return Text(availableTags[idx], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                        reservedSize: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 32),
            const Text('Tag Suppliers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...docs.map((doc) {
              final supplier = Supplier.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
              final tags = supplier.tags;
              return ListTile(
                title: Text(supplier.supplierName),
                subtitle: Wrap(
                  spacing: 8,
                  children: availableTags.map((tag) {
                    final selected = tags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: selected,
                      onSelected: (_) {},
                    );
                  }).toList().cast<Widget>(),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}