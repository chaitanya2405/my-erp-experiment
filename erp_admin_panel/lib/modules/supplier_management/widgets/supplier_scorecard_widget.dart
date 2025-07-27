import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier.dart'; // Adjust the import based on your project structure

class SupplierScorecardWidget extends StatelessWidget {
  const SupplierScorecardWidget({Key? key}) : super(key: key);

  Color getKpiColor(double value, {required double good, required double warn}) {
    if (value >= good) return Colors.green;
    if (value >= warn) return Colors.orange;
    return Colors.red;
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

        // Aggregate KPIs
        double totalSpend = 0;
        int totalOrders = 0;
        double totalLeadTime = 0;
        int leadTimeCount = 0;
        int onTimeDeliveries = 0;
        int totalDeliveries = 0;
        double totalRating = 0;
        int ratingCount = 0;

        for (var doc in docs) {
          final supplier = Supplier.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          totalSpend += supplier.totalSpend;
          totalOrders += supplier.orderVolume is int ? supplier.orderVolume : (supplier.orderVolume as num).toInt();
          if (supplier.averageLeadTime != 0) {
            totalLeadTime += supplier.averageLeadTime;
            leadTimeCount++;
          }
          if (supplier.onTimeDeliveryRate != 0) {
            onTimeDeliveries += (((supplier.onTimeDeliveryRate) * (supplier.orderVolume is int ? supplier.orderVolume : (supplier.orderVolume as num).toInt())) / 100).round();
            totalDeliveries += supplier.orderVolume is int ? supplier.orderVolume : (supplier.orderVolume as num).toInt();
          }
          if (supplier.rating != 0) {
            totalRating += supplier.rating.toDouble();
            ratingCount++;
          }
        }

        final avgLeadTime = leadTimeCount > 0 ? totalLeadTime / leadTimeCount : 0;
        final onTimeRate = totalDeliveries > 0 ? (onTimeDeliveries / totalDeliveries) * 100 : 0;
        final avgRating = ratingCount > 0 ? totalRating / ratingCount : 0;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text('Supplier Scorecard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _kpiCard(
                    label: 'Total Spend',
                    value: '₹${totalSpend.toStringAsFixed(0)}',
                    color: Colors.blue,
                    icon: Icons.attach_money,
                  ),
                  _kpiCard(
                    label: 'Total Orders',
                    value: '$totalOrders',
                    color: Colors.indigo,
                    icon: Icons.shopping_cart,
                  ),
                  _kpiCard(
                    label: 'Avg. Lead Time',
                    value: '${avgLeadTime.toStringAsFixed(1)} days',
                    color: getKpiColor(avgLeadTime.toDouble(), good: 3, warn: 7),
                    icon: Icons.timer,
                  ),
                  _kpiCard(
                    label: 'On-Time Delivery',
                    value: '${onTimeRate.toStringAsFixed(1)}%',
                    color: getKpiColor(onTimeRate.toDouble(), good: 95, warn: 85),
                    icon: Icons.local_shipping,
                  ),
                  _kpiCard(
                    label: 'Avg. Rating',
                    value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '-',
                    color: getKpiColor(avgRating.toDouble(), good: 4.5, warn: 3.5),
                    icon: Icons.star,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Supplier List (Top 5 by Spend)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(() {
                final suppliers = docs
                    .map((doc) => Supplier.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
                    .where((s) => s.totalSpend != 0)
                    .toList();
                suppliers.sort((a, b) => b.totalSpend.compareTo(a.totalSpend));
                return suppliers.take(5).map((s) => Card(
                  child: ListTile(
                    title: Text(s.supplierName),
                    subtitle: Text('Spend: 9${s.totalSpend} | Orders: ${s.orderVolume} | Rating: ${s.rating}'),
                  ),
                ));
              })(),
              const SizedBox(height: 32),
              const Text('All Suppliers', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Supplier',
                  border: OutlineInputBorder(),
                ),
                items: docs.map<DropdownMenuItem<String>>((doc) {
                  final supplier = Supplier.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(supplier.supplierName),
                  );
                }).toList(),
                onChanged: (value) {
                  // Handle supplier selection
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpiCard({required String label, required String value, required Color color, required IconData icon}) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: SizedBox(
        width: 180,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}