import 'package:flutter/material.dart';

class PoSupplierIntegration extends StatefulWidget {
  final String poId;
  final String currentStatus;
  final Function(String status, String comment) onSupplierUpdate;

  const PoSupplierIntegration({
    Key? key,
    required this.poId,
    required this.currentStatus,
    required this.onSupplierUpdate,
  }) : super(key: key);

  @override
  State<PoSupplierIntegration> createState() => _PoSupplierIntegrationState();
}

class _PoSupplierIntegrationState extends State<PoSupplierIntegration> {
  final _commentController = TextEditingController();
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'Acknowledged',
    'Processing',
    'Shipped',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Supplier Portal Integration', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('PO ID: ${widget.poId}'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statusOptions.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              )).toList(),
              onChanged: (val) => setState(() => _selectedStatus = val),
              decoration: const InputDecoration(labelText: 'Update Status'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Supplier Comment (optional)',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_selectedStatus != null) {
                  widget.onSupplierUpdate(_selectedStatus!, _commentController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Supplier update submitted!')),
                  );
                }
              },
              icon: const Icon(Icons.sync),
              label: const Text('Submit Update'),
            ),
          ],
        ),
      ),
    );
  }
}
