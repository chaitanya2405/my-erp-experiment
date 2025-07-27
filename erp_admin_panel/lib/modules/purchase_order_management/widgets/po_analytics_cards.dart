import 'package:flutter/material.dart';

class PoAnalyticsCards extends StatelessWidget {
  final int totalPOs;
  final int pendingPOs;
  final int approvedPOs;
  final int rejectedPOs;
  final double totalValue;

  const PoAnalyticsCards({
    Key? key,
    required this.totalPOs,
    required this.pendingPOs,
    required this.approvedPOs,
    required this.rejectedPOs,
    required this.totalValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildCard('Total POs', totalPOs.toString(), Icons.list_alt, Colors.blue),
        _buildCard('Pending', pendingPOs.toString(), Icons.hourglass_empty, Colors.orange),
        _buildCard('Approved', approvedPOs.toString(), Icons.check_circle, Colors.green),
        _buildCard('Rejected', rejectedPOs.toString(), Icons.cancel, Colors.red),
        _buildCard('Total Value', '₹${totalValue.toStringAsFixed(2)}', Icons.attach_money, Colors.teal),
      ],
    );
  }

  Widget _buildCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
