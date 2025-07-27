import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InventoryAnalyticsScreen extends StatelessWidget {
  const InventoryAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Analytics', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.deepPurple.shade700),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('Business Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _StockAgingChart(),
          _TurnoverRatioCard(),
          _ExpiryHeatmapCard(),
          _LowStockTable(),
          _ABCAnalysisCard(),
        ],
      ),
    );
  }
}

class _StockAgingChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pie_chart),
        title: const Text('Stock Aging Chart'),
        subtitle: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            final now = DateTime.now();
            final aging = {'<30d': 0, '30-90d': 0, '>90d': 0};
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final mfg = (data['manufacture_date'] as Timestamp?)?.toDate();
              if (mfg == null) continue;
              final days = now.difference(mfg).inDays;
              if (days < 30) aging['<30d'] = aging['<30d']! + 1;
              else if (days < 90) aging['30-90d'] = aging['30-90d']! + 1;
              else aging['>90d'] = aging['>90d']! + 1;
            }
            return Text(' <30d: \\${aging['<30d']} | 30-90d: \\${aging['30-90d']} | >90d: \\${aging['>90d']}');
          },
        ),
      ),
    );
  }
}

class _TurnoverRatioCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bar_chart),
        title: const Text('Turnover Ratio'),
        subtitle: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            double total = 0;
            double turnover = 0;
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              total += (data['quantity_available'] ?? 0) as num;
              turnover += (data['stock_turnover_ratio'] ?? 0) as num;
            }
            return Text('Total: \\${total.toStringAsFixed(2)} | Avg Turnover: \\${turnover.toStringAsFixed(2)}');
          },
        ),
      ),
    );
  }
}

class _ExpiryHeatmapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.thermostat),
        title: const Text('Expiry Heatmap'),
        subtitle: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            int expiringSoon = 0;
            final now = DateTime.now();
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final expiry = (data['expiry_date'] as Timestamp?)?.toDate();
              if (expiry != null && expiry.difference(now).inDays < 30) expiringSoon++;
            }
            return Text('Expiring in <30d: \\${expiringSoon}');
          },
        ),
      ),
    );
  }
}

class _LowStockTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning),
        title: const Text('Low Stock Table'),
        subtitle: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('inventory').where('quantity_available', isLessThan: 10).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            final items = snapshot.data!.docs;
            if (items.isEmpty) return const Text('No low stock items.');
            return Text(items.map((d) => d['product_id']).join(', '));
          },
        ),
      ),
    );
  }
}

class _ABCAnalysisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pie_chart_outline),
        title: const Text('ABC Analysis'),
        subtitle: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            int a = 0, b = 0, c = 0;
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final ratio = (data['stock_turnover_ratio'] ?? 0) as num;
              if (ratio > 10) a++;
              else if (ratio > 5) b++;
              else c++;
            }
            return Text('A: \\${a} | B: \\${b} | C: \\${c}');
          },
        ),
      ),
    );
  }
}
