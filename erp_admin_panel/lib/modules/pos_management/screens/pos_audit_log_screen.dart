import 'package:flutter/material.dart';

class PosAuditLogScreen extends StatefulWidget {
  const PosAuditLogScreen({Key? key}) : super(key: key);

  @override
  State<PosAuditLogScreen> createState() => _PosAuditLogScreenState();
}

class _PosAuditLogScreenState extends State<PosAuditLogScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Transactions', 'Refunds', 'User Actions', 'System Events'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Audit Log'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: _filters.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    // Export functionality
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                ),
              ],
            ),
          ),
          
          // Audit Log List
          Expanded(
            child: ListView.builder(
              itemCount: 20, // Mock data
              itemBuilder: (context, index) {
                return _buildAuditLogItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogItem(int index) {
    final List<Map<String, dynamic>> mockAuditData = [
      {
        'time': '10:30 AM',
        'event': 'Transaction Created',
        'user': 'John Doe',
        'details': 'Transaction #TXN001 created for ₹450',
        'type': 'transaction',
      },
      {
        'time': '10:25 AM',
        'event': 'User Login',
        'user': 'Jane Smith',
        'details': 'User logged into POS system',
        'type': 'user',
      },
      {
        'time': '10:20 AM',
        'event': 'Refund Processed',
        'user': 'John Doe',
        'details': 'Refund of ₹200 processed for TXN005',
        'type': 'refund',
      },
      {
        'time': '10:15 AM',
        'event': 'Inventory Updated',
        'user': 'System',
        'details': 'Product PROD001 inventory decreased by 2',
        'type': 'system',
      },
    ];

    final audit = mockAuditData[index % mockAuditData.length];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _getEventIcon(audit['type']),
        title: Text(audit['event']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(audit['details']),
            const SizedBox(height: 4),
            Text(
              'By: ${audit['user']} at ${audit['time']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showAuditDetails(audit);
          },
        ),
      ),
    );
  }

  Widget _getEventIcon(String type) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case 'transaction':
        iconData = Icons.receipt;
        color = Colors.green;
        break;
      case 'user':
        iconData = Icons.person;
        color = Colors.blue;
        break;
      case 'refund':
        iconData = Icons.undo;
        color = Colors.orange;
        break;
      case 'system':
        iconData = Icons.settings;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.info;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color),
    );
  }

  void _showAuditDetails(Map<String, dynamic> audit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(audit['event']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${audit['time']}'),
            const SizedBox(height: 8),
            Text('User: ${audit['user']}'),
            const SizedBox(height: 8),
            Text('Details: ${audit['details']}'),
            const SizedBox(height: 8),
            Text('Type: ${audit['type']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
