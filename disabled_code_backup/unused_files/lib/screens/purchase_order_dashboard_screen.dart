import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/po_analytics_cards.dart';
import '../widgets/po_advanced_analytics.dart';

class PurchaseOrderDashboardScreen extends StatelessWidget {
  const PurchaseOrderDashboardScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchAnalytics() async {
    final snapshot = await FirebaseFirestore.instance.collection('purchase_orders').get();
    final docs = snapshot.docs;

    int totalPOs = docs.length;
    int pendingPOs = docs.where((d) => d['status'] == 'Pending').length;
    int approvedPOs = docs.where((d) => d['status'] == 'Approved').length;
    int rejectedPOs = docs.where((d) => d['status'] == 'Rejected').length;
    double totalValue = docs.fold(0.0, (sum, d) => sum + (d['totalValue'] ?? 0).toDouble());

    return {
      'totalPOs': totalPOs,
      'pendingPOs': pendingPOs,
      'approvedPOs': approvedPOs,
      'rejectedPOs': rejectedPOs,
      'totalValue': totalValue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Orders Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Purchase Order Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchAnalytics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;
                return PoAnalyticsCards(
                  totalPOs: data['totalPOs'],
                  pendingPOs: data['pendingPOs'],
                  approvedPOs: data['approvedPOs'],
                  rejectedPOs: data['rejectedPOs'],
                  totalValue: data['totalValue'],
                );
              },
            ),
            const SizedBox(height: 32),
            Expanded(
              child: PoAdvancedAnalytics(),
            ),
          ],
        ),
      ),
    );
  }
}
