import 'package:flutter/material.dart';

class POStatusChip extends StatelessWidget {
  final String status;
  const POStatusChip({Key? key, required this.status}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Draft':
        return Colors.grey;
      case 'Sent':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Delivered':
        return Colors.teal;
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status),
      backgroundColor: _getStatusColor(status).withOpacity(0.15),
      labelStyle: TextStyle(
        color: _getStatusColor(status),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

